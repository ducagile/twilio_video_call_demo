/// Cấu hình ứng dụng
/// LƯU Ý: Thay YOUR_AGORA_APP_ID bằng AppID thực tế từ Agora Console
class AppConfig {
  static const String agoraAppId = '00eb19b2e5784cb3b46887e4e8b86b73';

  /// Token RTC của Agora (hardcode cho demo).
  ///
  /// Lưu ý: Token thường gắn với `channelName` và có hạn sử dụng.
  static const String agoraToken =
      '007eJxTYGBYt+pM+IKdiu/Ob2fUMVIqXzj10lZtnupopmf2m7bMPheowGBgkJpkaJlklGpqbmGSnGScZGJmYWGeapJqkWRhlmRuLLesMbMhkJGB/2c3AyMUgvgsDCWpxSUMDAAw9R7/';

  /// Channel mặc định (phải khớp với token nếu token là channel-specific).
  static const String defaultChannelName = 'test';
}
