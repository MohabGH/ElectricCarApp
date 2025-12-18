import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_state.dart';
import '../../services/bluetooth_service.dart';
import '../../widgets/battery_indicator.dart';

/// Settings page for wheel speed configuration
class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsState>(context);
    final bluetoothService = Provider.of<BluetoothService>(
      context,
      listen: false,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: BatteryIndicator(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Wheel Speed Control',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),

              // Left Wheel Speed
              Text(
                'Left Wheel Speed: ${settings.leftWheelSpeed.toInt()}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Slider(
                value: settings.leftWheelSpeed,
                min: 0,
                max: 255,
                divisions: 255,
                label: settings.leftWheelSpeed.toInt().toString(),
                onChanged: (value) {
                  settings.setLeftWheelSpeed(value);
                },
                onChangeEnd: (value) {
                  bluetoothService.sendData('LS:${value.toInt()}');
                },
              ),
              const SizedBox(height: 20),

              // Right Wheel Speed
              Text(
                'Right Wheel Speed: ${settings.rightWheelSpeed.toInt()}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Slider(
                value: settings.rightWheelSpeed,
                min: 0,
                max: 255,
                divisions: 255,
                label: settings.rightWheelSpeed.toInt().toString(),
                onChanged: (value) {
                  settings.setRightWheelSpeed(value);
                },
                onChangeEnd: (value) {
                  bluetoothService.sendData('RS:${value.toInt()}');
                },
              ),
              const SizedBox(height: 30),

              ElevatedButton.icon(
                onPressed: () {
                  settings.setLeftWheelSpeed(255);
                  settings.setRightWheelSpeed(255);
                  bluetoothService.sendData('LS:255');
                  bluetoothService.sendData('RS:255');
                },
                icon: const Icon(Icons.restart_alt),
                label: const Text('Reset to Maximum'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
