import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../constants.dart';
import '../../../logic/ESP_logic/ESP32Client.dart';
import '../../../logic/ESP_logic/ESP32WifiConnector.dart';
import '../../../main.dart';
import '../../../models/chat_message.dart';
import 'chat_input_field.dart';

class Message extends StatefulWidget {
  const Message({super.key});

  @override
  State<Message> createState() => _MessageState();
}

class _MessageState extends State<Message> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // ✅ Use the global ESP32Client instance
  late final ESP32Client _espClient;

  @override
  void initState() {
    super.initState();

    // Assign the global instance to this screen
    _espClient = espClient;

    () async {
      bool wifiOk = await ESP32WifiConnector.connectToESP(
        ssid: "ESP32_AP",
        password: "12345678",
      );

      if (wifiOk) {
        await _espClient.connect();

        // Listen for messages from ESP32
        _espClient.messages.listen((msg) {
          final newMessage = ChatMessage(
            text: msg,
            isSender: false,
            messageType: ChatMessageType.text,
            status: MessageStatus.delivered,
            time: DateTime.now(),
          );
          setState(() => _messages.add(newMessage));
          _scrollToBottom();
        });
      }
    }();
  }

  @override
  void dispose() {
    // ❌ Do not disconnect global espClient if used across screens
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    final newMessage = ChatMessage(
      text: text,
      isSender: true,
      messageType: ChatMessageType.text,
      status: MessageStatus.sent,
      time: DateTime.now(),
    );

    setState(() => _messages.add(newMessage));
    _controller.clear();
    _scrollToBottom();

    _espClient.sendMessage(text);

    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() => newMessage.status = MessageStatus.delivered);
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: _messages.isEmpty
              ? _buildEmptyChatProfile()
              : _buildMessageList(),
        ),
        ChatInputField(controller: _controller, onSend: _sendMessage),
      ],
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      reverse: true,
      controller: _scrollController,
      padding: const EdgeInsets.all(kDefaultPadding),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[_messages.length - 1 - index];
        final ChatMessage? nextMessage = index > 0
            ? _messages[_messages.length - 1 - (index - 1)]
            : null;

        final currentTime = DateFormat('hh:mm a').format(message.time);
        final nextTime = nextMessage != null
            ? DateFormat('hh:mm a').format(nextMessage.time)
            : null;
        final showDivider = nextMessage == null || currentTime != nextTime;

        return Column(
          crossAxisAlignment: message.isSender
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (showDivider)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  currentTime,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                ),
              ),
            _MessageBubble(message: message),
          ],
        );
      },
    );
  }

  Widget _buildEmptyChatProfile() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundImage: AssetImage("assets/images/user_2.png"),
            radius: 50,
          ),
          SizedBox(height: 16),
          Text(
            "John Doe",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "Online",
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
      message.isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: message.isSender ? kPrimaryColor : kItemBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isSender ? Colors.white : Colors.white70,
          ),
        ),
      ),
    );
  }
}
