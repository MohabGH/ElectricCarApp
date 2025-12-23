# Car Control App - Refactored Structure

This Flutter application has been refactored from a single file into a well-organized, modular structure for better maintainability and readability.

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── constants/
│   └── app_constants.dart            # Global constants
├── models/
│   ├── recording.dart                # Recording data model
│   └── recorded_command.dart         # Command data model
├── services/
│   └── bluetooth_service.dart        # Bluetooth communication service
├── providers/
│   ├── my_app_state.dart            # Word pair state (legacy)
│   ├── recordings_state.dart         # Recordings management
│   └── settings_state.dart           # App settings management
├── screens/
│   ├── home_page.dart               # Main navigation page
│   ├── modes_page.dart              # Mode selection screen
│   ├── manual_mode.dart             # Manual control mode
│   ├── auto_parking_mode.dart       # Auto parking mode
│   ├── autonomous_mode.dart         # Autonomous mode
│   ├── devices_page.dart            # Bluetooth devices screen
│   ├── recordings_page.dart         # Saved recordings screen
│   └── settings_page.dart           # App settings screen
└── widgets/
    ├── battery_indicator.dart        # Battery level widget
    ├── control_button.dart           # Simple control button
    └── recordable_control_button.dart # Button with recording support
```

## Key Features

### 1. **Multiple Control Modes**
   - **Manual Mode**: Direct control with recording capability
   - **Auto Parking**: Parallel parking
   - **Autonomous**: Self-navigation mode

### 2. **Bluetooth Communication**
   - Connect to paired Bluetooth devices
   - Send commands to control the car
   - Receive battery level updates

### 3. **Recording System**
   - Record manual control sequences
   - Save recordings with custom names
   - Replay saved recordings
   - Persistent storage using SharedPreferences

### 4. **Settings**
   - Adjustable left/right wheel speeds
   - Real-time speed configuration

### 5. **Continuous Mode**
   - Toggle between tap-to-command and hold-to-move modes

## Architecture

### Models
Data classes representing the app's domain objects:
- **Recording**: Container for saved command sequences
- **RecordedCommand**: Individual command with timestamp

### Services
Business logic and external communication:
- **BluetoothService**: Handles Bluetooth connectivity and data transmission

### Providers
State management using Provider pattern:
- **RecordingsState**: Manages recording storage and retrieval
- **SettingsState**: Manages app configuration
- **MyAppState**: Legacy word pair functionality

### Screens
Full-page UI components:
- Navigation and routing between different app sections
- Mode-specific control interfaces

### Widgets
Reusable UI components:
- Battery indicator
- Control buttons with different behaviors

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.0
  flutter_bluetooth_serial: ^0.4.0
  shared_preferences: ^2.0.0
  english_words: ^4.0.0
```

## Getting Started

1. Ensure all dependencies are installed:
   ```bash
   flutter pub get
   ```

2. Run the app:
   ```bash
   flutter run
   ```

3. The app will launch in landscape mode

## Usage

1. **Connect to Device**: Go to Devices tab and select your Bluetooth car
2. **Select Mode**: Choose your desired control mode from the Modes tab
3. **Control**: Use the on-screen buttons to control your car
4. **Record**: In Manual mode, start recording to save command sequences
5. **Settings**: Adjust wheel speeds in the Settings tab

## Command Protocol

- `F` - Forward
- `B` - Backward
- `L` - Left
- `R` - Right
- `S` - Stop
- `RF` - Right Parking
- `LF` - Left Parking
- `A` - Start Autonomous
- `LS:XXX` - Set Left Speed (0-255)
- `RS:XXX` - Set Right Speed (0-255)

## Benefits of Refactoring

1. **Modularity**: Each component has a single responsibility
2. **Maintainability**: Easy to locate and modify specific features
3. **Testability**: Individual components can be tested in isolation
4. **Scalability**: New features can be added without affecting existing code
5. **Readability**: Clear structure makes the codebase easier to understand
6. **Reusability**: Widgets and services can be reused across the app

## Future Improvements

- Add unit tests for models and services
- Implement integration tests for screens
- Add error handling and user feedback
- Enhance UI with animations
- Add more control modes
- Implement command queue for complex sequences
