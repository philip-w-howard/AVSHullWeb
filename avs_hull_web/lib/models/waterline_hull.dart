// ***************************************************************
// Part of the AVS Hull program
// Released under the MIT license.
// See https://github.com/philip-w-howard/AVSHullWeb for details
// ***************************************************************

import 'package:flutter/material.dart';
import '../geometry/point_3d.dart';
import '../geometry/hull_math.dart';
import '../geometry/spline.dart';
import 'bulkhead.dart';
import 'hull.dart';
import 'rotated_hull.dart';

class WaterlineParams {
  double heightIncrement = 0.25;  // Height increment for waterlines
  double lengthIncrement = 0.25;  // Length increment for waterlines
  double weight = 200;            // Weight of the loaded hull in pounds   
  double waterDensity = 62.4;     // lb/ft^3
  double heelAngle = 0;           // Angle of heel in degrees
  double pitchAngle = 0;          // Angle of pitch in degrees
  bool showAllWaterlines = false;
}

class WaterlineHull extends Hull {
  final WaterlineParams _params;
  List<List<Point3D>> _waterlines = [];
  HullView _view = HullView.side;

  //*****************************************************************
  WaterlineHull(Hull baseHull, this._params) : super.copy(baseHull) {
    // super constructed the hull for us.
    _generateWaterlines();
  }
  //*****************************************************************
  WaterlineHull.copy(WaterlineHull source)
      : _params = source._params,
        _waterlines = source._waterlines.map((wl) => wl.map((p) => Point3D(p.x, p.y, p.z)).toList()).toList(),
        super.copy(source);

  //*****************************************************************
  bool _takingOnWater(List<Spline> chines, double height, double length) {
    Point3D? point1 = interpolateToZ(chines[0].getPoints(), length);
    if (point1 != null && point1.y < height) return true; // Left point is below the waterline

    Point3D? point2 = interpolateToZ(chines[chines.length-1].getPoints(), length);
    if (point2 != null && point2.y < height) return true; // Right point is below the waterline

    return false; // No points below the waterline
  }
  //*****************************************************************
  Point3D? _findWaterlinePoint(List<Spline> chines, double height, double length, bool doLeft)
  {
    int start, end, increment;
    int index;
    Point3D? prevPoint, currPoint;

    if (doLeft)
    {
        start = 0;
        end = chines.length;
        increment = 1;
    }
    else
    {
        start = chines.length - 1;
        end = -1;
        increment = -1;
    }

    index = start;
    prevPoint = null;
    currPoint = null;

    // Loop through looking for one point below and and adjacent one above the height.
    while (index != end)
    {
        if (currPoint != null) prevPoint = currPoint;

        currPoint = interpolateToZ(chines[index].getPoints(), length);

        if (currPoint != null && prevPoint != null)
        {
            // If we have a point above and one below, we can interpolate
            if ((currPoint.y >= height && prevPoint.y <= height) ||
                (currPoint.y <= height && prevPoint.y >= height))
            {
                return interpolateBetween(prevPoint, currPoint, height);
            }
        }
        index += increment;
    }

    return null;

  }
  //*****************************************************************
  void setView(HullView view) {
    _view = view;
  }
  //*****************************************************************
  HullView getView() {
    return _view;
  }
  //*****************************************************************
  List<Point3D>? _gererateWaterline(List<Spline> chines, double height, double lenghtIncrement) {
    List<Point3D> leftPoints = [];
    List<Point3D> rightPoints = [];
    Point3D? point;

    Point3D hullSize = size();
    Point3D hullMin = min();

    double length = hullMin.z;

    while (length < hullSize.z) {
      if (_takingOnWater(chines, height, length)) return null;

      // Find the left point
      point = _findWaterlinePoint(chines, height, length, true);
      if (point != null) {
        leftPoints.add(point);
      }

      // Find the right point
      point = _findWaterlinePoint(chines, height, length, false);
      if (point != null) {
        rightPoints.add(point);
      }

      length += lenghtIncrement;
    }

    // Now we have the left and right points, we need to join them up.
    List<Point3D> points = [];  
    points.addAll(leftPoints);
    points.addAll(rightPoints.reversed);

    return points;
  }
  //*****************************************************************
  void _generateWaterlines() {
    double heightIncrement = _params.heightIncrement;
    double lengthIncrement = _params.lengthIncrement;
    List<Spline> chines = mChines;

    Point3D hullSize = size();
    Point3D hullMin = min();

    double height = hullMin.y;
    double heightMax = height + hullSize.y;

    _waterlines = []; // Clear existing waterlines

    while (height <= heightMax) {
      // Generate the waterline points
      List<Point3D>? points = _gererateWaterline(chines, height, lengthIncrement);
      if (points == null) return ; // This implies we started taking on water

      if (points.isNotEmpty) {
        _waterlines.add(points);
      }

      height += heightIncrement;
    }

    return;
  }

  bool hasWaterlines() {
    return true; // This hull has waterlines
  }

  int getWaterlineCount() {
    return _waterlines.length;
  }

  @override bool isEditable() {
    return false; // Waterline hulls are not editable
  }

  // **************************************************
  List<Offset> getWaterlineOffsets(int index) {
    List<Offset> offsets = [];
    if (index < 0 || index >= _waterlines.length) {
      return offsets; // Return empty if index is out of bounds
    }
    for (Point3D point in _waterlines[index]) {
      offsets.add(Offset(point.x, point.y));
    }
    
    return offsets;
  }
  // **************************************************
  List<Offset> getBulkheadOffsets(Bulkhead bulkhead) {
    List<Offset> offsets = [];
    for (Point3D point in bulkhead.mPoints) {
      if (_view == HullView.front) {
        offsets.add(Offset(point.x, -point.y)); 
      } else if (_view == HullView.side) {
        offsets.add(Offset(point.z, -point.y)); 
      } else if (_view == HullView.top) {
        offsets.add(Offset(point.z, point.x)); 
      }
    }

    // // close the path for non-bow bulkheads
    // if (bulkhead.mBulkheadType != BulkheadType.bow) {
    //   offsets.add(Offset(bulkhead.mPoints[0].x, bulkhead.mPoints[0].y));
    // }
    return offsets;
  }
  // **************************************************
  List<Offset> getSplinesOffsets(Spline spline) {
    List<Offset> offsets = [];
    for (Point3D point in spline.getPoints()) {
      if (_view == HullView.front) {
        offsets.add(Offset(point.x, -point.y));
      } else if (_view == HullView.side) {
        offsets.add(Offset(point.z, -point.y));
      } else if (_view == HullView.top) {
        offsets.add(Offset(point.z, point.x));
      }
    }
    // Optionally close the path if needed (not always required for splines)
    return offsets;
  }

}