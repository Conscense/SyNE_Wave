import 'dart:convert';
import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../logic/ESP_logic/ESP32Client.dart';
import '../../main.dart';
import '../../models/chat.dart';
import '../messages/components/top_pill_bar.dart';
import 'components/body.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatsScreen extends StatefulWidget {
  final String? peerId;

  const ChatsScreen({super.key, this.peerId});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  double freeSpaceHeight = 180;
  final double pillHeight = 60;
  final double freeSpacePadding = 16;

  PillBarState topPillState = PillBarState.main;

  final Map<String, Chat> _chats = {};
  final Map<String, Chat> _chatRequests = {}; // Pending requests

  @override
  void initState() {
    super.initState();
    _attemptAutoConnectThenSetup();
    // Keep existing chat selection behavior
    if (widget.peerId != null) {
      _chats[widget.peerId!] = Chat(
        userId: widget.peerId!,
        name: widget.peerId!,
        lastMessage: '',
        image: "assets/images/default_user.png",
        isActive: true,
        lastUpdated: DateTime.now(),
      );
    }
  }

  Future<void> _attemptAutoConnectThenSetup() async {
    // 1) try to load saved ID
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('savedUserId');
      if (saved != null) {
        print('🧠 Found saved userId: $saved — attempting ESP connect');
        // create or reconfigure espClient if needed
        // if espClient is a global, make sure it exists; otherwise create here:
        try {
          // If you already made a global espClient, remove the new creation and use it.
          // Example: assume `espClient` is global in main.dart
          espClient = ESP32Client(myUserId: saved); // optional if global exists
          await espClient.connect();
        } catch (e) {
          print('⚠️ ESP connect failed: $e');
        }
      } else {
        print('⚠️ No saved userId, user must login first.');
      }
    } catch (e) {
      print('⚠️ Error reading SharedPreferences: $e');
    }

    // 2) now attach the listener to update UI when messages arrive
    setupESPListener(_chats, _chatRequests, setState);
  }


  void _onScroll(double offset) {
    setState(() {
      freeSpaceHeight = (180 - offset).clamp(0, 180);
    });
  }

  void setupESPListener(
      Map<String, Chat> chatsMap,
      Map<String, Chat> requestsMap,
      void Function(void Function()) setState) {
    espClient.messages.listen((raw) {
      try {
        final doc = jsonDecode(raw);
        final type = doc['type'];
        final timestamp = DateTime.fromMillisecondsSinceEpoch(doc['timestamp']);

        if (type == 'new_user') {
          final userId = doc['userId'];
          setState(() {
            if (!chatsMap.containsKey(userId) &&
                !requestsMap.containsKey(userId)) {
              requestsMap[userId] = Chat(
                userId: userId,
                name: userId,
                lastMessage: '',
                image: 'assets/images/default_user.png',
                isActive: true,
                lastUpdated: timestamp,
              );
            }
          });
        } else if (type == 'message') {
          final sender = doc['senderId'];
          final text = doc['text'];
          setState(() {
            if (chatsMap.containsKey(sender)) {
              chatsMap[sender]!.lastMessage = text;
              chatsMap[sender]!.lastUpdated = timestamp;
            } else {
              requestsMap[sender] = Chat(
                userId: sender,
                name: sender,
                lastMessage: text,
                image: 'assets/images/default_user.png',
                isActive: true,
                lastUpdated: timestamp,
              );
            }
          });
        }
      } catch (e) {
        print('Invalid JSON: $raw');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double pillTop =
    (freeSpaceHeight - pillHeight - freeSpacePadding)
        .clamp(freeSpacePadding, double.infinity);

    final chatsList = _chats.values.toList()
      ..sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));
    final requestsList = _chatRequests.values.toList()
      ..sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));

    final chatsToShow =
    topPillState == PillBarState.main ? chatsList : requestsList;

    return SafeArea(
      child: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: freeSpaceHeight),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: Container(
                      color: kItemBackground,
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (scrollNotification) {
                          if (scrollNotification is ScrollUpdateNotification) {
                            _onScroll(scrollNotification.metrics.pixels);
                          }
                          return false;
                        },
                        child: Body(
                          chats: chatsToShow,
                          onTapAccept: topPillState == PillBarState.search
                              ? (chat) {
                            setState(() {
                              _chats[chat.userId] = chat;
                              _chatRequests.remove(chat.userId);
                            });
                          }
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Title
          Positioned(
            top: (freeSpaceHeight - 160).clamp(-70.0, double.infinity),
            left: 24,
            child: const Text(
              "Chats",
              style: TextStyle(
                color: kPrimaryColor,
                fontFamily: 'Cascadia',
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Top Pill Bar
          Positioned(
            top: pillTop,
            left: 16,
            right: 16,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: TopPillBar(
                key: ValueKey(freeSpaceHeight > 150 ? "main" : "search"),
                state: topPillState,
                maxHeight: 60,
                minHeight: 60,
                scrollShrink: false,
                onSearchChanged: (_) {},
                onTabChanged: (index) {
                  setState(() {
                    topPillState = index == 0 ? PillBarState.main : PillBarState.search;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
