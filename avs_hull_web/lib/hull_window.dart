// ***************************************************************
// Part of the AVS Hull program
// Released under the MIT license.
// See https://github.com/philip-w-howard/AVSHullWeb for details
// ***************************************************************

import 'package:flutter/material.dart';
import 'hull.dart';
import 'rotated_hull.dart';
import 'hull_painter.dart';
import 'hull_logger.dart';

class HullDrawDetails {
  double? height;
  Offset dragStart = Offset.zero;
  bool rotatable = false;
  bool editable = false;
  int selectedBulkheadPoint = -1;
  bool rotateModeA = true;
  Size size = Size.infinite;
}

class HullWindow extends StatelessWidget {
  static const double _rotateScale = 0.10;
  static const double _nearnessDistance = 20;

  HullWindow(Hull hull, HullView view, this._selector, this._updateScreen,
      {super.key, HullLogger? logger}) {
    _myHull = RotatedHull(hull, hullLogger: logger);
    _hullLogger = logger;
    _myHull.setView(view);
    if (view == HullView.rotated) {
      _myHull.rotateTo(10, 50, 190);
      _myHull.setDynamic();
    } else {
      _myHull.setStatic();
    }
    _painter = HullPainter(_myHull);
  }

  late final HullPainter _painter;
  late final RotatedHull _myHull;
  late final HullLogger? _hullLogger;
  final void Function()? _selector;
  final void Function()? _updateScreen;
  final HullDrawDetails _drawDetails = HullDrawDetails();
  final FocusNode _focusNode = FocusNode();

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
    _myHull.setView(_myHull.getView());
    if (static) _myHull.setStatic();

    _painter.redraw();
  }

  void setView(HullView view) {
    _myHull.setDynamic();
    if (view == HullView.rotated) {
      _myHull.rotateTo(10, 50, 190);
    } else {
      _myHull.setView(view);
    }
    _painter.redraw();
  }

  @override
  Widget build(BuildContext context) {
    _painter.setContext(context);
    if (_hullLogger != null) _focusNode.requestFocus();
    return Expanded(
      child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        _drawDetails.size = constraints.biggest;
        return RawKeyboardListener(
            focusNode: _focusNode,
            onKey: _processKeypress,
            child: Container(
                height: _drawDetails.height,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black, // Border color
                    width: 1.0, // Border width
                  ),
                  color: Colors.yellow,
                ),
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
                )));
      }),
    );
  }

  void _tapDown(TapDownDetails details) {
    _drawDetails.dragStart = details.localPosition;
  }

  void _tapUp(TapUpDetails details) {
    bool needsRedraw = false;
    double x, y;
    if (_drawDetails.editable && _myHull.isEditable()) {
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
            break;
          }
        }
      } else if (_myHull.movingHandle) {
        _myHull.updateBaseHull(
            _myHull.selectedBulkhead, _drawDetails.selectedBulkheadPoint, 0, 0);
        needsRedraw = true;
      }
    }

    _myHull.movingHandle = false;

    if (needsRedraw) _painter.redraw();
  }

  void _panStart(DragStartDetails details) {
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
          _nearnessDistance / _painter.scale() / 1.5);
      if (_drawDetails.selectedBulkheadPoint >= 0) {
        _myHull.movingHandle = true;
        _myHull.movingHandleX = x;
        _myHull.movingHandleY = y;
      } else {
        _myHull.movingHandle = false;
      }
    } else {
      _drawDetails.selectedBulkheadPoint = -1;
      _myHull.movingHandle = false;

      // determine rotation style
      double width = _drawDetails.size.width;
      if (width == 0) width = details.localPosition.dx * 2;
      double locRatio = details.localPosition.dx / _drawDetails.size.width;

      _drawDetails.rotateModeA = (locRatio < 0.25 || locRatio > .75);
    }
  }

  void _panUpdate(DragUpdateDetails details) {
    double x, y;

    if (_myHull.isEditable() && _myHull.movingHandle) {
      (x, y) = _painter.toHullCoords(details.localPosition);
      _myHull.movingHandleX = x;
      _myHull.movingHandleY = y;
      _painter.redraw();
    } else if (_drawDetails.rotatable) {
      double rotateX = details.delta.dx * _rotateScale;
      double rotateY = details.delta.dy * _rotateScale;
      if (_drawDetails.rotateModeA) {
        if (details.localPosition.dx < _drawDetails.size.width / 2) {
          rotateY = -rotateY;
        }
        _myHull.rotateBy(0, rotateX, rotateY);
      } else {
        _myHull.rotateBy(rotateY, rotateX, 0);
      }
      _painter.redraw();
    }
  }

  void _panEnd(DragEndDetails details) {
    double startX, startY;

    if (_myHull.movingHandle) {
      (startX, startY) = _painter.toHullCoords(_drawDetails.dragStart);

      _myHull.updateBaseHull(
          _myHull.selectedBulkhead,
          _drawDetails.selectedBulkheadPoint,
          startX - _myHull.movingHandleX,
          startY - _myHull.movingHandleY);

      _myHull.movingHandle = false;
      _updateScreen!();
    }
  }

  void redraw() {
    _painter.redraw();
  }

  void _processKeypress(RawKeyEvent event) {
    //print('keypress: ${event.logicalKey.keyLabel}');
    if (_hullLogger != null &&
        event.isControlPressed &&
        event.character == 'z') {
      _myHull.popLog();
      _updateScreen!();
    }
    //print('Keypress $event');
  }
}
