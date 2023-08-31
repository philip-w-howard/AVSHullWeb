// ***************************************************************
// Part of the AVS Hull program
// Released under the MIT license.
// See https://github.com/philip-w-howard/AVSHullWeb for details
// ***************************************************************

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'hull.dart';
import 'panel.dart';
import 'bulkhead.dart';
import 'panels_window.dart';

class LayoutData {
  int panelsX = 1;
  int panelsY = 1;
  double panelSizeX = 96;
  double panelSizeY = 48;
}

class PanelsScreen extends StatelessWidget {
  PanelsScreen(this._hull, {super.key}) {
    _basePanels.clear();

    // for (int ii = 0; ii < _hull.mChines.length / 2; ii++) {
    //   basePanels
    //       .add(Panel.fromChines(_hull.mChines[ii], _hull.mChines[ii + 1]));
    // }

    for (Bulkhead bulk in _hull.mBulkheads) {
      if (bulk.mBulkheadType != BulkheadType.bow) {
        _basePanels.add(Panel.fromBulkhead(bulk));
      }
    }

    for (Panel panel in _basePanels) {
      _displayedPanels.add(panel);
    }

    _panelsWindow = PanelsWindow(_displayedPanels);

    _textPanelsXController.text = _layout.panelsX.toString();
    _textPanelsYController.text = _layout.panelsY.toString();
    _textPanelSizeXController.text = _layout.panelSizeX.toString();
    _textPanelSizeYController.text = _layout.panelSizeY.toString();

    _textPanelsXFocus.addListener(_panelsXListener);
    _textPanelsYFocus.addListener(_panelsYListener);
    _textPanelSizeXFocus.addListener(_panelSizeXListener);
    _textPanelSizeXFocus.addListener(_panelSizeYListener);
  }

  final Hull _hull;
  final List<Panel> _basePanels = [];
  final List<Panel> _displayedPanels = [];
  late final PanelsWindow _panelsWindow;
  final TextEditingController _textPanelsXController = TextEditingController();
  final TextEditingController _textPanelsYController = TextEditingController();
  final TextEditingController _textPanelSizeXController =
      TextEditingController();
  final TextEditingController _textPanelSizeYController =
      TextEditingController();

  final FocusNode _textPanelsXFocus = FocusNode();
  final FocusNode _textPanelsYFocus = FocusNode();
  final FocusNode _textPanelSizeXFocus = FocusNode();
  final FocusNode _textPanelSizeYFocus = FocusNode();
  final LayoutData _layout = LayoutData();

  @override
  Widget build(BuildContext context) {
    final numericFormatter =
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,10}'));

    return Scaffold(
      body: Row(
        children: [
          Container(
            //color: Colors.blue,
            width: 125,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextField(
                  controller: _textPanelsXController,
                  decoration: const InputDecoration(labelText: 'Width'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [numericFormatter],
                  focusNode: _textPanelsXFocus,
                ),
                TextField(
                  controller: _textPanelsYController,
                  decoration: const InputDecoration(labelText: 'Height'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [numericFormatter],
                  focusNode: _textPanelsYFocus,
                ),
                TextField(
                  controller: _textPanelSizeXController,
                  decoration: const InputDecoration(labelText: 'Panel Width'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [numericFormatter],
                  focusNode: _textPanelSizeXFocus,
                ),
                TextField(
                  controller: _textPanelSizeYController,
                  decoration: const InputDecoration(labelText: 'Panel Height'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [numericFormatter],
                  focusNode: _textPanelSizeYFocus,
                ),
                TextButton(
                  onPressed: () {
                    // Note: this causes a redraw
                    _panelsWindow.updateLayout(_layout.panelsX, _layout.panelsY,
                        _layout.panelSizeX, _layout.panelSizeY);
                  },
                  child: const Text('Redraw'),
                ),
                // TextButton(
                //   onPressed: () {
                //     _hullWindow.setView(HullView.side);
                //   },
                //   child: const Text('Show Side'),
                // ),
                // TextButton(
                //   onPressed: () {
                //     _hullWindow.setView(HullView.top);
                //   },
                //   child: const Text('Show Top'),
                // ),
              ],
            ),
          ),
          _panelsWindow,
        ],
      ),
    );
  }

  void _panelsXListener() {
    // Code to execute when text field 3 changes
    if (!_textPanelsXFocus.hasFocus) {
      _layout.panelsX = int.parse(_textPanelsXController.text);

      // Note: this causes a redraw
      _panelsWindow.updateLayout(_layout.panelsX, _layout.panelsY,
          _layout.panelSizeX, _layout.panelSizeY);
    }
  }

  void _panelsYListener() {
    // Code to execute when text field 3 changes
    if (!_textPanelsXFocus.hasFocus) {
      _layout.panelsY = int.parse(_textPanelsYController.text);

      // Note: this causes a redraw
      _panelsWindow.updateLayout(_layout.panelsX, _layout.panelsY,
          _layout.panelSizeX, _layout.panelSizeY);
    }
  }

  void _panelSizeXListener() {
    // Code to execute when text field 3 changes
    if (!_textPanelsXFocus.hasFocus) {
      _layout.panelSizeX = double.parse(_textPanelSizeXController.text);

      // Note: this causes a redraw
      _panelsWindow.updateLayout(_layout.panelsX, _layout.panelsY,
          _layout.panelSizeX, _layout.panelSizeY);
    }
  }

  void _panelSizeYListener() {
    // Code to execute when text field 3 changes
    if (!_textPanelsXFocus.hasFocus) {
      _layout.panelSizeY = double.parse(_textPanelSizeYController.text);

      // Note: this causes a redraw
      _panelsWindow.updateLayout(_layout.panelsX, _layout.panelsY,
          _layout.panelSizeX, _layout.panelSizeY);
    }
  }
}