/// Cấu hình ứng dụng
/// LƯU Ý: Thay YOUR_AGORA_APP_ID bằng AppID thực tế từ Agora Console
class AppConfig {
  static const String agoraAppId = '24730eb0b0074a8cafd1db20bbcadf3b';

  /// Base URL API lấy token Agora (backend của bạn).
  static const String agoraTokenBaseUrl = 'http://185.196.21.68:5022';

  /// Token RTC fallback khi không gọi API được (demo).
  static const String agoraTokenFallback =
      '007eJxTYGBYt+pM+IKdiu/Ob2fUMVIqXzj10lZtnupopmf2m7bMPheowGBgkJpkaJlklGpqbmGSnGScZGJmYWGeapJqkWRhlmRuLLesMbMhkJGB/2c3AyMUgvgsDCWpxSUMDAAw9R7/';

  /// Channel mặc định (phải khớp với token nếu token là channel-specific).
  static const String defaultChannelName = 'test';
}
