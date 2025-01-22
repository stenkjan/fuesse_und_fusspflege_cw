import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fuesse_und_fusspflege_cw/src/registration/user.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

class Consent {
  String userId;
  String name;
  String address;
  String place;
  DateTime date;
  String description;
  String risks;
  Uint8List signature1;
  Uint8List signature2;

  Consent({
    required this.userId,
    required this.name,
    required this.address,
    required this.place,
    required this.date,
    required this.description,
    required this.risks,
    required this.signature1,
    required this.signature2,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'address': address,
      'place': place,
      'date': date.toIso8601String(),
      'description': description,
      'risks': risks,
      'signature1': signature1,
      'signature2': signature2,
    };
  }

  factory Consent.fromJson(Map<String, dynamic> json) {
    return Consent(
      userId: json['userId'],
      name: json['name'],
      address: json['address'],
      place: json['place'],
      date: DateTime.parse(json['date']),
      description: json['description'],
      risks: json['risks'],
      signature1: Uint8List.fromList(json['signature1'].cast<int>()),
      signature2: Uint8List.fromList(json['signature2'].cast<int>()),
    );
  }
}

Future<File> generateConsentPdf(Consent consent) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.MultiPage(
      build: (pw.Context context) => <pw.Widget>[
        pw.Text('Einwilligungserklärung',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 5),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: <pw.Widget>[
            pw.Align(
              alignment: pw.Alignment.centerLeft,
              child: pw.RichText(
                text: pw.TextSpan(
                  text: 'Name, Vorname: ',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  children: <pw.TextSpan>[
                    pw.TextSpan(
                      text: consent.name,
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
                  text: 'Adresse: ',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  children: <pw.TextSpan>[
                    pw.TextSpan(
                      text: consent.address,
                      style: pw.TextStyle(fontWeight: pw.FontWeight.normal),
                    ),
                  ],
                ),
              ),
            ),
            pw.SizedBox(height: 2),
            pw.Divider(thickness: 0.2),
            pw.Text(
                'Der/die Behandler/in hat mich in einer mir verständlichen Form über Art, Umfang und Durchführung der oben genannten Maßnahme aufgeklärt.'),
            pw.SizedBox(height: 2),
            pw.Divider(thickness: 0.2),
            pw.Align(
              alignment: pw.Alignment.centerLeft,
              child: pw.RichText(
                text: pw.TextSpan(
                  text: 'Ich wurde über folgende Risiken aufgeklärt: ',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  children: <pw.TextSpan>[
                    pw.TextSpan(
                      text: consent.risks,
                      style: pw.TextStyle(fontWeight: pw.FontWeight.normal),
                    ),
                  ],
                ),
              ),
            ),
            pw.SizedBox(height: 2),
            pw.Divider(thickness: 0.2),
            pw.Text(
                'Mir wurde mitgeteilt, wie ich mich in der Zeit nach der Behandlung verhalten soll, damit ein optimales Behandlungsergebnis erzielt werden kann.'),
            pw.SizedBox(height: 2),
            pw.Divider(thickness: 0.2),
            pw.Text(
                'Ich hatte Gelegenheit, ergänzende Fragen zu stellen. Meine Fragen wurden mir ausführlich und gut verständlich beantwortet.'),
            pw.SizedBox(height: 2),
            pw.Divider(thickness: 0.2),
            pw.Text(
                'Ich bin einverstanden, dass die oben genannten Maßnahmen vorgenommen und ggf. auch fotografisch dokumentiert werden.'),
            pw.SizedBox(height: 2),
            pw.Divider(thickness: 0.2),
            pw.Text('Ort: ${consent.place}'),
            pw.Text('Datum: ${DateFormat('dd.MM.yyyy').format(consent.date)}'),
            pw.SizedBox(height: 2),
            pw.Divider(thickness: 0.2),
            pw.Text('Unterschrift Patient/in:'),
            pw.FittedBox(
              fit: pw.BoxFit.cover,
              child: pw.Image(pw.MemoryImage(consent.signature1),
                  width: 100, height: 100),
            ),
            pw.SizedBox(height: 2),
            pw.Divider(thickness: 0.2),
            pw.Text('Unterschrift Behandler/in:'),
            pw.FittedBox(
              fit: pw.BoxFit.cover,
              child: pw.Image(pw.MemoryImage(consent.signature2),
                  width: 100, height: 100),
            ),
          ],
        ),
      ],
    ),
  );

  final output = await getTemporaryDirectory();
  final date = DateFormat('dd.MM.yyyy').format(DateTime.now());
  final file = File("${output.path}/einwilligung_${consent.name}_$date.pdf");
  await file.writeAsBytes(await pdf.save());

  OpenFile.open(file.path);

  return file;
}

Future<void> generateConsentPdfAndSend(Consent consent, User user) async {
  // Generate the consent PDF
  try {
    final file = await generateConsentPdf(consent);

    // Load the pre-existing PDF
    final pdfData = await rootBundle.load('assets/datenschutzPDF.pdf');
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/datenschutzPDF.pdf');
    await tempFile.writeAsBytes(pdfData.buffer.asUint8List());
    final date =
        DateFormat('dd.MM.yyyy').format(consent.date ?? DateTime.now());

    // Send both PDFs in an email
    final email = Email(
      body: 'Einverständniserklärung von ${user.name}',
      subject: 'Einverständniserklärung vom $date',
      recipients: [
        user.email,
      ], // Replace with the recipient's email address
      attachmentPaths: [file.path, tempFile.path],
      isHTML: false,
    );

    await FlutterEmailSender.send(email);
    Fluttertoast.showToast(
      msg: 'Consent erfolgreich exportiert und per E-Mail gesendet',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  } catch (e) {
    Fluttertoast.showToast(
      msg: 'Consent konnte nicht exportiert werden: $e',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
    rethrow;
  }
}