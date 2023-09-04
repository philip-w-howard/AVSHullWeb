// ***************************************************************
// Part of the AVS Hull program
// Released under the MIT license.
// See https://github.com/philip-w-howard/AVSHullWeb for details
// ***************************************************************

import 'package:avs_hull_web/hull_math.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';
import 'dart:math' as math;
import 'panel.dart';

class PanelPainter extends CustomPainter {
  BuildContext? _context;
  double _scale = 1.0;
  double _translateX = 0;
  double _translateY = 0;

  int _numPanelsX = 1;
  int _numPanelsY = 1;
  double _panelWidth = 96;
  double _panelHeight = 48;
  int _selectedPanel = -1;

  List<Panel> _panelList = [];

  PanelPainter(this._panelList);

  void setContext(BuildContext context) {
    _context = context;
  }

  void updateLayout(int numX, int numY, double sizeX, double sizeY) {
    _numPanelsX = numX;
    _numPanelsY = numY;
    _panelWidth = sizeX;
    _panelHeight = sizeY;
  }

  void updatePanelList(List<Panel> panelList) {
    _panelList = panelList;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color.fromARGB(255, 0, 0, 0)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    Path path = Path();

    for (int col = 0; col < _numPanelsX; col++) {
      for (int row = 0; row < _numPanelsY; row++) {
        path.addRect(Rect.fromLTWH(
            col * _panelWidth, row * _panelHeight, _panelWidth, _panelHeight));
      }
    }
    Offset screenMin = Offset.zero;
    Offset screenMax =
        Offset(_numPanelsX * _panelWidth, _numPanelsY * _panelHeight);

    for (Panel panel in _panelList) {
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

    Matrix4 xform = Matrix4.compose(Vector3(_translateX, _translateY, 0),
        Quaternion.identity(), Vector3(_scale, _scale, _scale));

    Path drawPath = path.transform(xform.storage);

    canvas.drawPath(drawPath, paint);

    if (_selectedPanel >= 0 && _selectedPanel < _panelList.length) {
      path = Path();
      path.addPolygon(_panelList[_selectedPanel].getOffsets(), false);
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
    Offset location = Offset(click.dx / _scale, click.dy / _scale);
    for (int ii = 0; ii < _panelList.length; ii++) {
      final Path path = Path();
      path.addPolygon(_panelList[ii].getOffsets(), false);
      if (path.contains(location)) return ii;
    }
    return -1;
  }

  void selectedPanel(int index) {
    _selectedPanel = index;
  }
}
