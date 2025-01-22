import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'dart:typed_data';

class SignatureScreen extends StatefulWidget {
  const SignatureScreen({super.key});

  @override
  _SignatureScreenState createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<SignatureScreen> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unterschrift'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () async {
              if (_controller.isNotEmpty) {
                final Uint8List? data = await _controller.toPngBytes();
                Navigator.pop(context, data);
              } else {
                Navigator.pop(context, null);
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Signature(
          controller: _controller,
          height: 300,
          backgroundColor: Colors.white,
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: () {
                _controller.clear();
              },
              child: const Text('Zurücksetzen'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_controller.isNotEmpty) {
                  final Uint8List? data = await _controller.toPngBytes();
                  Navigator.pop(context, data);
                } else {
                  Navigator.pop(context, null);
                }
              },
              child: const Text('Speichern'),
            ),
          ],
        ),
      ),
    );
  }
}