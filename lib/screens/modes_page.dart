import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../widgets/battery_indicator.dart';
import 'manual_mode.dart';
import 'auto_parking_mode.dart';
import 'autonomous_mode.dart';

/// Page to select control modes
class ModesPage extends StatelessWidget {
  const ModesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final modeWidgets = <String, Widget>{
      'Manual': const ManualMode(),
      'Auto Parking': const AutoParkingMode(),
      'Autonomous': const AutonomousMode(),
    };

    final modeIcons = <String, IconData>{
      'Manual': Icons.gamepad,
      'Auto Parking': Icons.local_parking,
      'Autonomous': Icons.smart_toy,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Mode'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: BatteryIndicator(),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: modeNames.length,
        itemBuilder: (context, index) {
          final modeName = modeNames[index];
          final icon = modeIcons[modeName]!;
          final targetWidget = modeWidgets[modeName]!;

          return Card(
            margin: const EdgeInsets.only(bottom: 12.0),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 12.0,
              ),
              leading: Icon(
                icon,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                modeName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(builder: (context) => targetWidget),
                );
              },
            ),
          );
        },
      ),
    );
  }
}