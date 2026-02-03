import 'package:flutter/material.dart';

/// Toolbar với các nút điều khiển cuộc gọi
class CallToolbar extends StatelessWidget {
  final bool isMuted;
  final bool isVideoEnabled;
  final VoidCallback onToggleMute;
  final VoidCallback onToggleVideo;
  final VoidCallback onSwitchCamera;
  final VoidCallback onLeave;

  const CallToolbar({
    super.key,
    required this.isMuted,
    required this.isVideoEnabled,
    required this.onToggleMute,
    required this.onToggleVideo,
    required this.onSwitchCamera,
    required this.onLeave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Toggle mute
            _ToolbarButton(
              icon: isMuted ? Icons.mic_off : Icons.mic,
              label: isMuted ? 'Bật mic' : 'Tắt mic',
              onPressed: onToggleMute,
              backgroundColor: isMuted ? Colors.red : Colors.grey[700]!,
            ),

            // Toggle video
            _ToolbarButton(
              icon: isVideoEnabled ? Icons.videocam : Icons.videocam_off,
              label: isVideoEnabled ? 'Tắt camera' : 'Bật camera',
              onPressed: onToggleVideo,
              backgroundColor: isVideoEnabled ? Colors.grey[700]! : Colors.red,
            ),

            // Switch camera
            _ToolbarButton(
              icon: Icons.switch_camera,
              label: 'Đổi camera',
              onPressed: onSwitchCamera,
              backgroundColor: Colors.grey[700]!,
            ),

            // Leave call
            _ToolbarButton(
              icon: Icons.call_end,
              label: 'Kết thúc',
              onPressed: onLeave,
              backgroundColor: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;

  const _ToolbarButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.white),
            onPressed: onPressed,
            iconSize: 24,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
