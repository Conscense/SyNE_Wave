import '../../../models/chat.dart';
import 'package:flutter/material.dart';
import '../../../constants.dart';

class ChatCard extends StatelessWidget {
  final Chat chat;
  final VoidCallback press;
  final void Function(Chat chat)? onTapAccept; // ← added

  const ChatCard({
    super.key,
    required this.chat,
    required this.press,
    this.onTapAccept, // ← optional callback
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: press,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: kDefaultPadding,
            vertical: kDefaultPadding * 0.5,
          ),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: kItemBackground,
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.9),
                Colors.white.withOpacity(0.2),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: kItemBackground.withOpacity(0.08),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar
              Stack(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: AssetImage(chat.image),
                  ),
                  if (chat.isActive)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        height: 16,
                        width: 16,
                        decoration: BoxDecoration(
                          color: kPrimaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: kDarkBackground,
                            width: 3,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              // Texts
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chat.name.length > 15
                            ? '${chat.name.substring(0, 15)}…'
                            : chat.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Opacity(
                        opacity: 0.64,
                        child: Text(
                          chat.lastMessage.length > 15
                              ? '${chat.lastMessage.substring(0, 15)}…'
                              : chat.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Time or Accept Button
              if (chat.isRequesting)
                ElevatedButton(
                  onPressed: () {
                    if (onTapAccept != null) onTapAccept!(chat);
                  },
                  child: const Text("Accept"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                  ),
                )
              else
                Opacity(
                  opacity: 0.64,
                  child: Text(
                    '${chat.lastUpdated.hour.toString().padLeft(2, '0')}:${chat.lastUpdated.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
