import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fuesse_und_fusspflege_cw/src/registration/user.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'user_list.dart';

class UserListProvider with ChangeNotifier {
  List<User> _userList = [];
  String? selectedUserId;
  DateTime? _lastBackupDate;

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
      _lastBackupDate = await _getLastBackupDate();
    } catch (e) {
      _userList = [];
    }
    notifyListeners();
  }

  Future<void> addUser(User user) async {
    _userList.add(user);
    await _saveUserList();
    await _checkAndBackupUserList();
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

  Future<bool> updateUser(String userId, User updatedUser) async {
    int index = _userList.indexWhere((user) => user.userId == userId);
    if (index != -1) {
      updatedUser.lastEdited = DateTime.now();
      _userList[index] = updatedUser;
      await _saveUserList();
      await _checkAndBackupUserList();
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> removeUser(String? userId) async {
    if (userId == null) return;
    _userList.removeWhere((user) => user.userId == userId);
    await _saveUserList();
    await _checkAndBackupUserList();
    notifyListeners();
  }

  Future<void> _checkAndBackupUserList() async {
    final now = DateTime.now();
    if (_lastBackupDate == null ||
        now.difference(_lastBackupDate!).inDays >= 30) {
      await _backupUserList(now);
      _lastBackupDate = now;
      await _saveLastBackupDate(now);
    }
  }

  Future<void> _backupUserList(DateTime now) async {
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
    final backupFile = File(
        '${appDirectory.path}/backup_${now.month.toString().padLeft(2, '0')}${now.year}.json');
    final userListJson =
        jsonEncode(_userList.map((user) => user.toJson()).toList());
    await backupFile.writeAsString(userListJson);
  }

  Future<void> importUserList(String filePath) async {
    final importFile = File(filePath);
    if (await importFile.exists()) {
      final importedJson = await importFile.readAsString();
      final importedList = jsonDecode(importedJson) as List;
      final importedUsers = importedList.map((userJson) {
        final userMap = Map<String, dynamic>.from(userJson);
        if (userMap['lastEdited'] == null) {
          userMap['lastEdited'] = DateTime.now().toIso8601String();
        }
        return User.fromJson(userMap);
      }).toList();
      _userList.clear(); // Clear the existing user list
      _userList.addAll(importedUsers); // Add the imported users
      await _saveUserList();
      notifyListeners();
    } else {
      throw Exception('Datei existiert nicht');
    }
  }

  Future<DateTime?> _getLastBackupDate() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/last_backup_date.txt');
    if (await file.exists()) {
      final dateStr = await file.readAsString();
      return DateTime.tryParse(dateStr);
    }
    return null;
  }

  Future<void> _saveLastBackupDate(DateTime date) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/last_backup_date.txt');
    await file.writeAsString(date.toIso8601String());
  }
}
