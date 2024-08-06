import 'package:flutter/material.dart';
import '../UI/export_offsets_dialog.dart';
import '../models/panel.dart';
import '../models/panel_layout.dart';
import 'file_io.dart';

bool exportPanelOffset(PanelLayout panels, OffsetsParams params) {
  String output = '';

  for (int index = 0; index < panels.length(); index++) {
    output += offsetString(panels.get(index), params);
  }
  
  saveFile(output, 'offsets', 'txt');

  return false;
}

// **********************************************************
String offsetString(Panel panel, OffsetsParams params) {
  String output = '';

  output += 'Panel ${panel.name}\n\n';

  List<Offset> offsets = panel.getOffsets();
  for (Offset offset in offsets) {
    output += '(${offset.dx}, ${offset.dy})\n';
  }

  output += '\n';

  return output;
}
