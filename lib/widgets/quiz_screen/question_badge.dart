import 'package:flutter/material.dart';

class QuestionBadge extends StatelessWidget {
  final int currentQuestion;
  const QuestionBadge({Key? key, required this.currentQuestion})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          '${currentQuestion + 1}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ),
    );
  }
}
