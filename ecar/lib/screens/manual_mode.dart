import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/bluetooth_service.dart';
import '../../providers/recordings_state.dart';
import '../../models/recording.dart';
import '../../models/recorded_command.dart';
import '../../widgets/battery_indicator.dart';
import '../../widgets/recordable_control_button.dart';

/// Manual control mode with directional controls and recording capability
class ManualMode extends StatefulWidget {
  const ManualMode({super.key});

  @override
  State<ManualMode> createState() => _ManualModeState();
}

class _ManualModeState extends State<ManualMode> {
  bool _isRecording = false;
  List<RecordedCommand> _currentRecording = [];
  DateTime? _recordingStartTime;
  bool _isToggleOn = false; // Toggle state for continuous command mode

  void _toggleRecording(BuildContext context) {
    setState(() {
      if (_isRecording) {
        // Stop recording and save
        _isRecording = false;
        if (_currentRecording.isNotEmpty) {
          _showSaveDialog(context);
        }
      } else {
        // Start recording
        _isRecording = true;
        _currentRecording = [];
        _recordingStartTime = DateTime.now();
      }
    });
  }

  void _recordCommand(String command) {
    if (_isRecording) {
      setState(() {
        _currentRecording.add(
          RecordedCommand(command: command, timestamp: DateTime.now()),
        );
      });
    }
  }

  void _showSaveDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController(
      text: 'Recording ${DateTime.now().toString().substring(0, 19)}',
    );

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Save Recording'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Recording Name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _currentRecording = [];
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Discard'),
            ),
            ElevatedButton(
              onPressed: () {
                final recordingsState = Provider.of<RecordingsState>(
                  context,
                  listen: false,
                );
                recordingsState.addRecording(
                  Recording(
                    name: nameController.text,
                    timestamp: _recordingStartTime ?? DateTime.now(),
                    commands: List.from(_currentRecording),
                  ),
                );
                _currentRecording = [];
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Recording saved!')),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bluetoothService = Provider.of<BluetoothService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual Mode'),
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
                // Toggle switch for continuous command mode
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Continuous Mode:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Switch(
                        value: _isToggleOn,
                        onChanged: (value) {
                          setState(() {
                            _isToggleOn = value;
                          });
                        },
                        activeColor: Colors.green,
                      ),
                      Text(
                        _isToggleOn ? 'ON' : 'OFF',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _isToggleOn ? Colors.green : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                // Recording indicator and button
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isRecording)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.fiber_manual_record,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Recording (${_currentRecording.length} commands)',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () => _toggleRecording(context),
                        icon: Icon(
                          _isRecording ? Icons.stop : Icons.fiber_manual_record,
                        ),
                        label: Text(
                          _isRecording ? 'Stop Recording' : 'Start Recording',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isRecording
                              ? Colors.red
                              : Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Forward button
                RecordableControlButton(
                  icon: Icons.arrow_upward,
                  label: 'Forward',
                  command: 'F',
                  bluetoothService: bluetoothService,
                  onCommandSent: _recordCommand,
                  isContinuousMode: _isToggleOn,
                ),
                const SizedBox(height: 20),

                // Left, Stop, Right buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RecordableControlButton(
                      icon: Icons.arrow_back,
                      label: 'Left',
                      command: 'L',
                      bluetoothService: bluetoothService,
                      onCommandSent: _recordCommand,
                      isContinuousMode: _isToggleOn,
                    ),
                    const SizedBox(width: 40),
                    RecordableControlButton(
                      icon: Icons.stop,
                      label: 'Stop',
                      command: 'S',
                      bluetoothService: bluetoothService,
                      color: Colors.red,
                      onCommandSent: _recordCommand,
                      isContinuousMode: _isToggleOn,
                    ),
                    const SizedBox(width: 40),
                    RecordableControlButton(
                      icon: Icons.arrow_forward,
                      label: 'Right',
                      command: 'R',
                      bluetoothService: bluetoothService,
                      onCommandSent: _recordCommand,
                      isContinuousMode: _isToggleOn,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Backward button
                RecordableControlButton(
                  icon: Icons.arrow_downward,
                  label: 'Backward',
                  command: 'B',
                  bluetoothService: bluetoothService,
                  onCommandSent: _recordCommand,
                  isContinuousMode: _isToggleOn,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
