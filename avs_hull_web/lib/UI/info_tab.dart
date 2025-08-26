import 'package:flutter/material.dart';
import '../settings/settings.dart';
// InfoTab: non-editable program description
class InfoTab extends StatelessWidget {
  const InfoTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Program Description',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            'AVS Hull is a program for designing and analyzing plywood hulls for boats. \n'
            '\n'
            'AVS Hull is released under the MIT license. The source is available at https://github.com/philip-w-howard/AVSHullWeb.git\n'
            '\n'
            'Known issues:\n'
            '\n'
            'Under some conditions, the waterlines are not properly computed near their ends (near the bow and stern). This only seems to happen when there is a non-zero heel angle.\n'
            , style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          Text(
            'Version: $version\n',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
