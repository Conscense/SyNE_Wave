import 'dart:ui';
import 'package:chat/screens/auth/signin_or_signup_screen.dart';
import 'package:chat/screens/menus/settings.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../auth/login_screen.dart';
import '../auth/signup_screen.dart';

class ProfileUI extends StatefulWidget {
  const ProfileUI({super.key});

  @override
  State<ProfileUI> createState() => _ProfileUIState();
}

class _ProfileUIState extends State<ProfileUI> {
  bool _isDarkMode = false; // for appearance toggle

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        final isGuest = user?.isAnonymous ?? true;

        return Scaffold(
          backgroundColor: const Color(0xFF121212),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF1F1F2E), Color(0xFF121212)],
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        _ProfileHeader(user: user),
                        const SizedBox(height: 30),
                        if (!isGuest) _StatsRow(),
                        const SizedBox(height: 30),
                        if (!isGuest) _InfoSection(user: user),
                        const SizedBox(height: 20),
                        _SettingsSection(
                          onAppearanceTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SettingsScreen()),
                            );
                          },
                          onPrivacyTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Privacy settings coming soon!")),
                            );
                          },
                          onNotificationsTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Notification settings coming soon!")),
                            );
                          },
                        ),
                        const SizedBox(height: 40),
                        isGuest ? _AuthButtons() : _LogoutButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 🔹 Profile Header
class _ProfileHeader extends StatelessWidget {
  final User? user;
  const _ProfileHeader({this.user});

  @override
  Widget build(BuildContext context) {
    final isGuest = user?.isAnonymous ?? true;

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: const AssetImage("assets/images/user_2.png"),
              backgroundColor: Colors.grey.shade800,
            ),
            if (!isGuest)
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (_) => _ProfileCustomizationSheet(user: user),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  padding: const EdgeInsets.all(6),
                  child: const Icon(Icons.edit, size: 20, color: Colors.white),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isGuest ? "Guest" : (user!.displayName ?? "User"),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (!isGuest) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _showEditNameDialog(context, user!),
                child: const Icon(Icons.edit, size: 18, color: Colors.white70),
              ),
            ],
          ],
        ),
        Text(
          isGuest ? "@guest" : (user!.email ?? "@unknown"),
          style: const TextStyle(fontSize: 14, color: Colors.white54),
        ),
      ],
    );
  }
}

void _showEditNameDialog(BuildContext context, User user) {
  final controller = TextEditingController(text: user.displayName ?? "");

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: _frostedCard(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Edit Name",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: controller,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      hintText: "Enter your name",
                      hintStyle: const TextStyle(color: Colors.white54),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide:
                        BorderSide(color: Colors.white24, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                            color: Colors.blueAccent, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final newName = controller.text.trim();
                          if (newName.isNotEmpty) {
                            await user.updateDisplayName(newName);
                            await user.reload();
                          }
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text("Save",
                            style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

/// 🔹 Profile Customization Sheet
class _ProfileCustomizationSheet extends StatelessWidget {
  final User? user;
  const _ProfileCustomizationSheet({this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      child: _frostedCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              "Customize Profile",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            _drawerOption(Icons.image, "Change Avatar", () {
              Navigator.pop(context);
            }, center: true),
            const SizedBox(height: 30),
            _drawerOption(Icons.palette, "Change Theme Color", () {
              Navigator.pop(context);
            }, center: true),
          ],
        ),
      ),
    );
  }

  Widget _drawerOption(IconData icon, String label, VoidCallback onTap,
      {bool center = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment:
        center ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 12),
          Text(label,
              style: const TextStyle(color: Colors.white, fontSize: 16)),
        ],
      ),
    );
  }
}

/// 🔹 Stats Row
class _StatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStat("Chats", "120"),
        _divider(),
        _buildStat("Friends", "85"),
        _divider(),
        _buildStat("Nodes", "12"),
      ],
    );
  }

  static Widget _buildStat(String label, String value) => Column(
    children: [
      Text(value,
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white)),
      const SizedBox(height: 4),
      Text(label,
          style: const TextStyle(color: Colors.white54, fontSize: 14)),
    ],
  );

  static Widget _divider() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 20),
    height: 30,
    width: 1,
    color: Colors.white24,
  );
}

/// 🔹 Info Section
class _InfoSection extends StatelessWidget {
  final User? user;
  const _InfoSection({this.user});

  @override
  Widget build(BuildContext context) {
    return _frostedCard(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.email, color: Colors.white70),
            title: Text(user?.email ?? "No email",
                style: const TextStyle(color: Colors.white)),
          ),
          Divider(color: Colors.white24, height: 1),
          ListTile(
            leading: const Icon(Icons.phone, color: Colors.white70),
            title: Text(user?.phoneNumber ?? "No phone",
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

/// 🔹 Settings Section
class _SettingsSection extends StatelessWidget {
  final VoidCallback onAppearanceTap;
  final VoidCallback onPrivacyTap;
  final VoidCallback onNotificationsTap;

  const _SettingsSection({
    required this.onAppearanceTap,
    required this.onPrivacyTap,
    required this.onNotificationsTap,
  });

  @override
  Widget build(BuildContext context) {
    return _frostedCard(
      child: Column(
        children: [
          _setting(
              icon: Icons.palette, title: "Appearance", onTap: onAppearanceTap),
          Divider(color: Colors.white24, height: 1),
          _setting(
              icon: Icons.lock, title: "Privacy", onTap: onPrivacyTap),
          Divider(color: Colors.white24, height: 1),
        ],
      ),
    );
  }

  static Widget _setting(
      {required IconData icon,
        required String title,
        required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.arrow_forward_ios,
          size: 16, color: Colors.white54),
      onTap: onTap,
    );
  }
}

class _LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        await FirebaseAuth.instance.signOut();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SigninOrSignupScreen()),
        );
      },
      icon: const Icon(Icons.logout),
      label: const Text("Logout"),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

/// 🔹 Guest Auth Buttons
class _AuthButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text("Login"),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SignUpScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.greenAccent,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text("Sign Up"),
          ),
        ),
      ],
    );
  }
}

/// 🔹 Frosted card helper
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
