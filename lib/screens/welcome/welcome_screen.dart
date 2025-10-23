import 'dart:async';
import 'package:flutter/material.dart';
import '../../constants.dart';
import '../auth/signin_or_signup_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  bool _loading = true;
  bool _showButton = false;
  late AnimationController _controller;
  late Animation<double> _animation;
  double _fillProgress = 0.0; // for smooth fill effect

  @override
  void initState() {
    super.initState();

    // Animation with acceleration/deceleration motion
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Custom cubic curve gives acceleration effect (slow-fast-slow)
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Simulated initialization
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // Stop scanning motion
    _controller.stop();

    // Begin smooth fill animation
    _startFillAnimation();

    // Small delay, then show button
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) setState(() => _showButton = true);
  }

  void _startFillAnimation() {
    Timer.periodic(const Duration(milliseconds: 20), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _fillProgress += 0.05;
        if (_fillProgress >= 1.0) {
          _fillProgress = 1.0;
          _loading = false;
          timer.cancel();
        }
      });
    });
  }

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SigninOrSignupScreen()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double bottomBarOffset = _loading ? 40 : 80;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: Stack(
        children: [
          // Center icon + text
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.wifi_tethering, size: 80, color: kSignInButton),
                const SizedBox(height: 16),
                Text(
                  _loading ? "Establishing signal..." : "",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Bottom bar + button
          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            bottom: bottomBarOffset,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Button fades in after loading
                AnimatedOpacity(
                  opacity: _showButton ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 600),
                  child: _showButton
                      ? ElevatedButton(
                    onPressed: _goToLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kSignInButton,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Join In",
                      style:
                      TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 20),

                // Animated scanning bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 90),
                  child: SizedBox(
                    height: 8,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          const highlightWidth = 60.0;
                          final barWidth =
                              MediaQuery.of(context).size.width - 180;
                          final offset =
                              (barWidth - highlightWidth) * _animation.value;

                          return Stack(
                            children: [
                              // Base track
                              Container(
                                color: Colors.white.withOpacity(0.15),
                              ),

                              // Moving highlight during scanning
                              if (_loading)
                                Positioned(
                                  left: offset,
                                  child: Container(
                                    width: highlightWidth,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          kSignInButton.withOpacity(0.1),
                                          kSignInButton,
                                          kSignInButton.withOpacity(0.1),
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                    ),
                                  ),
                                )
                              else
                              // Smooth filling effect
                                FractionallySizedBox(
                                  widthFactor: _fillProgress,
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    height: 8,
                                    color: kSignInButton,
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
