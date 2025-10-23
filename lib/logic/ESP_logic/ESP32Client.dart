import 'dart:io';
import 'dart:async';
import 'dart:convert';

class ESP32Client {
  Socket? _socket;
  final StreamController<String> _messageController = StreamController.broadcast();
  Stream<String> get messages => _messageController.stream;

  final String host;
  final int port;

  final String myUserId; // unique ID for this phone

  ESP32Client({this.host = '192.168.4.1', this.port = 12345, required this.myUserId});

  Future<void> connect() async {
    try {
      _socket = await Socket.connect(host, port, timeout: const Duration(seconds: 5));
      print('✅ Connected to ESP32 at $host:$port');

      // Reg4ister this phone
      final registerJson = jsonEncode({"type": "register", "userId": myUserId});
      _socket!.write('$registerJson\n');

      _socket!.listen((data) {
        final message = String.fromCharCodes(data).trim();
        _messageController.add(message);
      }, onDone: disconnect, onError: (e) => disconnect());
    } catch (e) {
      print('❌ Failed to connect: $e');
    }
  }

  void sendMessage(String text) {
    if (_socket != null) {
      final msgJson = jsonEncode({
        "type": "message",
        "senderId": myUserId,
        "text": text,
        "timestamp": DateTime.now().millisecondsSinceEpoch
      });
      _socket!.write('$msgJson\n');
    }
  }

  void disconnect() {
    _socket?.close();
    _socket = null;
  }
}
