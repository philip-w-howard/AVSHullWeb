// ***************************************************************
// Part of the AVS Hull program
// Released under the MIT license.
// See https://github.com/philip-w-howard/AVSHullWeb for details
// ***************************************************************

import 'point_3d.dart';
import 'hull_math.dart';
import 'bulkhead.dart';
import 'spline.dart';
import 'hull.dart';

enum HullView { front, side, top, rotated }

class RotatedHull extends Hull {
  final Hull mBaseHull;
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
  RotatedHull(this.mBaseHull) {
    _createFromBase();
  }

  void _createFromBase() {
    mBulkheads = List<Bulkhead>.from(mBaseHull.mBulkheads);

    // force a deep copy of chines.
    mChines = [];
    for (Spline spline in mBaseHull.mChines) {
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
    _rotateX += x;
    _rotateY += y;
    _rotateZ += z;

    rotateTo(_rotateX, _rotateY, _rotateZ);
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
        print('rotate to $_rotateX, $_rotateY, $_rotateZ');
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

    print('updateBaseHull $bulk, $chine, $deltaX, $deltaY');

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
    newX += mBaseHull.mBulkheads[bulk].mPoints[chine].x;
    newY += mBaseHull.mBulkheads[bulk].mPoints[chine].y;
    newZ += mBaseHull.mBulkheads[bulk].mPoints[chine].z;

    mBaseHull.updateBulkhead(bulk, chine, newX, newY, newZ);
  }
}
