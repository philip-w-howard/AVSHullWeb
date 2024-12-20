// ***************************************************************
// Part of the AVS Hull program
// Released under the MIT license.
// See https://github.com/philip-w-howard/AVSHullWeb for details
// ***************************************************************

import 'package:avs_hull_web/UI/input_helpers.dart';
import 'package:flutter/material.dart';
import '../models/hull.dart';
import 'hull_window.dart';
import '../models/rotated_hull.dart';

class WaterlineScreen extends StatelessWidget {
  WaterlineScreen(this._hull, {super.key}) {
    _hullWindow = HullWindow(_hull, HullView.rotated, null, null, xyz: XYZWidget());
    _hullWindow.setRotatable();

    resetScreen();
  }

  final Hull _hull;
  late final HullWindow _hullWindow;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Column(
            children: [
              const Text('this is row 1'),
              const Text('this is row 2'),
              const Text('this is row 3'),
              TextButton(
                onPressed: () {
                  _hullWindow.setView(HullView.front);
                },
                child: const Text('Show Front'),
              ),
              TextButton(
                onPressed: () {
                  _hullWindow.setView(HullView.side);
                },
                child: const Text('Show Side'),
              ),
              TextButton(
                onPressed: () {
                  _hullWindow.setView(HullView.top);
                },
                child: const Text('Show Top'),
              ),
            ],
          ),
          _hullWindow,
        ],
      ),
    );
  }

  void resetScreen() {
    _hullWindow.resetView();
  }
}
