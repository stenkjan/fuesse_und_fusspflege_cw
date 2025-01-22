import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';

class Policies {
  String userId;
  String name;
  String address;
  String place;
  DateTime date;
  Uint8List signature1;

  Policies({
    required this.userId,
    required this.name,
    required this.address,
    required this.place,
    required this.date,
    required this.signature1,
  });

    Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'address': address,
      'place': place,
      'date': date.toIso8601String(),
      'signature1': signature1,
    };
  }

  factory Policies.fromJson(Map<String, dynamic> json) {
    return Policies(
      userId: json['userId'],
      name: json['name'],
      address: json['address'],
      place: json['place'],
      date: DateTime.parse(json['date']),
      signature1: Uint8List.fromList(json['signature1'].cast<int>()),
    );
  }
}

Future<File> generatePoliciesPdf(Policies policies) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.MultiPage(
      build: (pw.Context context) => <pw.Widget>[
        pw.Text('Vereinbarung Terminregeln',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 5),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: <pw.Widget>[
            pw.Align(
              alignment: pw.Alignment.centerLeft,
              child: pw.RichText(
                text: pw.TextSpan(
                  text: 'Name: ',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  children: <pw.TextSpan>[
                    pw.TextSpan(
                      text: policies.name,
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
                      text: policies.address,
                      style: pw.TextStyle(fontWeight: pw.FontWeight.normal),
                    ),
                  ],
                ),
              ),
            ),
            pw.SizedBox(height: 2),
            pw.Divider(thickness: 0.2),
            pw.SizedBox(height: 2),
            pw.Text(
                'Vereinbarte Termine sind einzuhalten und können bis 24 Stunden vor Terminbeginn kostenfrei abgesagt werden.\n\n'
                'Sollte die Absage später oder gar nicht erfolgen, ist das Nagelstudio gemäß §615 BGB dazu berechtigt, den entstandenen Ausfall in Rechnung zu stellen, soweit in der Zeit des geplanten Termins keine Ersatzeinnahmen erwirtschaftet werden konnten.\n\n'
                'Die Höhe der Ausfallgebühr beträgt 50% der Kosten für die Leistung, die Sie bei mir gebucht haben.\n\n'
                'Eine Absage kann per Email auf meiner Webseite, per Anruf oder per WhatsApp erfolgen.\n\n'
                'Ich stimme hiermit den Terminregeln zu'),
            pw.SizedBox(height: 2),
            pw.Divider(thickness: 0.2),
            pw.SizedBox(height: 10),
            pw.Text(
                'Ich bin einverstanden, dass die oben genannten Maßnahmen vorgenommen und ggf. auch fotografisch dokumentiert werden.'),
            pw.SizedBox(height: 2),
            pw.Divider(thickness: 0.2),
            pw.Text('Ort: ${policies.place}'),
            pw.Text('Datum: ${DateFormat('dd.MM.yyyy').format(policies.date)}'),
            pw.SizedBox(height: 2),
            pw.Divider(thickness: 0.2),
            pw.Text('Unterschrift Patient/in:'),
            pw.FittedBox(
              fit: pw.BoxFit.cover,
              child: pw.Image(pw.MemoryImage(policies.signature1),
                  width: 100, height: 100),
            ),
          ],
        ),
      ],
    ),
  );

  final output = await getTemporaryDirectory();
  final date = DateFormat('dd.MM.yyyy').format(DateTime.now());
  final file = File("${output.path}/terminregelnvereinbarung_${policies.name}_$date.pdf");
  await file.writeAsBytes(await pdf.save());

  OpenFile.open(file.path);

  return file;
}

// Future<void> generatePoliciesPdfAndSend(Policies policies, User user) async {
//   // Generate the policies PDF
//   try {
//     final file = await generatePoliciesPdf(policies);

//     // Load the pre-existing PDF
//     final pdfData = await rootBundle.load('assets/datenschutzPDF.pdf');
//     final tempDir = await getTemporaryDirectory();
//     final tempFile = File('${tempDir.path}/datenschutzPDF.pdf');
//     await tempFile.writeAsBytes(pdfData.buffer.asUint8List());
//     final date =
//         DateFormat('dd.MM.yyyy').format(policies.date ?? DateTime.now());

//     // Send both PDFs in an email
//     final email = Email(
//       body: 'Terminregelvereinbarung von ${user.name}',
//       subject: 'Terminregelvereinbarung vom $date',
//       recipients: [
//         user.email,
//       ], // Replace with the recipient's email address
//       attachmentPaths: [file.path, tempFile.path],
//       isHTML: false,
//     );

//     await FlutterEmailSender.send(email);
//     Fluttertoast.showToast(
//       msg: 'Policies erfolgreich exportiert und per E-Mail gesendet',
//       toastLength: Toast.LENGTH_SHORT,
//       gravity: ToastGravity.BOTTOM,
//       timeInSecForIosWeb: 1,
//       backgroundColor: Colors.black,
//       textColor: Colors.white,
//       fontSize: 16.0,
//     );
//   } catch (e) {
//     Fluttertoast.showToast(
//       msg: 'Policies konnte nicht exportiert werden: $e',
//       toastLength: Toast.LENGTH_SHORT,
//       gravity: ToastGravity.BOTTOM,
//       timeInSecForIosWeb: 1,
//       backgroundColor: Colors.red,
//       textColor: Colors.white,
//       fontSize: 16.0,
//     );
//     rethrow;
//   }
// }
