# Migration Guide: From Single File to Modular Structure

## Overview
This guide helps you understand how the original single-file Flutter app has been reorganized into a maintainable, modular structure.

## Quick Reference Table

| Original Location (Line #) | New Location | Component |
|----------------------------|--------------|-----------|
| Lines 11 | `constants/app_constants.dart` | Mode names constant |
| Lines 108-161 | `models/recorded_command.dart` & `models/recording.dart` | Data models |
| Lines 47-106 | `providers/recordings_state.dart` | Recordings state management |
| Lines 407-423 | `providers/settings_state.dart` | Settings state |
| Lines 425-443 | `providers/my_app_state.dart` | Word pair state |
| Lines 522-608 | `services/bluetooth_service.dart` | Bluetooth service |
| Lines 164-404 | `screens/recordings_page.dart` | Recordings page |
| Lines 610-706 | `screens/settings_page.dart` | Settings page |
| Lines 708-871 | `screens/devices_page.dart` | Devices page |
| Lines 922-989 | `screens/modes_page.dart` | Modes selection |
| Lines 992-1276 | `screens/manual_mode.dart` | Manual mode |
| Lines 1390-1467 | `screens/auto_parking_mode.dart` | Auto parking mode |
| Lines 1470-1547 | `screens/autonomous_mode.dart` | Autonomous mode |
| Lines 446-519 | `screens/home_page.dart` | Main navigation |
| Lines 874-919 | `widgets/battery_indicator.dart` | Battery widget |
| Lines 1550-1581 | `widgets/control_button.dart` | Control button |
| Lines 1278-1387 | `widgets/recordable_control_button.dart` | Advanced button |

## File-by-File Breakdown

### 1. Constants Extraction
**From:** Lines 11 in original `main.dart`
**To:** `constants/app_constants.dart`
```dart
// Before: In main.dart
const modeNames = ['Manual', 'Auto Parking', 'Autonomous'];

// After: In constants/app_constants.dart
const List<String> modeNames = ['Manual', 'Auto Parking', 'Autonomous'];
```

### 2. Models Separation
**From:** Lines 108-161 in original `main.dart`
**To:** `models/recording.dart` and `models/recorded_command.dart`

#### RecordedCommand (Lines 140-161 → `models/recorded_command.dart`)
```dart
// Extracted the RecordedCommand class with JSON methods
class RecordedCommand {
  final String command;
  final DateTime timestamp;
  // ... JSON serialization methods
}
```

#### Recording (Lines 108-138 → `models/recording.dart`)
```dart
// Extracted the Recording class with JSON methods
class Recording {
  final String name;
  final DateTime timestamp;
  final List<RecordedCommand> commands;
  // ... JSON serialization methods
}
```

### 3. Services Layer
**From:** Lines 522-608 in original `main.dart`
**To:** `services/bluetooth_service.dart`

```dart
// All Bluetooth functionality extracted
class BluetoothService extends ChangeNotifier {
  // Connection management
  // Data transmission
  // Battery monitoring
}
```

### 4. Providers/State Management
**From:** Multiple sections in original `main.dart`
**To:** Separate provider files

#### RecordingsState (Lines 47-106 → `providers/recordings_state.dart`)
```dart
// Recording management with persistence
class RecordingsState extends ChangeNotifier {
  // CRUD operations
  // SharedPreferences integration
}
```

#### SettingsState (Lines 407-423 → `providers/settings_state.dart`)
```dart
// Wheel speed settings
class SettingsState extends ChangeNotifier {
  // Speed configuration
}
```

### 5. Screens Reorganization
Each major UI component became its own screen file:

#### Home Page (Lines 446-519 → `screens/home_page.dart`)
- Main navigation rail
- Page switching logic

#### Modes Page (Lines 922-989 → `screens/modes_page.dart`)
- Mode selection interface
- Navigation to specific modes

#### Manual Mode (Lines 992-1276 → `screens/manual_mode.dart`)
- Manual control interface
- Recording functionality
- Continuous mode toggle

#### Auto Parking Mode (Lines 1390-1467 → `screens/auto_parking_mode.dart`)
- Parallel parking button
- Perpendicular parking button

#### Autonomous Mode (Lines 1470-1547 → `screens/autonomous_mode.dart`)
- Start/pause/stop autonomous control

#### Devices Page (Lines 708-871 → `screens/devices_page.dart`)
- Bluetooth device list
- Connection management
- Draggable data indicator

#### Recordings Page (Lines 164-404 → `screens/recordings_page.dart`)
- List of saved recordings
- Play/delete functionality

#### Settings Page (Lines 610-706 → `screens/settings_page.dart`)
- Wheel speed sliders
- Reset functionality

### 6. Widgets Extraction
Reusable components extracted into separate widget files:

#### Battery Indicator (Lines 874-919 → `widgets/battery_indicator.dart`)
```dart
// Reusable battery display widget
class BatteryIndicator extends StatelessWidget {
  // Color-coded battery level
}
```

#### Control Button (Lines 1550-1581 → `widgets/control_button.dart`)
```dart
// Simple command button
class ControlButton extends StatelessWidget {
  // Basic button for sending commands
}
```

#### Recordable Control Button (Lines 1278-1387 → `widgets/recordable_control_button.dart`)
```dart
// Advanced button with recording and continuous mode
class RecordableControlButton extends StatefulWidget {
  // Press-and-hold functionality
  // Command recording
}
```

## Import Changes

### Before (Original single file)
```dart
// Everything was in one file - no imports needed
// Just external package imports at the top
```

### After (Modular structure)
Each file imports what it needs:

**Example: `screens/manual_mode.dart`**
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/bluetooth_service.dart';
import '../providers/recordings_state.dart';
import '../models/recording.dart';
import '../models/recorded_command.dart';
import '../widgets/battery_indicator.dart';
import '../widgets/recordable_control_button.dart';
```

## Provider Setup

### Before (Original)
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (context) => MyAppState()),
    ChangeNotifierProvider(create: (context) => BluetoothService()),
    ChangeNotifierProvider(create: (context) => SettingsState()),
    ChangeNotifierProvider(create: (context) => RecordingsState()),
  ],
  // ...
)
```

### After (Same, but in organized main.dart)
```dart
// In lib/main.dart
import 'providers/my_app_state.dart';
import 'providers/recordings_state.dart';
import 'providers/settings_state.dart';
import 'services/bluetooth_service.dart';

// Same MultiProvider setup
```

## How to Add New Features

### Adding a New Control Mode
1. Create `lib/screens/new_mode.dart`
2. Import required services/providers
3. Build UI using existing widgets
4. Add to `screens/modes_page.dart`:
```dart
final modeWidgets = <String, Widget>{
  'Manual': const ManualMode(),
  'Auto Parking': const AutoParkingMode(),
  'Autonomous': const AutonomousMode(),
  'New Mode': const NewMode(), // Add here
};
```

### Adding a New Widget
1. Create `lib/widgets/new_widget.dart`
2. Make it reusable (parameterized)
3. Import and use in screens

### Modifying Bluetooth Protocol
1. Go to `services/bluetooth_service.dart`
2. Modify `sendData()` or `_onDataReceived()`
3. Changes automatically propagate to all screens

## Testing the Migration

### Verify Each Component
1. **Bluetooth Connection**: Test in Devices page
2. **Manual Controls**: Test all buttons in Manual mode
3. **Recording**: Record, save, and playback
4. **Auto Parking**: Test both parking modes
5. **Autonomous**: Test start/pause/stop
6. **Settings**: Adjust speeds and verify transmission
7. **Navigation**: Switch between all tabs

### Common Issues After Migration

**Issue**: Import errors
**Solution**: Ensure all files have correct import paths

**Issue**: Provider not found
**Solution**: Check that all providers are in main.dart MultiProvider

**Issue**: Widget not found
**Solution**: Import the widget file in the screen that uses it

## Benefits Achieved

1. **Reduced File Size**: From 1582 lines to manageable chunks
2. **Clear Separation**: Each file has one responsibility
3. **Easy Navigation**: Know where to find code
4. **Better Git**: Smaller diffs, less conflicts
5. **Testable**: Can test components independently
6. **Scalable**: Easy to add new features

## Development Workflow

### Before (Single File)
```
Edit main.dart (1582 lines)
  ↓
Find the right section
  ↓
Make changes
  ↓
Risk breaking unrelated features
  ↓
Hard to review changes
```

### After (Modular)
```
Identify feature location
  ↓
Open specific file (50-300 lines)
  ↓
Make focused changes
  ↓
Changes isolated to feature
  ↓
Easy to review and test
```

## Checklist for Similar Migrations

- [ ] Identify logical groupings (models, services, screens, widgets)
- [ ] Extract constants first
- [ ] Extract models (no dependencies)
- [ ] Extract services (may depend on models)
- [ ] Extract providers (may depend on services/models)
- [ ] Extract widgets (reusable components)
- [ ] Extract screens (use widgets and providers)
- [ ] Create main.dart entry point
- [ ] Update all import statements
- [ ] Test all functionality
- [ ] Document new structure
- [ ] Update README

## Conclusion

This migration transforms a monolithic 1582-line file into 19 focused, maintainable files. Each file has a clear purpose, making the codebase easier to understand, modify, and extend.
