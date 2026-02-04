/// Chuyển userId (từ SessionBloc/sign-in) sang Agora UID (int).
/// Nếu [userId] là số thì dùng, không thì dùng hash.
int agoraUidFromUserId(String? userId) {
  if (userId == null || userId.trim().isEmpty) return 1;
  final parsed = int.tryParse(userId.trim());
  if (parsed != null && parsed > 0) {
    return parsed.clamp(1, 9999999);
  }
  return (userId.hashCode.abs() % 10000000).clamp(1, 9999999);
}
