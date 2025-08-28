// ***************************************************************
// Part of the AVS Hull program
// Released under the MIT license.
// See https://github.com/philip-w-howard/AVSHullWeb for details
// ***************************************************************

import 'package:avs_hull_web/geometry/hull_math.dart';
import 'package:avs_hull_web/models/hull_manager.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';
import 'dart:math' as math;
import '../models/panel.dart';
import '../models/panel_layout.dart';
import '../settings/settings.dart';

class PanelPainter extends CustomPainter {
  BuildContext? _context;
  double _scale = 1.0;
  double _translateX = 0;
  double _translateY = 0;

  LayoutSettings _layoutSettings = loadLayoutSettings();
  int _selectedPanel = -1;

  PanelPainter();

  void setContext(BuildContext context) {
    _context = context;
  }

  void updateLayout() {
    _layoutSettings = loadLayoutSettings();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color.fromARGB(255, 0, 0, 0)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    Path path = Path();


    for (int col = 0; col < _layoutSettings.width; col++) {
      for (int row = 0; row < _layoutSettings.height; row++) {
        path.addRect(Rect.fromLTWH(
            (col * _layoutSettings.panelWidth).toDouble(), (row * _layoutSettings.panelHeight).toDouble(), 
            _layoutSettings.panelWidth.toDouble(), _layoutSettings.panelHeight.toDouble()));
      }
    }
    Offset screenMin = Offset.zero;
    Offset screenMax =
        Offset(
          (_layoutSettings.width * _layoutSettings.panelWidth).toDouble(),
          (_layoutSettings.height * _layoutSettings.panelHeight).toDouble()
          );

    for (int index = 0; index < HullManager().panelLayout.length(); index++) {
      Panel panel = HullManager().panelLayout.get(index);

      Offset panelMin = Offset.zero;
      Offset panelMax = Offset.zero;

      (panelMin, panelMax) = getMinMax2D(panel.getOffsets());

      if (panelMin.dx < screenMin.dx) {
        screenMin = Offset(panelMin.dx, screenMin.dy);
      }

      if (panelMin.dy < screenMin.dy) {
        screenMin = Offset(screenMin.dx, panelMin.dy);
      }

      if (panelMax.dx > screenMax.dx) {
        screenMax = Offset(panelMax.dx, screenMax.dy);
      }

      if (panelMax.dy > screenMax.dy) {
        screenMax = Offset(screenMax.dx, panelMax.dy);
      }

      path.addPolygon(panel.getOffsets(), false);
    }

    double scaleX = 0.9 * size.width / (screenMax.dx - screenMin.dx);
    double scaleY = 0.9 * size.height / (screenMax.dy - screenMin.dy);

    _scale = math.min(scaleX, scaleY);
    _translateX = 0.05 * size.width;
    _translateY = 0.05 * size.height;
    if (screenMin.dx < 0) _translateX -= _scale * screenMin.dx;
    if (screenMin.dy < 0) _translateY -= _scale * screenMin.dy;

    //print('draw factors: $_scale, ($_translateX, $_translateY)');
    Matrix4 xform = Matrix4.compose(Vector3(_translateX, _translateY, 0),
        Quaternion.identity(), Vector3(_scale, _scale, _scale));

    Path drawPath = path.transform(xform.storage);

    canvas.drawPath(drawPath, paint);

    if (_selectedPanel >= 0 && _selectedPanel < HullManager().panelLayout.length()) {
      path = Path();
      path.addPolygon(HullManager().panelLayout.get(_selectedPanel).getOffsets(), false);
      drawPath = path.transform(xform.storage);
      paint.color = const Color.fromRGBO(255, 0, 0, 1.0);
      canvas.drawPath(drawPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  void redraw() {
    final RenderBox? renderBox = _context?.findRenderObject() as RenderBox?;
    renderBox?.markNeedsPaint();
  }

  double scale() {
    return _scale;
  }

  int clickInPanel(Offset click) {
    Offset location = Offset(
        (click.dx - _translateX) / _scale, (click.dy - _translateY) / _scale);
    for (int ii = 0; ii < HullManager().panelLayout.length(); ii++) {
      final Path path = Path();
      path.addPolygon(HullManager().panelLayout.get(ii).getOffsets(), false);
      if (path.contains(location)) return ii;
    }
    return -1;
  }

  void selectedPanel(int index) {
    _selectedPanel = index;
  }
}
