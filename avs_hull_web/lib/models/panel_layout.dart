// ***************************************************************
// Part of the AVS Hull program
// Released under the MIT license.
// See https://github.com/philip-w-howard/AVSHullWeb for details
// ***************************************************************

import 'package:avs_hull_web/settings/settings.dart';
import 'package:flutter/material.dart';
import 'panel.dart';
import '../geometry/hull_math.dart';

class PanelLayout {
  final List<Panel> _panels = [];
  DateTime timeUpdated = DateTime.now();
  DateTime timeSaved = DateTime.now();

  void addPanel(Panel panel) {
    _panels.add(panel);
    timeUpdated = DateTime.now();
  }

  void removePanel(int index) {
    _panels.removeAt(index);
  }

  void clear() {
    _panels.clear();
    timeUpdated = DateTime.now();
  }

  // *************************************************************
  Panel get(int index) {
    return _panels[index];
  }

  DateTime timestamp() {
    return timeUpdated;
  }

  void rotate(int index, double angle) {
    if (index >= 0 && index < _panels.length) {
      _panels[index].mPoints = rotate2D(_panels[index].mPoints, -angle);
      timeUpdated = DateTime.now();
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

  void updateFromJson(Map<String, dynamic> json) {
    _panels.clear();
    if (json['panels'] != null) {
      for (var panelJson in json['panels']) {
        _panels.add(Panel.fromJson(panelJson));
      }
    }
    if (json['timeUpdated'] != null) {
      timeUpdated = DateTime.parse(json['timeUpdated']);
    } else {
      timeUpdated = DateTime.now();
    }
    if (json['timeSaved'] != null) {
      timeSaved = DateTime.parse(json['timeSaved']);
    } else {
      timeSaved = DateTime.now();
    }
  }

  int length() {
    return _panels.length;
  }

  Map<String, dynamic> toJson() {
    LayoutSettings layoutSettings = loadLayoutSettings();
    return {
      'panels': _panels.map((panel) => panel.toJson()).toList(),
      'layoutSettings': layoutSettings.toJson(),
      'timeUpdated': timeUpdated.toIso8601String(),
      'timeSaved': timeSaved.toIso8601String(),
    };
  }

}
