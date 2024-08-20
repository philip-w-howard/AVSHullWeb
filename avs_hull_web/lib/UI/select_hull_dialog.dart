// ***************************************************************
// Part of the AVS Hull program
// Released under the MIT license.
// See https://github.com/philip-w-howard/AVSHullWeb for details
// ***************************************************************

import 'package:avs_hull_web/IO/file_io.dart';
import 'package:flutter/material.dart';
import '../settings/settings.dart';

// *****************************************************
class SelectHullDialog extends StatefulWidget {
  const SelectHullDialog(
      {super.key, required this.onSubmit});

  final Function(String selectedHull) onSubmit;

  @override
  SelectHullDialogState createState() => SelectHullDialogState();
}

class SelectHullDialogState extends State<SelectHullDialog> {
  late List<String> _hullNames;
  String _selectedHull = unnamedHullName;

  @override
  void initState() {
    super.initState();
    _hullNames = getHullNames();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Hull'),
           content: SizedBox(
            // width: double.maxFinite,
            width: 300,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _hullNames.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(_hullNames[index]),
                  selected: _selectedHull == _hullNames[index],
                  onTap: () {
                    setState(() {
                      _selectedHull = _hullNames[index];
                    });
                  },
                );
              },
            ),
          ),
      actions: [
        TextButton(
          onPressed: () {
            // Perform action on button press
            widget.onSubmit(_selectedHull);

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

