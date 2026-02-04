import 'package:equatable/equatable.dart';

/// Event để điều khiển phiên đăng nhập
abstract class SessionEvent extends Equatable {
  const SessionEvent();

  @override
  List<Object?> get props => [];
}

/// Bắt đầu phiên với userId
class StartSession extends SessionEvent {
  final String userId;

  const StartSession(this.userId);

  @override
  List<Object?> get props => [userId];
}
