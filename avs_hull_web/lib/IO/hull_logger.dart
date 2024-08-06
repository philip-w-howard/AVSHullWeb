// ***************************************************************
// Part of the AVS Hull program
// Released under the MIT license.
// See https://github.com/philip-w-howard/AVSHullWeb for details
// ***************************************************************
import '../models/hull.dart';

class HullLogger {
  final List<Hull> _hullLog = [];

  void logHull(Hull snapshot) {
    _hullLog.add(Hull.copy(snapshot));
  }

  Hull? popLog() {
    if (_hullLog.isEmpty) {
      return null;
    } else {
      Hull result = _hullLog.last;
      _hullLog.removeLast();
      return result;
    }
  }

  bool isEmpty() {
    return _hullLog.isEmpty;
  }

  void clear() {
    _hullLog.clear();
  }
}
