// ***************************************************************
// Part of the AVS Hull program
// Released under the MIT license.
// See https://github.com/philip-w-howard/AVSHullWeb for details
// ***************************************************************

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Panel.dart';

class AddPanelsDialog extends StatefulWidget {
  const AddPanelsDialog(this._panels, {super.key, required this.onSubmit});

  final Function(List<int>) onSubmit;
  final List<Panel> _panels;

  @override
  AddPanelsDialogState createState() => AddPanelsDialogState(_panels);
}

class AddPanelsDialogState extends State<AddPanelsDialog> {
  AddPanelsDialogState(this._panels) {
//    _itemList = [];
  }

  final List<Panel> _panels;
  //List<Checkbox> _itemList;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final numericFormatter =
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,10}'));

    return AlertDialog(
      title: const Text('Add Panels'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row(
          //   children: [
          //     Checkbox(
          //       value: _isChecked,
          //       onChanged: (bool? newValue) {
          //         setState(() {
          //           _isChecked = newValue!;
          //         });
          //       },
          //     ),
          //     const Text('Resize Proportionally'),
          //   ],
          // ),
          // TextField(
          //   controller: _textXController,
          //   decoration: const InputDecoration(labelText: 'Width'),
          //   keyboardType: TextInputType.number,
          //   inputFormatters: [numericFormatter],
          //   focusNode: _textFieldXFocus,
          // ),
          // TextField(
          //   controller: _textYController,
          //   decoration: const InputDecoration(labelText: 'Height'),
          //   keyboardType: TextInputType.number,
          //   inputFormatters: [numericFormatter],
          //   focusNode: _textFieldYFocus,
          // ),
          // TextField(
          //   controller: _textZController,
          //   decoration: const InputDecoration(labelText: 'Length'),
          //   keyboardType: TextInputType.number,
          //   inputFormatters: [numericFormatter],
          //   focusNode: _textFieldZFocus,
          // ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Perform action on button press
//            widget.onSubmit(_x, _y, _z);

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
