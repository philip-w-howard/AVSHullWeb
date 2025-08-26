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
import 'rotated_hull.dart';

class WaterlineParams {
  double heightIncrement = 0.25;  // Height increment for waterlines
  double lengthIncrement = 0.25;  // Length increment for waterlines
  double weight = 200;            // Weight of the loaded hull in pounds   
  double waterDensity = 62.4;     // lb/ft^3
  double heelAngle = 0;           // Angle of heel in degrees
  double pitchAngle = 0;          // Angle of pitch in degrees
  bool showAllWaterlines = false;
  HullView view = HullView.top;

  // Hull params computed based on WaterlineParams
  double freeboard = 0;
  double centroidX = 0;
  double centroidY = 0;
  double centroidZ = 0;
  double rightingMoment = 0;
}

class WaterlineHull extends RotatedHull {
  final WaterlineParams _params;
  List<List<Point3D>> _waterlines = [];

  //*****************************************************************
  WaterlineHull(this._params) : 
    super.copy(RotatedHull()) {
    // super constructed the hull for us.
    rotateTo(_params.pitchAngle, 0, _params.heelAngle);
    _generateWaterlines();
    setView(_params.view);
  }
  //*****************************************************************
  WaterlineHull.copy(WaterlineHull super.source)
      : _params = source._params,
        _waterlines = source._waterlines.map((wl) => wl.map((p) => Point3D(p.x, p.y, p.z)).toList()).toList(),
        super.copy();

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

    // Loop through looking for one point below and an adjacent one above the height.
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
              Point3D point = interpolateBetween(prevPoint, currPoint, height);
              return point;
          }
        }
        index += increment;
    }

    return null;

  }
  //*****************************************************************
  Point3D? getBulkheadPoint(Bulkhead bulkhead, double height, bool doLeft) {
    Point3D? point;

      // Find the location of the height on bulkheads[0] and bulkheads[bulkheads.length-1] 
    if (bulkhead.mBulkheadType == BulkheadType.bow) {
      // left and right point are the same for bow bulkhead
      for (int ii=0; ii<bulkhead.numPoints() - 1; ii++) {
        if (bulkhead.mPoints[ii].y <= height &&
            bulkhead.mPoints[ii + 1].y >= height) {
          point = interpolateBetween(
              bulkhead.mPoints[ii], bulkhead.mPoints[ii + 1], height);
          
          return point;
        }
      }
    } else if (doLeft) {
      for (int ii=0; ii<bulkhead.numPoints() - 1; ii++) {
        if (bulkhead.mPoints[ii].y >= height &&
            bulkhead.mPoints[ii + 1].y <= height) {
          point = interpolateBetween(
              bulkhead.mPoints[ii], bulkhead.mPoints[ii + 1], height);
          return point;
        }
      }
    } else {
      // Find the right point
      for (int ii=bulkhead.numPoints() - 2; ii>=0; ii--) {
        if (bulkhead.mPoints[ii].y <= height &&
            bulkhead.mPoints[ii + 1].y >= height) {
          point = interpolateBetween(
              bulkhead.mPoints[ii], bulkhead.mPoints[ii + 1], height);
          
          return point;
        }
      }
    }
    return point;
  }
  //*****************************************************************
  List<Point3D>? _gererateWaterline(List<Bulkhead> bulkheads, List<Spline> chines, double height, double lenghtIncrement) {
    List<Point3D> leftPoints = [];
    List<Point3D> rightPoints = [];
    Point3D? point;

    Point3D hullSize = size();
    Point3D hullMin = super.min();

    point = getBulkheadPoint(bulkheads[0], height, true);
    if (point != null) leftPoints.add(point);
    
    point = getBulkheadPoint(bulkheads[0], height, false);
    if (point != null) rightPoints.add(point);
    
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

    point = getBulkheadPoint(bulkheads[bulkheads.length-1], height, true);
    if (point != null) leftPoints.add(point);

    point = getBulkheadPoint(bulkheads[bulkheads.length-1], height, false);
    if (point != null) rightPoints.add(point); 

    // Now we have the left and right points, we need to join them up.
    List<Point3D> points = [];  
    points.addAll(leftPoints);
    points.addAll(rightPoints.reversed);

    return points;
  }
  //*****************************************************************
  void _generateWaterlines() {
    double weight = 0;
    double heightIncrement = _params.heightIncrement;
    double lengthIncrement = _params.lengthIncrement;

    double sumArea = 0;
    double sumMomentX = 0;
    double sumMomentY = 0;
    double sumMomentZ = 0;
	
	  bool takingOnWater = false;
    
    Point3D hullSize = size();
    Point3D hullMin = min();
    Point3D centerline = Point3D(hullSize.x / 2, hullMin.y / 2, hullSize.z / 2);

    double height = hullMin.y;
	  double waterlineHeight = hullMin.y;

    _waterlines = []; // Clear existing waterlines

    while (!takingOnWater) {
      // Generate the waterline points
      List<Point3D>? points = _gererateWaterline(mBulkheads, mChines, height, lengthIncrement);
      if (points == null) { // This implies we started taking on water
        takingOnWater = true;
	    } else {
	      if (weight < _params.weight) {
          AreaData areaData = computeFlatArea(points, centerline);
          if (areaData.area > 0) {
            double sliceWeight = areaData.area * heightIncrement * _params.waterDensity ;
            sliceWeight /= (12*12*12); // Convert to cubic feet
            weight += sliceWeight;
          } 

          if (points.isNotEmpty && weight < _params.weight) {
            sumArea += areaData.area;
            sumMomentX += areaData.centroidX * areaData.area;
            sumMomentY += areaData.area * (height - centerline.y);
            sumMomentZ += areaData.centroidZ * areaData.area;
            _waterlines.add(points);

      		  waterlineHeight = height;
          }
        }

        height += heightIncrement;
      }
    }
    if (waterlineHeight < height - heightIncrement)
    {
      _params.freeboard = height - waterlineHeight;
      _params.centroidX = sumMomentX / sumArea;
      _params.centroidY = sumMomentY / sumArea;
      _params.centroidZ = sumMomentZ / sumArea;
      _params.rightingMoment = _params.centroidX / 12 * weight; // convert inches to feet
    }
    else {
      _waterlines = [];
      _params.freeboard = waterlineHeight - height;
      _params.centroidX = 0;
      _params.centroidY = 0;
      _params.centroidZ = 0;
      _params.rightingMoment = 0;
    }
    return;
  }

  int getWaterlineCount() {
    if (_params.showAllWaterlines) {
      return _waterlines.length;
    } else if (_waterlines.isNotEmpty) {    
      return 1;
    } else {
      return 0;
    }
  }

  // **************************************************
  List<Offset> getWaterlineOffsets(int index) {
    List<Offset> offsets = [];
    if (_params.showAllWaterlines) {
      if (index < 0 || index >= _waterlines.length) {
        return offsets; // Return empty if index is out of bounds
      }
      for (Point3D point in _waterlines[index]) {
        if (_params.view == HullView.front) {
          offsets.add(Offset(point.x, -point.y)); 
        } else if (_params.view == HullView.side) {
          offsets.add(Offset(point.z, -point.y)); 
        } else if (_params.view == HullView.top) {
          offsets.add(Offset(point.z, point.x)); 
        }
      }
    } else if (_waterlines.isNotEmpty) {
      for (Point3D point in _waterlines[_waterlines.length - 1]) {
        if (_params.view == HullView.front) {
          offsets.add(Offset(point.x, -point.y)); 
        } else if (_params.view == HullView.side) {
          offsets.add(Offset(point.z, -point.y)); 
        } else if (_params.view == HullView.top) {
          offsets.add(Offset(point.z, point.x)); 
        }
      }
    }
    return offsets;
  }
  // **************************************************
  List<Offset> getBulkheadOffsets(Bulkhead bulkhead) {
    List<Offset> offsets = [];
    for (Point3D point in bulkhead.mPoints) {
      if (_params.view == HullView.front) {
        offsets.add(Offset(point.x, -point.y)); 
      } else if (_params.view == HullView.side) {
        offsets.add(Offset(point.z, -point.y)); 
      } else if (_params.view == HullView.top) {
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
      if (_params.view == HullView.front) {
        offsets.add(Offset(point.x, -point.y));
      } else if (_params.view == HullView.side) {
        offsets.add(Offset(point.z, -point.y));
      } else if (_params.view == HullView.top) {
        offsets.add(Offset(point.z, point.x));
      }
    }
    // Optionally close the path if needed (not always required for splines)
    return offsets;
  }
  //*****************************************************************
  @override void setView(HullView view) {
    _params.view = view;
  }
  //*****************************************************************
  @override HullView getView() {
    return _params.view;
  }
}