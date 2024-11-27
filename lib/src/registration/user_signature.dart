// import 'package:flutter_signature_pad/flutter_signature_pad.dart';
// import 'package:flutter/material.dart';
// import 'dart:ui' as ui;
// import 'dart:typed_data';

// Future<Uint8List> signaturePointsToImage(List<Offset> points, Color strokeColor,
//     double strokeWidth, ui.Size imageSize) async {
//   final ui.PictureRecorder recorder = ui.PictureRecorder();
//   final Canvas canvas = Canvas(recorder);
//   final Paint paint = Paint()
//     ..color = strokeColor
//     ..strokeWidth = strokeWidth
//     ..strokeCap = StrokeCap.round;

//   for (int i = 0; i < points.length - 1; i++) {
//     canvas.drawLine(points[i], points[i + 1], paint);
//   }

//   final ui.Picture picture = recorder.endRecording();
//   final ui.Image image =
//       await picture.toImage(imageSize.width.toInt(), imageSize.height.toInt());
//   final ByteData? byteData =
//       await image.toByteData(format: ui.ImageByteFormat.png);
//   return byteData!.buffer.asUint8List();
// }

// class SignatureTile extends StatefulWidget {
//   final Color color;
//   final GlobalKey<SignatureState> signatureKey;
//   final double strokeWidth;
//   final ValueChanged<bool> onSign;

//   const SignatureTile({
//     super.key,
//     required this.color,
//     required this.signatureKey,
//     required this.strokeWidth,
//     required this.onSign,
//   });

//   @override
//   _SignatureTileState createState() => _SignatureTileState();
// }

// class _SignatureTileState extends State<SignatureTile>
//     with AutomaticKeepAliveClientMixin {
//   @override
//   bool get wantKeepAlive => true;

//   @override
//   Widget build(BuildContext context) {
//     super.build(
//         context); // This is important when using AutomaticKeepAliveClientMixin
//     return Container(
//       height: 200,
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.black),
//       ),
//       child: Signature(
//         color: widget.color,
//         key: widget.signatureKey,
//         onSign: () {
//           final sign = widget.signatureKey.currentState;
//           widget.onSign(sign!.points.isNotEmpty);
//         },
//         strokeWidth: widget.strokeWidth,
//       ),
//     );
//   }
// }
