import 'package:flutter/material.dart';
import 'package:fuesse_und_fusspflege_cw/src/registration/note.dart';
import 'package:fuesse_und_fusspflege_cw/src/registration/user.dart';
import 'package:intl/intl.dart';

class NotepadScreen extends StatefulWidget {
  final User user;
  final List<User> users;

  const NotepadScreen({super.key, required this.user, required this.users});

  @override
  _NotepadScreenState createState() => _NotepadScreenState();
}

class _NotepadScreenState extends State<NotepadScreen> with WidgetsBindingObserver {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _saveNote();
    }
  }

  Future<bool> _onWillPop() async {
    _saveNote();
    return true;
  }

  void _saveNote() {
    final note = Note(
      userId: widget.user.userId,
      text: _controller.text,
      date: DateTime.now(),
    );
    setState(() {
      widget.user.notes.add(note);
    });
    _controller.clear();

    widget.user.hasNotes.value = true;

    // Pop the NotepadScreen and return the updated user
    Navigator.pop(context, widget.user);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
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
                    subtitle: Text(DateFormat('dd.MM.yyyy HH:mm').format(note.date)),
                    onTap: () {
                      _controller.text = note.text;
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
          child: const Icon(Icons.save),
          onPressed: _saveNote,
        ),
      ),
    );
  }
}