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
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'AVS Hull 0.2',
      home: MainAppWindow(),
    );
  }
}

class MainAppWindow extends StatefulWidget {
  const MainAppWindow({super.key});

  @override
  State<StatefulWidget> createState() => MainAppState();
}

class MainAppState extends State<MainAppWindow>
    with SingleTickerProviderStateMixin {
  final _mainHull = Hull.create(200, 50, 20, 5, 4);

  final List<Tab> myTabs = <Tab>[
    const Tab(text: 'Design'),
    const Tab(text: 'Layout'),
    const Tab(text: 'Waterlines'),
  ];

  late TabController _tabController;
  late DesignScreen _designScreen;
  late PanelsScreen _panelsScreen;
  late WaterlineScreen _waterlineScreen;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: myTabs.length);
    _tabController.addListener(_handleTabSelection);

    _designScreen = DesignScreen(mainHull: _mainHull);
    _panelsScreen = PanelsScreen(_mainHull);
    _waterlineScreen = WaterlineScreen(_mainHull);
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      switch (_tabController.index) {
        case 0:
          break;
        case 1:
          _panelsScreen.createPanels();
          break;
        case 2:
          break;
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text('AVS Hull 0.2'),
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: myTabs,
            )),
        body: TabBarView(
          controller: _tabController,
          children: [
            Center(child: _designScreen),
            Center(child: _panelsScreen),
            Center(child: _waterlineScreen),
          ],
        ));
  }
}
