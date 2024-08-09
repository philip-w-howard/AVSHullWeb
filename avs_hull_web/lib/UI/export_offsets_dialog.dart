// ***************************************************************
// Part of the AVS Hull program
// Released under the MIT license.
// See https://github.com/philip-w-howard/AVSHullWeb for details
// ***************************************************************

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../settings/settings.dart';

// *****************************************************
class ExportOffsetsDialog extends StatefulWidget {
  const ExportOffsetsDialog(
      {super.key, required this.onSubmit, required this.offsetParams});

  final Function(ExportOffsetsParams params) onSubmit;
  final ExportOffsetsParams offsetParams;

  @override
  OffsetsDialogState createState() => OffsetsDialogState();
}

class OffsetsDialogState extends State<ExportOffsetsDialog> {
  late ExportOffsetsParams _params;

  @override
  void initState() {
    super.initState();
    _params = widget.offsetParams;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Export Offsets'),
      content: SingleChildScrollView(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          OutputPrecisioneSelector(
              param: _params.precision,
              update: (OffsetsPrecision precision) {
                _params.precision = precision;
              }),
          SpacingStyleSelector(
              param: _params.spacingStyle,
              update: (SpacingStyle style) {
                _params.spacingStyle = style;
              }),
          DoubleEntry(
              title: const InputDecoration(labelText: 'Spacing'),
              initValue: _params.spacing.toString(),
              update: (double spacing) {
                _params.spacing = spacing;
              }),
          OriginSelector(
              param: _params.origin,
              update: (Origin origin) {
                _params.origin = origin;
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

// ****************************************************************
Map<OffsetsPrecision, String> enumOffsetsPrecision = {
  OffsetsPrecision.eigths: '8ths',
  OffsetsPrecision.sixteenths: '16ths',
  OffsetsPrecision.thirtysecondths: '32ndths',
  OffsetsPrecision.decimal2Digits: '2-digit decimal',
  OffsetsPrecision.decimal3Digits: '3-digit decimal',
  OffsetsPrecision.decimal4Digits: '4-digit decimal',  
} ;

// ****************************************************************
class OutputPrecisioneSelector extends DropdownMenu<OffsetsPrecision> {

  OutputPrecisioneSelector(
      {super.key,
      required OffsetsPrecision param,
      required ValueChanged<OffsetsPrecision> update})
      : super(
          initialSelection: param,
          onSelected: (OffsetsPrecision? newValue) {           
                if (newValue != null) {
                  update(newValue);
                }
            },
          dropdownMenuEntries: enumOffsetsPrecision.entries.map((entry) {
            return DropdownMenuEntry<OffsetsPrecision>(
              value: entry.key,
              label: entry.value,
            );
          }).toList(),
        );
}

Map<SpacingStyle, String> enumSpacingStyle = {
  SpacingStyle.everyPoint: 'every point',
  SpacingStyle.fixedSpacing: 'fixed spacing',
} ;

// ****************************************************************
class SpacingStyleSelector extends DropdownMenu<SpacingStyle> {
  SpacingStyleSelector(
      {super.key,
      required SpacingStyle param,
      required ValueChanged<SpacingStyle> update})
      : super(
          initialSelection: param,
          onSelected: (SpacingStyle? newValue) {
            if (newValue != null) {
              update(newValue);
            }
          },
          dropdownMenuEntries: enumSpacingStyle.entries.map((entry) {
            return DropdownMenuEntry<SpacingStyle>(
              value: entry.key,
              label: entry.value,
            );
          }).toList(),
        );
}

// ****************************************************************
Map<Origin, String> enumOrigin = {
  Origin.center: 'center',
  Origin.lowerLeft: 'lower left',
  Origin.upperLeft: 'upper left',
};

class OriginSelector extends DropdownMenu<Origin> {
  OriginSelector(
      {super.key,
      required Origin param,
      required ValueChanged<Origin> update})
      : super(
          initialSelection: param,
          onSelected: (Origin? newValue) {
            if (newValue != null) {
              update(newValue);
            }
          },
          dropdownMenuEntries: enumOrigin.entries.map((entry) {
            return DropdownMenuEntry<Origin>(
              value: entry.key,
              label: entry.value,
            );
          }).toList(),
        );
}

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
