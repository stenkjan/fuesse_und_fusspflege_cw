import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fuesse_und_fusspflege_cw/src/registration/consent.dart';
import 'package:fuesse_und_fusspflege_cw/src/registration/policies.dart';
import 'package:fuesse_und_fusspflege_cw/src/registration/consent_from_screen.dart';
import 'package:fuesse_und_fusspflege_cw/src/registration/policies_from_screen.dart';
import 'package:fuesse_und_fusspflege_cw/src/registration/notepad.dart';
import 'package:fuesse_und_fusspflege_cw/src/registration/registration_view.dart';
import 'package:fuesse_und_fusspflege_cw/src/registration/user.dart';
import 'package:fuesse_und_fusspflege_cw/src/registration/user_list_export.dart';
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
  String _sortCriteria = 'last_edited';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserListProvider>(context, listen: false)
          .setTitle('Nageldesign und Fußpflege');
    });
  }

  void _sortUsers(List<User> users) {
    switch (_sortCriteria) {
      case 'name_asc':
        users.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'name_desc':
        users.sort((a, b) => b.name.compareTo(a.name));
        break;
      case 'last_edited':
        users.sort((a, b) => b.lastEdited.compareTo(a.lastEdited));
        break;
      case 'standard':
        users.sort((a, b) => a.lastEdited.compareTo(b.lastEdited));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userListProvider = context.watch<UserListProvider>();
    final users = userListProvider.userList;
    _sortUsers(users);

    return Scaffold(
      backgroundColor: const Color.fromARGB(102, 119, 199, 216),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(102, 94, 196, 219),
        title: Text('Kundenliste (${users.length})'),
        actions: <Widget>[
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (String result) {
              setState(() {
                _sortCriteria = result;
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'name_asc',
                child: Text('Alphabetisch (aufsteigend)'),
              ),
              const PopupMenuItem<String>(
                value: 'name_desc',
                child: Text('Alphabetisch (absteigend)'),
              ),
              const PopupMenuItem<String>(
                value: 'last_edited',
                child: Text('Zuletzt bearbeitet (absteigend)'),
              ),
              const PopupMenuItem<String>(
                value: 'standard',
                child: Text('Zuletzt bearbeitet (aufsteigend)'),
              ),
            ],
          ),
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return GestureDetector(
              onTap: () {
                Provider.of<UserListProvider>(context, listen: false)
                    .selectUser(user.userId);
              },
              child: Card(
                elevation: 4.0,
                margin: const EdgeInsets.symmetric(vertical: 4.0),
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Radio(
                            fillColor:
                                WidgetStateProperty.all(Colors.blueAccent),
                            value: user.userId,
                            groupValue: Provider.of<UserListProvider>(context,
                                    listen: false)
                                .selectedUserId,
                            onChanged: (String? value) {
                              Provider.of<UserListProvider>(context,
                                      listen: false)
                                  .selectUser(value!);
                            },
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                          const SizedBox(width: 8.0),
                          Text(user.name, style: const TextStyle(fontSize: 18)),
                        ],
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'bearbeitet: ${DateFormat('dd.MM.yy HH:mm').format(user.lastEdited)}',
                        style:
                            const TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'Geburtstag: ${DateFormat('dd.MM.yyyy').format(user.dateOfBirth!)}',
                        style:
                            const TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          IconButton(
                            icon: const Icon(Icons.note_add, size: 20),
                             color: user.consent != null
                                ? Colors.blue
                                : Colors.black,
                            onPressed: () {
                              Provider.of<UserListProvider>(context,
                                      listen: false)
                                  .selectUser(user.userId);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ConsentFormScreen(),
                                ),
                              );
                            },
                          ),
                            IconButton(
                            icon: const Icon(Icons.handshake, size: 20),
                             color: user.policies != null
                                ? Colors.blue
                                : Colors.black,
                            onPressed: () {
                              Provider.of<UserListProvider>(context,
                                      listen: false)
                                  .selectUser(user.userId);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const PoliciesFormScreen(),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.note, size: 20),
                            color: user.notes.isNotEmpty
                                ? Colors.blue
                                : Colors.black,
                            onPressed: () async {
                              Provider.of<UserListProvider>(context,
                                      listen: false)
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
                                userListProvider.updateUser(
                                    user.userId, updatedUser);
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed: () {
                              Provider.of<UserListProvider>(context,
                                      listen: false)
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
                            icon: const Icon(Icons.delete, size: 20),
                            onPressed: () async {
                              Provider.of<UserListProvider>(context,
                                      listen: false)
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
                    ],
                  ),
                ),
              ),
            );
          },
        ),
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
                            } else {
                              Fluttertoast.showToast(
                                msg: 'Keine Einwilligungserklärung vorhanden',
                                toastLength: Toast.LENGTH_SHORT,
                              );
                            }
                            Navigator.pop(context);
                          },
                        ),
                         ListTile(
                          leading: const Icon(Icons.picture_as_pdf),
                          title: const Text('Terminregelvereinbarung als PDF'),
                          onTap: () {
                            if (userListProvider.selectedUser?.policies !=
                                null) {
                              generatePoliciesPdf(
                                  userListProvider.selectedUser!.policies!);
                            } else {
                              Fluttertoast.showToast(
                                msg: 'Keine Einwilligungserklärung vorhanden',
                                toastLength: Toast.LENGTH_SHORT,
                              );
                            }
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.mail),
                          title: const Text(
                              'Einwilligungserklärung als PDF und senden'),
                          onTap: () {
                            if (userListProvider.selectedUser?.consent !=
                                null) {
                              generateConsentPdfAndSend(
                                  userListProvider.selectedUser!.consent!,
                                  userListProvider.selectedUser!);
                            } else {
                              Fluttertoast.showToast(
                                msg: 'Keine Einwilligungserklärung vorhanden',
                                toastLength: Toast.LENGTH_SHORT,
                              );
                            }
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.backup),
                          title: const Text('Backup Exportieren'),
                          onTap: () async {
                            final exporter =
                                UserListExporter(userListProvider.userList);
                            await exporter.exportUserList();
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
