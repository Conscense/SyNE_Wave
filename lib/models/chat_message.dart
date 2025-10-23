// 📩 Enums
enum ChatMessageType { text, audio, video }
enum MessageStatus { sent, delivered, seen }

// 💬 Message Model
class ChatMessage {
  final String text;
  final bool isSender;
  final ChatMessageType messageType;
  MessageStatus status;
  final DateTime time; // timestamp

  ChatMessage({
    required this.text,
    required this.isSender,
    required this.messageType,
    required this.status,
    DateTime? time,
  }) : time = time ?? DateTime.now();
}

// 📄 Demo messages
List<ChatMessage> demoChatMessages = [
  ChatMessage(
    text: "Hi Sajol,",
    messageType: ChatMessageType.text,
    status: MessageStatus.seen,
    isSender: false,
  ),
  ChatMessage(
    text: "Hello, How are you?",
    messageType: ChatMessageType.text,
    status: MessageStatus.seen,
    isSender: true,
  ),
  ChatMessage(
    text: "",
    messageType: ChatMessageType.audio,
    status: MessageStatus.seen,
    isSender: false,
  ),
  ChatMessage(
    text: "",
    messageType: ChatMessageType.video,
    status: MessageStatus.seen,
    isSender: true,
  ),
  ChatMessage(
    text: "Error happened",
    messageType: ChatMessageType.text,
    status: MessageStatus.sent,
    isSender: true,
  ),
  ChatMessage(
    text: "This looks great man!!",
    messageType: ChatMessageType.text,
    status: MessageStatus.seen,
    isSender: false,
  ),
  ChatMessage(
    text: "Glad you like it",
    messageType: ChatMessageType.text,
    status: MessageStatus.delivered,
    isSender: true,
  ),
];
