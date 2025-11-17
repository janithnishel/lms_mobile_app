import 'package:flutter/material.dart';
import 'package:lms_app/widgets/see_answer_screen/answer_option.dart';

class QuestionDisplayCard extends StatelessWidget {
  final int questionIndex;
  final String questionText;
  final List<dynamic> options;
  final int correctAnswerIndex;
  final int userAnswerIndex;

  const QuestionDisplayCard({
    super.key,
    required this.questionIndex,
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
    required this.userAnswerIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question Header
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      '${questionIndex + 1}', // Dynamic Question Number
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1976D2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Question ${questionIndex + 1}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Question Text
            Text(
              questionText, // Dynamic Question Text
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),

            // Answer Options List
            ...options.asMap().entries.map((entry) {
              int index = entry.key;
              String optionText = entry.value as String;
              String label = String.fromCharCode('A'.codeUnitAt(0) + index);

              final bool isCorrect = index == correctAnswerIndex;
              // User answer is only highlighted as 'isUserAnswer' if it is NOT the correct answer
              final bool isUserAnswer = index == userAnswerIndex && index != correctAnswerIndex;

              return Column(
                children: [
                  AnswerOption(
                    label: label,
                    text: optionText,
                    isCorrect: isCorrect,
                    isUserAnswer: isUserAnswer,
                  ),
                  const SizedBox(height: 12),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
