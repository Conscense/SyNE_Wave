import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class UserProfile {
  static const _userIdKey = "userId";

  // Get current user ID, generate if none
  static Future<String> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString(_userIdKey);

    if (userId == null) {
      userId = const Uuid().v4(); // generate unique ID
      await prefs.setString(_userIdKey, userId);
    }

    return userId;
  }
}