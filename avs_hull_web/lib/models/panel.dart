import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../geometry/point_3d.dart';
import '../geometry/hull_math.dart';
import '../geometry/spline.dart';
import 'bulkhead.dart';

class Panel {
  static const double _minEdgeLength = 0.25;
  static const double _kneeAngle = 5;         // min angle of a knee in degrees

  List<Offset> mPoints = [];
  Offset origin = Offset.zero;
  String name = 'unnamed panel';

  // *******************************
  Panel() {
    mPoints.clear();
  }

  // *******************************
  Panel.copy(Panel source) {
    origin = Offset(source.origin.dx, source.origin.dy);
    mPoints = List.from(source.mPoints);
    name = source.name;
  }

  // *******************************
  Panel.fromBulkhead(Bulkhead bulk) {
    double scaleFactor = 1;

    if (bulk.mBulkheadType == BulkheadType.transom) {
      scaleFactor = math.sin(bulk.mTransomAngle * (math.pi / 180.0));
    }

    mPoints.clear();

    for (Point3D point in bulk.mPoints) {
      mPoints.add(Offset(point.x, point.y / scaleFactor));
    }

    mPoints.add(Offset(bulk.mPoints[0].x, bulk.mPoints[0].y / scaleFactor));
    _center(Offset.zero);
  }

  // *******************************
  Panel.fromChines(Spline chine1, Spline chine2) {
    mPoints.clear();
    origin = Offset.zero;
    _panelize(chine1.getPoints(), chine2.getPoints());
    _horizontalize();
    _center(Offset.zero);
  }

  Panel.toFixedOffsets(Panel source, int fixedOffset)
  {
    mPoints.clear();

    Offset p1 = source.mPoints[mPoints.length - 2];
    Offset p2 = source.mPoints[mPoints.length - 1];
    Offset p3;
    bool first = true;

    p1 = Offset(p1.dx + origin.dx, p1.dy + origin.dy);
    p2 = Offset(p2.dx + origin.dx, p2.dy + origin.dy);

    for (Offset p in mPoints)
    {
      p3 = Offset(p.dx + origin.dx, p.dy + origin.dy);

      if (first)
      {
        mPoints.add(p3);
        first = false;
      }
      else if (isKnee(p1, p2, p3, _kneeAngle))
      {
        mPoints.add(p2);
      }

      if (spansX(p2, p3, fixedOffset))
      {
        Offset temp = computeSpacingPoint(p1, p2, fixedOffset);
        mPoints.add(temp);
      }

      p1 = p2;
      p2 = p3;
    }

    origin = source.origin;
  }

  // *******************************
  void _center(Offset newOrigin) {
    origin = newOrigin;

    Offset center = computeMidpoint(mPoints);
    if (center.dx != 0 || center.dy != 0) {
      mPoints = translateShape(mPoints, -center.dx, -center.dy);
    }

    origin = Offset(origin.dx + center.dx, origin.dy + center.dy);
  }

  // *******************************
  void _horizontalize() {
    double x = mPoints[mPoints.length ~/ 2 - 1].dx - mPoints[0].dx;
    double y = mPoints[mPoints.length ~/ 2 - 1].dy - mPoints[0].dy;

    double angle;

    angle = math.atan2(y, x);
    _rotate(-angle);
  }

  // *************************************************************
  void _panelize(List<Point3D> chine1, List<Point3D> chine2) {
    double r1;
    List<Offset> edge2 = [];

    mPoints.clear();

    bool pointyBow = (chine1[0] - chine2[0]).length() < _minEdgeLength;
    bool pointyStern =
        (chine1[chine1.length - 1] - chine2[chine2.length - 1]).length() <
            _minEdgeLength;

    // Start at origin
    mPoints.add(const Offset(0, 0));
    edge2.add(const Offset(0, 0));

    if (pointyBow) {
      r1 = (chine1[0] - chine1[1]).length();
      mPoints
          .add(Offset(r1 * math.cos(math.pi / 4), r1 * math.sin(math.pi / 4)));
    } else {
      // Make the edge the first segment in edge2
      r1 = (chine1[0] - chine2[0]).length();
      edge2.add(Offset(0, -r1));

      // Compute next point, and favor positive X direction
      // advance edge1 by one point
      mPoints.add(_computePointDx(chine1[0], chine1[1], chine2[0],
          mPoints[mPoints.length - 1], edge2[edge2.length - 1]));
    }

    // add next point to edge2
    edge2.add(_computePointDx(chine2[0], chine2[1], chine1[1],
        edge2[edge2.length - 1], mPoints[mPoints.length - 1]));

    // Complete the rest of the points
    int lastPoint;
    if (pointyStern) {
      lastPoint = chine1.length - 2;
    } else {
      lastPoint = chine1.length - 1;
    }

    for (int ii = 1; ii < lastPoint; ii++) {
      mPoints.add(_computePointAngle(
          chine1[ii],
          chine1[ii + 1],
          chine2[ii],
          mPoints[mPoints.length - 1],
          edge2[edge2.length - 1],
          mPoints[mPoints.length - 2]));

      // advance edge2 by one point
      edge2.add(_computePointAngle(
          chine2[ii],
          chine2[ii + 1],
          chine1[ii + 1],
          edge2[edge2.length - 1],
          mPoints[mPoints.length - 1],
          edge2[edge2.length - 2]));
    }

    if (pointyStern) {
      mPoints.add(_computePointAngle(
          chine1[chine1.length - 2],
          chine1[chine1.length - 1],
          chine2[chine2.length - 2],
          mPoints[mPoints.length - 1],
          edge2[edge2.length - 1],
          mPoints[mPoints.length - 2]));

      // Don't need to add point to edge2 because it is the same (pointy) point and it would be a duplicate
    }

    // Copy edge2 input m_panelPoints
    for (int ii = edge2.length - 1; ii >= 0; ii--) {
      mPoints.add(edge2[ii]);
    }
  }

  // *******************************
  Offset _computePointDx(
      Point3D p1, Point3D p2, Point3D p3, Offset p4, Offset p5) {
    double r1 = (p1 - p2).length();
    double r2 = (p3 - p2).length();

    Offset intersection1 = Offset.zero;
    Offset intersection2 = Offset.zero;
    (intersection1, intersection2) = intersection(p4, r1, p5, r2);

    if (intersection1.dx >= intersection2.dx) {
      return intersection1;
    } else {
      return intersection2;
    }
  }

  // *******************************
  Offset _computePointAngle(
      Point3D p1, Point3D p2, Point3D p3, Offset p4, Offset p5, Offset p6) {
    double r1 = (p1 - p2).length();
    double r2 = (p3 - p2).length();

    Offset intersection1 = Offset.zero;
    Offset intersection2 = Offset.zero;
    (intersection1, intersection2) = intersection(p4, r1, p5, r2);

    Offset v_2 = p4 - p6;
    Offset v_2a = intersection1 - p4;
    Offset v_2b = intersection2 - p4;

    double b1 = angleBetween(v_2, v_2a);
    double b2 = angleBetween(v_2, v_2b);

    if (b1 < b2) {
      return intersection1;
    } else {
      return intersection2;
    }
  }

  // *******************************
  List<Offset> getOffsets() {
    List<Offset> offsets = [];
    for (Offset point in mPoints) {
      offsets.add(Offset(point.dx + origin.dx, point.dy + origin.dy));
    }

    return offsets;
  }

  // *************************************************************
  void _rotate(double angle) {
    mPoints = rotate2D(mPoints, -angle);
  }

  // void moveBy(double x, double y) {
  //   origin = Offset(origin.dx + x, origin.dy + y);
  // }

  // void flipVertically() {
  //   for (int ii = 0; ii < mPoints.length; ii++) {
  //     mPoints[ii] = Offset(mPoints[ii].dx, -mPoints[ii].dy);
  //   }
  // }

  // void flipHorizontally() {
  //   for (int ii = 0; ii < mPoints.length; ii++) {
  //     mPoints[ii] = Offset(-mPoints[ii].dx, mPoints[ii].dy);
  //   }
  // }
}
