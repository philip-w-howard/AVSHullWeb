// ***************************************************************
// Part of the AVS Hull program
// Released under the MIT license.
// See https://github.com/philip-w-howard/AVSHullWeb for details
// ***************************************************************

import 'package:flutter/material.dart';
import 'UI/design_screen.dart';
import 'UI/waterline_screen.dart';
import 'UI/panels_screen.dart';
import 'models/hull.dart';
import 'IO/hull_logger.dart';
import 'settings/settings.dart';
import 'io/file_io.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'AVS Hull $version',
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
  late final Hull _mainHull;
  final HullLogger _hullLog = HullLogger();

  final List<Tab> myTabs = <Tab>[
    const Tab(text: 'Design'),
    const Tab(text: 'Layout'),
    const Tab(text: 'Waterlines'),
  ];

  late TabController _tabController;
  late DesignScreen _designScreen;
  late PanelsScreen _panelsScreen;
  late WaterlineScreen _waterlineScreen;
  late BuildContext _context;

  @override
  void initState() {
    super.initState();

    String hullName = fetchLastHullName();
    if (hullName != unnamedHullName) {
      Hull? tempHull = readHull(hullName);
      if (tempHull != null) {
        _mainHull = tempHull;
      } else {
        HullParams params = HullParams();
        _mainHull = Hull.fromParams(params);
      }
    } else {
      HullParams params = HullParams();
      _mainHull = Hull.fromParams(params);
    }
    _tabController = TabController(vsync: this, length: myTabs.length);
    _tabController.addListener(_handleTabSelection);

    _designScreen = DesignScreen(mainHull: _mainHull, logger: _hullLog);
    _panelsScreen = PanelsScreen(_mainHull);
    _waterlineScreen = WaterlineScreen(_mainHull);
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      switch (_tabController.index) {
        case 0:
          break;
        case 1:
          // This is no longer needed
          _panelsScreen.checkPanels(_context);
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
    _context = context;
    return Scaffold(
        appBar: AppBar(
            toolbarHeight: 20.0,
            title: const Text('AVS Hull $version'),
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
