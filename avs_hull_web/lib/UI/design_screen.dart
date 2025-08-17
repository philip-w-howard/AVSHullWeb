// ***************************************************************
// Part of the AVS Hull program
// Released under the MIT license.
// See https://github.com/philip-w-howard/AVSHullWeb for details
// ***************************************************************

import 'package:avs_hull_web/UI/select_hull_dialog.dart';
import 'package:avs_hull_web/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'dart:convert';
import 'dart:async';
import '../models/hull.dart';
import '../IO/hull_logger.dart';
import 'hull_window.dart';
import '../models/rotated_hull.dart';
import 'resize_dialog.dart';
import 'new_hull_dialog.dart';
import '../IO/file_io.dart';
import 'package:avs_hull_web/UI/input_helpers.dart';


class DesignScreen extends StatelessWidget {

  DesignScreen({super.key, required Hull mainHull, required HullLogger logger})
      : _myHull = mainHull,
        _hullLogger = logger {
    xyz = XYZWidget();
    _frontWindow = HullWindow(_myHull, HullView.front, _selectFront, null, xyz: xyz,);
    _sideWindow = HullWindow(_myHull, HullView.side, _selectSide, null, xyz: xyz,);
    _topWindow = HullWindow(_myHull, HullView.top, _selectTop, null, xyz: xyz,);
    _editWindow = HullWindow(_myHull, HullView.rotated, null, resetScreen,
        logger: _hullLogger, xyz: xyz,);
    _editWindow.setRotatable();
    _editWindow.setEditable();
  }

  //final Hull myHull = Hull(length: 200, width: 50, height:20, numBulkheads:5 numChines:5);
  final Hull _myHull;
  final HullLogger _hullLogger;

  late final HullWindow _frontWindow;
  late final HullWindow _sideWindow;
  late final HullWindow _topWindow;
  late final HullWindow _editWindow;
  late final XYZWidget xyz;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    _frontWindow.setHeight(0.3 * screenHeight);
    _sideWindow.setHeight(0.3 * screenHeight);
    _topWindow.setHeight(0.3 * screenHeight);

    return Scaffold(
      body: Column(
        children: [
          Row(
            children: [
              PopupMenuButton<String>(
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'File',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                onSelected: (String choice) {
                  // Handle menu item selection
                  if (choice == 'Load') {
                    _selectAndLoadFile(context);
                  } else if (choice == 'Save') {
                    writeHull(_myHull);
                  }
                  else if (choice == 'ExportJSON') {
                    _selectAndSaveFile();
                  } else if (choice == 'XML') {
                    _selectAndXmlFile();
                  } else if (choice == 'ImportJSON') {
                    _selectAndReadFile();
                  } else if (choice == 'Create') {
                    _createHull(context);
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    const PopupMenuItem<String>(
                      value: 'Load',
                      child: Text('Load'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'Save',
                      child: Text('Save'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'ExportJSON',
                      child: Text('Export to JSON'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'ImportJSON',
                      child: Text('Import from JSON'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'XML',
                      child: Text('Export to XML'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'Create',
                      child: Text('Create'),
                    ),
                  ];
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
                  if (choice == 'Resize') {
                    _processResize(context);
                  } else if (choice == 'Chines') {
                    _processChines(context);
                  } else if (choice == 'AddBulkhead') {
                    _addBulkhead(context);
                  } else if (choice == 'DeleteBulkhead') {
                    _deleteBulkhead(context);
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    const PopupMenuItem<String>(
                      value: 'Resize',
                      child: Text('Resize'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'Chines',
                      child: Text('Chines'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'AddBulkhead',
                      child: Text('Add Bulkhead'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'DeleteBulkhead',
                      child: Text('Delete Bulkhead'),
                    ),
                  ];
                },
              ),
            ],
          ),
//          _MainMenu(mainHull, context),
          Row(
            children: [
              _frontWindow,
              _sideWindow,
              _topWindow,
            ],
          ),
          _editWindow,
          Padding(
              padding: const EdgeInsets.all(6.0),
              child: xyz,
            ),

        ],
      ),
    );
  }

  void resetScreen() {
      _frontWindow.resetView();
    _sideWindow.resetView();
    _topWindow.resetView();
    _editWindow.resetView();
  }

  void _selectFront() {
    _editWindow.setView(HullView.front);
  }

  void _selectSide() {
    _editWindow.setView(HullView.side);
  }

  void _selectTop() {
    _editWindow.setView(HullView.top);
  }

  Future _processResize(BuildContext context) async {
    var size = _myHull.size();
    double xSize = size.x;
    double ySize = size.y;
    double zSize = size.z;
    
    bool result = await showDialog(
      builder: (BuildContext context) {
        return ResizeDialog(
            xValue: size.x,
            yValue: size.y,
            zValue: size.z,
            onSubmit: (x, y, z) {
              xSize = x;
              ySize = y;
              zSize = z;
            });
      },
      context: context,
    );

    if (result) {
      _myHull.resize(xSize, ySize, zSize);
      resetScreen();
    }

    return result;
  }

  Future _processChines(BuildContext context) async {
    return _processResize(context);
  }



  Future _addBulkhead(BuildContext context) async {
    TextEditingController locationController = TextEditingController();
    bool okPressed = false;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter New Bulkhead Location'),
          content: TextField(
            controller: locationController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(hintText: 'Location'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                okPressed = true;
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
    if (okPressed) {
      double? location = double.tryParse(locationController.text);
      if (location != null && location > _myHull.minBulkheadPos() && location < _myHull.maxBulkheadPos()) {
        _myHull.insertBulkhead(location);
        resetScreen();
      } else {
        await showErrorDialog(context, 'Invalid bulkhead location: '
            '	$location\nValid range: '
            '${_myHull.minBulkheadPos()} to ${_myHull.maxBulkheadPos()}');
      }
    }
  }

  Future _deleteBulkhead(BuildContext context) async {
    if (_editWindow.bulkheadIsSelected()) {
      // If a bulkhead is selected, delete it
      int bulkheadNum = _editWindow.selectedBulkhead();
      if (bulkheadNum > 0 && bulkheadNum < _myHull.numBulkheads() - 1) {
        _myHull.deleteBulkhead(bulkheadNum);
        resetScreen();
      } else {
        await showErrorDialog(context, 'Cannot delete the first or last bulkhead.');
      }
      return;
    } else {
      // If no bulkhead is selected, prompt the user to select one
      await showErrorDialog(context, 'Please select a bulkhead to delete.');
    }
  }

  // Helper to show an error dialog
  Future<void> showErrorDialog(BuildContext context, String message) async{
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _selectAndLoadFile(BuildContext context) async {
    String hullName = unnamedHullName;

    bool result = await showDialog(
      builder: (BuildContext context) {
        return SelectHullDialog(
            onSubmit: (chosenHullName) {
              hullName = chosenHullName;
            });
      },
      context: context,
    );

    if (result) {
      readHull(hullName, _myHull);
      resetScreen();
    }
  }

  void _selectAndReadFile() async {
    String? contents = await readFile('avsh');
    if (contents != null) {
      Map<String, dynamic> jsonData = json.decode(contents);
      _myHull.updateFromJson(jsonData);
      resetScreen();
    }
  }

  void _selectAndSaveFile() async {
    _myHull.timeSaved = DateTime.now();
    const prettyJson = JsonEncoder.withIndent('  ');
    final String prettyStr = prettyJson.convert(_myHull.toJson());

    await saveFile(prettyStr, _myHull.name, 'avsh');
  }

  void _selectAndXmlFile() async {
    XmlDocument xml = _myHull.toXml();

    final String xmlStr = xml.toXmlString(pretty: true);
    await saveFile(xmlStr, _myHull.name, 'xml');
  }

  void _createHull(BuildContext context) async {
    HullParams params = HullParams();

    bool result = await showDialog(
      builder: (BuildContext context) {
        return NewHullDialog(
            hullParams: params,
            onSubmit: (newHullParams) {
              params = newHullParams;
            });
      },
      context: context,
    );

    if (result) {
      _myHull.updateFromParams(params);
      resetScreen();
    }
  }

}
