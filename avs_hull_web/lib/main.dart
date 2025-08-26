// ***************************************************************
// Part of the AVS Hull program
// Released under the MIT license.
// See https://github.com/philip-w-howard/AVSHullWeb for details
// ***************************************************************

import 'package:avs_hull_web/models/waterline_hull.dart';
import 'package:flutter/material.dart';
import 'UI/design_screen.dart';
import 'UI/waterline_screen.dart';
import 'UI/panels_screen.dart';
import 'models/hull.dart';
import 'models/hull_manager.dart';
import 'IO/hull_logger.dart';
import 'settings/settings.dart';
import 'UI/info_tab.dart';

//import 'dart:html' as html;
import 'dart:js_interop';

//*********************************************************
@JS('window')
external Window get window;

@JS()
@staticInterop
class Window {}

extension WindowExtension on Window {
  external set onbeforeunload(JSFunction handler);
}

@JS()
@staticInterop
class BeforeUnloadEvent {}

extension BeforeUnloadEventExtension on BeforeUnloadEvent {
  external set returnValue(String value);
}

//*********************************************************

void setupBeforeUnloadPrompt() {
  // Explicitly declare the function type to match JS interop constraints
  void handler(JSAny event) {
    if (HullManager().hull.timeSaved.isBefore(HullManager().hull.timeUpdated)) {
      final e = event as BeforeUnloadEvent;
      e.returnValue = 'Are you sure you want to leave?';
    }
  }

  // Convert to JS-safe function
  window.onbeforeunload = handler.toJS;
}//*********************************************************

void main() {
    // create a default hull
    HullParams params = loadHullParams();
    HullManager().hull.updateFromParams(params);

    // Setup the window close event
    setupBeforeUnloadPrompt();
    
    runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AVS Hull $version',
      home: MainAppWindow(hull: HullManager().hull),
    );
  }
}

class MainAppWindow extends StatefulWidget {
  final Hull hull;
  const MainAppWindow({super.key, required this.hull});

  @override
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() => MainAppState();
}

class MainAppState extends State<MainAppWindow>
    with SingleTickerProviderStateMixin {

  final List<Tab> myTabs = <Tab>[
    const Tab(text: 'Design'),
    const Tab(text: 'Layout'),
    const Tab(text: 'Waterlines'),
    const Tab(text: 'Info'), // Added Info tab
  ];

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
            const InfoTab(), // Added InfoTab to the TabBarView
          ],
        ));
  }
  final HullLogger _hullLog = HullLogger();

  
  late TabController _tabController;
  late DesignScreen _designScreen;
  late PanelsScreen _panelsScreen;
  late WaterlineScreen _waterlineScreen;
  late BuildContext _context;
  WaterlineParams _waterlineParams = WaterlineParams();

  MainAppState() ;
  
  @override
  void initState() {
    super.initState();

    // String hullName = fetchLastHullName();
    // if (hullName != unnamedHullName) {
    //   Hull? tempHull = readHull(hullName);
    //   if (tempHull != null) {
    //     HullManager().hull = tempHull;
    //   } else {
    //     HullParams params = HullParams();
    //     HullManager().hull = Hull.fromParams(params);
    //   }
    // } else {
    //   HullParams params = HullParams();
    //   HullManager().hull = Hull.fromParams(params);
    // }
    _tabController = TabController(vsync: this, length: myTabs.length);
    _tabController.addListener(_handleTabSelection);

    _designScreen = DesignScreen(logger: _hullLog);
    _panelsScreen = PanelsScreen();
    _waterlineScreen = WaterlineScreen(params: _waterlineParams, onParamsChanged: _waterlineParamsChanged);
  }

  void _waterlineParamsChanged(WaterlineParams params) {
    setState(() {
      _waterlineParams = params;
      _waterlineScreen = WaterlineScreen(params: _waterlineParams, onParamsChanged: _waterlineParamsChanged);
    });
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

  }
