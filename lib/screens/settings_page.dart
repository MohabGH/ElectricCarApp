import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_state.dart';
import '../../services/bluetooth_service.dart';
import '../../widgets/battery_indicator.dart';

/// Settings page for wheel speed configuration
class SettingsPage extends StatelessWidget {

  double _mapNumbersToSpeed(int number)
  {
    if(number == 0) return 0;
    if(number == 1) return 75;
    return 75 + number * 20;
  }

  int _mapSpeedToNumbers(double speed)
  {
    if(speed == 0) return 0;
    if(speed <= 75) return 1;
    return ((speed - 75) / 20).round();
  }

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
                'Left Wheel Speed: ${_mapSpeedToNumbers(settings.leftWheelSpeed)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Slider(
                value: _mapSpeedToNumbers(settings.leftWheelSpeed).toDouble(),
                min: 0,
                max: 9,
                divisions: 9,
                label: settings.leftWheelSpeed.toInt().toString(),
                onChanged: (value) {
                  settings.setLeftWheelSpeed(_mapNumbersToSpeed(value.toInt()));
                  print(_mapNumbersToSpeed(value.toInt()));
                },
                onChangeEnd: (value) {
                  bluetoothService.sendData('LS:${_mapNumbersToSpeed(value.toInt()).toInt()}');
                  print(_mapNumbersToSpeed(value.toInt()).toInt());
                },
              ),
              const SizedBox(height: 20),

              // Right Wheel Speed
              Text(
                'Right Wheel Speed: ${_mapSpeedToNumbers(settings.rightWheelSpeed)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Slider(
                value: _mapSpeedToNumbers(settings.rightWheelSpeed).toDouble(),
                min: 0,
                max: 9,
                divisions: 9,
                label: settings.rightWheelSpeed.toInt().toString(),
                onChanged: (value) {
                  settings.setRightWheelSpeed(_mapNumbersToSpeed(value.toInt()));
                  print(_mapNumbersToSpeed(value.toInt()));
                },
                onChangeEnd: (value) {
                  bluetoothService.sendData('RS:${_mapNumbersToSpeed(value.toInt()).toInt()}');
                  print(_mapNumbersToSpeed(value.toInt()).toInt());
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
