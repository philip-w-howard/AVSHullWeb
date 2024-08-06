// ***************************************************************
// Part of the AVS Hull program
// Released under the MIT license.
// See https://github.com/philip-w-howard/AVSHullWeb for details
// ***************************************************************

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ResizeDialog extends StatefulWidget {
  const ResizeDialog(
      {super.key,
      required this.onSubmit,
      required this.xValue,
      required this.yValue,
      required this.zValue});

  final Function(double, double, double) onSubmit;
  final double xValue;
  final double yValue;
  final double zValue;

  @override
  ResizeDialogState createState() => ResizeDialogState();
}

class ResizeDialogState extends State<ResizeDialog> {
  bool _isChecked = false;
  double _x = 0;
  double _y = 0;
  double _z = 0;

  final TextEditingController _textXController = TextEditingController();
  final TextEditingController _textYController = TextEditingController();
  final TextEditingController _textZController = TextEditingController();

  final FocusNode _textFieldXFocus = FocusNode();
  final FocusNode _textFieldYFocus = FocusNode();
  final FocusNode _textFieldZFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    _x = widget.xValue;
    _y = widget.yValue;
    _z = widget.zValue;

    _textXController.text = widget.xValue.toString();
    _textYController.text = widget.yValue.toString();
    _textZController.text = widget.zValue.toString();

    _textFieldXFocus.addListener(_textFieldXListener);
    _textFieldYFocus.addListener(_textFieldYListener);
    _textFieldZFocus.addListener(_textFieldZListener);
  }

  @override
  void dispose() {
    _textXController.dispose();
    _textYController.dispose();
    _textZController.dispose();

    _textFieldXFocus.dispose();
    _textFieldYFocus.dispose();
    _textFieldZFocus.dispose();

    super.dispose();
  }

  void _textFieldXListener() {
    // Code to execute when text field 1 changes
    if (!_textFieldXFocus.hasFocus) {
      double newX = double.parse(_textXController.text);
      double ratio = newX / widget.xValue;
      if (_isChecked) {
        setState(() {
          _x = newX;
          _y = ratio * widget.yValue;
          _z = ratio * widget.zValue;
          _textYController.text = _y.toString();
          _textZController.text = _z.toString();
        });
      } else {
        setState(() {
          _x = newX;
        });
      }
    }
  }

  void _textFieldYListener() {
    // Code to execute when text field 2 changes
    if (!_textFieldYFocus.hasFocus) {
      double newY = double.parse(_textYController.text);
      double ratio = newY / widget.yValue;
      if (_isChecked) {
        setState(() {
          _x = ratio * widget.xValue;
          _y = newY;
          _z = ratio * widget.zValue;
          _textXController.text = _x.toString();
          _textZController.text = _z.toString();
        });
      } else {
        setState(() {
          _y = newY;
        });
      }
    }
  }

  void _textFieldZListener() {
    // Code to execute when text field 3 changes
    if (!_textFieldZFocus.hasFocus) {
      double newZ = double.parse(_textZController.text);
      double ratio = newZ / widget.zValue;
      if (_isChecked) {
        setState(() {
          _x = ratio * widget.xValue;
          _y = ratio * widget.yValue;
          _z = newZ;
          _textXController.text = _x.toString();
          _textYController.text = _y.toString();
        });
      } else {
        setState(() {
          _z = newZ;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final numericFormatter =
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,10}'));

    return AlertDialog(
      title: const Text('Resize Hull'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Checkbox(
                value: _isChecked,
                onChanged: (bool? newValue) {
                  setState(() {
                    _isChecked = newValue!;
                  });
                },
              ),
              const Text('Resize Proportionally'),
            ],
          ),
          TextField(
            controller: _textXController,
            decoration: const InputDecoration(labelText: 'Width'),
            keyboardType: TextInputType.number,
            inputFormatters: [numericFormatter],
            focusNode: _textFieldXFocus,
          ),
          TextField(
            controller: _textYController,
            decoration: const InputDecoration(labelText: 'Height'),
            keyboardType: TextInputType.number,
            inputFormatters: [numericFormatter],
            focusNode: _textFieldYFocus,
          ),
          TextField(
            controller: _textZController,
            decoration: const InputDecoration(labelText: 'Length'),
            keyboardType: TextInputType.number,
            inputFormatters: [numericFormatter],
            focusNode: _textFieldZFocus,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Perform action on button press
            widget.onSubmit(_x, _y, _z);

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
