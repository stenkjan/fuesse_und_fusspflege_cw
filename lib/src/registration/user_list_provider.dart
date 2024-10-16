import 'dart:convert';
import 'dart:io';
// import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:fuesse_und_fusspflege_cw/src/registration/user.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'user_list.dart';

class UserListProvider with ChangeNotifier {
  List<User> _userList = [];
  String? selectedUserId;

  String _title = 'Nageldesign und Fußpflege';

  String get title => _title;

  UserListProvider() {
    loadUserList();
  }

  User? get selectedUser {
    if (selectedUserId == null) {
      return null;
    }
    try {
      return _userList.firstWhere((user) => user.userId == selectedUserId);
    } catch (e) {
      return null;
    }
  }

  List<User> get userList => _userList;

  Future<void> loadUserList() async {
    try {
      _userList = await readUserList();
    } catch (e) {
      _userList = [];
    }
    notifyListeners();
  }

  Future<void> addUser(User user) async {
    _userList.add(user);
    await _saveUserList();
    await backupUserList();
    notifyListeners();
  }

  void selectUser(String userId) {
    selectedUserId = userId;
    notifyListeners();
  }

  Future<void> _saveUserList() async {
    await writeUserList(_userList);
  }

  void setTitle(String title) {
    _title = title;
    notifyListeners();
  }

  Future<void> updateUser(String userId, User updatedUser) async {
    int index = _userList.indexWhere((user) => user.userId == userId);
    if (index != -1) {
      _userList[index] = updatedUser;
      await _saveUserList();
      await backupUserList();
      notifyListeners();
    }
  }

  Future<void> removeUser(String? userId) async {
    if (userId == null) return;
    _userList.removeWhere((user) => user.userId == userId);
    await _saveUserList();
    notifyListeners();
  }

  // Future<void> startBackup() async {
  //   print("Backup started");
  //   await AndroidAlarmManager.periodic(
  //     const Duration(days: 1),
  //     0, // id
  //     backupUserList,
  //     wakeup: true,
  //     exact: true,
  //     rescheduleOnReboot: true,
  //   );
  // }

  Future<void> backupUserList() async {
    print("BackupList started");
    var status = await Permission.manageExternalStorage.status;
    if (!status.isGranted) {
      status = await Permission.manageExternalStorage.request();
      if (!status.isGranted) {
        return;
      }
    }
    final directory = await getExternalStorageDirectory();
    final appDirectory =
        Directory('/storage/emulated/0/Kundenliste Fusspflege');
    if (!await appDirectory.exists()) {
      await appDirectory.create();
    }
    print(appDirectory.path);
    final backupFile = File('${appDirectory.path}/backup.json');
    final userListJson =
        jsonEncode(_userList.map((user) => user.toJson()).toList());
    await backupFile.writeAsString(userListJson);
  }

  Future<void> importUserList(String filePath) async {
    final importFile = File(filePath);
    if (await importFile.exists()) {
      final importedJson = await importFile.readAsString();
      final importedList = jsonDecode(importedJson) as List;
      final importedUsers =
          importedList.map((userJson) => User.fromJson(userJson)).toList();
      _userList.clear(); // Clear the existing user list
      _userList.addAll(importedUsers); // Add the imported users
      await _saveUserList();
      notifyListeners();
    } else {
      throw Exception('Datei existiert nicht');
    }
  }
}
