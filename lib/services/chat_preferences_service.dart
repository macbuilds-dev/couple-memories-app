import 'package:shared_preferences/shared_preferences.dart';

/// Local-only chat UI preferences (background image, etc.).
class ChatPreferencesService {
  static final ChatPreferencesService instance = ChatPreferencesService._();
  ChatPreferencesService._();

  static String _bgKey(String uid) => 'chat_bg_path_$uid';

  Future<String?> getBackgroundPath(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_bgKey(uid));
  }

  Future<void> setBackgroundPath(String uid, String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_bgKey(uid), path);
  }

  Future<void> clearBackgroundPath(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_bgKey(uid));
  }
}
