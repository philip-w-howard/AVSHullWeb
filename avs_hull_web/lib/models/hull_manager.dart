import 'hull.dart';
import 'panel_layout.dart';
import '../IO/layout_logger.dart';

class HullManager {
  static final HullManager _instance = HullManager._internal();
  factory HullManager() => _instance;
  HullManager._internal();

  final Hull hull = Hull(); 
  final PanelLayout panelLayout = PanelLayout();
  final LayoutLogger _layoutLogger = LayoutLogger();

  void logLayout() {
    _layoutLogger.logLayout();
  }

  void popLayout() {
    _layoutLogger.popLog();
  }

  void clearLayoutLog() {
    _layoutLogger.clear();
  }

}