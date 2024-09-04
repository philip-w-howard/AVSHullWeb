// ***************************************************************
// Part of the AVS Hull program
// Released under the MIT license.
// See https://github.com/philip-w-howard/AVSHullWeb for details
// ***************************************************************

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ****************************************************************
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
    focusNode?.addListener(_listener);
    controller?.text = initValue;
  }

  void _listener() {
    // Code to execute when text field 3 changes
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

// ****************************************************************
class IntEntry extends TextField {
  final ValueChanged<int> update;

  IntEntry(
      {super.key,
      required String initValue,
      required InputDecoration title,
      required this.update})
      : super(
          controller: TextEditingController(),
          decoration: title,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+'))
          ],
          focusNode: FocusNode(),
        ) {
    focusNode?.addListener(_listener);
    controller?.text = initValue;
  }

  void _listener() {
    // Code to execute when text field 3 changes
    bool? hasFocus = focusNode?.hasFocus;
    if (hasFocus != null && !hasFocus) {
      String? text = controller?.text;
      if (text != null) {
        int newValue = int.parse(text);
        update(newValue);
      }
    }
  }
}

// ****************************************************************
class MyTextEntry extends TextField {
  final ValueChanged<String> update;

  MyTextEntry(
      {super.key,
      required String initValue,
      required InputDecoration title,
      required this.update})
      : super(
          controller: TextEditingController(),
          decoration: title,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_]'))
          ],
          focusNode: FocusNode(),
        ) {
    focusNode?.addListener(_listener);
    controller?.text = initValue;
  }

  void _listener() {
    // Code to execute when text field 3 changes
    bool? hasFocus = focusNode?.hasFocus;
    if (hasFocus != null && !hasFocus) {
      String? text = controller?.text;
      if (text != null) {
        update(text);
      }
    }
  }
}

// *******************************************************
class CustomCheckbox extends StatefulWidget {
  final String label;
  final bool initValue;
  final ValueChanged<bool> onChanged;

  const CustomCheckbox({
    super.key, 
    required this.label,
    required this.onChanged,
    required this.initValue,
  });

  @override
  CustomCheckboxState createState() => CustomCheckboxState();
}

class CustomCheckboxState extends State<CustomCheckbox> {
  late bool isChecked;

  @override
  void initState() {
    super.initState();
    isChecked = widget.initValue; // Initialize checkbox state with initialValue
  }

  void _onCheckboxChanged(bool? value) {
    setState(() {
      isChecked = value ?? false;
    });
    widget.onChanged(isChecked);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: isChecked,
          onChanged: _onCheckboxChanged,
        ),
        Text(widget.label),
      ],
    );
  }
}
