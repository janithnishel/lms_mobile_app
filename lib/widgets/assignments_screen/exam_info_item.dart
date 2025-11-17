// =====================================================
// FILE: widgets/exam_info_item.dart
// =====================================================
import 'package:flutter/material.dart';

class ExamInfoItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const ExamInfoItem({
    Key? key,
    required this.icon,
    required this.text,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}