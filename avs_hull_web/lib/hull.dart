// ***************************************************************
// Part of the AVS Hull program
// Released under the MIT license.
// See https://github.com/philip-w-howard/AVSHullWeb for details
// ***************************************************************

import 'dart:math' as math;
import 'point_3d.dart';
import 'bulkhead.dart';
import 'spline.dart';

class Hull {
  List<Bulkhead> mBulkheads = [];
  List<Spline> mChines = [];
  static const int _pointsPerChine = 50;

  Hull();

  Hull.create(double length, double width, double height, int numBulkheads,
      int numChines) {
    double radius = height;

    List<Point3D> points = [];

    for (int ii = 0; ii <= numChines; ii++) {
      var angle = math.pi + ii * math.pi / 2 / numChines;
      var z = math.cos(angle) * radius + radius;
      var y = math.sin(angle) * radius + radius;
      points.add(Point3D(0, y, z));
    }
    for (int ii = numChines - 1; ii >= 0; ii--) {
      var angle = 2 * math.pi / 2 + ii * math.pi / 2 / numChines;
      var z = math.cos(angle) * radius + radius;
      var y = math.sin(angle) * radius + radius;
      points.add(Point3D(0, y, z));
    }
    mBulkheads.add(Bulkhead.fromPoints(points, BulkheadType.bow));

    for (int ii = 1; ii < numBulkheads; ii++) {
      mBulkheads
          .add(Bulkhead.round(width, ii * length / numBulkheads, numChines));
    }

    normalize();
    _createChines();
  }

  Hull.copy(Hull source) {
    mBulkheads = List<Bulkhead>.from(source.mBulkheads);
    mChines = List<Spline>.from(source.mChines);
  }

  Hull.fromJson(Map<String, dynamic> json) {
    if (json['mBulkheads'] != null) {
      json['mBulkheads'].forEach((bulkheadJson) {
        mBulkheads.add(Bulkhead.fromJson(bulkheadJson));
      });
    }

    _createChines();
  }

  void updateFromJson(Map<String, dynamic> json) {
    if (json['mBulkheads'] != null) {
      mBulkheads = [];
      json['mBulkheads'].forEach((bulkheadJson) {
        mBulkheads.add(Bulkhead.fromJson(bulkheadJson));
      });
    }

    _createChines();
  }

  void normalize() {
    Point3D myMin = min();
    Point3D mySize = size();
    Point3D myShift = Point3D(0, 0, 0);

    myShift.x = -(myMin.x + mySize.x / 2);
    myShift.y = -myMin.y;
    myShift.z = -myMin.z;

    shift(myShift);
  }

  void shift(Point3D movement) {
    for (Bulkhead bulkhead in mBulkheads) {
      for (Point3D point in bulkhead.mPoints) {
        point.x += movement.x;
        point.y += movement.y;
        point.z += movement.z;
      }
    }

    for (Spline spline in mChines) {
      spline.shift(movement);
    }
  }

  Point3D min() {
    Point3D minSize =
        Point3D(double.infinity, double.infinity, double.infinity);

    for (Bulkhead bulkhead in mBulkheads) {
      for (Point3D point in bulkhead.mPoints) {
        minSize.x = math.min(minSize.x, point.x);
        minSize.y = math.min(minSize.y, point.y);
        minSize.z = math.min(minSize.z, point.z);
      }
    }

    return minSize;
  }

  Point3D size() {
    Point3D size = Point3D(double.negativeInfinity, double.negativeInfinity,
        double.negativeInfinity);

    for (Bulkhead bulkhead in mBulkheads) {
      for (Point3D point in bulkhead.mPoints) {
        size.x = math.max(size.x, point.x);
        size.y = math.max(size.y, point.y);
        size.z = math.max(size.z, point.z);
      }
    }

    return size;
  }

  void resize(double xSize, double ySize, double zSize) {
    Point3D mySize = size();

    double xRatio = xSize / mySize.x;
    double yRatio = ySize / mySize.y;
    double zRatio = zSize / mySize.z;

    for (Bulkhead bulk in mBulkheads) {
      bulk.resize(xRatio, yRatio, zRatio);
    }

    _createChines();
  }

  int numBulkheads() {
    return mBulkheads.length;
  }

  Bulkhead getBulkhead(int index) {
    return mBulkheads[index];
  }

  void _createChines() {
    int nChines = mBulkheads[0].numPoints();
    mChines = [];

    for (int chine = 0; chine < nChines; chine++) {
      List<Point3D> chineData = [];

      for (int bulkhead = 0; bulkhead < mBulkheads.length; bulkhead++) {
        chineData.add(mBulkheads[bulkhead].mPoints[chine]);
      }
      mChines.add(Spline(chineData, _pointsPerChine));
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'mBulkheads': mBulkheads,
    };
  }

  bool isNearBulkhead(int bulk, double x, double y, double distance) {
    if (bulk < 0 || bulk >= mBulkheads.length) return false;

    return mBulkheads[bulk].isNearBulkhead(x, y, distance);
  }

  int isNearBulkheadPoint(int bulk, double x, double y, double distance) {
    if (bulk < 0 || bulk >= mBulkheads.length) return -1;

    return mBulkheads[bulk].isNearBulkheadPoint(x, y, distance);
  }

  void updateBulkhead(int bulk, int chine, double x, double y, double z) {
    mBulkheads[bulk].updatePoint(chine, x, y, z);
    _createChines();
  }
}
