class RecordedCommand {
  final String command;
  final DateTime timestamp;

  RecordedCommand({required this.command, required this.timestamp});

  /// Convert RecordedCommand to JSON
  Map<String, dynamic> toJson() {
    return {
      'command': command,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Create RecordedCommand from JSON
  factory RecordedCommand.fromJson(Map<String, dynamic> json) {
    return RecordedCommand(
      command: json['command'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
