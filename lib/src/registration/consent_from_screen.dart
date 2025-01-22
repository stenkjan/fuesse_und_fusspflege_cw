import 'package:flutter/material.dart';
import 'package:fuesse_und_fusspflege_cw/src/registration/consent.dart';
import 'package:fuesse_und_fusspflege_cw/src/registration/user_list_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'signature_screen.dart';
import 'dart:typed_data';

class ConsentFormScreen extends StatefulWidget {
  const ConsentFormScreen({super.key});

  @override
  _ConsentFormScreenState createState() => _ConsentFormScreenState();
}

class _ConsentFormScreenState extends State<ConsentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _placeController = TextEditingController();
  DateTime _date = DateTime.now();
  final _dateController = TextEditingController(text: DateFormat('dd.MM.yyyy').format(DateTime.now()));
  final _descriptionController = TextEditingController();
  final _risksController = TextEditingController();
  Uint8List? _signatureData1;
  Uint8List? _signatureData2;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserListProvider>(context, listen: false);
    final user = provider.selectedUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Einwilligungserklärung'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Name, Vorname: ${user!.name}'),
                Text('Adresse: ${user.strasse} ${user.plzOrt}'),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Beschreibung der Maßnahme',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bitte Beschreibung hinzufügen';
                    }
                    return null;
                  },
                ),
                const Text(
                    'Der/die Behandler/in hat mich in einer mir verständlichen Form über Art, Umfang und Durchführung der oben genannten Maßnahme aufgeklärt.'),
                const Text('Ich wurde über folgende Risiken aufgeklärt:'),
                TextFormField(
                  controller: _risksController,
                  decoration: const InputDecoration(
                    labelText: 'Risiken',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bitte Risiken hinzufügen';
                    }
                    return null;
                  },
                ),
                const Text(
                    'Mir wurde mitgeteilt, wie ich mich in der Zeit nach der Behandlung verhalten soll, damit ein optimales Behandlungsergebnis erzielt werden kann.'),
                const Text(
                    'Ich hatte Gelegenheit, ergänzende Fragen zu stellen. Meine Fragen wurden mir ausführlich und gut verständlich beantwortet.'),
                const Text(
                    'Ich bin einverstanden, dass die oben genannten Maßnahmen vorgenommen und ggf. auch fotografisch dokumentiert werden.'),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _placeController,
                  decoration: const InputDecoration(
                    labelText: 'Ort',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bitte Ort hinzufügen';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _dateController,
                  decoration: const InputDecoration(
                    labelText: 'Datum',
                  ),
                  onTap: () async {
                    FocusScope.of(context).requestFocus(FocusNode());
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      _dateController.text =
                          DateFormat('yyyy-MM-dd').format(date);
                      _date = date;
                    }
                  },
                ),
                const SizedBox(height: 16.0),
                const Text('Unterschrift Patient/in:'),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                  ),
                  child: GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignatureScreen(),
                        ),
                      );
                      if (result != null) {
                        setState(() {
                          _signatureData1 = result;
                        });
                      }
                    },
                    child: _signatureData1 != null
                        ? Image.memory(_signatureData1!)
                        : const Center(child: Text('zum unterschreiben hier tippen')),
                  ),
                ),
                const SizedBox(height: 16.0),
                const Text('Unterschrift Behandler/in:'),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                  ),
                  child: GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignatureScreen(),
                        ),
                      );
                      if (result != null) {
                        setState(() {
                          _signatureData2 = result;
                        });
                      }
                    },
                    child: _signatureData2 != null
                        ? Image.memory(_signatureData2!)
                        : const Center(child: Text('zum unterschreiben hier tippen')),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final consent = Consent(
                        userId: user.userId,
                        name: user.name,
                        address: '${user.strasse} ${user.plzOrt}',
                        place: _placeController.text,
                        date: _date,
                        description: _descriptionController.text,
                        risks: _risksController.text,
                        signature1: _signatureData1 ?? Uint8List(0),
                        signature2: _signatureData2 ?? Uint8List(0),
                      );
                      user.consent = consent;
                      provider.updateUser(provider.selectedUserId!, user);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Speichern'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}