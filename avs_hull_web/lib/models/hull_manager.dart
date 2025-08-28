import 'hull.dart';
import 'panel_layout.dart';

class HullManager {
  static final HullManager _instance = HullManager._internal();
  factory HullManager() => _instance;
  HullManager._internal();

  final Hull hull = Hull(); 
  final PanelLayout panelLayout = PanelLayout();
}