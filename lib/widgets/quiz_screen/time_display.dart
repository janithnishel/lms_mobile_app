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
    
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Icon(Icons.access_time, color: color, size: 20),
          const SizedBox(width: 4),
          Text(
            formatTime(timeRemaining),
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}