import 'package:equatable/equatable.dart';

/// State lưu trữ thông tin phiên và userId trong bộ nhớ
class SessionState extends Equatable {
  final String? userId;
  final bool isSessionStarted;

  const SessionState({
    this.userId,
    this.isSessionStarted = false,
  });

  SessionState copyWith({
    String? userId,
    bool? isSessionStarted,
  }) {
    return SessionState(
      userId: userId ?? this.userId,
      isSessionStarted: isSessionStarted ?? this.isSessionStarted,
    );
  }

  @override
  List<Object?> get props => [userId, isSessionStarted];
}
