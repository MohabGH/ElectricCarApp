import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/bluetooth_service.dart';
import '../../widgets/battery_indicator.dart';
import '../../widgets/control_button.dart';

/// Auto parking mode control screen
class AutoParkingMode extends StatelessWidget {
  const AutoParkingMode({super.key});

  @override
  Widget build(BuildContext context) {
    final bluetoothService = Provider.of<BluetoothService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Auto Parking Mode'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: BatteryIndicator(),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                bluetoothService.isConnected ? 'Connected' : 'Not Connected',
                style: TextStyle(
                  color: bluetoothService.isConnected
                      ? Colors.green
                      : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Auto Parking Controls',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 40),

                ControlButton(
                  icon: Icons.turn_right,
                  label: 'Start Right Parking',
                  command: 'RP',
                  bluetoothService: bluetoothService,
                  color: Colors.blue,
                ),
                const SizedBox(height: 20),

                ControlButton(
                  icon: Icons.turn_left,
                  label: 'Start Left Parking',
                  command: 'LP',
                  bluetoothService: bluetoothService,
                  color: Colors.green,
                ),
                const SizedBox(height: 20),

                ControlButton(
                  icon: Icons.stop,
                  label: 'Stop',
                  command: 'S',
                  bluetoothService: bluetoothService,
                  color: Colors.red,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
