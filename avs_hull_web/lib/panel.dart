import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'point_3d.dart';
import 'hull_math.dart';
import 'spline.dart';
import 'bulkhead.dart';

class Panel {
  static const double _minEdgeLength = 0.25;

  List<Offset> mPoints = [];
  Offset _origin = Offset.zero;
  String name = 'unnamed panel';

  Panel() {
    mPoints.clear();
  }

  Panel.copy(Panel source) {
    _origin = Offset(source._origin.dx, source._origin.dy);
    mPoints = List.from(source.mPoints);
    name = source.name;
  }

  Panel.fromBulkhead(Bulkhead bulk) {
    double scaleFactor = 1;

    if (bulk.mBulkheadType == BulkheadType.transom) {
      scaleFactor = math.sin(bulk.mTransomAngle);
    }

    mPoints.clear();

    for (Point3D point in bulk.mPoints) {
      mPoints.add(Offset(point.x, point.y / scaleFactor));
    }

    mPoints.add(Offset(bulk.mPoints[0].x, bulk.mPoints[0].y / scaleFactor));
    _center(Offset.zero);
  }

  Panel.fromChines(Spline chine1, Spline chine2) {
    mPoints.clear();
    _origin = Offset.zero;
    _panelize(chine1.getPoints(), chine2.getPoints());
    _horizontalize();
    _center(Offset.zero);
  }

  void _center(Offset origin) {
    _origin = origin;

    Offset center = computeMidpoint(mPoints);
    if (center.dx != 0 || center.dy != 0) {
      mPoints = translateShape(mPoints, -center.dx, -center.dy);
    }

    _origin = Offset(_origin.dx + center.dx, _origin.dy + center.dy);
  }

  void _horizontalize() {
    double x = mPoints[mPoints.length ~/ 2].dx - mPoints[0].dx;
    double y = mPoints[mPoints.length ~/ 2].dy - mPoints[0].dy;

    double angle;

    angle = math.atan2(y, x);
    rotate(angle);
  }

  // *************************************************************
  void rotate(double angle) {
    mPoints = rotate2D(mPoints, -angle);
  }

  // *************************************************************
  void _panelize(List<Point3D> chine1, List<Point3D> chine2) {
    double r1, r2;
    List<Offset> edge2 = [];

    mPoints.clear();

    bool pointyBow = (chine1[0] - chine2[0]).length() < _minEdgeLength;
    bool pointyStern =
        (chine1[chine1.length - 1] - chine2[chine2.length - 1]).length() <
            _minEdgeLength;

    if (pointyBow) {
      mPoints.add(const Offset(0, 0));
      edge2.add(const Offset(0, 0));

      r1 = (chine1[0] - chine1[1]).length();
      mPoints
          .add(Offset(r1 * math.cos(math.pi / 4), r1 * math.sin(math.pi / 4)));
    } else {
      // Start at origin
      mPoints.add(const Offset(0, 0));
      edge2.add(const Offset(0, 0));

      // Make the edge the first segment in edge2
      r1 = (chine1[0] - chine2[0]).length();
      edge2.add(Offset(0, -r1));

      // Compute next point, and favor positive X direction
      // advance edge1 by one point
      r1 = (chine1[0] - chine1[1]).length();
      r2 = (chine2[0] - chine1[1]).length();

      Offset intersectionA1 = Offset.zero;
      Offset intersectionA2 = Offset.zero;
      (intersectionA1, intersectionA2) = intersection(
          mPoints[mPoints.length - 1], r1, edge2[edge2.length - 1], r2);

      if (intersectionA1.dx >= intersectionA2.dy) {
        mPoints.add(intersectionA1);
      } else {
        mPoints.add(intersectionA2);
      }
    }

    // add next point to edge2
    r1 = (chine2[0] - chine2[1]).length();
    r2 = (chine1[1] - chine2[1]).length();
    Offset intersectionB1 = Offset.zero;
    Offset intersectionB2 = Offset.zero;
    (intersectionB1, intersectionB2) = intersection(
        edge2[edge2.length - 1], r1, mPoints[mPoints.length - 1], r2);

    if (intersectionB1.dx >= intersectionB2.dx) {
      edge2.add(intersectionB1);
    } else {
      edge2.add(intersectionB2);
    }

    // Complete the rest of the points
    int lastPoint;
    if (pointyStern) {
      lastPoint = chine1.length - 2;
    } else {
      lastPoint = chine1.length - 1;
    }

    for (int ii = 1; ii < lastPoint; ii++) {
      r1 = (chine1[ii] - chine1[ii + 1]).length();
      r2 = (chine2[ii] - chine1[ii + 1]).length();

      Offset intersectionA1;
      Offset intersectionA2;
      (intersectionA1, intersectionA2) = intersection(
          mPoints[mPoints.length - 1], r1, edge2[edge2.length - 1], r2);

      Offset v_1 = mPoints[mPoints.length - 1] - mPoints[mPoints.length - 2];
      Offset v_1a = intersectionA1 - mPoints[mPoints.length - 1];
      Offset v_1b = intersectionA2 - mPoints[mPoints.length - 1];

      double a1 = angleBetween(v_1, v_1a).abs();
      double a2 = angleBetween(v_1, v_1b).abs();

      if (a1 < a2) {
        mPoints.add(intersectionA1);
      } else {
        mPoints.add(intersectionA2);
      }

      // advance edge2 by one point
      r1 = (chine2[ii] - chine2[ii + 1]).length();
      r2 = (chine1[ii + 1] - chine2[ii + 1]).length();

      (intersectionB1, intersectionB2) = intersection(
          edge2[edge2.length - 1], r1, mPoints[mPoints.length - 1], r2);

      Offset v_2 = edge2[edge2.length - 1] - edge2[edge2.length - 2];
      Offset v_2a = intersectionB1 - edge2[edge2.length - 1];
      Offset v_2b = intersectionB2 - edge2[edge2.length - 1];

      double b1 = angleBetween(v_2, v_2a).abs();
      double b2 = angleBetween(v_2, v_2b).abs();

      if (b1 < b2) {
        edge2.add(intersectionB1);
      } else {
        edge2.add(intersectionB2);
      }
    }

    if (pointyStern) {
      r1 = (chine1[chine1.length - 2] - chine1[chine1.length - 1]).length();
      r2 = (chine2[chine2.length - 2] - chine2[chine2.length - 1]).length();

      Offset intersectionA1;
      Offset intersectionA2;

      (intersectionA1, intersectionA2) = intersection(
          mPoints[mPoints.length - 1], r1, edge2[edge2.length - 1], r2);

      Offset v_1 = mPoints[mPoints.length - 1] - mPoints[mPoints.length - 2];
      Offset v_1a = intersectionA1 - mPoints[mPoints.length - 1];
      Offset v_1b = intersectionA2 - mPoints[mPoints.length - 1];

      double a1 = angleBetween(v_1, v_1a).abs();
      double a2 = angleBetween(v_1, v_1b).abs();

      if (a1 < a2) {
        mPoints.add(intersectionA1);
      } else {
        mPoints.add(intersectionA2);
      }

      // Don't need to add point to edge2 because it is the same (pointy) point and it would be a duplicate
    }

    // Copy edge2 input m_panelPoints
    for (int ii = edge2.length - 1; ii >= 0; ii--) {
      mPoints.add(edge2[ii]);
    }
  }

  List<Offset> getOffsets() {
    List<Offset> offsets = [];
    for (Offset point in mPoints) {
      offsets.add(Offset(point.dx + _origin.dx, point.dy + _origin.dy));
    }

    return offsets;
  }

  void moveBy(double x, double y) {
    _origin = Offset(_origin.dx + x, _origin.dy + y);
  }

  void flipVertically() {
    for (int ii = 0; ii < mPoints.length; ii++) {
      mPoints[ii] = Offset(mPoints[ii].dx, -mPoints[ii].dy);
    }
  }

  void flipHorizontally() {
    for (int ii = 0; ii < mPoints.length; ii++) {
      mPoints[ii] = Offset(-mPoints[ii].dx, mPoints[ii].dy);
    }
  }
}
