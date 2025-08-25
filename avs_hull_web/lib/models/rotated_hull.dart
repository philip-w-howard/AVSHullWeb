// ***************************************************************
// Part of the AVS Hull program
// Released under the MIT license.
// See https://github.com/philip-w-howard/AVSHullWeb for details
// ***************************************************************

import '../geometry/point_3d.dart';
import '../geometry/hull_math.dart';
import 'bulkhead.dart';
import '../geometry/spline.dart';
import 'hull.dart';
import 'hull_manager.dart';
import '../IO/hull_logger.dart';

enum HullView { front, side, top, rotated }

class RotatedHull extends Hull {
  RotatedHull.copy(RotatedHull source)
      : hullLogger = source.hullLogger,
        _mView = source._mView,
        _static = source._static,
        _rotateX = source._rotateX,
        _rotateY = source._rotateY,
        _rotateZ = source._rotateZ {
    // Copy Hull fields
    name = source.name;
    timeUpdated = source.timeUpdated;
    timeSaved = source.timeSaved;
    mBulkheads = source.mBulkheads.map((b) => Bulkhead.copy(b)).toList();
    mChines = source.mChines.map((s) => Spline.copy(s)).toList();
    // Copy editing state
    movingHandle = source.movingHandle;
    movingHandleX = source.movingHandleX;
    movingHandleY = source.movingHandleY;
    bulkheadIsSelected = source.bulkheadIsSelected;
    selectedBulkhead = source.selectedBulkhead;
  }
  final HullLogger? hullLogger;
  HullView _mView = HullView.rotated;
  bool _static = false;
  double _rotateX = 0;
  double _rotateY = 0;
  double _rotateZ = 0;

  // the following are used when the RotatedHull is being edited
  bool movingHandle = false;
  double movingHandleX = 0;
  double movingHandleY = 0;
  bool bulkheadIsSelected = false;
  int selectedBulkhead = -1;

  // move code to createFromBase() method
  RotatedHull({this.hullLogger}) {
    _createFromBase();
  }

  void _createFromBase() {
    mBulkheads = List<Bulkhead>.from(HullManager().hull.mBulkheads);

    // force a deep copy of chines.
    mChines = [];
    for (Spline spline in HullManager().hull.mChines) {
      mChines.add(Spline.copy(spline));
    }
  }

  void rotateTo(double x, double y, double z) {
    if (!_static) {
      _rotateX = x;
      _rotateY = y;
      _rotateZ = z;

      List<List<double>> rotate = makeRotator(x, y, z);
      List<Point3D> points = [];

      _mView = HullView.rotated;

      _createFromBase();

      for (int ii = 0; ii < numBulkheads(); ii++) {
        points = rotatePoints(getBulkhead(ii).mPoints, rotate);

        mBulkheads[ii] =
            Bulkhead.fromPoints(points, mBulkheads[ii].mBulkheadType);
      }

      for (int ii = 0; ii < mChines.length; ii++) {
        mChines[ii].rotate(rotate);
      }
      _zero();
    }
  }

  void rotateBy(double x, double y, double z) {
    if (!_static) {
      _rotateX = x;
      _rotateY = y;
      _rotateZ = z;

      List<List<double>> rotate = makeRotator(x, y, z);
      List<Point3D> points = [];

      _mView = HullView.rotated;

      for (int ii = 0; ii < numBulkheads(); ii++) {
        points = rotatePoints(getBulkhead(ii).mPoints, rotate);

        mBulkheads[ii] =
            Bulkhead.fromPoints(points, mBulkheads[ii].mBulkheadType);
      }

      for (int ii = 0; ii < mChines.length; ii++) {
        mChines[ii].rotate(rotate);
      }
      _zero();
    }
  }

  void _zero() {
    Point3D minSize = min();
    minSize.x = -minSize.x;
    minSize.y = -minSize.y;
    minSize.z = -minSize.z;

    shift(minSize);
  }

  void setView(HullView view) {
    switch (view) {
      case HullView.front:
        rotateTo(0, 0, 180);
        _mView = view;
        break;
      case HullView.side:
        rotateTo(0, 90, 180);
        _mView = view;
        break;
      case HullView.top:
        rotateTo(0, 90, 90);
        _mView = view;
        break;
      default:
        rotateTo(_rotateX, _rotateY, _rotateZ);
        break;
    }
  }

  HullView getView() {
    return _mView;
  }

  void setStatic() {
    _static = true;
  }

  void setDynamic() {
    _static = false;
  }

  bool isEditable() {
    return !_static && _mView != HullView.rotated;
  }

  bool isStatic() {
    return _static;
  }

  void updateBaseHull(int bulk, int chine, double deltaX, double deltaY) {
    double newX = 0;
    double newY = 0;
    double newZ = 0;

    if (deltaX != 0 || deltaY != 0) hullLogger?.logHull(HullManager().hull);

    switch (_mView) {
      case HullView.front:
        newX = deltaX;
        newY = deltaY;
        newZ = 0;
        break;
      case HullView.top:
        newX = -deltaY;
        newY = 0;
        newZ = -deltaX;
        break;
      case HullView.side:
        newX = 0;
        newY = deltaY;
        newZ = -deltaX;
        break;
      case HullView.rotated:
        // Can't update a rotated hull
        break;
    }
    newX += HullManager().hull.mBulkheads[bulk].mPoints[chine].x;
    newY += HullManager().hull.mBulkheads[bulk].mPoints[chine].y;
    newZ += HullManager().hull.mBulkheads[bulk].mPoints[chine].z;

    HullManager().hull.updateBulkhead(bulk, chine, newX, newY, newZ);
    HullManager().hull.timeUpdated = DateTime.now();
  }

  void popLog() {
    Hull? previous;
    previous = hullLogger?.popLog();

    if (previous != null) HullManager().hull.updateFromHull(previous);
    _createFromBase();
  }
}
