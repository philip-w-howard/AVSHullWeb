// ***************************************************************
// Part of the AVS Hull program
// Released under the MIT license.
// See https://github.com/philip-w-howard/AVSHullWeb for details
// ***************************************************************
import 'package:avs_hull_web/models/hull_manager.dart';
import 'package:avs_hull_web/settings/settings.dart';

import '../models/panel_layout.dart';

class LayoutLogger {
  final List<PanelLayout> _layoutLog = [];
  final List<LayoutSettings> _settingsLog = [];

  void logLayout() {
    _layoutLog.add(PanelLayout.copy(HullManager().panelLayout));
    _settingsLog.add(LayoutSettings.copy(loadLayoutSettings()));
  }

  void popLog() {
    if (_layoutLog.isNotEmpty) {
      HullManager().panelLayout.updateFromCopy(_layoutLog.last);
      saveLayoutSettings(_settingsLog.last);

      _layoutLog.removeLast();
      _settingsLog.removeLast();
    }
  }

  bool isEmpty() {
    return _layoutLog.isEmpty;
  }

  void clear() {
    _layoutLog.clear();
  }
}
