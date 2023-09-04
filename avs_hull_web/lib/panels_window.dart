// ***************************************************************
// Part of the AVS Hull program
// Released under the MIT license.
// See https://github.com/philip-w-howard/AVSHullWeb for details
// ***************************************************************

import 'package:flutter/material.dart';
import 'panel_painter.dart';
import 'panel.dart';

class PanelsDrawDetails {
  int panelIndex = -1; // -1 means "none"
}

class PanelsWindow extends StatelessWidget {
  PanelsWindow(this._panels, {super.key}) {
    _painter = PanelPainter(_panels);
  }

  late final PanelPainter _painter;
  final List<Panel> _panels;
  final PanelsDrawDetails _drawDetails = PanelsDrawDetails();
  late final _context;

  @override
  Widget build(BuildContext context) {
    _context = context;
    _painter.setContext(context);
    return Expanded(
        child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black, // Border color
                width: 1.0, // Border width
              ),
              color: Colors.yellow,
            ),
            child: GestureDetector(
              //onDoubleTap: _selector,
              onTapDown: _tapDown,
              onTapUp: _tapUp,
              onLongPressStart: _longPress,
              onPanStart: _panStart,
              onPanUpdate: _panUpdate,
              onPanEnd: _panEnd,
              child: CustomPaint(
                painter: _painter,
                size: Size.infinite,
              ),
            )));
    ;
  }

  void _tapDown(TapDownDetails details) {
    // print('tapDown');
  }

  void _tapUp(TapUpDetails details) {
    // bool needsRedraw = false;
    // double x, y;
    // double startX, startY;
    // if (_drawDetails.editable && _myHull.isEditable()) {
    //   if (_drawDetails.dragStart.dx == details.localPosition.dx &&
    //       _drawDetails.dragStart.dy == details.localPosition.dy) {
    //     (x, y) = _painter.toHullCoords(_drawDetails.dragStart);
    //     _myHull.bulkheadIsSelected = false;

    //     for (int ii = 0; ii < _myHull.numBulkheads(); ii++) {
    //       if (_myHull.isNearBulkhead(
    //           ii, x, y, _nearnessDistance / _painter.scale())) {
    //         _myHull.bulkheadIsSelected = true;
    //         _myHull.selectedBulkhead = ii;
    //         _painter.redraw();
    //         break;
    //       }
    //     }
    //   } else if (_myHull.movingHandle) {
    //     (startX, startY) = _painter.toHullCoords(_drawDetails.dragStart);
    //     (x, y) = _painter.toHullCoords(details.localPosition);
    //     _myHull.updateBaseHull(_myHull.selectedBulkhead,
    //         _drawDetails.selectedBulkheadPoint, startX - x, startY - y);
    //     needsRedraw = true;
    //   }
    // }

    // if (needsRedraw) _painter.redraw();
  }

  void _longPress(LongPressStartDetails details) {
    print('LongPress');
    int selectedPanel = _painter.clickInPanel(details.localPosition);

    if (selectedPanel >= 0) {
      final RenderBox overlay =
          Overlay.of(_context).context.findRenderObject() as RenderBox;

      // Calculate the position for the context menu
      final Offset position = overlay.localToGlobal(details.globalPosition);

      // Show the context menu
      showMenu<String>(
        context: _context,
        position: RelativeRect.fromLTRB(
          position.dx,
          position.dy,
          position.dx + 1.0,
          position.dy + 1.0,
        ),
        items: [
          const PopupMenuItem<String>(
            value: 'Duplicate',
            child: Text('Duplicate'),
          ),
          const PopupMenuItem<String>(
            value: 'Horizontal',
            child: Text('Flip Horizontally'),
          ),
          const PopupMenuItem<String>(
            value: 'Veritcal',
            child: Text('Flip Vertically'),
          ),
        ],
      ).then((value) {
        if (value != null) {
          // Handle the selected item
          print('Selected: $value');

          if (value == 'Veritcal') {
            print('flipping vertically');
            _panels[selectedPanel].flipVertically();
            _painter.redraw();
          } else if (value == 'Horizontal') {
            print('flipping horizontally');
            _panels[selectedPanel].flipHorizontally();
            _painter.redraw();
          } else if (value == 'Duplicate') {
            print('Duplicating');
            _panels.add(Panel.copy(_panels[selectedPanel]));
            _painter.redraw();
            print('There are ${_panels.length} panels');
          }
        }
      });
    }
  }

  void _panStart(DragStartDetails details) {
    int panelIndex = _painter.clickInPanel(details.localPosition);

    _drawDetails.panelIndex = panelIndex;
  }

  void _panUpdate(DragUpdateDetails details) {
    if (_drawDetails.panelIndex >= 0) {
      _panels[_drawDetails.panelIndex].moveBy(
          details.delta.dx / _painter.scale(),
          details.delta.dy / _painter.scale());
      _painter.redraw();
    }
  }

  void _panEnd(DragEndDetails details) {
    //   double startX, startY;

    //   if (_myHull.movingHandle) {
    //     (startX, startY) = _painter.toHullCoords(_drawDetails.dragStart);

    //     _myHull.updateBaseHull(
    //         _myHull.selectedBulkhead,
    //         _drawDetails.selectedBulkheadPoint,
    //         startX - _myHull.movingHandleX,
    //         startY - _myHull.movingHandleY);

    //     _myHull.movingHandle = false;
    //     _updateScreen!();
    //   }
    // }
  }

  void updateLayout(int numX, int numY, double sizeX, double sizeY) {
    _painter.updateLayout(numX, numY, sizeX, sizeY);
    _painter.redraw();
  }
}
