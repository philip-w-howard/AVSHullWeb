// ***************************************************************
// Part of the AVS Hull program
// Released under the MIT license.
// See https://github.com/philip-w-howard/AVSHullWeb for details
// ***************************************************************

import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../geometry/point_3d.dart';
import '../geometry/hull_math.dart';
import '../geometry/spline.dart';
import 'bulkhead.dart';

class Panel {
  static const double _minEdgeLength = 0.25;

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
  Panel.fromBulkhead(Bulkhead bulk, {bool center = true}) {
    double scaleFactor = 1;

    if (bulk.mBulkheadType == BulkheadType.transom) {
      scaleFactor = math.sin(bulk.mTransomAngle * (math.pi / 180.0));
    }

    mPoints.clear();

    for (Point3D point in bulk.mPoints) {
      mPoints.add(Offset(point.x, point.y / scaleFactor));
    }

    // close the shape by adding the first point to the end
    mPoints.add(Offset(bulk.mPoints[0].x, bulk.mPoints[0].y / scaleFactor));

    if (center) {
      _center(Offset.zero);
    } else {
      mPoints.removeLast(); // remove duplicate point 
      _rotate(math.pi);
      Offset min = getMin2D(mPoints);
      _center(Offset(0, -min.dy));
    }
  }

  // *******************************
  Panel.fromChines(Spline chine1, Spline chine2) {
    mPoints.clear();
    origin = Offset.zero;
    _panelize(chine1.getPoints(), chine2.getPoints());
    _horizontalize();
    _center(Offset.zero);
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
      Offset edge1Point = _computePointAngle(
          chine1[ii],
          chine1[ii + 1],
          chine2[ii],
          mPoints[mPoints.length - 1],
          edge2[edge2.length - 1],
          mPoints[mPoints.length - 2]);
      if (!edge1Point.dx.isFinite || !edge1Point.dy.isFinite) {
        debugPrint('_panelize edge1: NaN at index $ii\n'
            '  chine1[$ii]=${chine1[ii]}\n'
            '  chine1[${ii+1}]=${chine1[ii+1]}\n'
            '  chine2[$ii]=${chine2[ii]}\n'
            '  mPoints last=${mPoints[mPoints.length - 1]}\n'
            '  edge2 last=${edge2[edge2.length - 1]}\n'
            '  mPoints second last=${mPoints[mPoints.length - 2]}');
        _listPoints('mPoints', mPoints);
        _listPoints('edge2', edge2);
        debugPrint('_panelize: dumping chine1 and chine2, then exiting _panelize');
        for (int jj = 0; jj < chine1.length; jj++) {
          debugPrint('  chine1[$jj]=${chine1[jj]}');
        }
        debugPrint('---');
        for (int jj = 0; jj < chine2.length; jj++) {
          debugPrint('  chine2[$jj]=${chine2[jj]}');
        }
        return;
      }
      mPoints.add(edge1Point);

      // advance edge2 by one point
      Offset edge2Point = _computePointAngle(
          chine2[ii],
          chine2[ii + 1],
          chine1[ii + 1],
          edge2[edge2.length - 1],
          mPoints[mPoints.length - 1],
          edge2[edge2.length - 2]);
      if (!edge2Point.dx.isFinite || !edge2Point.dy.isFinite) {
        debugPrint('_panelize edge2: NaN at index $ii'
            '  chine2[$ii]=${chine2[ii]}'
            '  chine2[${ii+1}]=${chine2[ii+1]}'
            '  chine1[${ii+1}]=${chine1[ii+1]}');
      }
      edge2.add(edge2Point);
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
  int _listPoints(String msg, List<Offset> points) {
    int count = 0;
    debugPrint('$msg:');
    for (Offset point in points) {
      debugPrint('  $count: $point');
      count++;
    }
    return count;
  }
  // *******************************
  // Find intersection of two circles. Favor the intersection with the larger X value
  Offset _computePointDx(
      Point3D p1, Point3D p2, Point3D p3, Offset p4, Offset p5) {
    double r1 = (p1 - p2).length();
    double r2 = (p3 - p2).length();

    Offset intersection1 = Offset.zero;
    Offset intersection2 = Offset.zero;
    (intersection1, intersection2) = intersection(p4, r1, p5, r2);
    if (!intersection1.dx.isFinite || !intersection1.dy.isFinite
      || !intersection2.dx.isFinite || !intersection2.dy.isFinite) {
      debugPrint('_computePointDx: intersection is NaN');
    }
    if (intersection1.dx >= intersection2.dx) {
      return intersection1;
    } else {
      return intersection2;
    }
  }

  // *******************************
  // Find the intersection of two circles. Favor the one with the smaller angle
  Offset _computePointAngle(
      Point3D p1, Point3D p2, Point3D p3, Offset p4, Offset p5, Offset p6) {
    double r1 = (p1 - p2).length();
    double r2 = (p3 - p2).length();

    Offset intersection1 = Offset.zero;
    Offset intersection2 = Offset.zero;
    (intersection1, intersection2) = intersection(p4, r1, p5, r2);
    
    if (!intersection1.dx.isFinite || !intersection1.dy.isFinite
      || !intersection2.dx.isFinite || !intersection2.dy.isFinite) {
      debugPrint('_computePointAngle: intersection is NaN');
      debugPrint(
            '  p1=$p1}\n'
            '  p2=$p2\n'
            '  p3=$p3\n'
            '  p4=$p4\n'
            '  p5=$p5\n'
            '  r1=$r1\n'
            '  r2=$r2\n');
    }

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

    // **************************************************
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'points': mPoints.map((pt) => {'x': pt.dx, 'y': pt.dy}).toList(),
      'origin': {'x': origin.dx, 'y': origin.dy}
    };
  }

  // *******************************
  factory Panel.fromJson(Map<String, dynamic> json) {
    Panel panel = Panel();
    if (json['name'] != null) {
      panel.name = json['name'];
    }
    if (json['origin'] != null) {
      var o = json['origin'];
      panel.origin = Offset((o['x'] ?? 0.0).toDouble(), (o['y'] ?? 0.0).toDouble());
    }
    if (json['points'] != null) {
      panel.mPoints = (json['points'] as List)
          .map((pt) => Offset((pt['x'] ?? 0.0).toDouble(), (pt['y'] ?? 0.0).toDouble()))
          .toList();
    }
    return panel;
  }
}