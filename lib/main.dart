import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';
import 'src/registration/user_list_provider.dart';
import 'package:provider/provider.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Request storage permission
  var status = await Permission.manageExternalStorage.status;
  if (!status.isGranted) {
    status = await Permission.manageExternalStorage.request();
  }

  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  final settingsController = SettingsController(SettingsService());

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();

  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.

  await AndroidAlarmManager.initialize();

  runApp(
    ChangeNotifierProvider(
        create: (context) => UserListProvider(),
        child: MyApp(settingsController: settingsController)),
  );
}
