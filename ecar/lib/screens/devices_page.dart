import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import '../../services/bluetooth_service.dart';
import '../../widgets/battery_indicator.dart';

/// Page to display and manage Bluetooth device connections
class DevicesPage extends StatefulWidget {
  @override
  State<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  List<BluetoothDevice> _pairedDevices = [];
  bool _isScanning = false;
  Offset _indicatorPosition = Offset(450, 200); // Initial position

  @override
  void initState() {
    super.initState();
    _getPairedDevices();
  }

  Future<void> _getPairedDevices() async {
    setState(() {
      _isScanning = true;
    });
    try {
      List<BluetoothDevice> devices = await FlutterBluetoothSerial.instance
          .getBondedDevices();
      if (mounted) {
        setState(() {
          _pairedDevices = devices;
          _isScanning = false;
        });
      }
    } catch (e) {
      print('Error getting bonded devices: $e');
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bluetoothService = Provider.of<BluetoothService>(
      context,
      listen: false,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paired Bluetooth Devices'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: BatteryIndicator(),
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _isScanning ? null : _getPairedDevices,
          ),
        ],
      ),
      body: Stack(
        children: [
          _isScanning
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: _pairedDevices.length,
                  itemBuilder: (context, index) {
                    BluetoothDevice device = _pairedDevices[index];

                    return ValueListenableBuilder<BluetoothDevice?>(
                      valueListenable: bluetoothService.connectedDeviceNotifier,
                      builder: (context, connectedDevice, child) {
                        final bool isConnected =
                            connectedDevice?.address == device.address;

                        return ListTile(
                          leading: Icon(
                            isConnected
                                ? Icons.bluetooth_connected
                                : Icons.bluetooth,
                          ),
                          title: Text(device.name ?? 'Unknown Device'),
                          subtitle: Text(device.address),
                          trailing: isConnected
                              ? const Icon(Icons.check, color: Colors.green)
                              : null,
                          onTap: () async {
                            if (isConnected) {
                              await bluetoothService.disconnect();
                            } else {
                              await bluetoothService.connectToDevice(device);
                            }
                          },
                        );
                      },
                    );
                  },
                ),
          
          // Draggable "Last Received" indicator
          Positioned(
            left: _indicatorPosition.dx,
            top: _indicatorPosition.dy,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  // Get the screen size
                  final RenderBox renderBox = context.findRenderObject() as RenderBox;
                  final size = renderBox.size;
                  
                  // Calculate new position
                  double newX = _indicatorPosition.dx + details.delta.dx;
                  double newY = _indicatorPosition.dy + details.delta.dy;
                  
                  // Constrain within boundaries (with some padding for the widget size)
                  // Approximate widget size: width ~200, height ~50
                  newX = newX.clamp(0.0, size.width - 200);
                  newY = newY.clamp(0.0, size.height - 150);
                  
                  _indicatorPosition = Offset(newX, newY);
                });
              },
              child: ValueListenableBuilder<String>(
                valueListenable: bluetoothService.receivedDataNotifier,
                builder: (context, receivedData, child) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.drag_indicator,
                          color: Colors.white54,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Last Received: ${receivedData.isEmpty ? 'N/A' : receivedData}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
