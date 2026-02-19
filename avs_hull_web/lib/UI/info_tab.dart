import 'package:flutter/material.dart';
import 'dart:html' as html;
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
            'AVS Hull is a program for designing hard-chine boat hulls suitable for stitch-and-glue construction. '
            'It is my hope that DIY boat builders will find this program useful in creating and building their own designs.\n'
            '\n'
            'The program can compute the panel shapes required to build the hull. It can output the panel layouts as a table of offsets that you can use to mark your plywood sheets for cutting.\n'
            '\n'
            'You can also compute rudimentary hydrostatic properties such as the waterline for various loads and heeling and pitch angles. The program also computes righting moments to help you determine the hull\'s stability. '
            'ALL OF THESE COMPUTATIONS SHOULD BE CONSIDERED ESTIMATES ONLY. '
            'The reliability and suitability of any hull designed using this program is the responsibility of the designer and builder.\n'
            '\n'
            'If you have any questions, suggestions, or want to report a bug, please contact me at avshull.questions@gmail.com\n'
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              html.AnchorElement(href: 'AVS Hull Users Manual.pdf')
                ..setAttribute('download', 'AVS Hull Users Manual.pdf')
                ..click();
            },
            icon: const Icon(Icons.download),
            label: const Text('Download Users Manual (PDF)'),
          ),
          const SizedBox(height: 32),
          const Text(
            'For the software nerds:',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
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
