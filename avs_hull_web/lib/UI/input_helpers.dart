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

// **************************************************************
class XYZWidget extends StatefulWidget {
  final String labelText;
  final String initValue;
  final double width;
  final double height;

  const XYZWidget({
    super.key,
    required this.labelText,
    required this.initValue,
    required this.width,
    required this.height,
    })
    : super();

  @override
  XYZWidgetState createState() => XYZWidgetState();
  
}

class XYZWidgetState extends State<XYZWidget> {
  // Step 1: Create a TextEditingController
  final TextEditingController _controller = TextEditingController(); 
  bool _isEnabled = false;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initValue;
  }

  @override
  void dispose() {
    _controller.dispose();
    // Dispose of the controller when the widget is disposed
    super.dispose();
  }

  // Method to programmatically update the text field
  void setContent(String newValue) {
    setState(() {
      _controller.text = newValue;
    });
  }

  // Method to read the text field content
  String getContent() {
    final textValue = _controller.text;
    return textValue;
  }
  
  void setEnabled() {
     setState(() {
      _isEnabled = true;
    });
  }
  void setDisabled() {
     setState(() {
      _isEnabled = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return  SizedBox(
        width: widget.width, height: widget.height, 
        child: TextField(
          enabled: _isEnabled,
          controller: _controller,
          decoration: InputDecoration(
            labelText: widget.labelText,
            contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4), 
            border: const OutlineInputBorder(),
          ),
        ),
      );

  }
}