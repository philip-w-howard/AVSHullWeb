// ***************************************************************
// Part of the AVS Hull program
// Released under the MIT license.
// See https://github.com/philip-w-howard/AVSHullWeb for details
// ***************************************************************

import 'package:avs_hull_web/UI/input_helpers.dart';
import 'package:avs_hull_web/models/hull.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/bulkhead.dart';

class NewHullDialog extends StatefulWidget {
  const NewHullDialog(
      {super.key, required this.onSubmit, required this.hullParams});

  final Function(HullParams params) onSubmit;
  final HullParams hullParams;

  @override
  ResizeDialogState createState() => ResizeDialogState();
}

class ResizeDialogState extends State<NewHullDialog> {
  late HullParams _params;

  @override
  void initState() {
    super.initState();
    _params = widget.hullParams;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Hull'),
      content: SingleChildScrollView(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MyTextEntry(
              initValue: _params.name,
              title: const InputDecoration(labelText: 'Name'),
              update: (String name) {
                _params.name = name;
              }),
           BulkheadTypeSelector(
              param: _params.bow,
              update: (BulkheadType type) {
                _params.bow = type;
              }),
          DoubleEntry(
              title: const InputDecoration(labelText: 'Bow transom angle'),
              initValue: _params.forwardTransomAngle.toString(),
              update: (double angle) {
                _params.forwardTransomAngle = angle;
              }),
          BulkheadTypeSelector(
              param: _params.stern,
              update: (BulkheadType type) {
                _params.stern = type;
              }),
          DoubleEntry(
              title: const InputDecoration(labelText: 'Stern transom angle'),
              initValue: _params.sternTransomAngle.toString(),
              update: (double angle) {
                _params.sternTransomAngle = angle;
              }),
          DoubleEntry(
              title: const InputDecoration(labelText: 'Length'),
              initValue: _params.length.toString(),
              update: (double value) {
                _params.length = value;
              }),
          DoubleEntry(
              title: const InputDecoration(labelText: 'Width'),
              initValue: _params.width.toString(),
              update: (double value) {
                _params.width = value;
              }),
          DoubleEntry(
              title: const InputDecoration(labelText: 'Height'),
              initValue: _params.height.toString(),
              update: (double value) {
                _params.height = value;
              }),
          DoubleEntry(
              title: const InputDecoration(labelText: 'Number of Bulkheads'),
              initValue: _params.numBulkheads.toString(),
              update: (double value) {
                _params.numBulkheads = value as int;
              }),
          DoubleEntry(
              title: const InputDecoration(labelText: 'Number of Chines'),
              initValue: _params.numBulkheads.toString(),
              update: (double value) {
                _params.numChines = value as int;
              }),
        ],
      )),
      actions: [
        TextButton(
          onPressed: () {
            // Perform action on button press
            widget.onSubmit(_params);

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

class BulkheadTypeSelector extends DropdownMenu<String> {
  BulkheadTypeSelector(
      {super.key,
      required BulkheadType param,
      required ValueChanged<BulkheadType> update})
      : super(
          initialSelection: param.name,
          onSelected: (String? newValue) {
            if (newValue == 'bow') {
              param = BulkheadType.bow;
            } else if (newValue == 'vertical') {
              param = BulkheadType.vertical;
            } else if (newValue == 'transom') {
              param = BulkheadType.transom;
            }
            update(param);
          },
          dropdownMenuEntries: <String>['bow', 'vertical', 'transom']
              .map<DropdownMenuEntry<String>>((String value) {
            return DropdownMenuEntry<String>(
              value: value,
              label: value,
            );
          }).toList(),
        );
}

class DoubleEntry extends TextField {
  final ValueChanged<double> update;

  DoubleEntry(
      {super.key,
      required String initValue,
      required InputDecoration title,
      required this.update})
      : super(
          controller: TextEditingController(),
          decoration: title,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,10}'))
          ],
          focusNode: FocusNode(),
        ) {
    focusNode?.addListener(listener);
    controller?.text = initValue;
  }

  void listener() {
    // Code to execut e when text field 3 changes
    bool? hasFocus = focusNode?.hasFocus;
    if (hasFocus != null && !hasFocus) {
      String? text = controller?.text;
      if (text != null) {
        double newValue = double.parse(text);
        update(newValue);
      }
    }
  }
}
