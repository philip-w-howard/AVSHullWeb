// ***************************************************************
// Part of the AVS Hull program
// Released under the MIT license.
// See https://github.com/philip-w-howard/AVSHullWeb for details
// ***************************************************************

import 'package:flutter/material.dart';
import 'main.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:html' as html;
import 'hull.dart';
import 'hull_window.dart';
import 'rotated_hull.dart';
import 'resize_dialog.dart';

class DesignScreen extends StatelessWidget {
  DesignScreen({super.key, required this.mainHull}) {
    frontWindow = HullWindow(mainHull, HullView.front, _selectFront, null);
    sideWindow = HullWindow(mainHull, HullView.side, _selectSide, null);
    topWindow = HullWindow(mainHull, HullView.top, _selectTop, null);
    mainWindow = HullWindow(mainHull, HullView.rotated, _selectTop, resetAll);
    mainWindow.setRotatable();
    mainWindow.setEditable();
    //resetScreen();
  }

  //final Hull myHull = Hull(length: 200, width: 50, height:20, numBulkheads:5 numChines:5);
  final Hull mainHull;
  late final HullWindow frontWindow;
  late final HullWindow sideWindow;
  late final HullWindow topWindow;
  late final HullWindow mainWindow;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    frontWindow.setHeight(0.3 * screenHeight);
    sideWindow.setHeight(0.3 * screenHeight);
    topWindow.setHeight(0.3 * screenHeight);

    return Scaffold(
      body: Column(
        children: [
          _MainMenu(mainHull, context),
          Row(
            children: [
              frontWindow,
              sideWindow,
              topWindow,
            ],
          ),
          mainWindow,
        ],
      ),
    );
  }

  void resetAll() {
    print('reset all');
    frontWindow.resetView();
    sideWindow.resetView();
    topWindow.resetView();
    mainWindow.resetView();
  }

  void _selectFront() {
    mainWindow.setView(HullView.front);
  }

  void _selectSide() {
    mainWindow.setView(HullView.side);
  }

  void _selectTop() {
    mainWindow.setView(HullView.top);
  }

  void resetScreen() {
    print('resetScreen');
    frontWindow.resetView();
    sideWindow.resetView();
    topWindow.resetView();
    mainWindow.setView(HullView.rotated);
  }
}

class _MainMenu extends Row {
  final Hull _hull;
  final BuildContext _context;
  _MainMenu(this._hull, this._context)
      : super(
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
                  selectAndSaveFile(_hull);
                } else if (choice == 'Open') {
                  selectAndReadFile(_hull);
                } else {
                  print('File: $choice');
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
                  processResize(_context, _hull);
                } else if (choice == 'Chines') {
                  processChines(_context, _hull);
                } else {
                  print('Edit: $choice');
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
        );
}

Future processResize(BuildContext context, Hull hull) async {
  var size = hull.size();
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
    hull.resize(xSize, ySize, zSize);
    print('Results: $xSize, $ySize, $zSize');
    mainScreen.resetScreen();
  } else {
    print('Cancel');
  }

  return result;
}

Future processChines(BuildContext context, Hull hull) async {
  return processResize(context, hull);
}

void selectAndReadFile(Hull hull) async {
  String? contents = await _readFile();
  if (contents != null) {
    Map<String, dynamic> jsonData = json.decode(contents);
    hull.updateFromJson(jsonData);
    mainScreen.resetScreen();
  } else {
    print('Did not open file');
  }
}

void selectAndSaveFile(Hull hull) async {
  final String jsonStr = json.encode(hull.toJson());
  await _saveFile(jsonStr);
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
    print('caught exception');
  }
  return null;
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
