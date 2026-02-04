import 'package:flutter_bloc/flutter_bloc.dart';
import 'session_event.dart';
import 'session_state.dart';

/// Bloc quản lý trạng thái phiên, lưu userId trong state
class SessionBloc extends Bloc<SessionEvent, SessionState> {
  SessionBloc() : super(const SessionState()) {
    on<StartSession>(_onStartSession);
  }

  void _onStartSession(StartSession event, Emitter<SessionState> emit) {
    // Lưu userId trong state của bloc, không dùng storage
    emit(state.copyWith(
      userId: event.userId,
      isSessionStarted: true,
    ));
  }
}
