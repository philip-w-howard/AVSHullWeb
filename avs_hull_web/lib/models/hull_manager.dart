import 'hull.dart';

class HullManager {
  static final HullManager _instance = HullManager._internal();
  factory HullManager() => _instance;
  HullManager._internal();

  final Hull hull = Hull(); 
}