import 'package:flutter/material.dart';
import 'package:flutter_signature_pad/flutter_signature_pad.dart';
import 'package:fuesse_und_fusspflege_cw/src/registration/consent.dart';
import 'package:fuesse_und_fusspflege_cw/src/registration/user_list_provider.dart';
import 'package:fuesse_und_fusspflege_cw/src/registration/user_signature.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ConsentFormScreen extends StatelessWidget {
  final GlobalKey<SignatureState> _signatureKey1 = GlobalKey<SignatureState>();
  final GlobalKey<SignatureState> _signatureKey2 = GlobalKey<SignatureState>();
  final _formKey = GlobalKey<FormState>();
  final _placeController = TextEditingController();
  DateTime _date = DateTime.now();
  final _dateController = TextEditingController(text: DateFormat('dd.MM.yyyy').format(DateTime.now()));
  final _descriptionController = TextEditingController();
  final _risksController = TextEditingController();

  ConsentFormScreen({super.key});

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
                SignatureTile(
                  color: Colors.black,
                  signatureKey: _signatureKey1,
                  strokeWidth: 5.0,
                  onSign: (isSigned) {
                    // Handle the signature
                  },
                ),
                const SizedBox(height: 16.0),
                const Text('Unterschrift Behandler/in:'),
                SignatureTile(
                  color: Colors.black,
                  signatureKey: _signatureKey2,
                  strokeWidth: 5.0,
                  onSign: (isSigned) {
                    // Handle the signature
                  },
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final signature1 = await signaturePointsToImage(
                        _signatureKey1.currentState!.points
                            .whereType<Offset>()
                            .toList(),
                        Colors.black,
                        5.0,
                        const Size(500, 500),
                      );
                      final signature2 = await signaturePointsToImage(
                        _signatureKey2.currentState!.points
                            .whereType<Offset>()
                            .toList(),
                        Colors.black,
                        5.0,
                        const Size(500, 500),
                      );
                      final consent = Consent(
                        userId: user.userId,
                        name: user.name,
                        address: '${user.strasse} ${user.plzOrt}',
                        place: _placeController.text,
                        date: _date,
                        description: _descriptionController.text,
                        risks: _risksController.text,
                        signature1: signature1,
                        signature2: signature2,
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
