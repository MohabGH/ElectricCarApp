import 'package:flutter/material.dart';
import '../../services/bluetooth_service.dart';

/// Control button that supports recording and continuous mode
class RecordableControlButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final String command;
  final BluetoothService bluetoothService;
  final Function(String) onCommandSent;
  final bool isContinuousMode;
  final Color? color;

  const RecordableControlButton({
    super.key,
    required this.icon,
    required this.label,
    required this.command,
    required this.bluetoothService,
    required this.onCommandSent,
    required this.isContinuousMode,
    this.color,
  });

  @override
  State<RecordableControlButton> createState() =>
      _RecordableControlButtonState();
}

class _RecordableControlButtonState extends State<RecordableControlButton> {
  bool _isPressed = false;

  void _handlePressStart() {
    if (!widget.bluetoothService.isConnected) return;

    setState(() {
      _isPressed = true;
    });

    if (widget.isContinuousMode) {
      // In continuous mode, send command immediately when pressed
      widget.bluetoothService.sendData(widget.command);
      widget.onCommandSent(widget.command);
    }
  }

  void _handlePressEnd() {
    if (!widget.bluetoothService.isConnected) return;

    setState(() {
      _isPressed = false;
    });

    if (!widget.isContinuousMode) {
      // In normal mode, send command when released
      widget.bluetoothService.sendData(widget.command);
      widget.onCommandSent(widget.command);
    } else {
      // In continuous mode, send stop command when released (except for Stop button)
      if (widget.command != 'S') {
        widget.bluetoothService.sendData('S');
        widget.onCommandSent('S'); // Record the stop command as well
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isContinuousMode) {
      // Use GestureDetector for continuous mode
      return GestureDetector(
        onTapDown: widget.bluetoothService.isConnected
            ? (_) => _handlePressStart()
            : null,
        onTapUp: widget.bluetoothService.isConnected
            ? (_) => _handlePressEnd()
            : null,
        onTapCancel: widget.bluetoothService.isConnected
            ? () => _handlePressEnd()
            : null,
        child: ElevatedButton.icon(
          onPressed: widget.bluetoothService.isConnected ? () {} : null,
          icon: Icon(widget.icon, size: 28),
          label: Text(widget.label, style: const TextStyle(fontSize: 18)),
          style: ElevatedButton.styleFrom(
            backgroundColor: _isPressed
                ? (widget.color?.withOpacity(0.7) ??
                      Theme.of(context).colorScheme.primary.withOpacity(0.7))
                : widget.color,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            minimumSize: const Size(200, 60),
          ),
        ),
      );
    } else {
      // Use normal onPressed for non-continuous mode
      return ElevatedButton.icon(
        onPressed: widget.bluetoothService.isConnected
            ? () {
                widget.bluetoothService.sendData(widget.command);
                widget.onCommandSent(widget.command);
              }
            : null,
        icon: Icon(widget.icon, size: 28),
        label: Text(widget.label, style: const TextStyle(fontSize: 18)),
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.color,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: const Size(200, 60),
        ),
      );
    }
  }
}
