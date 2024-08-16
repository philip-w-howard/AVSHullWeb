// ***************************************************************
// Part of the AVS Hull program
// Released under the MIT license.
// See https://github.com/philip-w-howard/AVSHullWeb for details
// ***************************************************************

import 'package:flutter/material.dart';
import '../settings/settings.dart';
import 'input_helpers.dart';

// *****************************************************
class PanelLayoutDialog extends StatefulWidget {
  const PanelLayoutDialog(
      {super.key, required this.onSubmit, required this.layoutSettings});

  final Function(LayoutSettings settings) onSubmit;
  final LayoutSettings layoutSettings;

  @override
  LayoutDialogState createState() => LayoutDialogState();
}

class LayoutDialogState extends State<PanelLayoutDialog> {
  late LayoutSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.layoutSettings;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Panel Layout'),
      content: SingleChildScrollView(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IntEntry(
              title: const InputDecoration(labelText: 'Width'),
              initValue: _settings.width.toString(),
              update: (int size) {
                _settings.width = size;
              }),
          IntEntry(
              title: const InputDecoration(labelText: 'Height'),
              initValue: _settings.height.toString(),
              update: (int size) {
                _settings.height = size;
              }),
          IntEntry(
              title: const InputDecoration(labelText: 'Panel Width'),
              initValue: _settings.panelWidth.toString(),
              update: (int size) {
                _settings.panelWidth = size;
              }),
          IntEntry(
              title: const InputDecoration(labelText: 'Panel Height'),
              initValue: _settings.panelHeight.toString(),
              update: (int size) {
                _settings.panelWidth = size;
              }),
        ],
      )),
      actions: [
        TextButton(
          onPressed: () {
            // Perform action on button press
            widget.onSubmit(_settings);

            Navigator.of(context).pop(true);
          },
          child: const Text('OK'),
        ),
        TextButton(
          onPressed: () {
            // Perform action on button press
            Navigator.of(context).pop(false);
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

