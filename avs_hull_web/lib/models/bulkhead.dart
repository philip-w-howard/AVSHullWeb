// ***************************************************************
// Part of the AVS Hull program
// Released under the MIT license.
// See https://github.com/philip-w-howard/AVSHullWeb for details
// ***************************************************************

import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'dart:math' as math;
import '../geometry/point_3d.dart';
import '../geometry/hull_math.dart';
import '../geometry/spline.dart';

enum BulkheadType { bow, vertical, transom }

class Bulkhead {
  List<Point3D> mPoints = [];
  BulkheadType mBulkheadType = BulkheadType.vertical;
  double mTransomAngle = 90;
  bool _mFlatBottomed = false;
  bool _mClosedTop = false;

  // **************************************************
  Bulkhead(int numChines, this.mBulkheadType) {
    mPoints = List.generate(numChines + 1, (_) => Point3D(0, 0, 0));
  }

  // **************************************************
  Bulkhead.copy(Bulkhead source) {
    mBulkheadType = source.mBulkheadType;
    mTransomAngle = source.mTransomAngle;
    _mFlatBottomed = source._mFlatBottomed;
    _mClosedTop = source._mClosedTop;

    // need a deep copy
    for (Point3D point in source.mPoints) {
      mPoints.add(Point3D(point.x, point.y, point.z));
    }
  }

  // **************************************************
  Bulkhead.round(double z, double width, double height, double top,
      int numChines, double transomAngle, bool flatBottomed, bool closedTop) {
    _mFlatBottomed = flatBottomed;
    _mClosedTop = closedTop;
    
    if (transomAngle == 90) {
      mBulkheadType = BulkheadType.vertical;
      mTransomAngle = 90;
    } else {
      mBulkheadType = BulkheadType.transom;
      mTransomAngle = transomAngle;
    }

    // convert to radians
    transomAngle *= math.pi / 180;

    int numPoints = 2 * numChines;
    if (flatBottomed) numPoints++;

    for (int ii = 0; ii <= numPoints; ii++) {
      var angle = math.pi + ii * math.pi / numPoints;
      var x = math.cos(angle) * width;
      var y = math.sin(angle) * height + height + top;
      mPoints.add(Point3D(x, y, z + math.cos(transomAngle) * (y - 2*height)));
    }
  }

  // **************************************************
  Bulkhead.bow(int numChines, double radius, double height, bool flatBottomed, bool closedTop) {
    List<Point3D> points = [];

    mBulkheadType = BulkheadType.bow;
    mTransomAngle = 90;
    _mFlatBottomed = flatBottomed;
    _mClosedTop = closedTop;

    for (int ii = 0; ii <= numChines; ii++) {
      var angle = math.pi + math.pi / 2 * (ii / numChines);
      var z = math.cos(angle) * radius + radius;
      var y = math.sin(angle) * height + 2*height;
      points.add(Point3D(0, y, z));

      // flat bottomed gets a duplicate bottom
      if (flatBottomed && ii==numChines) points.add(Point3D(0, y, z));
    }
    for (int ii = numChines - 1; ii >= 0; ii--) {
      var angle = math.pi + math.pi / 2 * (ii / numChines);
      var z = math.cos(angle) * radius + radius;
      var y = math.sin(angle) * height + 2*height;
      points.add(Point3D(0, y, z));
    }

    // NOTE: Should be able to compute angle, flatbottomed, and closedTop based on points
    mPoints = [...points];
  }
  // **************************************************
  Bulkhead.stern(int numChines, double radius, double height, double length, bool flatBottomed, bool closedTop) {
    List<Point3D> points = [];

    mBulkheadType = BulkheadType.bow;
    mTransomAngle = 90;
    _mFlatBottomed = flatBottomed;
    _mClosedTop = closedTop;

    for (int ii = 0; ii <= numChines; ii++) {
      var angle = math.pi + math.pi / 2 * (ii / numChines);
      var z = length - math.cos(angle) * radius - radius;
      var y = math.sin(angle) * height + 2*height;
      points.add(Point3D(0, y, z));

      // flat bottomed gets a duplicate bottom
      if (flatBottomed && ii==numChines) points.add(Point3D(0, y, z));
    }
    for (int ii = numChines - 1; ii >= 0; ii--) {
      var angle = math.pi + math.pi / 2 * (ii / numChines);
      var z = length - math.cos(angle) * radius - radius;
      var y = math.sin(angle) * height + 2*height;
      points.add(Point3D(0, y, z));
    }

    // NOTE: Should be able to compute angle, flatbottomed, and closedTop based on points
    mPoints = [...points];
  }
  // **************************************************
  Bulkhead.fromPoints(List<Point3D> points, BulkheadType type) {
    // NOTE: Should be able to compute angle, flatbottomed, and closedTop based on points
    mBulkheadType = type;
    mPoints = [...points];
    mTransomAngle = 90;
    _mFlatBottomed = points.length % 2 == 0; // even number of points means flat bottomed
    _mClosedTop = false;
  }

  // **************************************************
  Bulkhead.fromJson(Map<String, dynamic> json) {
    if (json['mPoints'] != null) {
      json['mPoints'].forEach((point) {
        mPoints.add(Point3D.fromJson(point));
      });
    }

    mBulkheadType = BulkheadType.values.firstWhere(
        (type) => type.toString() == 'BulkheadType.${json['mBulkheadType']}');
    mTransomAngle = json['mTransomAngle'] ?? 90;
    _mFlatBottomed = json['mFlatBottomed'] ?? false;
    _mClosedTop = json['mClosedTop'] ?? false;
  }

  // **************************************************
  int numPoints() {
    return mPoints.length;
  }

  // **************************************************
  Point3D point(int index) {
    return mPoints[index];
  }

  // **************************************************
  BulkheadType type() {
    return mBulkheadType;
  }

  // **************************************************
  void resize(double xRatio, double yRatio, double zRatio) {
    for (Point3D point in mPoints) {
      point.x *= xRatio;
      point.y *= yRatio;
      point.z *= zRatio;
    }

    // Recompute transom angle
    if (mBulkheadType == BulkheadType.transom) {
      Point3D p1 = mPoints[0];
      Point3D p2 = mPoints[mPoints.length ~/ 2];
      double deltaY = p1.y - p2.y;
      double deltaZ = p1.z - p2.z;
      double newAngle = math.atan2(deltaY, deltaZ) * 180 / math.pi;
      mTransomAngle = newAngle;
    }
  }

  // **************************************************
  Map<String, dynamic> toJson() {
    return {
      'mPoints': mPoints,
      'mBulkheadType': mBulkheadType.toString().split('.').last,
      'mTransomAngle': mTransomAngle,
      'mFlatBottomed': _mFlatBottomed,
      'mClosedTop': _mClosedTop,
    };
  }

  // **************************************************
  XmlDocument toXml() {
    final builder = XmlBuilder();
    addXmlContent(builder);

    return builder.buildDocument();
  }

  // **************************************************
  void addXmlContent(XmlBuilder builder) {
    builder.element('bulkhead', nest: () {
      builder.element('points', nest: () {
        for (var point in mPoints) {
          point.addXmlContent(builder);
        }
      });

      builder.element('BulkheadType', nest: mBulkheadType.toString().split('.').last);
      builder.element('TransomAngle', nest: mTransomAngle);
      builder.element('FlatBottomed', nest: _mFlatBottomed);
      builder.element('ClosedTop', nest: _mClosedTop);
    });
  }

    // **************************************************
  bool isNearBulkhead(double x, double y, double distance) {
    for (int ii = 0; ii < numPoints() - 1; ii++) {
      double l1x = mPoints[ii].x;
      double l1y = mPoints[ii].y;
      double l2x = mPoints[ii + 1].x;
      double l2y = mPoints[ii + 1].y;

      if (isNearLine(l1x, l1y, l2x, l2y, x, y, distance)) return true;
    }

    return false;
  }

  // **************************************************
  int isNearBulkheadPoint(double x, double y, double maxDistance) {
    double minDistance = 2 * maxDistance;
    int selectedPoint = -1;

    for (int ii = 0; ii < numPoints(); ii++) {
      double bulkX = mPoints[ii].x;
      double bulkY = mPoints[ii].y;
      double distance = distanceToPoint(bulkX, bulkY, x, y);

      if (distance < minDistance && distance < maxDistance) {
        minDistance = distance;
        selectedPoint = ii;
      }
    }

    return selectedPoint;
  }

  // **************************************************
  void updatePoint(int chine, double x, double y, double z) {
    switch (mBulkheadType) {
      case BulkheadType.bow:
        x = mPoints[chine].x;
        break;
      case BulkheadType.vertical:
        z = mPoints[chine].z;
        break;
      case BulkheadType.transom:
        Point3D center = mPoints[mPoints.length ~/ 2];
        double angle = mTransomAngle * math.pi / 180;
        z = center.z + math.cos(angle) * (y - center.y);
        // z = mPoints[mPoints.length ~/ 2].y +
        //     y * math.cos(mTransomAngle * math.pi / 180);
        break;
    }
    // mPoints.add(Point3D(x, y, z + math.cos(transomAngle) * (y - height)));

    // update corresponding point
    int secondPoint = numPoints() - chine - 1;

    double deltaX = mPoints[chine].x - x;

    mPoints[chine].x = x;
    mPoints[chine].y = y;
    mPoints[chine].z = z;

    x = mPoints[secondPoint].x + deltaX;

    mPoints[secondPoint].x = x;
    mPoints[secondPoint].y = y;
    mPoints[secondPoint].z = z;
  }

  // **************************************************
  List<Offset> getOffsets() {
    List<Offset> offsets = [];
    for (Point3D point in mPoints) {
      offsets.add(Offset(point.x, point.y));
    }

    // close the path for non-bow bulkheads
    if (mBulkheadType != BulkheadType.bow) {
      offsets.add(Offset(mPoints[0].x, mPoints[0].y));
    }
    return offsets;
  }

  // **************************************************
  void setNumChines(int numChines) {
    // Recreate points based on the new number of chines
    const int precision = 23; // Oversample rate for curve
    List<Point3D> curvePoints = [];
    int useableChines = numPoints() ~/ 2;
    if (!_mFlatBottomed) useableChines += 1;
    
    for (int ii=0; ii<useableChines; ii++) {
      double x = mPoints[ii].x;
      double y = mPoints[ii].y;
      double z = mPoints[ii].z;
      curvePoints.add(Point3D(x, y, z));
    }

    Spline shape = Spline(curvePoints, (numChines + 1) * precision);
    List<Point3D> points = shape.getPoints();

    List<Point3D> newPoints = [];
    int index = 0;
    for (int ii = 0; ii < numChines; ii++) {
      newPoints.add(points[index]);
      index += precision;
    }

    // Add the bottom point
    if (!_mFlatBottomed) {
      newPoints.add(mPoints[mPoints.length ~/ 2]);
    }

    // Add the other side points
    index = precision * numChines;
    for (int ii = 0; ii < numChines; ii++) {
      index -= precision;
      newPoints.add(Point3D(-points[index].x, points[index].y, points[index].z));
    }

    mPoints = newPoints;
  } 
}
