import 'package:flutter/material.dart';

/// Panel hiển thị logs của cuộc gọi
class CallLogsPanel extends StatefulWidget {
  final List<String> logs;

  const CallLogsPanel({
    super.key,
    required this.logs,
  });

  @override
  State<CallLogsPanel> createState() => _CallLogsPanelState();
}

class _CallLogsPanelState extends State<CallLogsPanel> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: _isExpanded ? 200 : 40,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            dense: true,
            title: Text(
              'Logs (${widget.logs.length})',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            trailing: IconButton(
              icon: Icon(
                _isExpanded ? Icons.expand_less : Icons.expand_more,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () {
                setState(() => _isExpanded = !_isExpanded);
              },
            ),
          ),
          if (_isExpanded)
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.logs.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 2,
                    ),
                    child: Text(
                      widget.logs[index],
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
