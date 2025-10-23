import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../../constants.dart';
import '../auth/login_screen.dart';
import '../auth/signup_screen.dart';
import '../backgrounds/DotPatternBackground.dart';

class TypingText extends StatefulWidget {
  final List<String> texts;
  final Duration typingSpeed;
  final Duration deletingSpeed;
  final Duration pauseDuration;
  final TextStyle style;

  const TypingText({
    super.key,
    required this.texts,
    required this.style,
    this.typingSpeed = const Duration(milliseconds: 70),
    this.deletingSpeed = const Duration(milliseconds: 35),
    this.pauseDuration = const Duration(milliseconds: 1000),
  });

  @override
  State<TypingText> createState() => _TypingTextState();
}

class _TypingTextState extends State<TypingText> {
  int _textIndex = 0;
  String _currentText = "";
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  void _startTyping() async {
    while (mounted) {
      final fullText = widget.texts[_textIndex];

      if (_isDeleting) {
        if (_currentText.isNotEmpty) {
          setState(() {
            _currentText = fullText.substring(0, _currentText.length - 1);
          });
          await Future.delayed(widget.deletingSpeed);
        } else {
          _isDeleting = false;
          _textIndex = (_textIndex + 1) % widget.texts.length;
        }
      } else {
        if (_currentText.length < fullText.length) {
          setState(() {
            _currentText = fullText.substring(0, _currentText.length + 1);
          });
          await Future.delayed(widget.typingSpeed);
        } else {
          await Future.delayed(widget.pauseDuration);
          _isDeleting = true;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _currentText,
      style: widget.style,
    );
  }
}

class SigninOrSignupScreen extends StatefulWidget {
  const SigninOrSignupScreen({super.key});

  @override
  State<SigninOrSignupScreen> createState() => _SigninOrSignupScreenState();
}

class _SigninOrSignupScreenState extends State<SigninOrSignupScreen> {
  bool _pillExpanded = false;

  // ✅ Google Sign-In
  Future<void> _signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Signed in with Google!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google sign-in failed: $e")),
      );
    }
  }

  // ✅ Phone Auth (placeholder)
  Future<void> _signInWithPhone() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+1234567890',
      verificationCompleted: (credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
      },
      verificationFailed: (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Phone sign-in failed: ${e.message}")),
        );
      },
      codeSent: (verificationId, resendToken) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("OTP sent! Enter code to continue.")),
        );
      },
      codeAutoRetrievalTimeout: (verificationId) {},
    );
  }

  void _signInWithEmail() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const DotPatternBackground(
            backgroundColor: Color(0xFF0D1117),
            dotColor: kDotColor,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 🔹 TOP TEXT AREA
                  Column(
                    children: [
                      const SizedBox(height: 40),
                      Text(
                        "SyNE Wave",
                        style: TextStyle(
                          fontFamily: 'Cascadia',
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // ✨ Typing + Deleting Animated Subtitle
                      TypingText(
                        texts: const [
                          "Connecting the world...",
                          "Empowering ISPless signals.",
                          "SyNE — where connection thrives.",
                        ],
                        style: const TextStyle(
                          fontSize: 20,
                          fontFamily: 'Cascadia',
                          color: Colors.white70,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(flex: 2),

                  // 🔹 Expandable Social Pill
                  GestureDetector(
                    onTap: () => setState(() => _pillExpanded = !_pillExpanded),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.10),
                                Colors.black.withOpacity(0.15),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            border: Border.all(
                              color: kItemBackground.withOpacity(0.1),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _clickableIcon(
                                icon: Icons.tag,
                                label: "Phone",
                                color: kSocialTagColor,
                                onTap: _signInWithPhone,
                              ),
                              const SizedBox(width: 12),
                              _clickableIcon(
                                icon: Icons.g_mobiledata_rounded,
                                label: "Google",
                                color: kSocialGoogleColor,
                                onTap: _signInWithGoogle,
                              ),
                              const SizedBox(width: 12),
                              _clickableIcon(
                                icon: Icons.alternate_email,
                                label: "Email",
                                color: kSocialOtherColor,
                                onTap: _signInWithEmail,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 🔑 Frosted Glass Sign In / Sign Up buttons
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.10),
                                Colors.black.withOpacity(0.15),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            border: Border.all(
                              color: kItemBackground.withOpacity(0.1),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _glassButton(
                                text: "Sign In",
                                color: kSignInButton,
                                icon: Icons.join_full_rounded,
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                                ),
                              ),
                              const SizedBox(height: 16),
                              _glassButton(
                                text: "Sign Up",
                                color: kSignUpButton,
                                icon: Icons.join_inner_rounded,
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const SignUpScreen()),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Frosted glass button
  Widget _glassButton({
    required String text,
    required Color color,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: OutlinedButton.icon(
          icon: Icon(icon, color: color, size: 32),
          label: Text(text, style: TextStyle(fontSize: 18, color: color)),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(kButtonHeight),
            side: BorderSide(color: color, width: 2),
            backgroundColor: kItemBackground,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }

  // Expandable pill icons
  Widget _clickableIcon({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: _pillExpanded ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(horizontal: _pillExpanded ? 12 : 8, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.05),
              Colors.black.withOpacity(0.2),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: color, width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _pillExpanded
                  ? Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Text(label, style: TextStyle(color: color, fontSize: 14)),
              )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
