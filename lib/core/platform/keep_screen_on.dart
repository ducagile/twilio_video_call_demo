import 'package:flutter/services.dart';

/// Gọi native (Android/iOS) để bật/tắt giữ màn hình sáng.
/// Android: FLAG_KEEP_SCREEN_ON. iOS: isIdleTimerDisabled.
class KeepScreenOn {
  KeepScreenOn._();

  static const MethodChannel _channel =
      MethodChannel('twilio_video_call_demo/keep_screen_on');

  /// Bật (true) hoặc tắt (false) chế độ luôn sáng màn hình.
  static Future<void> setEnabled(bool enable) async {
    try {
      await _channel.invokeMethod<void>('setKeepScreenOn', enable);
    } on PlatformException catch (_) {
      // Bỏ qua lỗi nếu platform chưa implement
    }
  }
}
