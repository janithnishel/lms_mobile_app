import 'package:flutter/material.dart';

class QuestionNavigatorDrawer extends StatelessWidget {
  final int totalQuestions;
  final int currentQuestion;
  final Map<int, String?> answers;
  final void Function(int) jumpToQuestion;
  final int answeredCount;

  const QuestionNavigatorDrawer({
    Key? key,
    required this.totalQuestions,
    required this.currentQuestion,
    required this.answers,
    required this.jumpToQuestion,
    required this.answeredCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    // Question Navigator
                    'Question Navigator',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1,
                        ),
                    itemCount: totalQuestions,
                    itemBuilder: (context, index) {
                      final isCurrent = index == currentQuestion;
                      final isAnswered = answers[index] != null;
                      Color bg;
                      Color textColor;
                      Color borderColor;
                      double borderWidth;
                      if (isCurrent) {
                        bg = Colors.blue;
                        textColor = Colors.white;
                        borderColor = Colors.blue[700]!;
                        borderWidth = 2;
                      } else if (isAnswered) {
                        bg = Colors.green[50]!;
                        textColor = Colors.green[700]!;
                        borderColor = Colors.green[200]!;
                        borderWidth = 1;
                      } else {
                        bg = Colors.grey[200]!;
                        textColor = Colors.grey[700]!;
                        borderColor = Colors.grey[300]!;
                        borderWidth = 1;
                      }

                      return InkWell(
                        onTap: () {
                          jumpToQuestion(index);
                          Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: borderColor,
                              width: borderWidth,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(top: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        '$totalQuestions',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      // Total Questions
                      const Text('Total Questions'),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        '$answeredCount',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      // Answered
                      const Text('Answered'),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        '${totalQuestions - answeredCount}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      // Remaining
                      const Text('Remaining'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
