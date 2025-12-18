import 'recorded_command.dart';

class Recording {
  final String name;
  final DateTime timestamp;
  final List<RecordedCommand> commands;

  Recording({
    required this.name,
    required this.timestamp,
    required this.commands,
  });

  /// Convert Recording to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'timestamp': timestamp.toIso8601String(),
      'commands': commands.map((cmd) => cmd.toJson()).toList(),
    };
  }

  /// Create Recording from JSON
  factory Recording.fromJson(Map<String, dynamic> json) {
    return Recording(
      name: json['name'],
      timestamp: DateTime.parse(json['timestamp']),
      commands: (json['commands'] as List)
          .map((cmdJson) => RecordedCommand.fromJson(cmdJson))
          .toList(),
    );
  }
}
