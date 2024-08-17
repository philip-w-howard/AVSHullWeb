// ***************************************************************
// Part of the AVS Hull program
// Released under the MIT license.
// See https://github.com/philip-w-howard/AVSHullWeb for details
// ***************************************************************

import 'dart:math' as math;
import 'package:avs_hull_web/geometry/hull_math.dart';
import 'package:xml/xml.dart';

import '../geometry/point_3d.dart';
import 'bulkhead.dart';
import '../geometry/spline.dart';

class HullParams {
  BulkheadType bow = BulkheadType.bow;
  double forwardTransomAngle = 115;
  BulkheadType stern = BulkheadType.transom;
  double sternTransomAngle = 75;
  int numBulkheads = 5;
  int numChines = 5;
  double length = 96;
  double width = 40;
  double height = 10;
}

class Hull {
  List<Bulkhead> mBulkheads = [];
  List<Spline> mChines = [];
  DateTime timeUpdated = DateTime.now();
  static const int _pointsPerChine = 50;

  Hull();

  //Hull.create(double length, double width, double height, int numBulkheads,
  //    int numChines) {
  Hull.fromParams(HullParams params) {
    updateFromParams(params);
  }

  void updateFromParams(HullParams params) {
    int bulk = 0;
    double bulkSpacing = params.length / (params.numBulkheads - 1);
    mBulkheads = [];

    for (bulk=0; bulk<params.numBulkheads; bulk++)
    {
      // double radius = (params.width / 2) * (1 - (bulk * bulkSpacing - params.length / 2) / (params.length / 2.5)).abs();
      double radius = (params.width / 2) * (1 - (bulk * bulkSpacing - params.length / 2).abs() / (params.length / 1.5));

      if (bulk == 0) {
        if (params.bow == BulkheadType.bow) {
          radius = params.height;
          if (radius > bulkSpacing * 0.9) radius = bulkSpacing * 0.9;

          mBulkheads.add(Bulkhead.bow(params.numChines, radius, params.height));
        } else if (params.bow == BulkheadType.vertical) {
          mBulkheads.add(Bulkhead.round(0, radius, params.height,
              params.height, params.numChines, 90));
        } else {
          mBulkheads.add(Bulkhead.round(0, radius, params.height,
              params.height, params.numChines, params.forwardTransomAngle));
        }
      } else if (bulk == params.numBulkheads - 1) {
        if (params.stern == BulkheadType.bow) {
          radius = params.height;
          if (radius > bulkSpacing * 0.9) radius = bulkSpacing * 0.9;

          mBulkheads.add(Bulkhead.stern(params.numChines, radius, params.height, params.length));
        } else if (params.stern == BulkheadType.vertical) {
          mBulkheads.add(Bulkhead.round(bulk * bulkSpacing, radius, params.height,
              params.height, params.numChines, 90));
        } else if (params.stern == BulkheadType.transom) {
          mBulkheads.add(Bulkhead.round(bulk * bulkSpacing, radius, params.height,
              params.height, params.numChines, params.sternTransomAngle));
        }
      } else {
          mBulkheads.add(Bulkhead.round(bulk * bulkSpacing, radius, params.height,
              params.height, params.numChines, 90));
      }
    }

    normalize();
    _createChines();
    timeUpdated = DateTime.now();
  }

  Hull.copy(Hull source) {
    // need a deep copy
    for (Bulkhead bulk in source.mBulkheads) {
      mBulkheads.add(Bulkhead.copy(bulk));
    }

    _createChines();
    timeUpdated = DateTime.now();
  }

  Hull.fromJson(Map<String, dynamic> json) {
    if (json['mBulkheads'] != null) {
      json['mBulkheads'].forEach((bulkheadJson) {
        mBulkheads.add(Bulkhead.fromJson(bulkheadJson));
      });
    }

    if (json['timeUpdated'] != null) {
      timeUpdated = DateTime.parse(json['timeUpdated']);
    } else {
      timeUpdated = DateTime.now();
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

    if (json['timeUpdated'] != null) {
      timeUpdated = DateTime.parse(json['timeUpdated']);
    } else {
      timeUpdated = DateTime.now();
    }
    _createChines();
  }

  void updateFromHull(Hull source) {
    mBulkheads.clear();

    // need a deep copy
    for (Bulkhead bulk in source.mBulkheads) {
      mBulkheads.add(Bulkhead.copy(bulk));
    }

    timeUpdated = source.timeUpdated;
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
    Point3D min = Point3D.zero();
    Point3D max = Point3D.zero();
    Point3D sizeMin = Point3D.zero();
    Point3D sizeMax = Point3D.zero();

    for (Bulkhead bulkhead in mBulkheads) {
      (min, max) = getMinMax(bulkhead.mPoints);

      sizeMin = min3D(min, sizeMin);
      sizeMax = max3D(max, sizeMax);
    }

    return Point3D(
        sizeMax.x - sizeMin.x, sizeMax.y - sizeMin.y, sizeMax.z - sizeMin.z);
  }

  void resize(double xSize, double ySize, double zSize) {
    Point3D mySize = size();

    double xRatio = xSize / mySize.x;
    double yRatio = ySize / mySize.y;
    double zRatio = zSize / mySize.z;

    for (Bulkhead bulk in mBulkheads) {
      bulk.resize(xRatio, yRatio, zRatio);
    }

    timeUpdated = DateTime.now();

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
      'timeUpdated': timeUpdated.toIso8601String(),
    };
  }

  // **************************************************
  XmlDocument toXml() {
    final builder = XmlBuilder();
    builder.element('hull', nest: () {
      builder.element('bulkheads', nest: () {
        for (var bulkhead in mBulkheads) {
          bulkhead.addXmlContent(builder);
        }
      });

      builder.element('timeUpdated', nest: timeUpdated.toIso8601String());
    });
    return builder.buildDocument();
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
    timeUpdated = DateTime.now();
    _createChines();
  }
}
