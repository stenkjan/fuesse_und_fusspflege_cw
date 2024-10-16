import 'package:flutter/material.dart';
import 'package:fuesse_und_fusspflege_cw/src/registration/registration_view.dart';
import 'package:fuesse_und_fusspflege_cw/src/registration/navbar.dart';
import 'package:fuesse_und_fusspflege_cw/src/registration/user_list.dart';
import 'package:provider/provider.dart';
import 'settings/settings_controller.dart';
import 'settings/settings_view.dart';
import 'registration/user_list_provider.dart'; // Import your UserListProvider
import 'package:permission_handler/permission_handler.dart';

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _requestPermissions();
    Provider.of<UserListProvider>(context, listen: false).loadUserList();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          // ...
          home: const MainView(),
          onGenerateRoute: (RouteSettings routeSettings) {
            return MaterialPageRoute<void>(
              settings: routeSettings,
              builder: (BuildContext context) {
                switch (routeSettings.name) {
                  case UserList.routeName:
                    return const UserList();
                  case RegistrationForm.routeName:
                    return const RegistrationForm();
                  case SettingsView.routeName:
                    return SettingsView(controller: widget.settingsController);
                  default:
                    return const MainView();
                }
              },
            );
          },
        );
      },
    );
  }

  Future<void> _requestPermissions() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

}