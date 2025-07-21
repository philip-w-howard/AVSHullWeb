// ***************************************************************
// Part of the AVS Hull program
// Released under the MIT license.
// See https://github.com/philip-w-howard/AVSHullWeb for details
// ***************************************************************

import 'package:avs_hull_web/UI/input_helpers.dart';
import 'package:flutter/material.dart';
import '../models/hull.dart';
import '../models/rotated_hull.dart';
import '../models/waterline_hull.dart';
import 'waterline_painter.dart';
import 'package:flutter/services.dart';

class WaterlineDrawDetails {
  double? height;
  Size size = Size.infinite;
}

class WaterlineWindow extends StatelessWidget {
  late final XYZWidget xyz;

  late final WaterlinePainter _painter;
  late final WaterlineHull _myHull;
  final WaterlineDrawDetails _drawDetails = WaterlineDrawDetails();
  final FocusNode _focusNode = FocusNode();

  WaterlineWindow(WaterlineHull hull, HullView view,
      {super.key, required this.xyz}) {
    _myHull = WaterlineHull.copy(hull);

    _myHull.setView(view);
    _painter = WaterlinePainter(_myHull);
  }

  void setHeight(double height) {
    _drawDetails.height = height;
  }

  void setView(HullView view) {
    _myHull.setView(view);
    _painter.redraw();
  }

  @override
  Widget build(BuildContext context) {
    _painter.setContext(context);
    return Expanded(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          _drawDetails.size = constraints.biggest;
          return KeyboardListener(
            focusNode: _focusNode,
            child: Container(
              height: _drawDetails.height,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 1.0,
                ),
                color: Colors.yellow,
              ),
              child: GestureDetector(
                child: MouseRegion(
                  onHover: _hover,
                  child: CustomPaint(
                    painter: _painter,
                    size: Size.infinite,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _hover(PointerEvent details) {
    double rawX,rawY;
    double x,y,z;

    (rawX, rawY) = _painter.toHullCoords(details.localPosition);

    switch (_myHull.getView()) {
      case HullView.front:
        x = rawX - _myHull.size().x/2;
        y = _myHull.size().y - rawY;
        z = 0;
        break;
      case HullView.side:
        x = 0;
        y = _myHull.size().y - rawY;
        z = rawX;
        break;
      case HullView.top:
        x = rawY - _myHull.size().y/2;
        y = 0;
        z = rawX;
        break;
      default:
        x = 0;
        y = 0;
        z = 0;
        break;
    }
    xyz.setX(x);
    xyz.setY(y);
    xyz.setZ(z);   
  }


  void redraw() {
    _painter.redraw();
  }
}
