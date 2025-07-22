// Widget for editing WaterlineParams
import 'package:flutter/material.dart';
import '../models/waterline_hull.dart';

class WaterlineParamsEditor extends StatefulWidget {
  final WaterlineParams? initialParams;
  final void Function(WaterlineParams)? onChanged;

  const WaterlineParamsEditor({super.key, this.initialParams, this.onChanged});

  @override
  State<WaterlineParamsEditor> createState() => _WaterlineParamsEditorState();
}

class _WaterlineParamsEditorState extends State<WaterlineParamsEditor> {
  late WaterlineParams params;
  late TextEditingController heightIncrementController;
  late TextEditingController lengthIncrementController;
  late TextEditingController weightController;
  late TextEditingController waterDensityController;
  late TextEditingController heelAngleController;
  late TextEditingController pitchAngleController;

  @override
  void initState() {
    super.initState();
    params = widget.initialParams ?? WaterlineParams();
    heightIncrementController = TextEditingController(text: params.heightIncrement.toString());
    lengthIncrementController = TextEditingController(text: params.lengthIncrement.toString());
    weightController = TextEditingController(text: params.weight.toString());
    waterDensityController = TextEditingController(text: params.waterDensity.toString());
    heelAngleController = TextEditingController(text: params.heelAngle.toString());
    pitchAngleController = TextEditingController(text: params.pitchAngle.toString());
  }

  void _update() {
    setState(() {});
    widget.onChanged?.call(params);
    // Update controllers if params changed externally
    heightIncrementController.text = params.heightIncrement.toString();
    lengthIncrementController.text = params.lengthIncrement.toString();
    weightController.text = params.weight.toString();
    waterDensityController.text = params.waterDensity.toString();
    heelAngleController.text = params.heelAngle.toString();
    pitchAngleController.text = params.pitchAngle.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          decoration: const InputDecoration(labelText: 'Height Increment'),
          keyboardType: TextInputType.number,
          controller: heightIncrementController,
          onChanged: (value) {
            final v = double.tryParse(value);
            if (v != null) params.heightIncrement = v;
          },
        ),
        TextField(
          decoration: const InputDecoration(labelText: 'Length Increment'),
          keyboardType: TextInputType.number,
          controller: lengthIncrementController,
          onChanged: (value) {
            final v = double.tryParse(value);
            if (v != null) params.lengthIncrement = v;
          },
        ),
        TextField(
          decoration: const InputDecoration(labelText: 'Weight (lbs)'),
          keyboardType: TextInputType.number,
          controller: weightController,
          onChanged: (value) {
            final v = double.tryParse(value);
            if (v != null) params.weight = v;
          },
        ),
        TextField(
          decoration: const InputDecoration(labelText: 'Water Density (lb/ft³)'),
          keyboardType: TextInputType.number,
          controller: waterDensityController,
          onChanged: (value) {
            final v = double.tryParse(value);
            if (v != null) params.waterDensity = v;
          },
        ),
        TextField(
          decoration: const InputDecoration(labelText: 'Heel Angle (deg)'),
          keyboardType: TextInputType.number,
          controller: heelAngleController,
          onChanged: (value) {
            final v = double.tryParse(value);
            if (v != null) params.heelAngle = v;
          },
        ),
        TextField(
          decoration: const InputDecoration(labelText: 'Pitch Angle (deg)'),
          keyboardType: TextInputType.number,
          controller: pitchAngleController,
          onChanged: (value) {
            final v = double.tryParse(value);
            if (v != null) params.pitchAngle = v;
          },
        ),
        SwitchListTile(
          title: const Text('Show All Waterlines'),
          value: params.showAllWaterlines,
          onChanged: (value) {
            setState(() {
              params.showAllWaterlines = value;
            });
          },
        ),
      ],
    );
  @override
  void dispose() {
    heightIncrementController.dispose();
    lengthIncrementController.dispose();
    weightController.dispose();
    waterDensityController.dispose();
    heelAngleController.dispose();
    pitchAngleController.dispose();
    super.dispose();
  }
  }
}
