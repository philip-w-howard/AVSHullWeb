// ***************************************************************
// Part of the AVS Hull program
// Released under the MIT license.
// See https://github.com/philip-w-howard/AVSHullWeb for details
// ***************************************************************

import 'package:flutter/material.dart';
import 'design_screen.dart';
import 'waterline_screen.dart';
import 'panels_screen.dart';
import 'hull.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  MainApp({super.key});

  final _mainHull = Hull.create(200, 50, 20, 5, 4);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AVS Hull dev project',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
            appBar: AppBar(
                title: const Text('AVS Hull 0.1'),
                bottom: const PreferredSize(
                    preferredSize: Size.fromHeight(kToolbarHeight),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: TabBar(
                          isScrollable: true,
                          tabs: [
                            Tab(text: 'Design'),
                            Tab(text: 'Layout'),
                            Tab(text: 'Waterlines'),
                          ],
                        )))),
            body: TabBarView(
              children: [
                Center(child: DesignScreen(mainHull: _mainHull)),
                Center(child: PanelsScreen(_mainHull)),
                Center(child: WaterlineScreen(_mainHull)),
              ],
            )),
      ),
    );
  }
}
