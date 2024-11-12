import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fuesse_und_fusspflege_cw/src/registration/consent.dart';
import 'package:fuesse_und_fusspflege_cw/src/registration/consent_from_screen.dart';
import 'package:fuesse_und_fusspflege_cw/src/registration/notepad.dart';
import 'package:fuesse_und_fusspflege_cw/src/registration/registration_view.dart';
import 'package:fuesse_und_fusspflege_cw/src/registration/user.dart';
import 'package:fuesse_und_fusspflege_cw/src/registration/user_list_provider.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:fuesse_und_fusspflege_cw/src/registration/user_search.dart';

// Convert Map to Offset
Offset offsetFromJson(Map<String, dynamic> json) {
  return Offset(
    json['dx'],
    json['dy'],
  );
}

// Convert Offset to Map
Map<String, dynamic> offsetToJson(Offset offset) {
  return {
    'dx': offset.dx,
    'dy': offset.dy,
  };
}

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<File> get _localFile async {
  final path = await _localPath;
  return File('$path/users.json');
}

Future<File> writeUserList(List<User> users) async {
  final file = await _localFile;
  return file
      .writeAsString(jsonEncode(users.map((user) => user.toJson()).toList()));
}

Future<List<User>> readUserList() async {
  try {
    final file = await _localFile;

    // Check if the file exists
    if (await file.exists()) {
      final contents = await file.readAsString();
      final data = jsonDecode(contents) as List;
      return data.map((item) => User.fromJson(item)).toList();
    } else {
      // If the file doesn't exist, return an empty list
      return [];
    }
  } catch (e) {
    // If encountering an error, return an empty list
    return [];
  }
}

class UserList extends StatefulWidget {
  static const routeName = 'user_list';

  const UserList({super.key});

  @override
  UserListState createState() => UserListState();
}

class UserListState extends State<UserList> {
  int? _selectedUserIndex;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserListProvider>(context, listen: false)
          .setTitle('Nageldesign und Fußpflege');
    });
    // readUserList().then((users) {
    //   setState(() {
    //     _users = users;
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    final userListProvider = context.watch<UserListProvider>();
    final users = userListProvider.userList;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kundenliste'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              final selectedUser = await showSearch<User?>(
                context: context,
                delegate: UserSearch(),
              );
              if (selectedUser != null) {
                final selectedIndex = users.indexOf(selectedUser);
                setState(() {
                  _selectedUserIndex = selectedIndex;
                });
              }
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return Material(
            child: ListTile(
              leading: Radio(
                fillColor: WidgetStateProperty.all(Colors.blueAccent),
                value: user.userId,
                groupValue:
                    Provider.of<UserListProvider>(context, listen: false)
                        .selectedUserId,
                onChanged: (String? value) {
                  Provider.of<UserListProvider>(context, listen: false)
                      .selectUser(value!);
                },
              ),
              title: Text(user.name),
              subtitle:
                  Text(DateFormat('dd.MM.yyyy').format(user.dateOfBirth!)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.note_add),
                    onPressed: () {
                      Provider.of<UserListProvider>(context, listen: false)
                          .selectUser(user.userId);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ConsentFormScreen(),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.note),
                    color: user.notes.isNotEmpty ? Colors.blue : Colors.grey,
                    onPressed: () async {
                      Provider.of<UserListProvider>(context, listen: false)
                          .selectUser(user.userId);
                      final updatedUser = await Navigator.push<User>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NotepadScreen(
                            user: user,
                            users: users,
                          ),
                        ),
                      );

                      if (updatedUser != null) {
                        updatedUser.notes = user.notes;
                        userListProvider.updateUser(user.userId, updatedUser);
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Provider.of<UserListProvider>(context, listen: false)
                          .selectUser(user.userId);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Scaffold(
                            appBar: AppBar(
                              title: const Text(
                                'Kunde bearbeiten',
                                style: TextStyle(color: Colors.white),
                              ),
                              elevation: 5.0, // This adds shadow
                              backgroundColor: Colors.blue[300],
                            ),
                            body: RegistrationForm(user: user),
                          ),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      Provider.of<UserListProvider>(context, listen: false)
                          .selectUser(user.userId);
                      final confirm = await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Löschen bestätigen'),
                            content: const Text(
                                'Sicher, dass du den Kundeneintrag löschen willst?'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const Text('Ja'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text('Nein'),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirm == true) {
                        userListProvider.removeUser(user.userId);
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: userListProvider.selectedUser == null
            ? null
            : () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return Wrap(
                      children: <Widget>[
                        ListTile(
                          leading: const Icon(Icons.picture_as_pdf),
                          title: const Text('PDF generieren'),
                          onTap: () {
                            generatePdf([userListProvider.selectedUser!]);
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.mail),
                          title: const Text(
                              'PDF generieren und Unterlagen senden'),
                          onTap: () {
                            generatePdfAndSend(
                                [userListProvider.selectedUser!]);
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.picture_as_pdf),
                          title: const Text('Einwilligungserklärung als PDF'),
                          onTap: () {
                            if (userListProvider.selectedUser?.consent !=
                                null) {
                              generateConsentPdf(
                                  userListProvider.selectedUser!.consent!);
                            }
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.mail),
                          title:
                              const Text('Einwilligungserklärung als PDF und senden'),
                          onTap: () {
                            if (userListProvider.selectedUser?.consent !=
                                null) {
                              generateConsentPdfAndSend(
                                  userListProvider.selectedUser!.consent!, userListProvider.selectedUser!);
                            }
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    );
                  },
                );
              },
        child: const Icon(Icons.picture_as_pdf, color: Colors.blueAccent),
      ),
    );
  }
}

// final List<User> _users = [
//   User(
//     name: 'John Smith',
//     plzOrt: '12345 City',
//     strasse: 'Street 1',
//     telefonnummer: '1234567890',
//     besonderheiten: 'None',
//     erkrankungen: 'None',
//     uebertragbareErkrankungen: 'None',
//     einnahmeVonHormonen: 'None',
//     einnahmeVonMedikamenten: 'None',
//     allergien: 'None',
//     erfahrungenGelAcrylmodellage: false,
//     bluter: false,
//     diabetiker: false,
//     schwangerschaft: false,
//     dateOfBirth: DateTime(1990, 1, 1),
//     informationsbogenDate: DateTime.now(),
//     einwilligungDate: DateTime.now(),
//     signature1Date: DateTime.now(),
//     signature2Date: DateTime.now(),
//     signature1: [],
//     signature2: [],
//     selectedHautZustandFussruecken: 'rau/trocken',
//     selectedHautZustandFussohle: 'rau/trocken',
//     selectedNagelzustand: 'glatt/fest',
//     selectedNagelerkrankungen: 'Nagelpilz',
//     selectedNagelform: 'oval',
//     selectedNagelspitzenform: 'rundlich',
//   ),
//   User(
//     name: 'Jane Smith',
//     plzOrt: '67890 City',
//     strasse: 'Street 2',
//     telefonnummer: '0987654321',
//     besonderheiten: 'None',
//     erkrankungen: 'None',
//     uebertragbareErkrankungen: 'None',
//     einnahmeVonHormonen: 'None',
//     einnahmeVonMedikamenten: 'None',
//     allergien: 'None',
//     erfahrungenGelAcrylmodellage: false,
//     bluter: false,
//     diabetiker: false,
//     schwangerschaft: false,
//     dateOfBirth: DateTime(1992, 2, 2),
//     informationsbogenDate: DateTime.now(),
//     einwilligungDate: DateTime.now(),
//     signature1Date: DateTime.now(),
//     signature2Date: DateTime.now(),
//     signature1: [],
//     signature2: [],
//     selectedHautZustandFussruecken: 'rau/trocken',
//     selectedHautZustandFussohle: 'rau/trocken',
//     selectedNagelzustand: 'glatt/fest',
//     selectedNagelerkrankungen: 'Nagelpilz',
//     selectedNagelform: 'oval',
//     selectedNagelspitzenform: 'rundlich',
//   ),
//   // Add more users if needed...
// ];
