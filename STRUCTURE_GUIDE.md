# Project Structure Guide

## File Organization Overview

### Directory Structure
```
car_control_app/
│
├── lib/
│   ├── main.dart                           [Entry Point - App Initialization]
│   │
│   ├── constants/
│   │   └── app_constants.dart             [Global app constants]
│   │
│   ├── models/                            [Data Models]
│   │   ├── recording.dart                 • Recording data structure
│   │   └── recorded_command.dart          • Command data structure
│   │
│   ├── services/                          [Business Logic & External APIs]
│   │   └── bluetooth_service.dart         • Bluetooth connectivity
│   │                                       • Data transmission
│   │                                       • Battery monitoring
│   │
│   ├── providers/                         [State Management]
│   │   ├── my_app_state.dart             • Legacy word pair state
│   │   ├── recordings_state.dart          • Recording CRUD operations
│   │   │                                   • Persistent storage
│   │   └── settings_state.dart            • Wheel speed settings
│   │
│   ├── screens/                           [Full-Page Views]
│   │   ├── home_page.dart                • Main navigation
│   │   ├── modes_page.dart               • Mode selection
│   │   ├── manual_mode.dart              • Manual controls
│   │   ├── auto_parking_mode.dart        • Auto parking
│   │   ├── autonomous_mode.dart          • Autonomous navigation
│   │   ├── devices_page.dart             • Bluetooth device list
│   │   ├── recordings_page.dart          • Saved recordings
│   │   └── settings_page.dart            • App configuration
│   │
│   └── widgets/                           [Reusable Components]
│       ├── battery_indicator.dart         • Battery level display
│       ├── control_button.dart            • Simple command button
│       └── recordable_control_button.dart • Advanced button with recording
│
└── README.md                               [Documentation]
```

## Component Relationships

```
main.dart
    ↓
    Providers Setup:
    ├── MyAppState
    ├── BluetoothService
    ├── SettingsState
    └── RecordingsState
    ↓
MyHomePage (Navigation)
    ↓
    ├── ModesPage → Manual/AutoParking/Autonomous Modes
    ├── DevicesPage → Bluetooth Connection
    ├── RecordingsPage → View/Play Recordings
    └── SettingsPage → Configure Speeds
```

## Data Flow

### Recording Flow
```
User Action (Manual Mode)
    ↓
RecordableControlButton
    ↓
_recordCommand()
    ↓
RecordingsState.addRecording()
    ↓
SharedPreferences (Persistent Storage)
```

### Control Flow
```
User Tap
    ↓
ControlButton / RecordableControlButton
    ↓
BluetoothService.sendData()
    ↓
Bluetooth Device (Car)
```

### Settings Flow
```
User Adjusts Slider
    ↓
SettingsState.setWheelSpeed()
    ↓
BluetoothService.sendData('LS:XXX' or 'RS:XXX')
    ↓
Car Updates Speed
```

## Key Design Patterns

### 1. Provider Pattern (State Management)
- **RecordingsState**: Manages recording list
- **SettingsState**: Manages app settings
- **BluetoothService**: Manages connection state

### 2. Widget Composition
- Reusable widgets (BatteryIndicator, ControlButton)
- Screen-specific widgets (RecordableControlButton)

### 3. Service Layer
- BluetoothService encapsulates all Bluetooth logic
- Clean separation between UI and business logic

### 4. Model-View-Provider (MVP-like)
- Models: Data structures
- Views: Screens and Widgets
- Providers: Business logic and state

## File Purposes

### Constants (`app_constants.dart`)
- Mode names array
- Shared across multiple screens

### Models
**recording.dart**
- Defines Recording class
- JSON serialization methods

**recorded_command.dart**
- Defines RecordedCommand class
- Timestamp and command data

### Services
**bluetooth_service.dart**
- Connection management
- Data transmission
- Battery monitoring
- Extends ChangeNotifier for state updates

### Providers
**recordings_state.dart**
- Add, delete, retrieve recordings
- SharedPreferences integration
- Persistent storage

**settings_state.dart**
- Wheel speed configuration
- Notifies listeners on changes

### Screens
All screens follow similar pattern:
1. Import required providers/services
2. Use Provider.of<> to access state
3. Build UI with widgets
4. Handle user interactions

### Widgets
**battery_indicator.dart**
- Displays battery percentage
- Color-coded by level

**control_button.dart**
- Simple command button
- Disabled when not connected

**recordable_control_button.dart**
- Advanced button with states
- Supports continuous mode
- Records commands when enabled

## Migration from Original File

### Original Structure (Single File - 1582 lines)
```
main.dart (everything)
├── Constants
├── All Models
├── All Services
├── All Providers
├── All Screens
└── All Widgets
```

### New Structure (Multiple Files - Organized)
```
├── constants/     (1 file)
├── models/        (2 files)
├── services/      (1 file)
├── providers/     (3 files)
├── screens/       (8 files)
└── widgets/       (3 files)
```

## Benefits

1. **Find Code Faster**: Know exactly where each feature lives
2. **Easier Collaboration**: Multiple developers can work on different files
3. **Better Testing**: Test individual components in isolation
4. **Reduced Merge Conflicts**: Changes in different features don't conflict
5. **Clear Dependencies**: Import statements show component relationships
6. **Reusability**: Widgets and services can be easily reused
7. **Maintainability**: Modify features without affecting others

## How to Navigate

**To modify control commands:**
→ Go to `widgets/control_button.dart` or `widgets/recordable_control_button.dart`

**To change Bluetooth logic:**
→ Go to `services/bluetooth_service.dart`

**To add a new mode:**
1. Create new file in `screens/`
2. Add to `screens/modes_page.dart`

**To modify recording storage:**
→ Go to `providers/recordings_state.dart`

**To change UI layout:**
→ Go to specific screen in `screens/`

**To add global constants:**
→ Go to `constants/app_constants.dart`
