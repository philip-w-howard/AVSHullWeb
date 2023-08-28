// ***************************************************************
// Part of the AVS Hull program
// Released under the MIT license.
// See https://github.com/philip-w-howard/AVSHullWeb for details
// ***************************************************************

import 'dart:math' as math;
import 'point_3d.dart';

// ********************************************************************
List<List<double>> matrixMultiply(List<List<double>> a, List<List<double>> b) {
  int rows1 = a.length;
  int cols1 = a[0].length;
  int cols2 = b[0].length;

  // Create a new matrix to store the result
  List<List<double>> result =
      List.generate(rows1, (_) => List<double>.filled(cols2, 0.0));

  for (int i = 0; i < rows1; i++) {
    for (int j = 0; j < cols2; j++) {
      for (int k = 0; k < cols1; k++) {
        result[i][j] += a[i][k] * b[k][j];
      }
    }
  }

  return result;
}

// ********************************************************************
List<List<double>> makeRotator(double x, double y, double z) {
  double angle = 0.0;
  List<List<double>> result =
      List.generate(3, (_) => List<double>.filled(3, 0.0));
  List<List<double>> rotate_1 =
      List.generate(3, (_) => List<double>.filled(3, 0.0));

  // Order is: Z, X, Y

  // Z
  angle = z * math.pi / 180.0;
  result[2][2] = 1.0;
  result[0][0] = math.cos(angle);
  result[1][1] = math.cos(angle);
  result[0][1] = math.sin(angle);
  result[1][0] = -math.sin(angle);

  // X
  rotate_1 = List.generate(3, (_) => List<double>.filled(3, 0.0));
  angle = x * math.pi / 180.0;
  rotate_1[0][0] = 1.0;
  rotate_1[1][1] = math.cos(angle);
  rotate_1[2][2] = math.cos(angle);
  rotate_1[1][2] = math.sin(angle);
  rotate_1[2][1] = -math.sin(angle);

  result = matrixMultiply(result, rotate_1);

  // Y
  rotate_1 = List.generate(3, (_) => List<double>.filled(3, 0.0));
  angle = y * math.pi / 180.0;
  rotate_1[1][1] = 1.0;
  rotate_1[0][0] = math.cos(angle);
  rotate_1[2][2] = math.cos(angle);
  rotate_1[2][0] = math.sin(angle);
  rotate_1[0][2] = -math.sin(angle);

  result = matrixMultiply(result, rotate_1);

  return result;
}

// ********************************************************************
Point3D rotatePoint(Point3D point, List<List<double>> rotate) {
  List<List<double>> matPoint = [
    [point.x, point.y, point.z]
  ];
  List<List<double>> newPoint = matrixMultiply(matPoint, rotate);

  Point3D result = Point3D(newPoint[0][0], newPoint[0][1], newPoint[0][2]);

  return result;
}

// ********************************************************************
List<Point3D> rotatePoints(List<Point3D> points, List<List<double>> rotate) {
  List<Point3D> result = [];

  for (int ii = 0; ii < points.length; ii++) {
    result.add(rotatePoint(points[ii], rotate));
  }

  return result;
}

// ******************************************************************
double distanceToLine(
  double pointX,
  double pointY,
  double lineX1,
  double lineY1,
  double lineX2,
  double lineY2,
) {
  double lineLength =
      math.sqrt(math.pow(lineX2 - lineX1, 2) + math.pow(lineY2 - lineY1, 2));
  if (lineLength == 0) {
    return math
        .sqrt(math.pow(pointX - lineX1, 2) + math.pow(pointY - lineY1, 2));
  }

  double t = math.max(
      0,
      math.min(
          1,
          ((pointX - lineX1) * (lineX2 - lineX1) +
                  (pointY - lineY1) * (lineY2 - lineY1)) /
              math.pow(lineLength, 2)));

  double projectedX = lineX1 + t * (lineX2 - lineX1);
  double projectedY = lineY1 + t * (lineY2 - lineY1);

  return math.sqrt(
      math.pow(pointX - projectedX, 2) + math.pow(pointY - projectedY, 2));
}

// **************************************************************************
// Determine if the point (p3_x,p3_y) is near the line defined by (p1_x, p1_y) and (p2_x, p2_y)
bool isNearPoint(double p1x, double p1y, double p2x, double p2y, double range) {
  double deltaX = p1x - p2x;
  double deltaY = p1y - p2y;
  double distance = math.sqrt(deltaX * deltaX + deltaY * deltaY);

  if (distance <= range) return true;

  return false;
}

// **************************************************************************
// Determine if the point (p3_x,p3_y) is near the line defined by (p1_x, p1_y) and (p2_x, p2_y)
double distanceToPoint(double p1x, double p1y, double p2x, double p2y) {
  double deltaX = p1x - p2x;
  double deltaY = p1y - p2y;
  double distance = math.sqrt(deltaX * deltaX + deltaY * deltaY);

  return distance;
}

// **************************************************************************
// Determine if the point (p3_x,p3_y) is near the line defined by (p1_x, p1_y) and (p2_x, p2_y)
bool isNearLine(double line1x, double line1y, double line2x, double line2y,
    double pointX, double pointY, double range) {
  if (line1x == line2x) // vertical line
  {
    // is point along segment?
    if ((line1y <= pointY && line2y >= pointY) ||
        (line1y >= pointY && line2y <= pointY)) {
      if ((line1x - pointX).abs() <= range) return true;
    }

    return false;
  } else if (line1y == line2y) // horizontal line
  {
    // is point along segment?
    if ((line1x <= pointX && line2x >= pointX) ||
        (line1x >= pointX && line2x <= pointX)) {
      if ((line1y - pointY).abs() <= range) return true;
    }

    return false;
  } else {
    // sloped line
    double m1, m2;
    double b1, b2;
    double x, y;

    // compute slope between first two points:
    m1 = (line2y - line1y) / (line2x - line1x);

    // y intercept for first line
    b1 = -m1 * line1x + line1y;

    // compute slope of second (perpendicular) line
    m2 = -1 / m1;

    // y intercept for second (perpendicular) line
    b2 = -m2 * pointX + pointY;

    // Itersection of the two lines
    x = (b2 - b1) / (m1 - m2);
    y = m1 * x + b1;

    // is the intersection NOT within the line segment?
    if ((x <= line1x && x <= line2x) || (x >= line1x && x >= line2x)) {
      return false;
    }

    if ((y <= line1y && y <= line2y) || (y >= line1y && y >= line2y)) {
      return false;
    }

    // Is the intersection within delta of the point?
    double distance =
        math.sqrt((x - pointX) * (x - pointX) + (y - pointY) * (y - pointY));
    if (distance <= range) return true;

    return false;
  }
}
