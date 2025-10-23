class Chat {
  final String userId;   // unique id (used internally)
  final String name;     // display name shown in UI
  String lastMessage;
  final String image;
  bool isActive;
  DateTime lastUpdated;
  final String time;     // for display (added for UI)
  bool isRequesting;     // new field to track chat requests

  Chat({
    required this.userId,
    required this.name,
    required this.lastMessage,
    required this.image,
    this.isActive = false,
    this.isRequesting = false,  // default false
    this.time = '',
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();
}

// 🧩 Demo chat data
List<Chat> demoChats = [
  Chat(
    userId: "user1",
    name: "Jenny Wilson",
    lastMessage: "Hope you are doing well...",
    image: "assets/images/user.png",
    time: "3m ago",
    isActive: false,
  ),
  Chat(
    userId: "user2",
    name: "Esther Howard",
    lastMessage: "Hello Abdullah! I am...",
    image: "assets/images/user_2.png",
    time: "8m ago",
    isActive: true,
  ),
  Chat(
    userId: "user3",
    name: "Ralph Edwards",
    lastMessage: "Do you have update...",
    image: "assets/images/user_3.png",
    time: "5d ago",
    isActive: false,
  ),
  Chat(
    userId: "user4",
    name: "Jacob Jones",
    lastMessage: "You’re welcome :)",
    image: "assets/images/user_4.png",
    time: "5d ago",
    isActive: true,
  ),
  Chat(
    userId: "user5",
    name: "Albert Flores",
    lastMessage: "Thanks",
    image: "assets/images/user_5.png",
    time: "6d ago",
    isActive: false,
  ),
];
