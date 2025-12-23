import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../models/recording.dart';

/// Provider for managing recordings with persistent storage
class RecordingsState extends ChangeNotifier {
  List<Recording> _recordings = [];
  List<Recording> get recordings => _recordings;
  bool _isLoaded = false;

  RecordingsState() {
    _loadRecordings();
  }

  /// Load recordings from SharedPreferences
  Future<void> _loadRecordings() async {
    if (_isLoaded) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? recordingsJson = prefs.getString('recordings');
      
      if (recordingsJson != null) {
        final List<dynamic> decodedList = json.decode(recordingsJson);
        _recordings = decodedList
            .map((item) => Recording.fromJson(item))
            .toList();
        _isLoaded = true;
        notifyListeners();
      }
    } catch (e) {
      print('Error loading recordings: $e');
    }
  }

  /// Save recordings to SharedPreferences
  Future<void> _saveRecordings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String recordingsJson = json.encode(
        _recordings.map((recording) => recording.toJson()).toList(),
      );
      await prefs.setString('recordings', recordingsJson);
    } catch (e) {
      print('Error saving recordings: $e');
    }
  }

  /// Add a new recording
  void addRecording(Recording recording) {
    _recordings.add(recording);
    _saveRecordings();
    notifyListeners();
  }

  /// Delete a recording by index
  void deleteRecording(int index) {
    _recordings.removeAt(index);
    _saveRecordings();
    notifyListeners();
  }

  /// Get a recording by index
  Recording? getRecording(int index) {
    if (index >= 0 && index < _recordings.length) {
      return _recordings[index];
    }
    return null;
  }
}
