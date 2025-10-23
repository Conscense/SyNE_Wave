import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../constants.dart';
import '../../models/chat.dart';
import '../../models/chat_message.dart';
import 'package:chat/logic/ESP_logic/ESP32Client.dart';
import 'components/chat_input_field.dart';
import '../../main.dart'; // import global espClient and currentUserId

class MessagesScreen extends StatefulWidget {
  final Chat chat;
  const MessagesScreen({super.key, required this.chat});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final List<ChatMessage> messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Connect ESP32 client
    espClient.connect();

    // ✅ Pre-fill chat with example messages
    messages.addAll([
      ChatMessage(
        text: "Hi there! 👋",
        isSender: false,
        messageType: ChatMessageType.text,
        status: MessageStatus.delivered,
        time: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      ChatMessage(
        text: "Hello! How's it going?",
        isSender: true,
        messageType: ChatMessageType.text,
        status: MessageStatus.delivered,
        time: DateTime.now().subtract(const Duration(minutes: 4)),
      ),
      ChatMessage(
        text: "All good here. Testing the chat screen.",
        isSender: false,
        messageType: ChatMessageType.text,
        status: MessageStatus.delivered,
        time: DateTime.now().subtract(const Duration(minutes: 3)),
      ),
    ]);

    // Scroll to bottom after build
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    // Listen for incoming ESP32 messages
    espClient.messages.listen((msg) {
      setState(() {
        messages.add(ChatMessage(
          text: msg,
          isSender: false,
          messageType: ChatMessageType.text,
          status: MessageStatus.delivered,
          time: DateTime.now(),
        ));
        _scrollToBottom();
      });
    });
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

    setState(() => messages.add(newMessage));
    _controller.clear();
    _scrollToBottom();

    espClient.sendMessage(text); // 🚀 send to ESP32

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() => newMessage.status = MessageStatus.delivered);
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDarkBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Container(
              color: kItemBackground,
              child: Column(
                children: [
                  _buildProfileHeader(context),
                  Expanded(
                    child: messages.isEmpty
                        ? _buildEmptyChatProfile()
                        : ListView.builder(
                      reverse: true,
                      controller: _scrollController,
                      padding: const EdgeInsets.all(kDefaultPadding),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[messages.length - 1 - index];
                        final ChatMessage? nextMessage = index > 0
                            ? messages[messages.length - 1 - (index - 1)]
                            : null;

                        return _buildMessageBubble(message, nextMessage);
                      },
                    ),
                  ),
                  ChatInputField(
                    controller: _controller,
                    onSend: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: kDarkBackground, // base dark color
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.1), // subtle top highlight
                Colors.black.withOpacity(0.2), // subtle bottom shadow
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            border: Border.all(
              color: kItemBackground.withOpacity(0.1),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(40),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundImage: AssetImage(widget.chat.image),
                radius: 20,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.chat.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white)),
                  Text(widget.chat.isActive ? "Online" : "Offline",
                      style: const TextStyle(
                          fontSize: 12, color: Colors.white70)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: kDarkBackground,
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.6),
            Colors.black.withOpacity(0.2),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border.all(color: kItemBackground.withOpacity(0.1), width: 2),
        borderRadius: BorderRadius.circular(40),
      ),
      child: child,
    );
  }

  Widget _buildEmptyChatProfile() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundImage: AssetImage(widget.chat.image),
            radius: 50,
          ),
          const SizedBox(height: 16),
          Text(widget.chat.name,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 6),
          Text(widget.chat.isActive ? "Online" : "Offline",
              style: const TextStyle(fontSize: 14, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, ChatMessage? nextMessage) {
    final currentTime = DateFormat('hh:mm a').format(message.time);
    String? nextTime = nextMessage != null ? DateFormat('hh:mm a').format(nextMessage.time) : null;

    final showMeta = nextMessage == null || currentTime != nextTime;

    return Align(
      alignment: message.isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: message.isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: message.isSender ? kPrimaryColor : kItemBackground,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              message.text,
              style: TextStyle(color: message.isSender ? Colors.white : Colors.white70),
            ),
          ),
          if (showMeta)
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, bottom: 2),
              child: Text(
                "$currentTime  •  ${message.isSender ? "Sent" : "Delivered"}",
                style: const TextStyle(fontSize: 10, color: Colors.white54),
              ),
            ),
        ],
      ),
    );
  }
}
