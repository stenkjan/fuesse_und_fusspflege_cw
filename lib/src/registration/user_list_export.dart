import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fuesse_und_fusspflege_cw/src/registration/user.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pdf/widgets.dart' as pw;

class UserListExporter {
  final List<User> userList;

  UserListExporter(this.userList);

  Future<void> exportUserList() async {
    try {
      final userListJson = jsonEncode(userList.map((user) => user.toJson()).toList());
      final directory = await getTemporaryDirectory();
      final now = DateTime.now();
      final fileName = 'backup_${now.month.toString().padLeft(2, '0')}${now.year}.json';
      final exportFile = File('${directory.path}/$fileName');
      await exportFile.writeAsString(userListJson);

      final pdfFile = await _generatePdf(userList, directory, fileName);

      final email = Email(
        body: 'Aktuelle Kundenliste für ${now.month.toString().padLeft(2, '0')}${now.year}.json',
        subject: 'Kundenliste',
        recipients: ['wiedrich_christina@gmx.de'], // Replace with the recipient's email
        attachmentPaths: [exportFile.path, pdfFile.path],
        isHTML: false,
      );

      await FlutterEmailSender.send(email);
      Fluttertoast.showToast(
        msg: 'Liste erfolgreich exportiert und per E-Mail gesendet',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Liste konnte nicht exportiert werden: $e',
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

  Future<File> _generatePdf(List<User> users, Directory directory, String fileName) async {
    final pdf = pw.Document();
    for (var user in users) {
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: user.toJson().entries
                  .where((entry) => entry.key != 'signature1' && entry.key != 'signature2')
                  .map((entry) => pw.Text('${entry.key}: ${entry.value}'))
                  .toList(),
            );
          },
        ),
      );
    }

    final pdfFile = File('${directory.path}/${fileName.replaceAll('.json', '.pdf')}');
    await pdfFile.writeAsBytes(await pdf.save());
    return pdfFile;
  }
}