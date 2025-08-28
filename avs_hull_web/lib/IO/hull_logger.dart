// ***************************************************************
// Part of the AVS Hull program
// Released under the MIT license.
// See https://github.com/philip-w-howard/AVSHullWeb for details
// ***************************************************************
import '../models/hull.dart';
import '../models/hull_manager.dart';

class HullLogger {
  final List<Hull> _hullLog = [];

  void logHull() {
    _hullLog.add(Hull.copy(HullManager().hull));
  }

  void popLog() {
    if (_hullLog.isNotEmpty) {
      HullManager().hull.updateFromHull(_hullLog.last);
      _hullLog.removeLast();
    }
  }

  bool isEmpty() {
    return _hullLog.isEmpty;
  }

  void clear() {
    _hullLog.clear();
  }
}
