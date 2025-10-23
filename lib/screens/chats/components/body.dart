import 'package:flutter/material.dart';
import '../../../models/chat.dart';
import 'chat_card.dart';

class Body extends StatelessWidget {
  final List<Chat> chats;
  final ScrollController? scrollController;
  final void Function(Chat chat)? onTapAccept; // ← add this

  const Body({
    super.key,
    required this.chats,
    this.scrollController,
    this.onTapAccept, // ← add this
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final chat = chats[index];
        return ChatCard(
          chat: chat,
          onTapAccept: onTapAccept, press: () {  }, // ← pass it down
        );
      },
    );
  }
}
