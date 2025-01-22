import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:fuesse_und_fusspflege_cw/src/registration/consent.dart';
import 'package:fuesse_und_fusspflege_cw/src/registration/policies.dart';
import 'package:fuesse_und_fusspflege_cw/src/registration/note.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';

class User {
  final String userId;
  final String name;
  final String plzOrt;
  final String strasse;
  final String telefonnummer;
  final String email;
  final String beruf;
  final String besonderheiten;
  final String erkrankungen;
  final String uebertragbareErkrankungen;
  final String einnahmeVonHormonen;
  final String einnahmeVonMedikamenten;
  final String allergien;
  final bool erfahrungenGelAcrylmodellage;
  final bool bluter;
  final bool diabetiker;
  final bool schwangerschaft;
  final bool informationsbogenCheck;
  final bool einwilligungCheck;
  final DateTime? dateOfBirth;
  final DateTime? informationsbogenDate;
  final DateTime? einwilligungDate;
  DateTime lastEdited;
  // final List<Offset?> signature1;
  // final List<Offset?> signature2;
  final Uint8List? signature1;
  final Uint8List? signature2;
  //selectBoxes
  String? selectedHautZustandFussruecken;
  String? selectedHautZustandFussohle;
  String? selectedNagelzustand;
  String? selectedNagelerkrankungen;
  String? selectedNagelform;
  String? selectedNagelspitzenform;

  List<Note> notes;
  Consent? consent;
  Policies? policies;
  ValueNotifier<bool> hasNotes;

  User({
    required this.userId,
    required this.name,
    required this.plzOrt,
    required this.strasse,
    required this.telefonnummer,
    required this.email,
    required this.beruf,
    required this.besonderheiten,
    required this.erkrankungen,
    required this.uebertragbareErkrankungen,
    required this.einnahmeVonHormonen,
    required this.einnahmeVonMedikamenten,
    required this.allergien,
    required this.erfahrungenGelAcrylmodellage,
    required this.bluter,
    required this.diabetiker,
    required this.schwangerschaft,
    required this.informationsbogenCheck,
    required this.einwilligungCheck,
    required this.dateOfBirth,
    required this.informationsbogenDate,
    required this.einwilligungDate,
    required this.signature1,
    required this.signature2,
    //selectBoxes
    required this.selectedHautZustandFussruecken,
    required this.selectedHautZustandFussohle,
    required this.selectedNagelzustand,
    required this.selectedNagelerkrankungen,
    required this.selectedNagelform,
    required this.selectedNagelspitzenform,
    required this.lastEdited,
    this.consent,
    this.policies,
    List<Note>? notes,
  })  : notes = notes ?? [],
        hasNotes = ValueNotifier((notes ?? []).isNotEmpty);

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'],
      name: json['name'],
      plzOrt: json['plzOrt'],
      strasse: json['strasse'],
      telefonnummer: json['telefonnummer'],
      email: json['email'],
      beruf: json['beruf'],
      besonderheiten: json['besonderheiten'],
      erkrankungen: json['erkrankungen'],
      uebertragbareErkrankungen: json['uebertragbareErkrankungen'],
      einnahmeVonHormonen: json['einnahmeVonHormonen'],
      einnahmeVonMedikamenten: json['einnahmeVonMedikamenten'],
      allergien: json['allergien'],
      erfahrungenGelAcrylmodellage: json['erfahrungenGelAcrylmodellage'],
      bluter: json['bluter'] ?? false,
      diabetiker: json['diabetiker'] ?? false,
      schwangerschaft: json['schwangerschaft'] ?? false,
      informationsbogenCheck: json['informationsbogenCheck'] ?? false,
      einwilligungCheck: json['einwilligungCheck'] ?? false,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : null,
      informationsbogenDate: json['informationsbogenDate'] != null
          ? DateTime.parse(json['informationsbogenDate'])
          : null,
      einwilligungDate: json['einwilligungDate'] != null
          ? DateTime.parse(json['einwilligungDate'])
          : null,
      signature1: json['signature1'] != null
          ? Uint8List.fromList(json['signature1'].cast<int>())
          : null,
      signature2: json['signature2'] != null
          ? Uint8List.fromList(json['signature2'].cast<int>())
          : null,

      // signature1: (json['signature1'] as List)
      //     .map((item) => offsetFromJson(Map<String, dynamic>.from(item)))
      //     .toList(),
      // signature2: (json['signature2'] as List)
      //     .map((item) => offsetFromJson(Map<String, dynamic>.from(item)))
      //     .toList(),
      selectedHautZustandFussruecken: json['selectedHautZustandFussruecken'],
      selectedHautZustandFussohle: json['selectedHautZustandFussohle'],
      selectedNagelzustand: json['selectedNagelzustand'],
      selectedNagelerkrankungen: json['selectedNagelerkrankungen'],
      selectedNagelform: json['selectedNagelform'],
      selectedNagelspitzenform: json['selectedNagelspitzenform'],
      lastEdited: json['lastEdited'] != null
          ? DateTime.parse(json['lastEdited'])
          : DateTime.now(),
      notes: json['notes'] != null
          ? (json['notes'] as List)
              .map((item) => Note.fromJson(Map<String, dynamic>.from(item)))
              .toList()
          : [],
      consent:
          json['consent'] != null ? Consent.fromJson(json['consent']) : null,
      policies:
          json['policies'] != null ? Policies.fromJson(json['policies']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'plzOrt': plzOrt,
      'strasse': strasse,
      'telefonnummer': telefonnummer,
      'email': email,
      'beruf': beruf,
      'besonderheiten': besonderheiten,
      'erkrankungen': erkrankungen,
      'uebertragbareErkrankungen': uebertragbareErkrankungen,
      'einnahmeVonHormonen': einnahmeVonHormonen,
      'einnahmeVonMedikamenten': einnahmeVonMedikamenten,
      'allergien': allergien,
      'erfahrungenGelAcrylmodellage': erfahrungenGelAcrylmodellage,
      'bluter': bluter,
      'diabetiker': diabetiker,
      'schwangerschaft': schwangerschaft,
      'informationsbogenCheck': informationsbogenCheck,
      'einwilligungCheck': einwilligungCheck,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'informationsbogenDate': informationsbogenDate?.toIso8601String(),
      'einwilligungDate': einwilligungDate?.toIso8601String(),
      'signature1': signature1?.toList(),
      'signature2': signature2?.toList(),

      // 'signature1': signature1
      //     .where((item) => item != null)
      //     .map((item) => offsetToJson(item!))
      //     .toList(),
      // 'signature2': signature2
      //     .where((item) => item != null)
      //     .map((item) => offsetToJson(item!))
      //     .toList(),
      'selectedHautZustandFussruecken': selectedHautZustandFussruecken,
      'selectedHautZustandFussohle': selectedHautZustandFussohle,
      'selectedNagelzustand': selectedNagelzustand,
      'selectedNagelerkrankungen': selectedNagelerkrankungen,
      'selectedNagelform': selectedNagelform,
      'selectedNagelspitzenform': selectedNagelspitzenform,
      'lastEdited': lastEdited.toIso8601String(),
      'notes': notes.map((item) => item.toJson()).toList(),
      if (consent != null) 'consent': consent!.toJson(),
      if (policies != null) 'policies': policies!.toJson(),
    };
  }
}

Future<File> generatePdf(List<User> users) async {
  final pdf = pw.Document();
  User selUser = users.first;
  for (var user in users) {
    final Uint8List? signature1 = user.signature1;
    final Uint8List? signature2 = user.signature2;
    selUser = user;
    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) => <pw.Widget>[
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: <pw.Widget>[
              pw.Text('Kundendaten',
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 5),
              pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: pw.RichText(
                  text: pw.TextSpan(
                    text: 'Vorname / Name: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    children: <pw.TextSpan>[
                      pw.TextSpan(
                        text: user.name ?? '',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.normal),
                      ),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Divider(thickness: 0.2),
              pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: pw.RichText(
                  text: pw.TextSpan(
                    text: 'Geburtsdatum: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    children: <pw.TextSpan>[
                      pw.TextSpan(
                        text: user.dateOfBirth != null
                            ? DateFormat('dd.MM.yyyy').format(user.dateOfBirth!)
                            : '',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.normal),
                      ),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Divider(thickness: 0.2),
              pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: pw.RichText(
                  text: pw.TextSpan(
                    text: 'PLZ / Ort: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    children: <pw.TextSpan>[
                      pw.TextSpan(
                        text: user.plzOrt ?? '',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.normal),
                      ),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Divider(thickness: 0.2),
              pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: pw.RichText(
                  text: pw.TextSpan(
                    text: 'Straße: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    children: <pw.TextSpan>[
                      pw.TextSpan(
                        text: user.strasse ?? '',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.normal),
                      ),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Divider(thickness: 0.2),
              pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: pw.RichText(
                  text: pw.TextSpan(
                    text: 'Telefonnummer: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    children: <pw.TextSpan>[
                      pw.TextSpan(
                        text: user.telefonnummer ?? '',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.normal),
                      ),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Divider(thickness: 0.2),
              pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: pw.RichText(
                  text: pw.TextSpan(
                    text: 'Beruf: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    children: <pw.TextSpan>[
                      pw.TextSpan(
                        text: user.beruf ?? '',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.normal),
                      ),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Divider(thickness: 0.2),
              pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: pw.RichText(
                  text: pw.TextSpan(
                    text: 'Besonderheiten: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    children: <pw.TextSpan>[
                      pw.TextSpan(
                        text: user.besonderheiten ?? '',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.normal),
                      ),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Divider(thickness: 0.2),
              pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: pw.RichText(
                  text: pw.TextSpan(
                    text: 'Erkrankungen/Einnahme von Hormonen/Allergien: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    children: <pw.TextSpan>[
                      pw.TextSpan(
                        text: user.erkrankungen ?? '',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.normal),
                      ),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Divider(thickness: 0.2),
              pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: pw.RichText(
                  text: pw.TextSpan(
                    text: 'Übertragbare/relevante Erkrankungen: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    children: <pw.TextSpan>[
                      pw.TextSpan(
                        text: user.uebertragbareErkrankungen ?? '',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.normal),
                      ),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Divider(thickness: 0.2),
              pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: pw.RichText(
                  text: pw.TextSpan(
                    text: 'Einnahme von Hormonen: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    children: <pw.TextSpan>[
                      pw.TextSpan(
                        text: user.einnahmeVonHormonen ?? '',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.normal),
                      ),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Divider(thickness: 0.2),
              pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: pw.RichText(
                  text: pw.TextSpan(
                    text: 'Einnahme von Medikamenten: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    children: <pw.TextSpan>[
                      pw.TextSpan(
                        text: user.einnahmeVonMedikamenten ?? '',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.normal),
                      ),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Divider(thickness: 0.2),
              pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: pw.RichText(
                  text: pw.TextSpan(
                    text: 'Allergien: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    children: <pw.TextSpan>[
                      pw.TextSpan(
                        text: user.allergien ?? '',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.normal),
                      ),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Divider(thickness: 0.2),
              pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: pw.RichText(
                  text: pw.TextSpan(
                    text: 'Erfahrungen Gel-/Acrylmodellage: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    children: <pw.TextSpan>[
                      pw.TextSpan(
                        text: user.erfahrungenGelAcrylmodellage ? 'Ja' : 'Nein',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.normal),
                      ),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Divider(thickness: 0.2),
              pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: pw.RichText(
                  text: pw.TextSpan(
                    text: 'Bluter: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    children: <pw.TextSpan>[
                      pw.TextSpan(
                        text: user.bluter ? 'Ja' : 'Nein',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.normal, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: pw.RichText(
                  text: pw.TextSpan(
                    text: 'Diabetiker: ',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 10),
                    children: <pw.TextSpan>[
                      pw.TextSpan(
                        text: user.diabetiker ? 'Ja' : 'Nein',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.normal, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Divider(thickness: 0.2),
              pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: pw.RichText(
                  text: pw.TextSpan(
                    text: 'Schwangerschaft: ',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 10),
                    children: <pw.TextSpan>[
                      pw.TextSpan(
                        text: user.schwangerschaft ? 'Ja' : 'Nein',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.normal, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Divider(thickness: 0.2),
              pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: pw.RichText(
                  text: pw.TextSpan(
                    text: 'Zustand der Haut der Füße: Fußrücken: ',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 10),
                    children: <pw.TextSpan>[
                      pw.TextSpan(
                        text: user.selectedHautZustandFussruecken ?? '',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.normal, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Divider(thickness: 0.2),
              pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: pw.RichText(
                  text: pw.TextSpan(
                    text: 'Zustand der Haut der Füße: Fußsohle: ',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 10),
                    children: <pw.TextSpan>[
                      pw.TextSpan(
                        text: user.selectedHautZustandFussohle ?? '',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.normal, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Divider(thickness: 0.2),
              pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: pw.RichText(
                  text: pw.TextSpan(
                    text: 'Nagelzustand: ',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 10),
                    children: <pw.TextSpan>[
                      pw.TextSpan(
                        text: user.selectedNagelzustand ?? '',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.normal, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Divider(thickness: 0.2),
              pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: pw.RichText(
                  text: pw.TextSpan(
                    text: 'Erkrankungen des Nagels bzw. der Nagelumgebung: ',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 10),
                    children: <pw.TextSpan>[
                      pw.TextSpan(
                        text: user.selectedNagelerkrankungen ?? '',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.normal, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Divider(thickness: 0.2),
              pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: pw.RichText(
                  text: pw.TextSpan(
                    text: 'Nagelform: ',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 10),
                    children: <pw.TextSpan>[
                      pw.TextSpan(
                        text: user.selectedNagelform ?? '',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.normal, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Divider(thickness: 0.2),
              pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: pw.RichText(
                  text: pw.TextSpan(
                    text: 'Gewünschte Nagelspitzenform: ',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 10),
                    children: <pw.TextSpan>[
                      pw.TextSpan(
                        text: user.selectedNagelspitzenform ?? '',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.normal, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Divider(thickness: 0.2),
              pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: pw.RichText(
                  text: pw.TextSpan(
                    text:
                        'Informationsbogen über die Verarbeitung meiner Daten ausgehändigt: ',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 10),
                    children: <pw.TextSpan>[
                      pw.TextSpan(
                        text: user.informationsbogenCheck ? 'Ja' : 'Nein',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.normal, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Divider(thickness: 0.2),
              pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: pw.RichText(
                  text: pw.TextSpan(
                    text: 'Informationsbogendatum: ',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 10),
                    children: <pw.TextSpan>[
                      pw.TextSpan(
                        text: user.informationsbogenDate != null
                            ? DateFormat('dd.MM.yyyy')
                                .format(user.informationsbogenDate!)
                            : '',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.normal, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Divider(thickness: 0.2),
              if (signature1 != null)
                pw.FittedBox(
                  fit: pw.BoxFit.cover,
                  child: pw.Image(pw.MemoryImage(signature1),
                      width: 100, height: 100),
                ),
              pw.SizedBox(height: 2),
              pw.Divider(thickness: 0.2),
              pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: pw.RichText(
                  text: pw.TextSpan(
                    text: 'Einwilligung: ',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 10),
                    children: <pw.TextSpan>[
                      pw.TextSpan(
                        text: user.einwilligungCheck ? 'Ja' : 'Nein',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.normal, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Divider(thickness: 0.2),
              pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: pw.RichText(
                  text: pw.TextSpan(
                    text: 'Einwilligungsdatum: ',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 10),
                    children: <pw.TextSpan>[
                      pw.TextSpan(
                        text: user.einwilligungDate != null
                            ? DateFormat('dd.MM.yyyy')
                                .format(user.einwilligungDate!)
                            : '',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.normal, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Divider(thickness: 0.2),
              if (signature2 != null)
                pw.FittedBox(
                  fit: pw.BoxFit.cover,
                  child: pw.Image(pw.MemoryImage(signature2),
                      width: 100, height: 100),
                ),
              pw.SizedBox(height: 2),
              pw.Divider(thickness: 0.2),
              // pw.Container(
              //   height: 400,
              //   padding: pw.EdgeInsets.all(20),
              //   decoration: pw.BoxDecoration(
              //     border: pw.Border.all(
              //         color: PdfColor.fromInt(Colors.black.value), width: 1),
              //   ),
              //   child: pw.Column(
              //     crossAxisAlignment: pw.CrossAxisAlignment.start,
              //     children: <pw.Widget>[
              //       pw.Text(
              //         'Notizen',
              //         style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              //       ),
              //       pw.SizedBox(height: 10),
              //       pw.Container(),
              //     ],
              //   ),
              // ),
            ],
          ),
        ],
      ),
    );
  }

  final output = await getTemporaryDirectory();
  final date = DateFormat('dd.MM.yyyy').format(DateTime.now());
  final file = File("${output.path}/${selUser.name}_$date.pdf");
  await file.writeAsBytes(await pdf.save());

  OpenFile.open(file.path);

  return file;
}

Future<void> generatePdfAndSend(List<User> users) async {
  // Generate the PDF
  final file = await generatePdf(users);

  // Load the pre-existing PDF
  final pdfData = await rootBundle.load('assets/datenschutzPDF.pdf');
  final tempDir = await getTemporaryDirectory();
  final tempFile = File('${tempDir.path}/datenschutzPDF.pdf');
  await tempFile.writeAsBytes(pdfData.buffer.asUint8List());
  final date = DateFormat('dd.MM.yyyy')
      .format(users.first.einwilligungDate ?? DateTime.now());
  // If the selected user has a consent, generate the consent PDF
  File? consentFile;
  if (users.first.consent != null) {
    consentFile = await generateConsentPdf(users.first.consent!);
  }

  // Send the email
  final email = Email(
    body: 'Kundendaten für ${users.first.name}',
    subject: 'Kundendaten vom $date',
    recipients: [
      users.first.email,
    ],
    attachmentPaths: [
      file.path,
      tempFile.path,
      if (consentFile != null) ...[consentFile.path]
    ],
    isHTML: false,
  );

  await FlutterEmailSender.send(email);
}
