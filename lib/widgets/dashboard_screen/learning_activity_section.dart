import 'package:flutter/material.dart';

class LearningActivitySection extends StatelessWidget {
  const LearningActivitySection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ActivityItem(text: 'Completed Database Fundamentals', color: Colors.green),
        ActivityItem(text: 'Started Python Programming', color: Colors.blue),
        ActivityItem(text: 'Assignment submitted', color: Colors.orange),
      ],
    );
  }
}

class ActivityItem extends StatelessWidget {
  final String text;
  final Color color;

  const ActivityItem({
    Key? key,
    required this.text,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}