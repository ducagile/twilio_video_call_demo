import 'package:flutter/material.dart';
import 'package:twilio_video_call_demo/domain/entities/call_state.dart';
import 'video_view_item.dart';

/// Grid hiển thị video của các người dùng
class VideoViewGrid extends StatelessWidget {
  final List<CallUser> users;

  const VideoViewGrid({
    super.key,
    required this.users,
  });

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return const Center(
        child: Text(
          'Đang chờ người dùng tham gia...',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    // Xác định số cột dựa trên số lượng người dùng
    final crossAxisCount = _getCrossAxisCount(users.length);

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: users.length,
      itemBuilder: (context, index) {
        return VideoViewItem(user: users[index]);
      },
    );
  }

  int _getCrossAxisCount(int userCount) {
    if (userCount == 1) return 1;
    if (userCount == 2) return 2;
    if (userCount <= 4) return 2;
    if (userCount <= 6) return 3;
    return 4;
  }
}
