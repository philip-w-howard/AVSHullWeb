// ***************************************************************
// Part of the AVS Hull program
// Released under the MIT license.
// See https://github.com/philip-w-howard/AVSHullWeb for details
// ***************************************************************

import 'package:flutter/material.dart';
import 'panel.dart';
import '../geometry/hull_math.dart';

class PanelLayout {
  final List<Panel> _panels = [];
  DateTime _timeUpdated = DateTime.now();

  int length() {
    return _panels.length;
  }

  void addPanel(Panel panel) {
    _panels.add(panel);
    _timeUpdated = DateTime.now();
  }

  void removePanel(int index) {
    _panels.removeAt(index);
  }

  void clear() {
    _panels.clear();
    _timeUpdated = DateTime.now();
  }

  // *************************************************************
  Panel get(int index) {
    return _panels[index];
  }

  DateTime timestamp() {
    return _timeUpdated;
  }

  void rotate(int index, double angle) {
    if (index >= 0 && index < _panels.length) {
      _panels[index].mPoints = rotate2D(_panels[index].mPoints, -angle);
      _timeUpdated = DateTime.now();
    }
  }

  void moveBy(int index, double x, double y) {
    if (index >= 0 && index < _panels.length) {
      _panels[index].origin =
          Offset(_panels[index].origin.dx + x, _panels[index].origin.dy + y);
    }
  }

  void flipVertically(int index) {
    if (index >= 0 && index < _panels.length) {
      for (int ii = 0; ii < _panels[index].mPoints.length; ii++) {
        _panels[index].mPoints[ii] = Offset(
            _panels[index].mPoints[ii].dx, -_panels[index].mPoints[ii].dy);
      }
    }
  }

  void flipHorizontally(int index) {
    if (index >= 0 && index < _panels.length) {
      for (int ii = 0; ii < _panels[index].mPoints.length; ii++) {
        _panels[index].mPoints[ii] = Offset(
            -_panels[index].mPoints[ii].dx, _panels[index].mPoints[ii].dy);
      }
    }
  }
}
