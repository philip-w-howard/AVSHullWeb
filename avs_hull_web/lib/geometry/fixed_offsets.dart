// ***************************************************************
// Part of the AVS Hull program
// Released under the MIT license.
// See https://github.com/philip-w-howard/AVSHullWeb for details
// ***************************************************************

import 'package:flutter/material.dart';
import '../models/panel.dart';
import 'hull_math.dart';

const double _kneeAngle = 5;         // min angle of a knee in degrees

List<Offset> getFixedOffsets(Panel source, double fixedOffset)
{
  List<Offset> offsets = [];
  List<Offset> sourceOffsets = source.getOffsets();

  Offset p1 = sourceOffsets[sourceOffsets.length - 2];
  Offset p2 = sourceOffsets[sourceOffsets.length - 1];
  Offset p3;
  bool first = true;

  for (Offset p in sourceOffsets)
  {
    p3 = p;

    if (first)
    {
      print('add first ${p3.toString()}');
      offsets.add(p3);
      first = false;
    }
    else if (isKnee(p1, p2, p3, _kneeAngle))
    {
      print('add knee ${p2.toString()}');
      offsets.add(p2);
    }


    if (spansX(p2, p3, fixedOffset.toInt()))
    {
      Offset temp = computeSpacingPoint(p2, p3, fixedOffset.toInt());
      print('add span ${temp.toString()}');
      offsets.add(temp);
    }

    p1 = p2;
    p2 = p3;
  }

  return offsets;
}
