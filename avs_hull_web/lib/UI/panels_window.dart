// ***************************************************************
// Part of the AVS Hull program
// Released under the MIT license.
// See https://github.com/philip-w-howard/AVSHullWeb for details
// ***************************************************************

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../models/hull_manager.dart';
import 'panel_painter.dart';
import '../models/panel.dart';

class PanelsDrawDetails {
  int panelIndex = -1; // -1 means "none"
  int panIndex = -1; // -1 means "none"
}

class PanelsWindow extends StatelessWidget {
  late final PanelPainter _painter;
  final PanelsDrawDetails _drawDetails = PanelsDrawDetails();
  final FocusNode _focusNode = FocusNode();

  PanelsWindow({super.key}) {
    _painter = PanelPainter();
  }

  @override
  Widget build(BuildContext context) {
    _focusNode.requestFocus();
    _painter.setContext(context);
    return KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: (KeyEvent event) {
          _processKeypress(event);
        },
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
            onLongPressStart: (LongPressStartDetails details) {
              _longPress(details, context);
            },
            onPanStart: _panStart,
            onPanUpdate: _panUpdate,
            onPanEnd: _panEnd,
            child: CustomPaint(
              painter: _painter,
              size: Size.infinite,
            ),
          ),
        ),
      );
  }

  void _tapDown(TapDownDetails details) {}

  void _tapUp(TapUpDetails details) {
    _drawDetails.panelIndex = _painter.clickInPanel(details.localPosition);
    _painter.selectedPanel(_drawDetails.panelIndex);
    _painter.redraw();
  }

  void _longPress(LongPressStartDetails details, BuildContext context) {
    int selectedPanel = _painter.clickInPanel(details.localPosition);

    if (selectedPanel >= 0) {
      _orientPanel(details, context, selectedPanel);
    }
  }

  void _panStart(DragStartDetails details) {
    _drawDetails.panIndex = _painter.clickInPanel(details.localPosition);
  }

  void _panUpdate(DragUpdateDetails details) {
    if (_drawDetails.panelIndex >= 0) {
      if (_drawDetails.panelIndex == _drawDetails.panIndex) {
        HullManager().logLayout();
        HullManager().panelLayout.moveBy(
            _drawDetails.panelIndex,
            details.delta.dx / _painter.scale(),
            details.delta.dy / _painter.scale());
      } else {
        double angle = details.delta.dx / 125;
        HullManager().logLayout();
        HullManager().panelLayout.rotate(_drawDetails.panelIndex, angle);
      }
      _painter.redraw();
    }
  }

  void _panEnd(DragEndDetails details) {
    // all functionality happens in _panUpdate();
  }

  void redraw() {
    debugPrint('redraw panels');
    _painter.redraw();
  }

  void updateLayout() {
    _painter.updateLayout();
    _painter.redraw();
  }

  void _orientPanel(
      LongPressStartDetails details, BuildContext context, int selectedPanel) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    // Calculate the position for the context menu
    final Offset position = overlay.localToGlobal(details.globalPosition);

    // Show the context menu
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1.0,
        position.dy + 1.0,
      ),
      items: [
        const PopupMenuItem<String>(
          value: 'Duplicate',
          child: Text('Duplicate panel'),
        ),
        const PopupMenuItem<String>(
          value: 'Delete',
          child: Text('Delete panel'),
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
        if (value == 'Veritcal') {
          HullManager().logLayout();
          HullManager().panelLayout.flipVertically(selectedPanel);
          _painter.redraw();
        } else if (value == 'Horizontal') {
          HullManager().logLayout();
          HullManager().panelLayout.flipHorizontally(selectedPanel);
          _painter.redraw();
        } else if (value == 'Duplicate') {
          HullManager().logLayout();
          HullManager().panelLayout.addPanel(Panel.copy(HullManager().panelLayout.get(selectedPanel)));
          _painter.redraw();
        } else if (value == 'Delete') {
          HullManager().logLayout();
          HullManager().panelLayout.removePanel(selectedPanel);
          selectedPanel = -1;
          _painter.selectedPanel(-1);
          _painter.redraw();
        }
      }
    });
  }

  void _processKeypress(KeyEvent event) {
    if (HardwareKeyboard.instance.isControlPressed &&
        event.character == 'z') {
      HullManager().popLayout();
      _painter.redraw();
    }
  }
}
