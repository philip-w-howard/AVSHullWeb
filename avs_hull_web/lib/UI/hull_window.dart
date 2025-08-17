// ***************************************************************
// Part of the AVS Hull program
// Released under the MIT license.
// See https://github.com/philip-w-howard/AVSHullWeb for details
// ***************************************************************

import 'package:avs_hull_web/UI/input_helpers.dart';
import 'package:flutter/material.dart';
import '../models/hull.dart';
import '../models/rotated_hull.dart';
import 'hull_painter.dart';
import '../IO/hull_logger.dart';
import 'package:flutter/services.dart';

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
  late final XYZWidget xyz;

  HullWindow(Hull hull, HullView view, this._selector, this._updateScreen,
      {super.key, HullLogger? logger, required this.xyz}) {
    if (hull is RotatedHull) {
      _myHull = RotatedHull.copy(hull);
    } else {
      _myHull = RotatedHull(hull, hullLogger: logger);
    }

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
  final void Function(Hull? newHull)? _updateScreen;
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

  void resetView(Hull? newHull) {
    if (newHull != null) {
      //_myHull.updateFromHull(newHull);
    }
    
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
          return KeyboardListener(
            focusNode: _focusNode,
            onKeyEvent: (KeyEvent event) {
              _processKeypress(event);
            },
            child: Container(
              height: _drawDetails.height,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 1.0,
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
                onLongPressStart: (LongPressStartDetails details) {
                  _longPress(details, context);
                },
                child: MouseRegion(
                  onHover: _hover,
                  child: CustomPaint(
                    painter: _painter,
                    size: Size.infinite,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  void _longPress(LongPressStartDetails details, BuildContext context) {
    debugPrint('Long press at ${details.localPosition}');
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
            debugPrint('Display bulkhead edit menu');
            _showDeleteBulkheadDialog(context, ii);
            _painter.redraw();
            break;
          }
        }
      }    
    }
  }

  void _hover(PointerEvent details) {
    double rawX,rawY;
    double x,y,z;

    (rawX, rawY) = _painter.toHullCoords(details.localPosition);

    switch (_myHull.getView()) {
      case HullView.front:
        x = rawX - _myHull.size().x/2;
        y = _myHull.size().y - rawY;
        z = 0;
        break;
      case HullView.side:
        x = 0;
        y = _myHull.size().y - rawY;
        z = rawX;
        break;
      case HullView.top:
        x = rawY - _myHull.size().y/2;
        y = 0;
        z = rawX;
        break;
      default:
        x = 0;
        y = 0;
        z = 0;
        break;
    }
    xyz.setX(x);
    xyz.setY(y);
    xyz.setZ(z);   
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
      _updateScreen!(null);
    }
  }

  void redraw() {
    _painter.redraw();
  }

  void _processKeypress(KeyEvent event) {
    //print('keypress: ${event.logicalKey.keyLabel}');
    if (_hullLogger != null &&
        HardwareKeyboard.instance.isControlPressed &&
        event.character == 'z') {
      _myHull.popLog();
      _updateScreen!(null);
    }
    //print('Keypress $event');
  }

  // Show a dialog to confirm bulkhead deletion
Future<void> _showDeleteBulkheadDialog(BuildContext context, int bulkheadIndex) async {
  bool? shouldDelete = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Delete Bulkhead'),
        content: Text('Delete bulkhead #$bulkheadIndex?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );
  if (shouldDelete == true) {
    _myHull.deleteBulkhead(bulkheadIndex);
    //_myHull.rotateTo(0, 0, 0);
    _updateScreen!(_myHull);
  }
}

}
