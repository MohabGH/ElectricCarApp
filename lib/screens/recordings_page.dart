import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/recordings_state.dart';
import '../../services/bluetooth_service.dart';
import '../../models/recording.dart';
import '../../widgets/battery_indicator.dart';

/// Page to display and manage saved recordings
class RecordingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final recordingsState = Provider.of<RecordingsState>(context);
    final bluetoothService = Provider.of<BluetoothService>(
      context,
      listen: false,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Recordings'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: BatteryIndicator(),
          ),
        ],
      ),
      body: recordingsState.recordings.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.video_library_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No recordings yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Go to Manual mode and start recording',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: recordingsState.recordings.length,
              itemBuilder: (context, index) {
                final recording = recordingsState.recordings[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ExpansionTile(
                    leading: const Icon(Icons.play_circle_outline, size: 32),
                    title: Text(
                      recording.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${recording.commands.length} commands • ${recording.timestamp.toString().substring(0, 16)}',
                    ),
                    children: [
                      SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Commands:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ConstrainedBox(
                                constraints: BoxConstraints(maxHeight: 150),
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: List.generate(
                                      recording.commands.length,
                                      (cmdIndex) {
                                        final cmd =
                                            recording.commands[cmdIndex];
                                        final commandName = _getCommandName(
                                          cmd.command,
                                        );
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 2.0,
                                          ),
                                          child: Text(
                                            '${cmdIndex + 1}. $commandName',
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: bluetoothService.isConnected
                                        ? () => _playRecording(
                                            context,
                                            recording,
                                            bluetoothService,
                                          )
                                        : null,
                                    icon: const Icon(Icons.play_arrow),
                                    label: const Text('Play'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext dialogContext) {
                                          return AlertDialog(
                                            title: const Text(
                                              'Delete Recording',
                                            ),
                                            content: Text(
                                              'Are you sure you want to delete "${recording.name}"?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.of(
                                                  dialogContext,
                                                ).pop(),
                                                child: const Text('Cancel'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  recordingsState
                                                      .deleteRecording(index);
                                                  Navigator.of(
                                                    dialogContext,
                                                  ).pop();
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'Recording deleted',
                                                      ),
                                                    ),
                                                  );
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                ),
                                                child: const Text('Delete'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    icon: const Icon(Icons.delete),
                                    label: const Text('Delete'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  String _getCommandName(String command) {
    switch (command) {
      case 'F':
        return 'Forward';
      case 'B':
        return 'Backward';
      case 'L':
        return 'Left';
      case 'R':
        return 'Right';
      case 'S':
        return 'Stop';
      default:
        return command;
    }
  }

  void _playRecording(
    BuildContext context,
    Recording recording,
    BluetoothService bluetoothService,
  ) async {
    if (!bluetoothService.isConnected) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Not connected to device')));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Playing recording: ${recording.name}'),
        duration: Duration(seconds: 2),
      ),
    );

    for (int i = 0; i < recording.commands.length; i++) {
      final command = recording.commands[i];
      bluetoothService.sendData(command.command);

      // Calculate delay to next command
      if (i < recording.commands.length - 1) {
        final nextCommand = recording.commands[i + 1];
        final delay = nextCommand.timestamp.difference(command.timestamp);
        await Future.delayed(delay);
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recording playback completed')),
    );
  }
}
