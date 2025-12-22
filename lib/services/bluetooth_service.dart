import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:typed_data';

/// Service for managing Bluetooth connections and data transmission
class BluetoothService extends ChangeNotifier {
  BluetoothConnection? connection;

  final ValueNotifier<String> receivedDataNotifier = ValueNotifier<String>('');
  final ValueNotifier<BluetoothDevice?> connectedDeviceNotifier =
      ValueNotifier<BluetoothDevice?>(null);

  double _batteryLevel = 0.0;
  bool _isPlayingRecording = false;

  double get batteryLevel => _batteryLevel;
  bool get isPlayingRecording => _isPlayingRecording;

  

  bool get isConnected => connection != null && connection!.isConnected;

  /// Connect to a Bluetooth device
  Future<void> connectToDevice(BluetoothDevice device) async {
    if (connection != null && connection!.isConnected) {
      await disconnect();
      return;
    }

    try {
      print('Connecting to ${device.address}...');
      connection = await BluetoothConnection.toAddress(device.address);
      connectedDeviceNotifier.value = device;
      print('Connected to the device');
      notifyListeners();

      connection!.input!.listen(
        _onDataReceived,
        onDone: () {
          print('Disconnected by remote end');
          disconnect();
        },
        onError: (error) {
          print('Error during connection: $error');
          disconnect();
        },
      );
    } catch (exception) {
      print('Cannot connect, exception: $exception');
      disconnect();
    }
  }

  /// Handle incoming data from Bluetooth connection
  void _onDataReceived(Uint8List data) {
    String dataString = String.fromCharCodes(data);
    print('Data incoming: $dataString');
    receivedDataNotifier.value = dataString;

    // Parse battery level if the data starts with "BAT:"
    if (dataString.startsWith('BAT:')) {
      try {
        _batteryLevel = double.parse(dataString.substring(4));
        if (_batteryLevel > 100) _batteryLevel = 100;
        if (_batteryLevel < 0) _batteryLevel = 0;
        notifyListeners();
      } catch (e) {
        print('Error parsing battery level: $e');
      }
    }
  }

  /// Disconnect from the current Bluetooth device
  Future<void> disconnect() async {
    if (connection != null) {
      print('Disconnecting from device...');
      await connection!.close();
      connection = null;
      connectedDeviceNotifier.value = null;
      _batteryLevel = 0.0;
      print('Disconnected.');
      notifyListeners();
    }
  }

  /// Send data to the connected Bluetooth device
  void sendData(String text) async {
    if (connection != null && connection!.isConnected) {
      try {
        connection!.output.add(Uint8List.fromList(text.codeUnits));
        await connection!.output.allSent;
        print('Data sent: $text');
      } catch (e) {
        print('Error sending data: $e');
      }
    } else {
      print('Cannot send data: Not connected.');
    }
  }
}
