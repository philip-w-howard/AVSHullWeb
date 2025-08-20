// ***************************************************************
// Part of the AVS Hull program
// Released under the MIT license.
// See https://github.com/philip-w-howard/AVSHullWeb for details
// ***************************************************************

import 'dart:math' as math;
import 'package:avs_hull_web/geometry/hull_math.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';

import '../geometry/point_3d.dart';
import 'bulkhead.dart';
import '../geometry/spline.dart';
//import '../geometry/hull_math.dart';
import '../settings/settings.dart';

class HullParams {
  String name = unnamedHullName;
  BulkheadType bow = BulkheadType.bow;
  double forwardTransomAngle = 115;
  BulkheadType stern = BulkheadType.transom;
  double sternTransomAngle = 75;
  int numBulkheads = 5;
  int numChines = 5;
  double length = 96;
  double width = 40;
  double height = 10;
  bool closedTop = false;
  bool flatBottomed = false;
}

class Hull {
  String name = unnamedHullName;
  List<Bulkhead> mBulkheads = [];
  List<Spline> mChines = [];
  DateTime timeUpdated = DateTime.now();
  DateTime timeSaved = DateTime.now();
  static const int _pointsPerChine = 50;

  Hull();

  void updateFromParams(HullParams params) {
    int bulk = 0;
    double bulkSpacing = params.length / (params.numBulkheads - 1);
    mBulkheads = [];
    name = params.name;

    for (bulk=0; bulk<params.numBulkheads; bulk++)
    {
      // double radius = (params.width / 2) * (1 - (bulk * bulkSpacing - params.length / 2) / (params.length / 2.5)).abs();
      double radius = (params.width / 2) * (1 - (bulk * bulkSpacing - params.length / 2).abs() / (params.length / 1.5));

      if (bulk == 0) {
        if (params.bow == BulkheadType.bow) {
          radius = params.height;
          if (radius > bulkSpacing * 0.9) radius = bulkSpacing * 0.9;

          mBulkheads.add(Bulkhead.bow(params.numChines, radius, params.height, params.flatBottomed, params.closedTop));
        } else if (params.bow == BulkheadType.vertical) {
          mBulkheads.add(Bulkhead.round(0, radius, params.height,
              params.height, params.numChines, 90, params.flatBottomed, params.closedTop));
        } else {
          mBulkheads.add(Bulkhead.round(0, radius, params.height,
              params.height, params.numChines, params.forwardTransomAngle, params.flatBottomed, params.closedTop));
        }
      } else if (bulk == params.numBulkheads - 1) {
        if (params.stern == BulkheadType.bow) {
          radius = params.height;
          if (radius > bulkSpacing * 0.9) radius = bulkSpacing * 0.9;

          mBulkheads.add(Bulkhead.stern(params.numChines, radius, params.height, params.length, params.flatBottomed, params.closedTop));
        } else if (params.stern == BulkheadType.vertical) {
          mBulkheads.add(Bulkhead.round(bulk * bulkSpacing, radius, params.height,
              params.height, params.numChines, 90, params.flatBottomed, params.closedTop));
        } else if (params.stern == BulkheadType.transom) {
          mBulkheads.add(Bulkhead.round(bulk * bulkSpacing, radius, params.height,
              params.height, params.numChines, params.sternTransomAngle, params.flatBottomed, params.closedTop));
        }
      } else {
          mBulkheads.add(Bulkhead.round(bulk * bulkSpacing, radius, params.height,
              params.height, params.numChines, 90, params.flatBottomed, params.closedTop));
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
  
    // force a deep copy of chines.
    mChines = [];
    for (Spline spline in source.mChines) {
      mChines.add(Spline.copy(spline));
    }

    timeUpdated = DateTime.now();
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

    if (json['timeSaved'] != null) {
      timeSaved = DateTime.parse(json['timeSaved']);
    } else {
      timeSaved = DateTime.now();
    }

    _createChines();
  }

  void updateFromHull(Hull source) {
    mBulkheads.clear();

    // need a deep copy
    for (Bulkhead bulk in source.mBulkheads) {
      mBulkheads.add(Bulkhead.copy(bulk));
    }

    if (timeSaved  == source.timeUpdated) {
      timeUpdated = source.timeUpdated;
    } else {
      timeUpdated = DateTime.now();
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
    Point3D minPoint, maxPoint;
    Point3D minSize =
        Point3D(double.infinity, double.infinity, double.infinity);

    for (Bulkhead bulkhead in mBulkheads) {
      (minPoint, maxPoint) = getMinMax(bulkhead.mPoints);
      minSize = min3D(minSize, minPoint);
    }
    // Check all chine points (if any)
    for (Spline spline in mChines) {
      List<Point3D> points = spline.getPoints();
      (minPoint, maxPoint) = getMinMax(points);
      minSize = min3D(minPoint, minSize);
    }

    return minSize;
  }

  Point3D size() {
    Point3D min = Point3D(double.infinity, double.infinity, double.infinity);
    Point3D max = Point3D(double.negativeInfinity, double.negativeInfinity, double.negativeInfinity);
    Point3D sizeMin = Point3D(double.infinity, double.infinity, double.infinity);
    Point3D sizeMax = Point3D(double.negativeInfinity, double.negativeInfinity, double.negativeInfinity);

    for (Bulkhead bulkhead in mBulkheads) {
      (min, max) = getMinMax(bulkhead.mPoints);

      sizeMin = min3D(min, sizeMin);
      sizeMax = max3D(max, sizeMax);
    }

    // Check all chine points (if any)
    for (Spline spline in mChines) {
      List<Point3D> points = spline.getPoints();
      (min, max) = getMinMax(points);

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

  // **************************************************
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'mBulkheads': mBulkheads,
      'timeUpdated': timeUpdated.toIso8601String(),
      'timeSaved': timeSaved.toIso8601String(),
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

  double minBulkheadPos() {
    Bulkhead bulkhead = mBulkheads[0];
    int nPoints = bulkhead.numPoints()~/2;

    if (bulkhead.type() == BulkheadType.vertical) {
      return 0;
    } else if (bulkhead.type() == BulkheadType.bow) {
      return bulkhead.mPoints[nPoints-1].z;
    } else if (bulkhead.mTransomAngle < 90) {
      return bulkhead.mPoints[0].z;
    } else {    
      return bulkhead.mPoints[nPoints - 1].z;
    }
  }

  double maxBulkheadPos() {
    Bulkhead bulkhead = mBulkheads[mBulkheads.length - 1];
    int nPoints = bulkhead.numPoints()~/2;

    if (bulkhead.type() == BulkheadType.vertical) {
      return bulkhead.mPoints[0].z;
    } else if (bulkhead.type() == BulkheadType.bow) {
      return bulkhead.mPoints[nPoints-1].z;
    } else if (bulkhead.mTransomAngle > 90) {
      return bulkhead.mPoints[0].z;
    } else {    
      return bulkhead.mPoints[nPoints - 1].z;
    }
  }

  // create a bulkhead at the specified position
  void insertBulkhead(double position) {
    int bulk = mBulkheads.length-1;

    // find the bulkhead to insert before
    for (int ii=1; ii<mBulkheads.length-1; ii++) {
      if (mBulkheads[ii].mPoints[0].z > position) {
        bulk = ii;
        break;  // <<<<<<<<<<<<<<<<<<<<<<<
      }
    }
    // create a new bulkhead
    Bulkhead newBulkhead = Bulkhead.copy(mBulkheads[bulk]);
    for (int ii=0; ii<newBulkhead.numPoints(); ii++) {
      Point3D? point = interpolateToZ(mChines[ii].getPoints(), position);
      if (point != null) {
        newBulkhead.mPoints[ii] = point;
      } else {
        newBulkhead.mPoints[ii] = Point3D(0, 0, position);
      }
    }
    
    // insert the new bulkhead
    mBulkheads.insert(bulk, newBulkhead);
    
    timeUpdated = DateTime.now();
    _createChines();
  }

  // delete specified bulkhead
  void deleteBulkhead(int bulk) {
    // Can't delete bow nor stern bulkheads
    if (bulk < 1 || bulk >= mBulkheads.length - 1) return;

    debugPrint('Deleting bulkhead $bulk');
    if (mBulkheads.length > 2) {
      mBulkheads.removeAt(bulk);
      timeUpdated = DateTime.now();
      _createChines();
    }
  }

  void setNumChines(int numChines) {
    if (numChines < 2) numChines = 2;
    if (numChines > 50) numChines = 50;

    for (Bulkhead bulkhead in mBulkheads) {
      bulkhead.setNumChines(numChines);
    }

    _createChines();
    timeUpdated = DateTime.now();
  }
}