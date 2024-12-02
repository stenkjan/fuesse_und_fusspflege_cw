import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fuesse_und_fusspflege_cw/src/registration/user_list_provider.dart';
import 'package:provider/provider.dart';
import 'user_list.dart';
import 'registration_view.dart';
import 'package:fuesse_und_fusspflege_cw/src/registration/user_list_export.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _selectedIndex = 0;
  final List<Widget Function()> _widgetOptions = <Widget Function()>[
    () => const UserList(),
    () => const RegistrationForm(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Provider.of<UserListProvider>(context).title,
          style: const TextStyle(color: Colors.white),
        ),
        elevation: 5.0, // This adds shadow
        backgroundColor: Colors.blue[300], // This sets the background color to indigo
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: (String result) async {
              if (result == 'Import') {
                final pickedFile = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['json'],
                );
                if (pickedFile != null && pickedFile.files.isNotEmpty) {
                  final filePath = pickedFile.files.single.path;
                  try {
                    await Provider.of<UserListProvider>(context, listen: false)
                        .importUserList(filePath!);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Fehler beim Importieren der Datei'),
                      ),
                    );
                  }
                }
              } else if (result == 'Export') {
                final exporter = UserListExporter(Provider.of<UserListProvider>(context, listen: false).userList);
                try {
                  await exporter.exportUserList();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Backup erfolgreich exportiert und per E-Mail gesendet'),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fehler beim Exportieren des Backups'),
                    ),
                  );
                }
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'Import',
                child: Text('Backup Importieren'),
              ),
              const PopupMenuItem<String>(
                value: 'Export',
                child: Text('Backup Exportieren'),
              ),
            ],
          ),
        ],
      ),
      body: _widgetOptions[_selectedIndex](),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.list),
            label: 'Kundenliste',
            backgroundColor:const Color.fromARGB(205, 100, 180, 246),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Registrierung',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}