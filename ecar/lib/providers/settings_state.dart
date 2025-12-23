import 'package:flutter/material.dart';

/// Provider for managing app settings (wheel speeds)
class SettingsState extends ChangeNotifier {
  double _leftWheelSpeed = 255.0;
  double _rightWheelSpeed = 255.0;

  double get leftWheelSpeed => _leftWheelSpeed;
  double get rightWheelSpeed => _rightWheelSpeed;

  void setLeftWheelSpeed(double speed) {
    _leftWheelSpeed = speed;
    notifyListeners();
  }

  void setRightWheelSpeed(double speed) {
    _rightWheelSpeed = speed;
    notifyListeners();
  }
}
