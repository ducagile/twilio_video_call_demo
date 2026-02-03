import 'package:flutter/material.dart';
import '../widgets/channel_form.dart';

/// Màn hình chính để nhập tên channel
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agora Video Call'),
        centerTitle: true,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: ChannelForm(),
        ),
      ),
    );
  }
}
