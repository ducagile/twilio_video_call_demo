import 'package:shared_preferences/shared_preferences.dart';

/// Lưu/đọc cấu hình user ở local (không có BE).
/// Dùng cho: tên hiển thị dashboard, tên dùng khi join Agora.
class UserPreferences {
  UserPreferences._();

  static const String _keyDisplayName = 'user_display_name';
  static const String _keyAgoraJoinName = 'agora_join_name';

  static Future<SharedPreferences> get _prefs =>
      SharedPreferences.getInstance();

  /// Đã cấu hình tên (ít nhất một trong hai) chưa.
  static Future<bool> hasConfigured() async {
    final display = await getDisplayName();
    return display != null && display.trim().isNotEmpty;
  }

  /// Tên hiển thị trên dashboard.
  static Future<String?> getDisplayName() async {
    final p = await _prefs;
    return p.getString(_keyDisplayName);
  }

  /// Tên dùng khi join Agora (trong form tham gia call).
  static Future<String?> getAgoraJoinName() async {
    final p = await _prefs;
    return p.getString(_keyAgoraJoinName);
  }

  /// Lưu cả hai tên.
  static Future<void> save({
    required String displayName,
    required String agoraJoinName,
  }) async {
    final p = await _prefs;
    await p.setString(_keyDisplayName, displayName.trim());
    await p.setString(_keyAgoraJoinName, agoraJoinName.trim());
  }
}
