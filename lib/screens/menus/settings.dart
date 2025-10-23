import 'dart:ui';
import 'package:chat/screens/menus/appearance.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Settings"),
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
                  leading: const Icon(Icons.palette, color: Colors.white70),
                  title: const Text("Appearance",
                      style: TextStyle(color: Colors.white)),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.white54),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AppearanceScreen(),
                      ),
                    );
                  },
                ),
                Divider(color: Colors.white24, height: 1),
                ListTile(
                  leading: const Icon(Icons.notifications,
                      color: Colors.white70),
                  title: const Text("Notifications",
                      style: TextStyle(color: Colors.white)),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.white54),
                  onTap: () {},
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
