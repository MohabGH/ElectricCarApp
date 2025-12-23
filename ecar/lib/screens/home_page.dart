import 'package:flutter/material.dart';
import 'modes_page.dart';
import 'devices_page.dart';
import 'recordings_page.dart';
import 'settings_page.dart';

/// Main home page with navigation rail
class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = ModesPage();
        break;
      case 1:
        page = DevicesPage();
        break;
      case 2:
        page = RecordingsPage();
        break;
      case 3:
        page = SettingsPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: false,
                  minWidth: 72,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.directions_car),
                      label: Text('Modes'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.bluetooth),
                      label: Text('Devices'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.video_library),
                      label: Text('Recordings'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.settings),
                      label: Text('Settings'),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
