import 'package:flutter/material.dart';
import '../../services/bluetooth_service.dart';

/// Reusable control button widget for sending commands
class ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String command;
  final BluetoothService bluetoothService;
  final Color? color;

  const ControlButton({
    super.key,
    required this.icon,
    required this.label,
    required this.command,
    required this.bluetoothService,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: bluetoothService.isConnected
          ? () => bluetoothService.sendData(command)
          : null,
      icon: Icon(icon, size: 28),
      label: Text(label, style: const TextStyle(fontSize: 18)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        minimumSize: const Size(200, 60),
      ),
    );
  }
}
