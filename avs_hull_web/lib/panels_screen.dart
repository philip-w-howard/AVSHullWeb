// ***************************************************************
// Part of the AVS Hull program
// Released under the MIT license.
// See https://github.com/philip-w-howard/AVSHullWeb for details
// ***************************************************************

import 'package:avs_hull_web/hull_math.dart';
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
    createPanels();

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
  final List<String> _panelNames = [];

  @override
  Widget build(BuildContext context) {
    final numericFormatter =
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,10}'));

    return Scaffold(
      body: Row(
        children: [
          Container(
            color: Colors.yellow,
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
                    _showItemSelectionDialog(context);
                    _panelsWindow.redraw();
                  },
                  child: const Text('Add Panel'),
                ),
                const Spacer(flex: 1),
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

  void createPanels() {
    _basePanels.clear();
    _displayedPanels.clear();
    _panelNames.clear();

    for (int ii = 0; ii < _hull.mBulkheads.length; ii++) {
      Bulkhead bulk = _hull.mBulkheads[ii];
      if (bulk.mBulkheadType != BulkheadType.bow) {
        Panel panel = Panel.fromBulkhead(bulk);
        panel.name = 'Bulkhead $ii';
        _basePanels.add(panel);
        _panelNames.add(panel.name);
      }
    }

    for (int ii = 0; ii < _hull.mChines.length / 2; ii++) {
      print('********** create Panel ${ii + 1} *******');
      Panel panel = Panel.fromChines(_hull.mChines[ii], _hull.mChines[ii + 1]);
      panel.name = 'Panel ${ii + 1}';
      _basePanels.add(panel);
      _panelNames.add(panel.name);
    }

    double xOffset = 0;
    double yOffset = 0;

    Offset min = Offset.zero;
    Offset max = Offset.zero;

    for (Panel panel in _basePanels) {
      (min, max) = getMinMax2D(panel.getOffsets());

      _displayedPanels.add(Panel.copy(panel));

      xOffset = -min.dx + 5;
      _displayedPanels[_displayedPanels.length - 1].moveBy(xOffset, yOffset);
      yOffset += max.dy + 5;
    }
  }

  void _showItemSelectionDialog(BuildContext context) async {
    final selected = await showMenu<String>(
      context: context,
      color: Colors.amber,
      position: RelativeRect.fromRect(
        Offset.zero & const Size(10, 10),
        Offset.zero & MediaQuery.of(context).size,
      ),
      items: _panelNames.map((item) {
        return PopupMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
    );
    if (selected != null) {
      int index = _panelNames.indexOf(selected);
      _displayedPanels.add(Panel.copy(_basePanels[index]));
    }
  }
}
