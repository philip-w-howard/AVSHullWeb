// ***************************************************************
// Part of the AVS Hull program
// Released under the MIT license.
// See https://github.com/philip-w-howard/AVSHullWeb for details
// ***************************************************************

import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'point_3d.dart';
import 'hull_math.dart';

enum BulkheadType { bow, vertical, transom }

class Bulkhead {
  List<Point3D> mPoints = [];
  BulkheadType mBulkheadType = BulkheadType.vertical;
  double mTransomAngle = 90;
  bool mFlatBottomed = false;
  bool mClosedTop = false;

  Bulkhead(int numChines, this.mBulkheadType) {
    mPoints = List.generate(numChines + 1, (_) => Point3D(0, 0, 0));
  }

  Bulkhead.copy(Bulkhead source) {
    mBulkheadType = source.mBulkheadType;
    mTransomAngle = source.mTransomAngle;
    mFlatBottomed = source.mFlatBottomed;
    mClosedTop = source.mClosedTop;
    mPoints = [...source.mPoints];
  }

  Bulkhead.round(double radius, double z, int numChines) {
    for (int ii = 0; ii <= 2 * numChines; ii++) {
      var angle = math.pi + ii * math.pi / 2 / numChines;
      var x = math.cos(angle) * radius;
      var y = math.sin(angle) * radius + radius;
      mPoints.add(Point3D(x, y, z));
    }
  }

  Bulkhead.fromPoints(List<Point3D> points, BulkheadType type) {
    // NOTE: Should be able to compute angle, flatbottomed, and closedTop based on points
    mBulkheadType = type;
    mPoints = [...points];
    mTransomAngle = 90;
    mFlatBottomed = false;
    mClosedTop = false;
  }

  Bulkhead.fromJson(Map<String, dynamic> json) {
    if (json['mPoints'] != null) {
      json['mPoints'].forEach((point) {
        mPoints.add(Point3D.fromJson(point));
      });
    }

    mBulkheadType = BulkheadType.values.firstWhere(
        (type) => type.toString() == 'BulkheadType.${json['mBulkheadType']}');
    mTransomAngle = json['mTransomAngle'] ?? 90;
    mFlatBottomed = json['mFlatBottomed'] ?? false;
    mClosedTop = json['mClosedTop'] ?? false;
  }
  int numPoints() {
    return mPoints.length;
  }

  Point3D point(int index) {
    return mPoints[index];
  }

  BulkheadType type() {
    return mBulkheadType;
  }

  void resize(double xRatio, double yRatio, double zRatio) {
    for (Point3D point in mPoints) {
      point.x *= xRatio;
      point.y *= yRatio;
      point.z *= zRatio;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'mPoints': mPoints,
      'mBulkheadType': mBulkheadType.toString().split('.').last,
      'mTransomAngle': mTransomAngle,
      'mFlatBottomed': mFlatBottomed,
      'mClosedTop': mClosedTop,
    };
  }

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

  void updatePoint(int chine, double x, double y, double z) {
    switch (mBulkheadType) {
      case BulkheadType.bow:
        x = mPoints[chine].x;
        break;
      case BulkheadType.vertical:
        z = mPoints[chine].z;
        break;
      case BulkheadType.transom:
        break;
    }

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
}
