import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'providers/my_app_state.dart';
import 'providers/recordings_state.dart';
import 'providers/settings_state.dart';
import 'services/bluetooth_service.dart';
import 'screens/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((value) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MyAppState()),
        ChangeNotifierProvider(create: (context) => BluetoothService()),
        ChangeNotifierProvider(create: (context) => SettingsState()),
        ChangeNotifierProvider(create: (context) => RecordingsState()),
      ],
      child: MaterialApp(
        title: 'الجزري',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue.shade900),
        ),
        home: MyHomePage(),
      ),
    );
  }
}
