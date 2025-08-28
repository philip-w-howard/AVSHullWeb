// ***************************************************************
// Part of the AVS Hull program
// Released under the MIT license.
// See https://github.com/philip-w-howard/AVSHullWeb for details
// ***************************************************************

// ***********************************************************
// Export to Offsets details
import 'dart:convert';
import '../IO/file_io.dart';
import '../models/bulkhead.dart';
import '../models/rotated_hull.dart';

enum OffsetsPrecision { eigths, sixteenths, thirtysecondths, decimal2Digits, decimal3Digits, decimal4Digits }
enum SpacingStyle {everyPoint, fixedSpacing}
enum Origin {lowerLeft, upperLeft, center}

const layoutSettingsKey = 'LayoutSettings';
const hullParamsKey = 'HullParams';
const exportOffsetsParamsKey = 'ExportOffsetsParams';
const waterlineParamsKey = 'WaterlineParams';
const unnamedHullName = 'unnamed';
const version = '0.5.2';

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

  LayoutSettings.copy(LayoutSettings other) {
    width = other.width;
    height = other.height;
    panelWidth = other.panelWidth;
    panelHeight = other.panelHeight;
  }
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

// *****************************************************
// *****************************************************
class HullParams {
  String name = unnamedHullName;
  BulkheadType bow = BulkheadType.bow;
  double forwardTransomAngle = 115;
  BulkheadType stern = BulkheadType.transom;
  double sternTransomAngle = 75;
  int numBulkheads = 5;
  int numChines = 5;
  double length = 96;
  double width = 40;
  double height = 10;
  bool closedTop = false;
  bool flatBottomed = false;

  // **************************************************
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'bow': bow.toString().split('.').last,
      'stern': stern.toString().split('.').last,
      'forwardTransomAngle': forwardTransomAngle,
      'sternTransomAngle': sternTransomAngle,
      'numBulkheads': numBulkheads,
      'numChines': numChines,
      'length': length,
      'width': width,
      'height': height,
      'closedTop': closedTop,
      'flatBottomed': flatBottomed,
    };
  }

  void updateFromJson(Map<String, dynamic> json) {
    BulkheadType bulkType;

    if (json['bow'] != null) {
      try {
        bulkType = BulkheadType.values.firstWhere(
            (type) => type.toString() == 'BulkheadType.${json['bow']}');
        bow = bulkType;
      } catch (e) {
        // If the value from JSON doesn't match any enum, keep the current value
      }
    } 

    if (json['stern'] != null) {
      try {
        bulkType = BulkheadType.values.firstWhere(
            (type) => type.toString() == 'BulkheadType.${json['stern']}');
        stern = bulkType;
      } catch (e) {
        // If the value from JSON doesn't match any enum, keep the current value
      }
    } 
    name = json['name'] ?? name;
    forwardTransomAngle = json['forwardTransomAngle'] ?? forwardTransomAngle;
    sternTransomAngle = json['sternTransomAngle'] ?? sternTransomAngle;
    numBulkheads = json['numBulkheads'] ?? numBulkheads;
    numChines = json['numChines'] ?? numChines;
    length = json['length'] ?? length;
    width = json['width'] ?? width;
    height = json['height'] ?? height;
    closedTop = json['closedTop'] ?? closedTop;
    flatBottomed = json['flatBottomed'] ?? flatBottomed;
  }
}

// ***********************************************************
void saveHullParams(HullParams params) {
  String jsonString = json.encode(params.toJson());
  writeString(hullParamsKey, jsonString);
}

// ***********************************************************
HullParams loadHullParams() {
  String? jsonString = readString(hullParamsKey);
  if (jsonString != null) {
    Map<String, dynamic> settingsMap = json.decode(jsonString);
    HullParams params = HullParams();
    params.updateFromJson(settingsMap);
    return params;
  }

  // If setting not found, create default settings
  return HullParams();
}

// ***********************************************************
// ***********************************************************
class WaterlineParams {
  double heightIncrement = 0.25;  // Height increment for waterlines
  double lengthIncrement = 0.25;  // Length increment for waterlines
  double weight = 200;            // Weight of the loaded hull in pounds   
  double waterDensity = 62.4;     // lb/ft^3
  double heelAngle = 0;           // Angle of heel in degrees
  double pitchAngle = 0;          // Angle of pitch in degrees
  bool showAllWaterlines = false;
  HullView view = HullView.top;

  // Hull params computed based on WaterlineParams
  double freeboard = 0;
  double centroidX = 0;
  double centroidY = 0;
  double centroidZ = 0;
  double rightingMoment = 0;

  // **************************************************
  Map<String, dynamic> toJson() {
    return {
      'heightIncrement': heightIncrement,
      'lengthIncrement': lengthIncrement,
      'weight': weight,
      'waterDensity': waterDensity,
      'heelAngle': heelAngle,
      'pitchAngle': pitchAngle,
      'showAllWaterlines': showAllWaterlines,
      'view': view.toString().split('.').last,
    };
  }

  void updateFromJson(Map<String, dynamic> json) {
    HullView hullView;

    if (json['view'] != null) {
      try {
        hullView = HullView.values.firstWhere(
            (type) => type.toString() == 'HullView.${json['view']}');
        view = hullView;
      } catch (e) {
        // If the value from JSON doesn't match any enum, keep the current value
      }
    } 
    heightIncrement = json['heightIncrement'] ?? heightIncrement;
    lengthIncrement = json['lengthIncrement'] ?? lengthIncrement;
    weight = json['weight'] ?? weight;
    waterDensity = json['waterDensity'] ?? waterDensity;
    heelAngle = json['heelAngle'] ?? heelAngle;
    pitchAngle = json['pitchAngle'] ?? pitchAngle;
    showAllWaterlines = json['showAllWaterlines'] ?? showAllWaterlines;
  }
}
// ***********************************************************
void saveWaterlineParams(WaterlineParams params) {
  String jsonString = json.encode(params.toJson());
  writeString(waterlineParamsKey, jsonString);
}

// ***********************************************************
WaterlineParams loadWaterlineParams() {
  String? jsonString = readString(waterlineParamsKey);
  if (jsonString != null) {
    Map<String, dynamic> settingsMap = json.decode(jsonString);
    WaterlineParams params = WaterlineParams();
    params.updateFromJson(settingsMap);
    return params;
  }

  // If setting not found, create default settings
  return WaterlineParams();
}
