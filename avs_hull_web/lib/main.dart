// ***************************************************************
// Part of the AVS Hull program
// Released under the MIT license.
// See https://github.com/philip-w-howard/AVSHullWeb for details
// ***************************************************************

import 'package:flutter/material.dart';
import 'design_screen.dart';
import 'waterline_screen.dart';
import 'hull.dart';

void main() {
  runApp(const MainApp());
}

final mainHull = Hull.create(200, 50, 20, 5, 4);
DesignScreen mainScreen = DesignScreen(mainHull: mainHull);

class MainApp extends StatelessWidget {
  const MainApp({super.key});

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
                Center(child: mainScreen),
                const Text('Layout view: TBA'),
                Center(child: WaterlineScreen(mHull: mainHull)),
              ],
            )),
      ),
    );
  }
}
