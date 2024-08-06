// ***************************************************************
// Part of the AVS Hull program
// Released under the MIT license.
// See https://github.com/philip-w-howard/AVSHullWeb for details
// ***************************************************************

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';
import 'dart:math' as math;
import '../geometry/point_3d.dart';
import '../models/bulkhead.dart';
import '../models/rotated_hull.dart';
import '../geometry/spline.dart';

class HullPainter extends CustomPainter {
  static const double _nearnessDistance = 5;

  final RotatedHull _myHull;
  BuildContext? _context;
  double _scale = 1.0;
  double _translateX = 0.0;
  double _translateY = 0.0;

  HullPainter(this._myHull);

  void setContext(BuildContext context) {
    _context = context;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color.fromARGB(255, 243, 33, 180)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    if (_myHull.isEditable()) paint.color = const Color.fromARGB(255, 0, 0, 0);

    Point3D hullSize = _myHull.size();
    Path path = Path();

    // Scale to fit using the 'size' parameter
    for (Bulkhead bulkhead in _myHull.mBulkheads) {
      path.addPolygon(bulkhead.getOffsets(), false);
    }

    for (Spline chine in _myHull.mChines) {
      path.addPolygon(chine.getOffsets(), false);
    }

    double scaleX = 0.9 * size.width / hullSize.x;
    double scaleY = 0.9 * size.height / hullSize.y;

    _scale = math.min(scaleX, scaleY);
    _translateX = 0.05 * size.width;
    _translateY = 0.05 * size.height;

    Matrix4 xform = Matrix4.compose(Vector3(_translateX, _translateY, 0),
        Quaternion.identity(), Vector3(_scale, _scale, _scale));

    // Add handles after computing the xform, so they don't impact scale.
    if (_myHull.bulkheadIsSelected && _myHull.isEditable()) {
      for (int index = 0;
          index < _myHull.mBulkheads[_myHull.selectedBulkhead].numPoints();
          index++) {
        Point3D p = _myHull.mBulkheads[_myHull.selectedBulkhead].point(index);
        Offset handleCenter = Offset(p.x, p.y);
        Rect handle = Rect.fromCenter(
            center: handleCenter,
            width: _nearnessDistance / _scale,
            height: _nearnessDistance / _scale);
        path.addRect(handle);
      }

      if (_myHull.movingHandle) {
        Offset handleCenter =
            Offset(_myHull.movingHandleX, _myHull.movingHandleY);
        Rect handle = Rect.fromCenter(
            center: handleCenter,
            width: _nearnessDistance / _scale,
            height: _nearnessDistance / _scale);
        path.addRect(handle);
      }
    }

    Path drawPath = path.transform(xform.storage);

    canvas.drawPath(drawPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  (double, double) toHullCoords(Offset point) {
    double x = (point.dx - _translateX) / _scale;
    double y = (point.dy - _translateY) / _scale;

    return (x, y);
  }

  void redraw() {
    final RenderBox? renderBox = _context?.findRenderObject() as RenderBox?;
    renderBox?.markNeedsPaint();
  }

  double scale() {
    return _scale;
  }
}
