import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/session/session_bloc.dart';
import '../bloc/session/session_event.dart';
import '../bloc/session/session_state.dart';

/// Màn hình đăng nhập đơn giản với userId được lưu trong state của bloc
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onStartPressed(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    final userId = _controller.text.trim();
    context.read<SessionBloc>().add(StartSession(userId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
        centerTitle: true,
      ),
      body: BlocListener<SessionBloc, SessionState>(
        listener: (context, state) {
          if (state.isSessionStarted) {
            // Khi phiên bắt đầu, điều hướng tới màn hình chính
            context.go('/dashboard');
          }
        },
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Enter your user ID to start',
                    style: theme.textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'User ID',
                      hintText: 'Enter user id',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'User ID cannot be empty';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _onStartPressed(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Start'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'User ID is stored only in bloc state and not persisted.',
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
