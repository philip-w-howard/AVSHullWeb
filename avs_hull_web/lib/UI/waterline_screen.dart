// ***************************************************************
// Part of the AVS Hull program
// Released under the MIT license.
// See https://github.com/philip-w-howard/AVSHullWeb for details
// ***************************************************************

import 'package:avs_hull_web/UI/input_helpers.dart';
import 'package:flutter/material.dart';
import '../models/hull.dart';
import 'waterline_window.dart';
import 'waterline_params_editor.dart';
import '../models/rotated_hull.dart';
import '../models/waterline_hull.dart';

class WaterlineScreen extends StatefulWidget {
  final Hull hull;
  final WaterlineParams? params;
  const WaterlineScreen(this.hull, {super.key, this.params});

  @override
  State<WaterlineScreen> createState() => _WaterlineScreenState();
}

class _WaterlineScreenState extends State<WaterlineScreen> {
  late WaterlineParams _params;

  void _recomputeWaterlines() {
    setState(() {
      _hull = WaterlineHull(widget.hull, _params);
      _hullWindow = WaterlineWindow(_hull, _hull.getView(), xyz: xyz);
    });
  }
  late WaterlineHull _hull;
  late WaterlineWindow _hullWindow;
  late XYZWidget xyz;

  @override
  void initState() {
    super.initState();
    _params = widget.params ?? WaterlineParams();
    _createWaterlineHull();
  }

  @override
  void didUpdateWidget(covariant WaterlineScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hull != oldWidget.hull || widget.params != oldWidget.params) {
      _params = widget.params ?? WaterlineParams();
      _createWaterlineHull();
    }
  }

  void _createWaterlineHull() {
    xyz = XYZWidget();
    _hull = WaterlineHull(widget.hull, _params);
    _hullWindow = WaterlineWindow(_hull, HullView.side, xyz: xyz);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 200,
                  child: WaterlineParamsEditor(
                    initialParams: _params,
                    onChanged: (params) {
                      setState(() {
                        _params = params;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _recomputeWaterlines,
                  child: const Text('Recompute Waterlines'),
                ),
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
          ),
          _hullWindow,
        ],
      ),
    );
  }
}
