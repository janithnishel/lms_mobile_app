import 'package:flutter/material.dart';

class QuestionNavigationFooter extends StatelessWidget {
  final int currentQuestionIndex;
  final int totalQuestions;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const QuestionNavigationFooter({
    super.key,
    required this.currentQuestionIndex,
    required this.totalQuestions,
    this.onPrevious,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous Button (disabled if on the first question)
          TextButton.icon(
            onPressed: onPrevious,
            icon: const Icon(Icons.chevron_left),
            label: const Text('Previous'),
            style: TextButton.styleFrom(disabledForegroundColor: Colors.grey),
          ),
          
          // Question Index Text
          Text(
            'Question ${currentQuestionIndex + 1} of $totalQuestions',
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
          
          // Next Button (disabled if on the last question)
          ElevatedButton.icon(
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right, size: 18),
            label: const Text('Next'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              disabledBackgroundColor: Colors.grey[300],
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}