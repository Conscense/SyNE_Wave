import 'dart:ui';
import 'package:flutter/material.dart';

class AppearanceScreen extends StatelessWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Appearance"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _frostedCard(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.brightness_6,
                      color: Colors.white70),
                  title: const Text("Theme Mode",
                      style: TextStyle(color: Colors.white)),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.white54),
                  onTap: () {
                    // TODO: toggle light/dark/system
                  },
                ),
                Divider(color: Colors.white24, height: 1),
                ListTile(
                  leading: const Icon(Icons.color_lens, color: Colors.white70),
                  title: const Text("Accent Color",
                      style: TextStyle(color: Colors.white)),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.white54),
                  onTap: () {
                    // TODO: pick accent color
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _frostedCard({required Widget child}) => ClipRRect(
  borderRadius: BorderRadius.circular(25),
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.black.withOpacity(0.05),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 2),
      ),
      child: child,
    ),
  ),
);
