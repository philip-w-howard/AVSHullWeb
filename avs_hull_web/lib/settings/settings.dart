// ***************************************************************
// Part of the AVS Hull program
// Released under the MIT license.
// See https://github.com/philip-w-howard/AVSHullWeb for details
// ***************************************************************

// ***********************************************************
// Export to Offsets details
import 'package:avs_hull_web/IO/file_io.dart';

enum OffsetsPrecision { eigths, sixteenths, thirtysecondths, decimal2Digits, decimal3Digits, decimal4Digits }
enum SpacingStyle {everyPoint, fixedSpacing}
enum Origin {lowerLeft, upperLeft, center}

// ***********************************************************
class ExportOffsetsParams {
  OffsetsPrecision precision = OffsetsPrecision.sixteenths;
  SpacingStyle spacingStyle = SpacingStyle.fixedSpacing;
  double spacing = 6;
  Origin origin = Origin.lowerLeft;

  ExportOffsetsParams( 
  {
    this.precision = OffsetsPrecision.sixteenths,
    this.spacingStyle = SpacingStyle.fixedSpacing,
    this.spacing = 6,
    this.origin = Origin.lowerLeft
  });
 
  factory ExportOffsetsParams.fromJson(Map<String, dynamic> json) {
    return ExportOffsetsParams(
      precision: OffsetsPrecision.values.firstWhere((type) => type.toString() == 'OffsetsPrecision.${json['precision']}'),
      spacingStyle: SpacingStyle.values.firstWhere((type) => type.toString() == 'SpacingStyle.${json['spacingStyle']}'),
      spacing: json['spacing'],
      origin: Origin.values.firstWhere((type) => type.toString() == 'Origin.${json['origin']}'),
    );
  }
  Map<String, dynamic> toJson() => {
    'precision': precision.toString().split('.').last,
    'spacingStyle': spacingStyle.toString().split('.').last,
    'spacing': spacing,
    'origin': origin.toString().split('.').last,
  };
  
}

// ***********************************************************
void saveExportOffsetsParams(ExportOffsetsParams params) {
  writeExportOffsetsParams(params);
}

ExportOffsetsParams loadExportOffsetsParams() {
  return readExportOffsetsParams();
}