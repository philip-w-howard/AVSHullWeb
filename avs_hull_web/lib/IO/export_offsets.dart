import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:html' as html;
import '../UI/export_offsets_dialog.dart';
import '../models/panel.dart';
import '../models/panel_layout.dart';

bool exportPanelOffset(PanelLayout panels, OffsetsParams params) {
  String output = '';

  for (int index = 0; index < panels.length(); index++) {
    output += offsetString(panels.get(index), params);
  }
  
  saveFile(output, 'txt');

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
// **********************************************************
// Could make function in design_screen.dart public and use that.
void saveFile(String contents, String extension) async {
  final encodedContent = base64.encode(utf8.encode(contents));

  final anchor = html.AnchorElement(
    href: 'data:text/plain;charset=utf-8;base64,$encodedContent',
  );
  anchor.download = 'saved_hull.$extension';
  anchor.click();
}
