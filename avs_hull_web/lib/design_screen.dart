// ***************************************************************
// Part of the AVS Hull program
// Released under the MIT license.
// See https://github.com/philip-w-howard/AVSHullWeb for details
// ***************************************************************

import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:html' as html;
import 'hull.dart';
import 'hull_logger.dart';
import 'hull_window.dart';
import 'rotated_hull.dart';
import 'resize_dialog.dart';
import 'new_hull_dialog.dart';

class DesignScreen extends StatelessWidget {
  DesignScreen({super.key, required Hull mainHull, required HullLogger logger})
      : _myHull = mainHull,
        _hullLogger = logger {
    _frontWindow = HullWindow(_myHull, HullView.front, _selectFront, null);
    _sideWindow = HullWindow(_myHull, HullView.side, _selectSide, null);
    _topWindow = HullWindow(_myHull, HullView.top, _selectTop, null);
    _editWindow = HullWindow(_myHull, HullView.rotated, null, resetScreen,
        logger: _hullLogger);
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
                  if (choice == 'Save') {
                    _selectAndSaveFile();
                  } else if (choice == 'Open') {
                    _selectAndReadFile();
                  } else if (choice == 'Create') {
                    _createHull(context);
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    const PopupMenuItem<String>(
                      value: 'Open',
                      child: Text('Open'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'Save',
                      child: Text('Save'),
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
                      value: 'Bulkheads',
                      child: Text('Bulkheads'),
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

  void _selectAndReadFile() async {
    String? contents = await _readFile();
    if (contents != null) {
      Map<String, dynamic> jsonData = json.decode(contents);
      _myHull.updateFromJson(jsonData);
      resetScreen();
    }
  }

  void _selectAndSaveFile() async {
    final String jsonStr = json.encode(_myHull.toJson());
    await _saveFile(jsonStr);
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

  // **********************************************
  // Need some way to return success/failure
  Future<void> _saveFile(String contents) async {
    final encodedContent = base64.encode(utf8.encode(contents));

    final anchor = html.AnchorElement(
      href: 'data:text/plain;charset=utf-8;base64,$encodedContent',
    );
    anchor.download = 'saved_hull.avsh';
    anchor.click();
  }

  // **********************************************
  // Does not indicate failure when "cancel" is hit
  Future<String?> _readFile() async {
    final completer = Completer<String>();
    try {
      html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
      uploadInput.click();

      await uploadInput.onChange.first;

      final file = uploadInput.files!.first;
      final reader = html.FileReader();

      reader.onLoadEnd.listen((event) {
        final fileContents = reader.result as String;
        completer.complete(fileContents);
      });

      reader.readAsText(file);

      return completer.future;
    } catch (e) {
      //print('caught exception');
    }
    return null;
  }
}
