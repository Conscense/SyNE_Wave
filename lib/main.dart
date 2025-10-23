import 'package:chat/constants.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'logic/ESP_logic/ESP32Client.dart';
import 'logic/UserProfiles.dart';
import 'screens/welcome/welcome_screen.dart';

// ✅ Global singletons (use carefully)
late final ESP32Client espClient;
late final String currentUserId;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔹 Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 🔹 Generate stable user ID at app startup
  currentUserId = await UserProfile.getUserId();
  debugPrint("✅ My User ID: $currentUserId");

  // 🔹 Initialize global ESP client
  espClient = ESP32Client(myUserId: currentUserId);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Flutter Way',
      debugShowCheckedModeBanner: false,

      scaffoldMessengerKey: GlobalKey<ScaffoldMessengerState>(),

      theme: ThemeData(
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: kDarkBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: Colors.white.withOpacity(0.08), // 70% opacity
              width: 2,
            ),
          ),
          elevation: 4,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          contentTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          actionTextColor: Colors.lightBlueAccent,
        ),
      ),

      darkTheme: ThemeData.dark().copyWith(
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.black.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: Colors.purpleAccent.withOpacity(0.8), // 80% opacity
              width: 2,
            ),
          ),
          elevation: 12,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          contentTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          actionTextColor: Colors.purpleAccent,
        ),
      ),

      themeMode: ThemeMode.light,
      home: const WelcomeScreen(),
    );
  }
}
