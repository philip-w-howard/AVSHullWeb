import 'package:flutter/material.dart';
import '../models/hull.dart';
import '../models/bulkhead.dart';
import '../models/panel.dart';
import '../models/panel_layout.dart';
import 'file_io.dart';
import '../settings/settings.dart';
import '../geometry/fixed_offsets.dart';
import '../geometry/point_3d.dart';

bool exportPanelOffset(PanelLayout panels, ExportOffsetsParams params, LayoutSettings layout) {
  String output = '';

  for (int index = 0; index < panels.length(); index++) {
    output += _offsetString(panels.get(index), params, layout);
  }
  
  saveFile(output, 'offsets', 'txt');

  return false;
}

bool exportBulkheads(Hull hull, ExportOffsetsParams params, LayoutSettings layout) {
  String output = '';

  Point3D max = hull.max();

  for (int index = 0; index < hull.mBulkheads.length; index++) {
    if (hull.mBulkheads[index].mBulkheadType != BulkheadType.bow) {
      Panel panel = Panel.fromBulkhead(hull.mBulkheads[index], center: false);

      panel.name = 'Bulkhead ${index+1} Z:${hull.mBulkheads[index].mPoints[0].z}' +
        ' Y:${max.y - hull.mBulkheads[index].mPoints[0].y}';
      output += _offsetString(panel, params, layout);
    }
  }
  
  saveFile(output, 'bulkheads', 'txt');

  return false;
}

// **********************************************************
String _offsetString(Panel panel, ExportOffsetsParams params, LayoutSettings layout) {
  String output = '';

  output += 'Panel ${panel.name}\n\n';

  List<Offset> offsets;

  if (params.spacingStyle == SpacingStyle.fixedSpacing) {
    offsets = getFixedOffsets(panel, params.spacing);
  } else {
    offsets = panel.getOffsets();
  }

  for (int i = 0; i < offsets.length - 1; i++) {
    output += '${formatPoint(offsets[i], params, layout)}\n';
  }

  output += '\n';

  return output;
}
 