// ***************************************************************
// Part of the AVS Hull program
// Released under the MIT license.
// See https://github.com/philip-w-howard/AVSHullWeb for details
// ***************************************************************

import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'point_3d.dart';
import 'hull_math.dart';

class Spline {
  List<Point3D> _points = [];

  // **********************************************************
  Spline(List<Point3D> points, int totalPoints) {
    _points = [];
    var mMatrix = List<List>.generate(
        points.length, (i) => List<double>.filled(points.length, 0.0));
    var bMatrix =
        List<List>.generate(points.length, (i) => List<double>.filled(3, 0.0));
    var chordLength = List<double>.filled(points.length - 1, 0.0);

    _computeChords(points, chordLength);
    _createMatrices(points, mMatrix, bMatrix, chordLength);
    _gaussianElimination(points, mMatrix, bMatrix);
    _generatePoints(points, mMatrix, bMatrix, chordLength, totalPoints);
  }

  // **********************************************************
  Spline.copy(Spline source) {
    _points = List<Point3D>.from(source._points);
  }

  // **********************************************************
  void _computeChords(List<Point3D> points, List<double> chordLength) {
    int numPoints = points.length;
    // // Use normalized chords: 0<t<1
    // for (int ii = 0; ii < numPoints - 1; ii++) {
    //   chordLength[ii] = 1;
    // }

    // Compute chord length for scaling
    for (int ii = 0; ii < numPoints - 1; ii++) {
      double x = points[ii].x - points[ii + 1].x;
      double y = points[ii].y - points[ii + 1].y;
      double z = points[ii].z - points[ii + 1].z;

      chordLength[ii] = math.sqrt(x * x + y * y + z * z);
    }
  }

  // **********************************************************
  double _getCoord(Point3D point, int axis) {
    if (axis == 0) {
      return point.x;
    } else if (axis == 1) {
      return point.y;
    } else if (axis == 2) {
      return point.z;
    } else {
      return double.nan;
    }
  }

  // **********************************************************
  void _createMatrices(List<Point3D> points, List<List<dynamic>> mMatrix,
      List<List<dynamic>> bMatrix, List<double> chordLength) {
    int numPoints = points.length;
    mMatrix[0][0] = 1;
    mMatrix[0][1] = .5;

    for (int ii = 1; ii < numPoints - 1; ii++) {
      mMatrix[ii][ii - 1] = chordLength[ii];
      mMatrix[ii][ii] = 2 * (chordLength[ii - 1] + chordLength[ii]);
      mMatrix[ii][ii + 1] = chordLength[ii - 1];
    }

    mMatrix[numPoints - 1][numPoints - 2] = 2;
    mMatrix[numPoints - 1][numPoints - 1] = 4;

    for (int axis = 0; axis < 3; axis++) {
      bMatrix[0][axis] = 3.0 /
          2.0 /
          chordLength[0] *
          (_getCoord(points[1], axis) - _getCoord(points[0], axis));
      bMatrix[numPoints - 1][axis] = 6.0 /
          chordLength[numPoints - 2] *
          (_getCoord(points[numPoints - 1], axis) -
              _getCoord(points[numPoints - 2], axis));

      for (int point = 1; point < numPoints - 1; point++) {
        double factor = 3 / chordLength[point - 1] / chordLength[point];
        double diff1 =
            _getCoord(points[point + 1], axis) - _getCoord(points[point], axis);
        double diff2 =
            _getCoord(points[point], axis) - _getCoord(points[point - 1], axis);
        double scale1 = chordLength[point - 1] * chordLength[point - 1];
        double scale2 = chordLength[point] * chordLength[point];
        bMatrix[point][axis] = factor * (scale1 * diff1 + scale2 * diff2);
      }
    }
  }

  // **********************************************************
  void _gaussianElimination(List<Point3D> points, List<List<dynamic>> mMatrix,
      List<List<dynamic>> bMatrix) {
    int numPoints = points.length;
    double scale;
    for (int row = 0; row < numPoints - 1; row++) {
      // Normalize current row
      scale = mMatrix[row][row];
      for (int col = row; col < numPoints; col++) {
        mMatrix[row][col] /= scale;
      }
      for (int axis = 0; axis < 3; axis++) {
        bMatrix[row][axis] /= scale;
      }

      // Zero left of next row
      scale = mMatrix[row + 1][row];
      for (int col = row; col < numPoints; col++) {
        mMatrix[row + 1][col] -= scale * mMatrix[row][col];
      }
      for (int axis = 0; axis < 3; axis++) {
        bMatrix[row + 1][axis] -= scale * bMatrix[row][axis];
      }
    }

    // Normalize the last row
    scale = mMatrix[numPoints - 1][numPoints - 1];
    for (int col = numPoints - 1; col < numPoints; col++) {
      mMatrix[numPoints - 1][col] /= scale;
    }
    for (int axis = 0; axis < 3; axis++) {
      bMatrix[numPoints - 1][axis] /= scale;
    }

    //****************************************
    // We now have a Reduced Row Echelon Form matrix
    // Solve for the unknowns
    // NOTE: this is optimized because we know we started with a tri-diagonal matrix
    for (int row = numPoints - 1; row > 0; row--) {
      scale = mMatrix[row - 1][row];
      mMatrix[row - 1][row] = 0;
      for (int axis = 0; axis < 3; axis++) {
        bMatrix[row - 1][axis] -= scale * bMatrix[row][axis];
      }
    }
  }

  // **********************************************************
  void _generatePoints(List<Point3D> points, List<List<dynamic>> mMatrix,
      List<List<dynamic>> bMatrix, List<double> chordLength, int totalPoints) {
    _points = [];

    int numPoints = points.length;

    // B[1-4, segment, axis]
    //double[,,] B = new double[4, numPoints - 1, 3];
    var B = List<List>.generate(
        4,
        (i) => List<List>.generate(numPoints,
            (j) => List<double>.generate(3, (k) => 0.0, growable: false),
            growable: false),
        growable: false);

    // Compute the coefficients
    for (int seg = 0; seg < numPoints - 1; seg++) {
      for (int axis = 0; axis < 3; axis++) {
        double tmax = chordLength[seg];
        B[0][seg][axis] = _getCoord(points[seg], axis);
        B[1][seg][axis] = bMatrix[seg][axis];
        B[2][seg][axis] = 3 /
                (tmax * tmax) *
                (_getCoord(points[seg + 1], axis) -
                    _getCoord(points[seg], axis)) -
            2 / tmax * bMatrix[seg][axis] -
            1.0 / tmax * bMatrix[seg + 1][axis];
        B[3][seg][axis] = 2 /
                (tmax * tmax * tmax) *
                (_getCoord(points[seg], axis) -
                    _getCoord(points[seg + 1], axis)) +
            1.0 / (tmax * tmax) * bMatrix[seg][axis] +
            1.0 / (tmax * tmax) * bMatrix[seg + 1][axis];
      }
    }

    int pointsPerSegment = (totalPoints - 1) ~/ (numPoints - 1);

    for (int seg = 0; seg < numPoints - 1; seg++) {
      double tmax = chordLength[seg];

      for (int point = 0; point < pointsPerSegment; point++) {
        double t = point * tmax / pointsPerSegment;

        Point3D loc = Point3D(0, 0, 0);

        loc.x = B[0][seg][0] +
            B[1][seg][0] * t +
            B[2][seg][0] * t * t +
            B[3][seg][0] * t * t * t;

        loc.y = B[0][seg][1] +
            B[1][seg][1] * t +
            B[2][seg][1] * t * t +
            B[3][seg][1] * t * t * t;

        loc.z = B[0][seg][2] +
            B[1][seg][2] * t +
            B[2][seg][2] * t * t +
            B[3][seg][2] * t * t * t;

        _points.add(loc);
      }
    }

    // Set the end point
    _points.add(points[numPoints - 1]);
  }

  void rotate(List<List<double>> rotater) {
    _points = rotatePoints(_points, rotater);
  }

  void shift(Point3D shift) {
    for (Point3D point in _points) {
      point.x += shift.x;
      point.y += shift.y;
      point.z += shift.z;
    }
  }

  List<Offset> getOffsets() {
    List<Offset> offsets = [];

    for (Point3D point in _points) {
      offsets.add(Offset(point.x, point.y));
    }

    return offsets;
  }
}
