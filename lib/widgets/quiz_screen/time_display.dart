import 'package:flutter/material.dart';

class TimeDisplay extends StatelessWidget {
  final int timeRemaining;
  final String Function(int) formatTime;
  const TimeDisplay({
    Key? key,
    required this.timeRemaining,
    required this.formatTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine if time is low (<= 300 seconds or 5 minutes)
    final isLow = timeRemaining <= 300;
    // Set color based on remaining time
    final color = isLow ? Colors.red : Colors.blue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isLow ? Colors.red.shade50 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: isLow ? 2 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.access_time,
            color: color,
            size: isLow ? 20 : 18,
          ),
          const SizedBox(width: 6),
          Text(
            formatTime(timeRemaining),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: isLow ? 15 : 14,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
