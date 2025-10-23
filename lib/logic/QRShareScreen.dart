import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:chat/main.dart';

import '../screens/chats/chats_screen.dart'; // for espClient & currentUserId

class QRShareScreen extends StatefulWidget {
  final bool showScanner;
  const QRShareScreen({super.key, this.showScanner = false});

  @override
  State<QRShareScreen> createState() => _QRShareScreenState();
}

class _QRShareScreenState extends State<QRShareScreen> {
  late final MobileScannerController controller;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    for (final barcode in capture.barcodes) {
      final code = barcode.rawValue;
      if (code == null) continue;

      try {
        final doc = jsonDecode(code);
        final userId = doc['userId'];

        // Send to ESP32 normally
        espClient.sendMessage(jsonEncode({
          "type": "new_user",
          "userId": userId,
        }));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ChatsScreen(peerId: userId)),
        );
      } catch (e) {
        print("❌ Invalid QR data: $code");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showScanner) {
      // 📷 Scanner mode
      return Scaffold(
        backgroundColor: Colors.black87,
        body: MobileScanner(
          controller: controller,
          onDetect: _onDetect,
        ),
      );
    }

    // 🖼 Generator mode
    final payload = jsonEncode({
      "type": "new_user",
      "userId": currentUserId,
    });

    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child: QrImageView(
          data: payload,
          version: QrVersions.auto,
          foregroundColor: Colors.white,
          size: 250,
        ),
      ),
    );
  }
}
