import 'package:flutter/material.dart';
import '../models/panel.dart';
import '../models/panel_layout.dart';
import 'file_io.dart';
import '../settings/settings.dart';

bool exportPanelOffset(PanelLayout panels, ExportOffsetsParams params) {
  String output = '';

  for (int index = 0; index < panels.length(); index++) {
    output += _offsetString(panels.get(index), params);
  }
  
  saveFile(output, 'offsets', 'txt');

  return false;
}

// **********************************************************
String _offsetString(Panel panel, ExportOffsetsParams params) {
  String output = '';

  output += 'Panel ${panel.name}\n\n';

  List<Offset> offsets = panel.getOffsets();
  for (Offset offset in offsets) {
    output += '(${offset.dx}, ${offset.dy})\n';
  }

  output += '\n';

  return output;
}
