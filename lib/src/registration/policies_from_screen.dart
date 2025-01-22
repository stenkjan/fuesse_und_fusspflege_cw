import 'package:flutter/material.dart';
import 'package:fuesse_und_fusspflege_cw/src/registration/policies.dart';
import 'package:fuesse_und_fusspflege_cw/src/registration/user_list_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'signature_screen.dart';
import 'dart:typed_data';

class PoliciesFormScreen extends StatefulWidget {
  const PoliciesFormScreen({super.key});

  @override
  _PoliciesFormScreenState createState() => _PoliciesFormScreenState();
}

class _PoliciesFormScreenState extends State<PoliciesFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _placeController = TextEditingController();
  DateTime _date = DateTime.now();
  final _dateController = TextEditingController(
      text: DateFormat('dd.MM.yyyy').format(DateTime.now()));
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
        title: const Text('Vereinbarung Terminregeln'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Name: ${user!.name}'),
                Text('Adresse: ${user.strasse} ${user.plzOrt}'),
                const SizedBox(height: 10),
                const Divider(thickness: 0.5),
                const SizedBox(height: 10),
                const Text(
                    'Vereinbarte Termine sind einzuhalten und können bis 24 Stunden vor Terminbeginn kostenfrei abgesagt werden.\n\n'
                    'Sollte die Absage später oder gar nicht erfolgen, ist das Nagelstudio gemäß §615 BGB dazu berechtigt, den entstandenen Ausfall in Rechnung zu stellen, soweit in der Zeit des geplanten Termins keine Ersatzeinnahmen erwirtschaftet werden konnten.\n\n'
                    'Die Höhe der Ausfallgebühr beträgt 50% der Kosten für die Leistung, die Sie bei mir gebucht haben.\n\n'
                    'Eine Absage kann per Email auf meiner Webseite, per Anruf oder per WhatsApp erfolgen.\n\n'
                    'Ich stimme hiermit den Terminregeln zu.'),
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
                        : const Center(
                            child: Text('zum unterschreiben hier tippen')),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final policies = Policies(
                        userId: user.userId,
                        name: user.name,
                        address: '${user.strasse} ${user.plzOrt}',
                        place: _placeController.text,
                        date: _date,
                        signature1: _signatureData1 ?? Uint8List(0),
                      );
                      user.policies = policies;
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
