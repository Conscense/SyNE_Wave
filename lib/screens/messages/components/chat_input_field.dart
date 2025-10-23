import 'package:flutter/material.dart';
import '../../../constants.dart';

class ChatInputField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSend;

  const ChatInputField({
    super.key,
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(kDefaultPadding / 2),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: kDefaultPadding / 2,
            vertical: kDefaultPadding / 3,
          ),
          decoration: BoxDecoration(
            color: kItemBackground,
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.6),
                Colors.black.withOpacity(0.2),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            border: Border.all(
              color: kItemBackground.withOpacity(0.1),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: kDefaultPadding,
                    vertical: kDefaultPadding / 3,
                  ),
                  decoration: BoxDecoration(
                    color: kDarkBackground,
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.09),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.mic, color: kPrimaryColor.withOpacity(0.8)),
                      const SizedBox(width: kDefaultPadding / 2),
                      Expanded(
                        child: TextField(
                          controller: controller,
                          style: const TextStyle(
                            fontFamily: 'Cascadia',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                          decoration: const InputDecoration(
                            hintText: "Type a message...",
                            hintStyle: TextStyle(
                              fontFamily: 'Cascadia',
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Colors.white70,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: kDefaultPadding / 2),
              GestureDetector(
                onTap: () => onSend(controller.text),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: kPrimaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.send_rounded, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
