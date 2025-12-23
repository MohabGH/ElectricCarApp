import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/bluetooth_service.dart';
import '../../widgets/battery_indicator.dart';
import '../../widgets/control_button.dart';

/// Autonomous navigation mode control screen
class AutonomousMode extends StatelessWidget {
  const AutonomousMode({super.key});

  @override
  Widget build(BuildContext context) {
    final bluetoothService = Provider.of<BluetoothService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Autonomous Mode'),
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
                  'Autonomous Navigation',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 40),

                ControlButton(
                  icon: Icons.play_arrow,
                  label: 'Start Autonomous',
                  command: 'A',
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
