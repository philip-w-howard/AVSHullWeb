// ***************************************************************
// Part of the AVS Hull program
// Released under the MIT license.
// See https://github.com/philip-w-howard/AVSHullWeb for details
// ***************************************************************

import 'package:flutter/material.dart';
import 'dart:convert';

import '../models/hull_manager.dart';
import '../models/panel.dart';
import '../models/bulkhead.dart';
import '../models/panel_layout.dart';
import '../settings/settings.dart';
import 'panels_window.dart';
import 'export_offsets_dialog.dart';
import 'panel_layout_dialog.dart';
import '../IO/export_offsets.dart';
import '../geometry/hull_math.dart';
import '../IO/file_io.dart';

class PanelsScreen extends StatelessWidget {
  static final GlobalKey<ScaffoldState> scaffoldKey =
      GlobalKey<ScaffoldState>();

  PanelsScreen({super.key}) {
    _createPanels();

    _panelsWindow = PanelsWindow();
  }

  final List<Panel> _basePanels = [];
  late final PanelsWindow _panelsWindow;
  final List<String> _panelNames = [];    // used to build a selection menu for panels

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        Container(
            color: Colors.white,
            height: 40,
            child: Row(
              children: [
                PopupMenuButton<String>(
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'File',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  itemBuilder: (BuildContext context) {
                    return [
                      const PopupMenuItem<String>(
                        value: 'Open',
                        child: Text('Load from Json'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'Save',
                        child: Text('Save to Json'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'Offsets',
                        child: Text('Export to Offsets'),
                      ),
                    ];
                  },
                  onSelected: (String choice) {
                    // Handle menu item selection
                    if (choice == 'Open') {
                      _selectAndReadFile();
                    } else if (choice == 'Save') {
                      _selectAndSaveFile();
                    } else if (choice == 'Offsets') {
                      _exportToOffsets(context);
                    }
                  },
                ),
                PopupMenuButton<String>(
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Edit',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  onSelected: (String choice) async {
                    // Handle menu item selection
                    if (choice == 'Layout') {
                      _changeLayout(context);
                    } else if (choice == 'Add') {
                      _showItemSelectionDialog(context);
                      _panelsWindow.redraw();
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      const PopupMenuItem<String>(
                        value: 'Layout',
                        child: Text('Panel Layout'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'Add',
                        child: Text('Add Panel'),
                      ),
                    ];
                  },
                ),
              ],
            )),
        Expanded(
          child: _panelsWindow
        ),
      ]),
    );
  }

  void checkPanels(BuildContext context) {
    if (HullManager().hull.timeUpdated.isAfter(HullManager().panelLayout.timestamp())) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirmation'),
            content: const Text('The hull has been modified since the panels'
                ' were laid out. The panel layout will be cleared'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  _createPanels();
                  _panelsWindow.redraw();
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  // Add your action here for "Yes"
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _createPanels() {
    _basePanels.clear();
    HullManager().panelLayout.clear();
    _panelNames.clear();

    for (int ii = 0; ii < HullManager().hull.mBulkheads.length; ii++) {
      Bulkhead bulk = HullManager().hull.mBulkheads[ii];
      if (bulk.mBulkheadType != BulkheadType.bow) {
        Panel panel = Panel.fromBulkhead(bulk);
        panel.name = 'Bulkhead $ii';
        _basePanels.add(panel);
        _panelNames.add(panel.name);
      }
    }

    for (int ii = 0; ii < HullManager().hull.mChines.length ~/ 2; ii++) {
      Panel panel = Panel.fromChines(HullManager().hull.mChines[ii], HullManager().hull.mChines[ii + 1]);
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

      HullManager().panelLayout.addPanel(Panel.copy(panel));

      xOffset = -min.dx + 5;
      HullManager().panelLayout.moveBy(HullManager().panelLayout.length() - 1, xOffset, yOffset);
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
      HullManager().panelLayout.addPanel(Panel.copy(_basePanels[index]));
    }
    _panelsWindow.redraw();
  }

  // *********************************************************
  void _exportToOffsets(BuildContext context) async {
    ExportOffsetsParams params = loadExportOffsetsParams();
    LayoutSettings layout = loadLayoutSettings();

    bool result = await showDialog(
      builder: (BuildContext context) {
        return ExportOffsetsDialog(
            offsetParams: params,
            onSubmit: (newHullParams) {
              params = newHullParams;
            });
      },
      context: context,
    );
    if (result) {
      exportPanelOffset(HullManager().panelLayout, params, layout);
      saveExportOffsetsParams(params);
    }
  }

  // *********************************************************
  void _changeLayout(BuildContext context) async {
    LayoutSettings settings = loadLayoutSettings();

    bool result = await showDialog(
      builder: (BuildContext context) {
        return PanelLayoutDialog(
            layoutSettings: settings,
            onSubmit: (newHullParams) {
              settings = newHullParams;
            });
      },
      context: context,
    );
    if (result) {
      saveLayoutSettings(settings);
      _panelsWindow.updateLayout();
      _panelsWindow.redraw();
    }
  }

  // *********************************************************
  void _selectAndReadFile() async {
    String? contents = await readFile('avshpanels');
    if (contents != null) {
      Map<String, dynamic> jsonData = json.decode(contents);

      if (jsonData['displayedPanels'] != null) {
        HullManager().panelLayout.updateFromJson(jsonData['displayedPanels']);
      }

      if (jsonData['panelLayout'] != null) {
        LayoutSettings settings = LayoutSettings.fromJson(jsonData['panelLayout']);
        saveLayoutSettings(settings);
      }

      _panelsWindow.updateLayout();
      _panelsWindow.redraw();
    }
  }
  
  // *********************************************************
  void _selectAndSaveFile() async {
    HullManager().panelLayout.timeSaved = DateTime.now();
    const prettyJson = JsonEncoder.withIndent('  ');
    final String prettyStr = prettyJson.convert(HullManager().panelLayout.toJson());

    await saveFile(prettyStr, HullManager().hull.name, 'avshpanels');

  }
}
