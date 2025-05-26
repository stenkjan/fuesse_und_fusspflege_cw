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
                if (!mounted) return;
                // ignore: use_build_context_synchronously
                Navigator.pop(context, data);
              } else {
                Navigator.pop(context, null);
              }
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[200],
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2.0),
              ),
              width: MediaQuery.of(context).size.width * 0.9,
              height: 300,
              child: Signature(
                controller: _controller,
                backgroundColor: Colors.white,
              ),
            ),
          ),
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
                  if (!mounted) return;
                  // ignore: use_build_context_synchronously
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
