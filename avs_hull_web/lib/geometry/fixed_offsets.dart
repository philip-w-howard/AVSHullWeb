// ***************************************************************
// Part of the AVS Hull program
// Released under the MIT license.
// See https://github.com/philip-w-howard/AVSHullWeb for details
// ***************************************************************

import 'package:flutter/material.dart';
import '../models/panel.dart';
import 'hull_math.dart';
import '../settings/settings.dart';

const double _kneeAngle = 5;         // min angle of a knee in degrees

List<Offset> getFixedOffsets(Panel source, double fixedOffset)
{
  List<Offset> offsets = [];
  List<Offset> sourceOffsets = source.getOffsets();

  Offset p1 = sourceOffsets[sourceOffsets.length - 2];
  Offset p2 = sourceOffsets[sourceOffsets.length - 1];
  Offset p3 = p1;

  bool first = true;

  for (Offset p in sourceOffsets)
  {
    p3 = p;

    if (!first && isKnee(p1, p2, p3, _kneeAngle))
    {
      offsets.add(p2);
    }

    first = false;


    if (spansX(p2, p3, fixedOffset.toInt()))
    {
      Offset temp = computeSpacingPoint(p2, p3, fixedOffset.toInt());
      offsets.add(temp);
    }

    p1 = p2;
    p2 = p3;
  }

  offsets.add(p3);

  return offsets;
}

String fraction(double value, int denominator)
{
    int intPart = value.toInt();
    double fNumerator = value - intPart;
    int numerator = (fNumerator*denominator).round().abs();

    String intStr = '$intPart'.padLeft(5);
    String result = '$intStr-$numerator/$denominator'.padRight(12);

    return result;
}
String decimal(double value, int digits)
{
    String result = value.toStringAsFixed(digits).padLeft(10);

    return result;
}

String formatPoint(Offset point, ExportOffsetsParams params, LayoutSettings layout)
{
    String result = "";

    // double layout_width = layout.SheetsWide * layout.SheetWidth;
    // double layout_height = layout.SheetsHigh * layout.SheetHeight;
    double layoutWidth = (layout.width * layout.panelWidth).toDouble();
    double layoutHeight = (layout.height * layout.panelHeight).toDouble();

    if (params.origin == Origin.upperLeft)
    {
        point = Offset(point.dx, point.dy);
    }
    else if (params.origin == Origin.center)
    {
        point = Offset(point.dx + layoutWidth / 2, point.dy - layoutHeight / 2);
    }
    else if (params.origin == Origin.lowerLeft)
    {
        point = Offset(point.dx, -(point.dy - layoutHeight));
    }

    switch (params.precision)
    {
        case OffsetsPrecision.eigths:
            result = '${fraction(point.dx, 8)} ${fraction(point.dy, 8)}';
            break;
        case OffsetsPrecision.sixteenths:
            result = '${fraction(point.dx, 16)} ${fraction(point.dy, 16)}';
            break;
        case OffsetsPrecision.thirtysecondths:
            result = '${fraction(point.dx, 32)} ${fraction(point.dy, 32)}';
            break;
        case OffsetsPrecision.decimal2Digits:
            result = '${decimal(point.dx, 2)} ${decimal(point.dy, 2)}';
            break;
        case OffsetsPrecision.decimal3Digits:
            result = '${decimal(point.dx, 3)} ${decimal(point.dy, 3)}';
            break;
        case OffsetsPrecision.decimal4Digits:
            result = '${decimal(point.dx, 4)} ${decimal(point.dy, 4)}';
            break;
      }

    return result;
}
