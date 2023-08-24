// ***************************************************************
// Part of the AVS Hull program
// Released under the MIT license.
// See https://github.com/philip-w-howard/AVSHullWeb for details
// ***************************************************************

import 'package:flutter/material.dart';
import 'hull.dart';
import 'rotated_hull.dart';
import 'hull_painter.dart';

class DrawDetails {
  double? height;
  Offset dragStart = Offset.zero;
  bool rotatable = false;
  bool editable = false;
  int selectedBulkheadPoint = -1;
}

class HullWindow extends StatelessWidget {
  HullWindow(Hull hull, this._view, this._selector, this._updateScreen,
      {super.key}) {
    _myHull = RotatedHull(hull);
    _myHull.setView(_view);
    if (_view == HullView.rotated) {
      _myHull.setView(HullView.front);
      _myHull.rotateBy(10, 50, 10);
      _myHull.setDynamic();
    } else {
      _myHull.setStatic();
    }
    _painter = HullPainter(_myHull);
  }

  static const double _nearnessDistance = 10;
  final HullView _view;
  late final HullPainter _painter;
  late final RotatedHull _myHull;
  final void Function()? _selector;
  final void Function()? _updateScreen;
  final DrawDetails _drawDetails = DrawDetails();

  void setHeight(double height) {
    _drawDetails.height = height;
  }

  void setEditable() {
    _drawDetails.editable = true;
  }

  void setRotatable() {
    _drawDetails.rotatable = true;
  }

  void resetView() {
    bool static = _myHull.isStatic();
    _myHull.setDynamic();
    _myHull.setView(_view);

    if (static) _myHull.setStatic();

    _painter.redraw();
  }

  void setView(HullView view) {
    _myHull.setDynamic();
    if (view == HullView.rotated) {
      _myHull.setView(HullView.front);
      _myHull.rotateBy(10, 50, 10);
    } else {
      _myHull.setView(view);
    }
    _painter.redraw();
  }

  @override
  Widget build(BuildContext context) {
    _painter.setContext(context);
    return Expanded(
      child: Container(
          height: _drawDetails.height,
          color: Colors.yellow,
          // wrap CustomPaint in a GestureDetector to catch onDoubleTap
          child: GestureDetector(
            onDoubleTap: _selector,
            onTapDown: _tapDown,
            onTapUp: _tapUp,
            onPanStart: _panStart,
            onPanUpdate: _panUpdate,
            onPanEnd: _panEnd,
            child: CustomPaint(
              painter: _painter,
              size: Size.infinite,
            ),
          )),
    );
  }

  void _tapDown(TapDownDetails details) {
    print('tapDown');
    _drawDetails.dragStart = details.localPosition;

    // _drawDetails.movingHandle = false;
    // _drawDetails.selectedBulkheadPoint = -1;
    // if (_drawDetails.editable && .isEditable()) {
    //   _drawDetails.dragStart = details.localPosition;
    // }

    // if (_drawDetails.bulkheadIsSelected) {
    //   double x;
    //   double y;
    //   (x, y) = toHullCoords(_mouseX, _mouseY);
    //   _selectedBulkheadPoint = mHull.isNearBulkheadPoint(
    //       _selectedBulkhead, x, y, _nearnessDistance / _scale / 2);
    //   if (_selectedBulkheadPoint >= 0) {
    //     _movingHandle = true;
    //     _handleX = x;
    //     _handleY = y;
    //   }
    // } else {
    //   _selectedBulkheadPoint = -1;
    //   _movingHandle = false;
    // }
  }

  void _tapUp(TapUpDetails details) {
    print('tapUp ${_drawDetails.editable} ${_myHull.isEditable()}');
    bool needsRedraw = false;
    double x, y;
    double startX, startY;
    if (_drawDetails.editable && _myHull.isEditable()) {
      print('checking bulkheads');
      if (_drawDetails.dragStart.dx == details.localPosition.dx &&
          _drawDetails.dragStart.dy == details.localPosition.dy) {
        (x, y) = _painter.toHullCoords(_drawDetails.dragStart);
        _myHull.bulkheadIsSelected = false;

        for (int ii = 0; ii < _myHull.numBulkheads(); ii++) {
          if (_myHull.isNearBulkhead(
              ii, x, y, _nearnessDistance / _painter.scale())) {
            _myHull.bulkheadIsSelected = true;
            _myHull.selectedBulkhead = ii;
            _painter.redraw();
            print('selected bulkhead');
            break;
          }
        }
        print('done checking bulkheads');
      } else if (_myHull.movingHandle) {
        (startX, startY) = _painter.toHullCoords(_drawDetails.dragStart);
        (x, y) = _painter.toHullCoords(details.localPosition);
        _myHull.updateBaseHull(_myHull.selectedBulkhead,
            _drawDetails.selectedBulkheadPoint, startX - x, startY - y);
        needsRedraw = true;
        print('moving handle');
      }
    }

    _myHull.movingHandle = false;

    if (needsRedraw) _painter.redraw();
  }

  void _panStart(DragStartDetails details) {
    print('PanStart ${details.localPosition}');

    _myHull.movingHandle = false;
    _drawDetails.selectedBulkheadPoint = -1;
    _drawDetails.dragStart = details.localPosition;

    if (_myHull.bulkheadIsSelected) {
      double x;
      double y;
      (x, y) = _painter.toHullCoords(_drawDetails.dragStart);
      _drawDetails.selectedBulkheadPoint = _myHull.isNearBulkheadPoint(
          _myHull.selectedBulkhead,
          x,
          y,
          _nearnessDistance / _painter.scale() / 2);
      if (_drawDetails.selectedBulkheadPoint >= 0) {
        _myHull.movingHandle = true;
        _myHull.movingHandleX = x;
        _myHull.movingHandleY = y;
      }
    } else {
      _drawDetails.selectedBulkheadPoint = -1;
      _myHull.movingHandle = false;
    }
  }

  void _panUpdate(DragUpdateDetails details) {
    double x, y;
    //   if (mouse.down) {
    //     if (_movingHandle) {
    //       double x, y;
    //       (x, y) = toHullCoords(mouse.localPosition.dx, mouse.localPosition.dy);
    //       _handleX = x;
    //       _handleY = y;
    //       //mHull.updateBulkhead(
    //       //    _selectedBulkhead, _selectedBulkheadPoint, x, y, 0);
    //     } else {
    //       mHull.rotateBy(2, 1, 0.5);
    //     }
    //     //if (!needsRepaint) updatePainter();
    //     updatePainter();
    //   }

    if (_myHull.isEditable() && _myHull.movingHandle) {
      (x, y) = _painter.toHullCoords(details.localPosition);
      print('PanUpdate handle ${details.localPosition}');
      _myHull.movingHandleX = x;
      _myHull.movingHandleY = y;
      _painter.redraw();
    } else if (_drawDetails.rotatable) {
      print('PanUpdate ${details.localPosition}');
      _myHull.rotateBy(2, 1, 0.5);
      _painter.redraw();
    }
  }

  void _panEnd(DragEndDetails details) {
    double startX, startY;

    print('panEnd');
    if (_myHull.movingHandle) {
      (startX, startY) = _painter.toHullCoords(_drawDetails.dragStart);

      _myHull.updateBaseHull(
          _myHull.selectedBulkhead,
          _drawDetails.selectedBulkheadPoint,
          startX - _myHull.movingHandleX,
          startY - _myHull.movingHandleY);

      _myHull.movingHandle = false;
      print('panEnd $_updateScreen $_selector');
      _updateScreen!();
      //_painter.redraw();
    }
  }

  void redraw() {
    _painter.redraw();
  }
}
