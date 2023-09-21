// ***************************************************************
// Part of the AVS Hull program
// Released under the MIT license.
// See https://github.com/philip-w-howard/AVSHullWeb for details
// ***************************************************************

import 'package:flutter/material.dart';
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
List<List<double>> makeRotator2D(double angle) {
  List<List<double>> rotate =
      List.generate(2, (_) => List<double>.filled(2, 0.0));

  rotate[0][0] = math.cos(angle);
  rotate[1][1] = math.cos(angle);
  rotate[0][1] = math.sin(angle);
  rotate[1][0] = -math.sin(angle);

  return rotate;
}

// ********************************************************************
List<Offset> rotate2D(List<Offset> points, double angle) {
  List<List<double>> rotate =
      List.generate(2, (_) => List<double>.filled(2, 0.0));
  List<Offset> result = [];
  double x, y;

  rotate[0][0] = math.cos(angle);
  rotate[1][1] = math.cos(angle);
  rotate[0][1] = math.sin(angle);
  rotate[1][0] = -math.sin(angle);

  for (Offset point in points) {
    x = point.dx * rotate[0][0] + point.dy * rotate[0][1];
    y = point.dx * rotate[1][0] + point.dy * rotate[1][1];
    result.add(Offset(x, y));
  }

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

// // ******************************************************************
// double distanceToLine(
//   double pointX,
//   double pointY,
//   double lineX1,
//   double lineY1,
//   double lineX2,
//   double lineY2,
// ) {
//   double lineLength =
//       math.sqrt(math.pow(lineX2 - lineX1, 2) + math.pow(lineY2 - lineY1, 2));
//   if (lineLength == 0) {
//     return math
//         .sqrt(math.pow(pointX - lineX1, 2) + math.pow(pointY - lineY1, 2));
//   }

//   double t = math.max(
//       0,
//       math.min(
//           1,
//           ((pointX - lineX1) * (lineX2 - lineX1) +
//                   (pointY - lineY1) * (lineY2 - lineY1)) /
//               math.pow(lineLength, 2)));

//   double projectedX = lineX1 + t * (lineX2 - lineX1);
//   double projectedY = lineY1 + t * (lineY2 - lineY1);

//   return math.sqrt(
//       math.pow(pointX - projectedX, 2) + math.pow(pointY - projectedY, 2));
// }

// **************************************************************************
// Determine if the point (p3_x,p3_y) is near the line defined by (p1_x, p1_y) and (p2_x, p2_y)
// bool isNearPoint(double p1x, double p1y, double p2x, double p2y, double range) {
//   double deltaX = p1x - p2x;
//   double deltaY = p1y - p2y;
//   double distance = math.sqrt(deltaX * deltaX + deltaY * deltaY);

//   if (distance <= range) return true;

//   return false;
// }

// // **************************************************************************
// // Determine if the point (p3_x,p3_y) is near the line defined by (p1_x, p1_y) and (p2_x, p2_y)
double distanceToPoint(double p1x, double p1y, double p2x, double p2y) {
  double deltaX = p1x - p2x;
  double deltaY = p1y - p2y;
  double distance = math.sqrt(deltaX * deltaX + deltaY * deltaY);

  return distance;
}

// // **************************************************************************
// // Determine if the point (p3_x,p3_y) is near the line defined by (p1_x, p1_y) and (p2_x, p2_y)
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

// *****************************************************************************
(Offset, Offset) intersection(Offset p1, double r1, Offset p2, double r2) {
  Offset intersection1 = Offset.infinite;
  Offset intersection2 = Offset.infinite;

  if (p1.dx != p2.dx) {
    //double A = (r1 * r1 - r2 * r2 - p1.X * p1.X + p2.X * p2.X - p1.Y * p1.Y + p2.Y * p2.Y) / (2 * p2.X - 2 * p1.X);
    double A = (r1 * r1 -
            r2 * r2 -
            p1.dx * p1.dx +
            p2.dx * p2.dx -
            p1.dy * p1.dy +
            p2.dy * p2.dy) /
        (2 * p2.dx - 2 * p1.dx);
    double B = (p1.dy - p2.dy) / (p2.dx - p1.dx);
    double a = B * B + 1;
    double b = 2 * A * B - 2 * p1.dx * B - 2 * p1.dy;
    double c = A * A - 2 * p1.dx * A + p1.dx * p1.dx + p1.dy * p1.dy - r1 * r1;

    double y1, y2;

    (y1, y2) = quadradicSolution(a, b, c);

    if (y1.isNaN || y2.isNaN) {
      return (
        const Offset(double.nan, double.nan),
        const Offset(double.nan, double.nan)
      );
    }

    intersection1 = Offset(A + B * y1, y1);
    intersection2 = Offset(A + B * y2, y2);
  } else {
    double A = (r1 * r1 -
            r2 * r2 -
            p1.dy * p1.dy +
            p2.dy * p2.dy -
            p1.dx * p1.dx +
            p2.dx * p2.dx) /
        (2 * p2.dy - 2 * p1.dy);
    double B = (p1.dx - p2.dx) / (p2.dy - p1.dy);
    double a = B * B + 1;
    double b = 2 * A * B - 2 * p1.dy * B - 2 * p1.dx;
    double c = A * A - 2 * p1.dy * A + p1.dy * p1.dy + p1.dx * p1.dx - r1 * r1;
    double x1, x2;

    (x1, x2) = quadradicSolution(a, b, c);
    if (x1.isNaN || x2.isNaN) {
      return (
        const Offset(double.nan, double.nan),
        const Offset(double.nan, double.nan)
      );
    }

    intersection1 = Offset(x1, A + B * x1);
    intersection2 = Offset(x2, A + b * x2);
  }

  return (intersection1, intersection2);
}

// ********************************************************************
// (Offset, Offset) intersection(Offset p1, double r1, Offset p2, double r2) {
//   double x1 = p1.dx;
//   double y1 = p1.dy;
//   double x2 = p2.dx;
//   double y2 = p2.dx;

//   double distance = math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 * y2));

//   // circles too far apart: no intersection
//   if (distance > r1 + r2) {
//     return (
//       const Offset(double.nan, double.nan),
//       const Offset(double.nan, double.nan)
//     );
//   }

//   // one circle encloses the other: No intersection
//   if (distance < (r1 - r2).abs()) {
//     return (
//       const Offset(double.nan, double.nan),
//       const Offset(double.nan, double.nan)
//     );
//   }

//   double len = (r1 * r1 - r2 * r2 + distance * distance) / (2 * distance);
//   double height = math.sqrt(r1 * r1 + len * len);

//   double xa = len / distance * (x2 - x1);
//   double xb = height / distance * (y2 - y1) + x1;
//   double ya = len / distance * (y2 - y1);
//   double yb = height / distance * (x2 - x1) + y1;
//   return (Offset(xa + xb, ya - yb), Offset(xa - xb, ya + yb));
// }

// ********************************************************************
// (Offset, Offset) intersection(Offset p1, double r1, Offset p2, double r2) {
//   Offset intersection1 = Offset.zero;
//   Offset intersection2 = Offset.zero;

//   if (p1.dx != p2.dx) {
//     double A = (r1 * r1 -
//             r2 * r2 -
//             p1.dx * p1.dx +
//             p2.dx * p2.dx -
//             p1.dy * p1.dy +
//             p2.dy * p2.dy) /
//         (2 * p2.dx - 2 * p1.dx);
//     double B = (p1.dy - p2.dy) / (p2.dx - p1.dx);
//     double a = B * B + 1;
//     double b = 2 * A * B - 2 * p1.dx * B - 2 * p1.dy;
//     double c = A * A - 2 * p1.dx * A + p1.dx * p1.dx + p1.dy * p1.dy - r1 * r1;

//     double y1 = 0;
//     double y2 = 0;
//     (y1, y2) = quadradicSolution(a, b, c);
//     if (y1.isNaN || y2.isNaN) {
//       return (Offset.infinite, Offset.infinite); // <<<<<<<<<<<<<<<<<<<<<<
//     }

//     intersection1 = Offset(A + B * y1, y1);
//     intersection2 = Offset(A + B * y2, y2);
//   } else {
//     double A = (r1 * r1 -
//             r2 * r2 -
//             p1.dy * p1.dy +
//             p2.dy * p2.dy -
//             p1.dx * p1.dx +
//             p2.dx * p2.dx) /
//         (2 * p2.dy - 2 * p1.dy);
//     double B = (p1.dx - p2.dx) / (p2.dy - p1.dy);
//     double a = B * B + 1;
//     double b = 2 * A * B - 2 * p1.dy * B - 2 * p1.dx;
//     double c = A * A - 2 * p1.dy * A + p1.dy * p1.dy + p1.dx * p1.dx - r1 * r1;

//     double x1, x2;
//     (x1, x2) = quadradicSolution(a, b, c);

//     intersection1 = Offset(x1, A + B * x1);
//     intersection2 = Offset(x2, A + B * x2);
//   }

//    return (intersection1, intersection2);
//  }

// Compute the two solutions to the quadradic forumula.
// a,b,c have the normal meaning for the quadradic formula.
(double, double) quadradicSolution(double a, double b, double c) {
  double x1 = double.nan;
  double x2 = double.nan;
  double base = (b * b) - (4 * a * c);
  if (base < 0) {
    return (double.nan, double.nan);
  }

  double root = math.sqrt(base);
  x1 = (-b + root) / (2 * a);
  x2 = (-b - root) / (2 * a);

  return (x1, x2);
}

// ********************************************************************
Offset computeMidpoint(List<Offset> points) {
  Offset min = Offset.zero;
  Offset max = Offset.zero;

  (min, max) = getMinMax2D(points);

  return Offset((min.dx + max.dx) / 2, (min.dy + max.dy) / 2);
}

(Point3D, Point3D) getMinMax(List<Point3D> points) {
  double maxX = double.negativeInfinity;
  double maxY = double.negativeInfinity;
  double maxZ = double.negativeInfinity;
  double minX = double.maxFinite;
  double minY = double.maxFinite;
  double minZ = double.maxFinite;

  for (Point3D point in points) {
    if (point.x < minX) minX = point.x;
    if (point.y < minY) minY = point.y;
    if (point.z < minZ) minZ = point.z;
    if (point.x > maxX) maxX = point.x;
    if (point.y > maxY) maxY = point.y;
    if (point.z > maxZ) maxZ = point.z;
  }

  return (Point3D(minX, minY, minZ), Point3D(maxX, maxY, minZ));
}

(Offset, Offset) getMinMax2D(List<Offset> points) {
  double maxX = double.negativeInfinity;
  double maxY = double.negativeInfinity;
  double minX = double.maxFinite;
  double minY = double.maxFinite;

  for (Offset point in points) {
    if (point.dx < minX) minX = point.dx;
    if (point.dy < minY) minY = point.dy;
    if (point.dx > maxX) maxX = point.dx;
    if (point.dy > maxY) maxY = point.dy;
  }

  return (Offset(minX, minY), Offset(maxX, maxY));
}

Offset getMin2D(List<Offset> points) {
  double minX = double.maxFinite;
  double minY = double.maxFinite;

  for (Offset point in points) {
    if (point.dx < minX) minX = point.dx;
    if (point.dy < minY) minY = point.dy;
  }

  return Offset(minX, minY);
}

Point3D min3D(Point3D p1, Point3D p2) {
  return Point3D(
      math.min(p1.x, p2.x), math.min(p1.y, p2.y), math.min(p1.z, p2.z));
}

Point3D max3D(Point3D p1, Point3D p2) {
  return Point3D(
      math.max(p1.x, p2.x), math.max(p1.y, p2.y), math.max(p1.z, p2.z));
}

List<Offset> translateShape(
    List<Offset> points, double xOffset, double yOffset) {
  List<Offset> result = [];

  for (Offset point in points) {
    result.add(Offset(point.dx + xOffset, point.dy + yOffset));
  }

  return result;
}

// *******************************************************************
double angleBetween(Offset vector1, Offset vector2) {
  double x1 = vector1.dx;
  double y1 = vector1.dy;
  double x2 = vector2.dx;
  double y2 = vector2.dy;

  double dotProduct = (x1 * x2) + (y1 * y2);
  double magnitude1 = math.sqrt(x1 * x1 + y1 * y1);
  double magnitude2 = math.sqrt(x2 * x2 + y2 * y2);

  double cosine = dotProduct / (magnitude1 * magnitude2);
  double angleRadians = math.acos(cosine);

  return angleRadians;
}
