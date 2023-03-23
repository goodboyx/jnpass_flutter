
import 'package:shared_preferences/shared_preferences.dart';

class ChatProvider {
  late final SharedPreferences prefs;

  ChatProvider({required this.prefs});

  String? getPref(String key) {
    return prefs.getString(key);
  }

  void sendMessage(String content, int type, String groupChatId,
      String currentUserId, String peerId) {

  }
}

class TypeMessage {
  static const text = 0;
  static const image = 1;
  static const sticker = 2;
}