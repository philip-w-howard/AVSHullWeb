// ***************************************************************
// Part of the AVS Hull program
// Released under the MIT license.
// See https://github.com/philip-w-howard/AVSHullWeb for details
// ***************************************************************

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';
import 'dart:math' as math;
import '../models/bulkhead.dart';
import '../models/waterline_hull.dart';
import '../geometry/spline.dart';

class WaterlinePainter extends CustomPainter {
  final WaterlineHull _myHull;
  BuildContext? _context;
  double _scale = 1.0;
  double _translateX = 0.0;
  double _translateY = 0.0;

  WaterlinePainter(this._myHull);

  void setContext(BuildContext context) {
    _context = context;
  }

  @override
  void paint(Canvas canvas, Size size) {
    
    final paint = Paint()
      ..color = _myHull.getWaterlineCount() > 0 ? 
        const Color.fromARGB(255, 243, 33, 180) :
        const Color.fromARGB(255, 0, 0, 0)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    Path path = Path();

    for (Bulkhead bulkhead in _myHull.mBulkheads) {
      path.addPolygon(_myHull.getBulkheadOffsets(bulkhead), false);
    }

    for (Spline chine in _myHull.mChines) {
      path.addPolygon(_myHull.getSplinesOffsets(chine), false);
    }

    Rect bounds = path.getBounds();

    // Scale to fit using the 'size' parameter
    double scaleX = 0.9 * size.width / bounds.width;
    double scaleY = 0.9 * size.height / bounds.height;

    _scale = math.min(scaleX, scaleY);
    _translateX = 0.05 * size.width - bounds.left * _scale;
    _translateY = 0.05 * size.height - bounds.top * _scale;

    Matrix4 xform = Matrix4.compose(Vector3(_translateX, _translateY, 0),
        Quaternion.identity(), Vector3(_scale, _scale, _scale));

    Path drawPath = path.transform(xform.storage);

    canvas.drawPath(drawPath, paint);

    // Draw the waterlines if they exist
    path = Path();
    paint.color = const Color.fromARGB(255, 0, 0, 255);

    for (int ii=0; ii<_myHull.getWaterlineCount(); ii++) {
      path.addPolygon(_myHull.getWaterlineOffsets(ii), true);
    }
    
    drawPath = path.transform(xform.storage);
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
