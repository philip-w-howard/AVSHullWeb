// ***************************************************************
// Part of the AVS Hull program
// Released under the MIT license.
// See https://github.com/philip-w-howard/AVSHullWeb for details
// ***************************************************************

import 'package:flutter/material.dart';
import 'hull.dart';
import 'hull_window.dart';
import 'rotated_hull.dart';

class WaterlineScreen extends StatelessWidget {
  WaterlineScreen({super.key, required this.mHull}) {
    _hullWindow = HullWindow(mHull, HullView.rotated, null, null);
    _hullWindow.setRotatable();

    resetScreen();
  }
  final Hull mHull;
  late final HullWindow _hullWindow;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          //_MainMenu(mHull, context),
          Column(
            children: [
              Text('this is row 1'),
              Text('this is row 2'),
              Text('this is row 3'),
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
