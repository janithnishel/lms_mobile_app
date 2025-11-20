import 'package:flutter/material.dart';
import 'package:lms_app/models/see_answers_model.dart';

class QuestionNavigatorDrawer extends StatelessWidget {
  final int currentQuestion;
  final int totalQuestions;
  final Function(int) onQuestionTap;
  final List<QuestionData> questions;

  const QuestionNavigatorDrawer({
    Key? key,
    required this.currentQuestion,
    required this.totalQuestions,
    required this.onQuestionTap,
    required this.questions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(
              top: 60,
              bottom: 20,
              left: 20,
              right: 20,
            ),
            color: Colors.blue[600],
            width: double.infinity,
            child: const Text(
              'Question Navigator',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: totalQuestions,
                itemBuilder: (context, index) {
                  final isCurrent = index == currentQuestion;
                  final hasExplanation =
                      questions[index].explanation != null ||
                      questions[index].visualExplanationUrl != null;

                  return GestureDetector(
                    onTap: () => onQuestionTap(index),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isCurrent ? Colors.blue[100] : Colors.grey[100],
                        border: Border.all(
                          color: isCurrent ? Colors.blue : Colors.grey[300]!,
                          width: isCurrent ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: isCurrent
                                    ? Colors.blue[900]
                                    : Colors.black87,
                                fontWeight: isCurrent
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                          // Explanation indicator - small book icon in top right
                          if (hasExplanation)
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Colors.orange[400],
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  Icons.menu_book,
                                  size: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                'Close',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
