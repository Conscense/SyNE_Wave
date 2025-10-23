import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants.dart';
import '../../main.dart';
import '../backgrounds/DotPatternBackground.dart';
import '../messages/components/pill_navigation.dart';
import '../nodes/node_screen.dart';
import '../chats/chats_screen.dart';
import '../profile/ProfileScreen.dart';
import 'signup_screen.dart';

// Make sure you have a global espClient accessible here (declare in main.dart or another global file).
// Example in main.dart: ESP32Client espClient = ESP32Client(myUserId: ''); and import it.

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}



class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscurePassword = true;

  int _tapCount = 0;
  bool _showDevBackdoor = false;

  bool _isAutoConnecting = false; // show overlay while auto-connecting
  Timer? _espWatcher;

  @override
  void initState() {
    super.initState();
    _checkAutoLogin();

    // Start background ESP watcher
    _espWatcher = Timer.periodic(Duration(seconds: 5), (_) => _tryEspConnect());
  }

  @override
  void dispose() {
    _espWatcher?.cancel(); // cancel timer when widget is disposed
    super.dispose();
  }

  Future<void> _tryEspConnect() async {
    try {
      await espClient.connect(); // do NOT reinitialize espClient
      print('🟢 Connected to ESP32');
    } catch (e) {
      // Only log, ignore if ESP is not available
      print('⚠️ ESP connect attempt failed: $e');
    }
  }

  Future<void> _checkAutoLogin() async {
    // Attempt to load saved user id and auto-connect to ESP, then navigate to main screen.
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUserId = prefs.getString('savedUserId');
      if (savedUserId != null && savedUserId.isNotEmpty) {
        setState(() => _isAutoConnecting = true);
        print('🔁 Auto-login: Found saved userId: $savedUserId');

        // Ensure espClient exists globally and set its userId if needed.
        try {
          // If espClient is a global and already constructed elsewhere, just set its myUserId or reconstruct.
          // Example if espClient is global and modifiable:
          // espClient = ESP32Client(myUserId: savedUserId);
          await espClient.connect(); // attempt connection (wrapped in try/catch)
          print('🟢 Auto ESP connect success');
        } catch (e) {
          print('⚠️ Auto ESP connect failed: $e');
          // Continue to navigate anyway — app can still function but offline
        } finally {
          if (!mounted) return;
          setState(() => _isAutoConnecting = false);
        }

        // Navigate to main screen
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const PillScreen(
                title: "Main",
                screens: [
                  ChatsScreen(),
                  NodesScreen(),
                  ProfileUI(),
                ],
              ),
            ),
          );
        }
      } else {
        print('🔁 No saved userId found on startup.');
      }
    } catch (e) {
      print('⚠️ Error during auto-login check: $e');
      setState(() => _isAutoConnecting = false);
    }
  }

  Future<void> _login() async {
    final email = usernameController.text.trim();
    final password = passwordController.text.trim();

    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = userCredential.user?.uid;
      if (uid != null) {
        await _saveUserIdLocally(uid);
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const PillScreen(
            title: "Main",
            screens: [
              ChatsScreen(),
              NodesScreen(),
              ProfileUI(),
            ],
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Login failed")),
      );
    }
  }

  Future<void> _saveUserIdLocally(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('savedUserId', userId);
    print('💾 Saved userId locally: $userId');
  }

  Future<void> _resetPassword() async {
    final email = usernameController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your email first")),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password reset link sent to your email.")),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Failed to send reset email")),
      );
    }
  }

  void _devBackdoor() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const PillScreen(
          title: "Main",
          screens: [
            ChatsScreen(),
            NodesScreen(),
            ProfileUI(),
          ],
        ),
      ),
    );
  }

  void _handleSecretTap() {
    if (!kReleaseMode) {
      setState(() {
        _tapCount++;
        if (_tapCount >= 5) {
          _showDevBackdoor = true;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Dev Backdoor unlocked")),
          );
        }
      });
    }
  }

  Widget _modernTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 12, right: 8),
          child: Icon(icon, color: Colors.white70, size: 22),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        suffixIcon: isPassword
            ? IconButton(
          splashRadius: 20,
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.white70,
            size: 22,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        )
            : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.14), width: 2.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Colors.blueAccent, width: 2.0),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: Stack(children: [
            const DotPatternBackground(
              backgroundColor: Color(0xFF0D1117),
              dotColor: kDotColor,
            ),
            SafeArea(
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.88,
                      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.08),
                            Colors.white.withOpacity(0.03),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.14),
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 30,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: _handleSecretTap,
                              child: const Text(
                                "Welcome Back",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Log in to continue your journey",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Email
                            _modernTextField(
                              controller: usernameController,
                              hint: "Email",
                              icon: Icons.email,
                            ),
                            const SizedBox(height: 16),

                            // Password
                            _modernTextField(
                              controller: passwordController,
                              hint: "Password",
                              icon: Icons.lock,
                              isPassword: true,
                            ),
                            const SizedBox(height: 12),

                            // Forgot Password
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _resetPassword,
                                child: const Text(
                                  "Forgot Password?",
                                  style: TextStyle(color: Colors.lightBlueAccent),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Login button
                            GestureDetector(
                              onTap: _login,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF4A90E2), Color(0xFF007AFF)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blueAccent.withOpacity(0.4),
                                      blurRadius: 16,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Text(
                                    "Log In",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Signup
                            GestureDetector(
                              onTap: () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const SignUpScreen()),
                              ),
                              child: const Text(
                                "Don't have an account? Sign Up",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 15,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Hidden dev backdoor
                            if (_showDevBackdoor)
                              TextButton(
                                onPressed: _devBackdoor,
                                child: const Text(
                                  "Dev Backdoor (skip login)",
                                  style: TextStyle(color: Colors.redAccent),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ]),
        ),

        // Loading overlay while auto-connecting
        if (_isAutoConnecting)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text(
                      'Connecting to local node...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
