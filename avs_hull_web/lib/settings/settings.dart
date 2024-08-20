// ***************************************************************
// Part of the AVS Hull program
// Released under the MIT license.
// See https://github.com/philip-w-howard/AVSHullWeb for details
// ***************************************************************

// ***********************************************************
// Export to Offsets details
import 'dart:convert';
import '../IO/file_io.dart';

enum OffsetsPrecision { eigths, sixteenths, thirtysecondths, decimal2Digits, decimal3Digits, decimal4Digits }
enum SpacingStyle {everyPoint, fixedSpacing}
enum Origin {lowerLeft, upperLeft, center}

const layoutSettingsKey = 'LayoutSettings';
const exportOffsetsParamsKey = 'ExportOffsetsParams';
const lastHullKey = 'LastHullName';
const unnamedHullName = 'unnamed';
const version = '0.3.0';

// ***********************************************************
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
  String jsonString = json.encode(params.toJson());
  writeString(exportOffsetsParamsKey, jsonString);
}

ExportOffsetsParams loadExportOffsetsParams() {
  String? jsonString = readString(exportOffsetsParamsKey);

  if (jsonString != null) {
    Map<String, dynamic> paramsMap = json.decode(jsonString);
    return ExportOffsetsParams.fromJson(paramsMap);
  }

  // If setting not found, create default settings
  return ExportOffsetsParams();
}

// ***************************************************************
// ***************************************************************

class LayoutSettings {
  int width = 1;
  int height = 1;
  int panelWidth = 96;
  int panelHeight = 48;

  LayoutSettings({
    this.width = 1,
    this.height = 1,
    this.panelWidth = 96,
    this.panelHeight = 48
  });

  factory LayoutSettings.fromJson(Map<String, dynamic> json) {
    return LayoutSettings(
      width: json['width'],
      height: json['height'],
      panelWidth: json['panelWidth'],
      panelHeight: json['panelHeight'],
    );
  }

    Map<String, dynamic> toJson() => {
    'width': width,
    'height': height,
    'panelWidth': panelWidth,
    'panelHeight': panelHeight,
  };
}
// ***********************************************************
void saveLayoutSettings(LayoutSettings settings) {
  String jsonString = json.encode(settings.toJson());
  writeString(layoutSettingsKey, jsonString);
}

// ***********************************************************
LayoutSettings loadLayoutSettings() {
  String? jsonString = readString(layoutSettingsKey);
  if (jsonString != null) {
    Map<String, dynamic> settingsMap = json.decode(jsonString);
    return LayoutSettings.fromJson(settingsMap);
  }

  // If setting not found, create default settings
  return LayoutSettings();
}

// ***********************************************************
// ***********************************************************
void recordLastHull(String name) {
  writeString(lastHullKey, name);
}

String fetchLastHullName() {
  String? name =  readString(lastHullKey);

  if (name != null) return name;
  return unnamedHullName;
}