import 'package:flutter/material.dart';

class BottomNavigation extends StatelessWidget {
  final int currentQuestion;
  final int totalQuestions;
  final int answeredCount;
  final VoidCallback nextQuestion;
  final VoidCallback previousQuestion;
  final VoidCallback showSubmitConfirmationDialog;

  const BottomNavigation({
    Key? key,
    required this.currentQuestion,
    required this.totalQuestions,
    required this.answeredCount,
    required this.nextQuestion,
    required this.previousQuestion,
    required this.showSubmitConfirmationDialog,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton.icon(
                // Previous
                onPressed: currentQuestion > 0 ? previousQuestion : null,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Previous'),
              ),
              Text('Question ${currentQuestion + 1} of $totalQuestions'),
              ElevatedButton.icon(
                // Next
                onPressed: currentQuestion < totalQuestions - 1
                    ? nextQuestion
                    : null,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Next'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: showSubmitConfirmationDialog,
              // Submit Exam Paper
              child: const Text('Submit Exam Paper'),
            ),
          ),
          const SizedBox(height: 8),
          if (answeredCount < totalQuestions)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFEF08A)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [ 
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 12,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    // ${totalQuestions - answeredCount} more questions remaining.
                    '${totalQuestions - answeredCount} more questions remaining.',
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
