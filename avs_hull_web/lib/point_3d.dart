// ***************************************************************
// Part of the AVS Hull program
// Released under the MIT license.
// See https://github.com/philip-w-howard/AVSHullWeb for details
// ***************************************************************

class Point3D {
  late double x;
  late double y;
  late double z;

  Point3D(this.x, this.y, this.z);

  Point3D.fromJson(Map<String, dynamic> json) {
    x = json['x'] ?? 0;
    y = json['y'] ?? 0;
    z = json['z'] ?? 0;
  }

  @override
  String toString() {
    return 'Point($x, $y, $z)';
  }

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      'z': z,
    };
  }
}
