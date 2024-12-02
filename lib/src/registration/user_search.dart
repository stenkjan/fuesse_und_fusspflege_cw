import 'package:flutter/material.dart';
import 'package:fuesse_und_fusspflege_cw/src/registration/notepad.dart';
import 'package:fuesse_und_fusspflege_cw/src/registration/registration_view.dart';
import 'package:fuesse_und_fusspflege_cw/src/registration/user.dart';
import 'package:fuesse_und_fusspflege_cw/src/registration/user_list_provider.dart';
import 'package:provider/provider.dart';

class UserSearch extends SearchDelegate<User?> {
  UserSearch();

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final userListProvider =
        Provider.of<UserListProvider>(context, listen: false);
    final users = userListProvider.userList;

    return ListView(
      children: users
          .asMap()
          .entries
          .where((entry) =>
              entry.value.name.toLowerCase().contains(query.toLowerCase()))
          .map((entry) => ListTile(
                title: Text(entry.value.name),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton(
                      icon: const Icon(Icons.note),
                      color: entry.value.notes.isNotEmpty
                          ? Colors.blue
                          : Colors.grey,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => NotepadScreen(
                                    user: users[entry.key],
                                    users: users,
                                  )),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
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
                              body: RegistrationForm(
                                  user: users[entry.key], index: entry.key),
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
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
                                      Navigator.of(context).pop(false),
                                  child: const Text('Nein'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text('Ja'),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirm == true) {
                          userListProvider.removeUser(users[entry.key].userId);
                          showResults(context); // Refresh the search results
                        }
                      },
                    ),
                  ],
                ),
                onTap: () {
                  close(context, users[entry.key]);
                },
              ))
          .toList(),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }
}
