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
  final void Function(WaterlineParams) onParamsChanged;
  const WaterlineScreen(this.hull, {super.key, this.params, required this.onParamsChanged});

  @override
  State<WaterlineScreen> createState() => _WaterlineScreenState();
}

class _WaterlineScreenState extends State<WaterlineScreen> {
  late WaterlineParams _params;
  late WaterlineHull _hull;
  late WaterlineWindow _hullWindow;
  late XYZWidget xyz;

  void _recomputeWaterlines() {
    setState(() {
      _hull = WaterlineHull(widget.hull, _params);
      _hullWindow = WaterlineWindow(_hull, xyz: xyz);
    });
  }

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
    _hullWindow = WaterlineWindow(_hull, xyz: xyz);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: 200,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WaterlineParamsEditor(
                      initialParams: _params,
                      onChanged: (params) {
                        setState(() {
                          _params = params;
                        });
                        widget.onParamsChanged(_params);
                      },
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
                    const SizedBox(height: 16),
                    Text('Freeboard: ${_params.freeboard.toStringAsFixed(2)}'),
                    Text('Centroid X: ${_params.centroidX.toStringAsFixed(2)}'),
                    Text('Centroid Y: ${_params.centroidY.toStringAsFixed(2)}'),
                    Text('Centroid Z: ${_params.centroidZ.toStringAsFixed(2)}'),
                    Text('Righting Moment: ${_params.rightingMoment.toStringAsFixed(2)}'),
                  ],
                ),
              ),
            ),
          ),
          _hullWindow,
        ],
      ),
    );
  }
}
