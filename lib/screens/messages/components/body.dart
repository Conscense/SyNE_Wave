import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../../models/chat_message.dart';

class Body extends StatelessWidget {
  final List<ChatMessage> messages;

  // ✅ Constructor no longer const (because demoChatMessages is not const)
  Body({Key? key, List<ChatMessage>? messages})
      : messages = messages ?? demoChatMessages,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[index];
        return Align(
          alignment:
          msg.isSender ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: msg.isSender ? kPrimaryColor : kItemBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: msg.messageType == ChatMessageType.text
                ? Text(
              msg.text,
              style: const TextStyle(color: Colors.white),
            )
                : Icon(
              msg.messageType == ChatMessageType.audio
                  ? Icons.mic
                  : Icons.videocam,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}
