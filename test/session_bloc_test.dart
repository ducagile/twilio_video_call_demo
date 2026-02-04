import 'package:flutter_test/flutter_test.dart';
import 'package:twilio_video_call_demo/presentation/bloc/session/session_bloc.dart';
import 'package:twilio_video_call_demo/presentation/bloc/session/session_event.dart';
import 'package:twilio_video_call_demo/presentation/bloc/session/session_state.dart';

void main() {
  group('SessionBloc', () {
    test('emits started state with userId when StartSession added', () async {
      final bloc = SessionBloc();
      const userId = 'user-123';

      bloc.add(const StartSession(userId));
      await expectLater(
        bloc.stream,
        emits(
          const SessionState(
            userId: userId,
            isSessionStarted: true,
          ),
        ),
      );
    });
  });
}
