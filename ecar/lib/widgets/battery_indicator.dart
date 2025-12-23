import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/bluetooth_service.dart';

/// Widget to display battery level indicator
class BatteryIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bluetoothService = Provider.of<BluetoothService>(context);
    final batteryLevel = bluetoothService.batteryLevel;

    Color batteryColor;
    if (batteryLevel > 50) {
      batteryColor = Colors.green;
    } else if (batteryLevel > 20) {
      batteryColor = Colors.orange;
    } else {
      batteryColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.battery_charging_full, color: batteryColor, size: 20),
          const SizedBox(width: 6),
          Text(
            '${batteryLevel.toInt()}%',
            style: TextStyle(
              color: batteryColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
