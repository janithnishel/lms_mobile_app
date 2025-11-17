import 'package:flutter/material.dart';
import 'package:lms_app/utils/colors.dart';

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
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: OutlinedButton.icon(
                    // Previous (styled like "Back to Papers" button)
                    onPressed: currentQuestion > 0 ? previousQuestion : null,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Previous'),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.lightBackground,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Center(
                  child: Text(
                    'Question ${currentQuestion + 1} of $totalQuestions',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: ElevatedButton.icon(
                    // Next (styled like "Start Paper" button)
                    onPressed: currentQuestion < totalQuestions - 1
                        ? nextQuestion
                        : null,
                    icon: const Icon(Icons.arrow_forward, color: Colors.white),
                    label: const Text('Next',style: TextStyle(color: Colors.white),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lightBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: showSubmitConfirmationDialog,
              // Submit Exam Paper (styled like "Start Paper" button)
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child:  Text(
                'Submit Exam Paper',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 17
                ),
              ),
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
