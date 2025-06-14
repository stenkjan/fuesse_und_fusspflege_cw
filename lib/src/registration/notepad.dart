import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fuesse_und_fusspflege_cw/src/registration/note.dart';
import 'package:fuesse_und_fusspflege_cw/src/registration/user.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fuesse_und_fusspflege_cw/src/registration/user_list_provider.dart';

class NotepadScreen extends StatefulWidget {
  final User user;
  final List<User> users;

  const NotepadScreen({super.key, required this.user, required this.users});

  @override
  _NotepadScreenState createState() => _NotepadScreenState();
}

class _NotepadScreenState extends State<NotepadScreen> {
  final _controller = TextEditingController();
  bool _isSaving = false;
  Note? _selectedNote;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _saveNote() async {
    if (_isSaving) return;
    _isSaving = true;

    final text = _controller.text.trim();
    if (text.isEmpty) {
      _isSaving = false;
      return;
    }

    if (_selectedNote != null) {
      // Update the selected note
      setState(() {
        _selectedNote!.text = text;
        _selectedNote!.date = DateTime.now();
      });
    } else {
      // Create a new note
      final note = Note(
        userId: widget.user.userId,
        text: text,
        date: DateTime.now(),
      );
      setState(() {
        widget.user.notes.add(note);
      });
    }

    _controller.clear();
    _selectedNote = null;

    final userListProvider =
        Provider.of<UserListProvider>(context, listen: false);
    bool success =
        await userListProvider.updateUser(widget.user.userId, widget.user);

    if (success) {
      Fluttertoast.showToast(
        msg: "Gespeichert",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } else {
      Fluttertoast.showToast(
        msg: "Fehler beim Speichern",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }

    widget.user.hasNotes.value = true;
    _isSaving = false;

    // Pop the NotepadScreen and return the updated user
    Navigator.pop(context, widget.user);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notizen'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Deine Notiz...',
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.user.notes.length,
              itemBuilder: (context, index) {
                final note = widget.user.notes[index];
                return ListTile(
                  title: Text(note.text),
                  subtitle:
                      Text(DateFormat('dd.MM.yyyy HH:mm').format(note.date)),
                  onTap: () {
                    setState(() {
                      _controller.text = note.text;
                      _selectedNote = note;
                    });
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        widget.user.notes.removeAt(index);
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveNote,
        child: const Icon(Icons.save),
      ),
    );
  }
}