import 'package:flutter/material.dart';
import 'package:lms_app/utils/colors.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestion = 0;
  int totalQuestions = 5;
  Map<int, String?> answers = {}; // Store answers for each question
  int timeRemaining = 3536; // 58:56 in seconds
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Map<String, dynamic>> questions = [
    {
      'question': 'first question',
      'options': [
        {'label': 'A', 'text': 'first answer'},
        {'label': 'B', 'text': 'second answer'},
        {'label': 'C', 'text': 'third answer'},
        {'label': 'D', 'text': 'forth question'},
        {'label': 'E', 'text': 'fifth question'},
      ],
    },
    {
      'question': 'second question',
      'options': [
        {'label': 'A', 'text': 'option one'},
        {'label': 'B', 'text': 'option two'},
        {'label': 'C', 'text': 'option three'},
        {'label': 'D', 'text': 'option four'},
        {'label': 'E', 'text': 'option five'},
      ],
    },
    {
      'question': 'third question',
      'options': [
        {'label': 'A', 'text': 'choice A'},
        {'label': 'B', 'text': 'choice B'},
        {'label': 'C', 'text': 'choice C'},
        {'label': 'D', 'text': 'choice D'},
        {'label': 'E', 'text': 'choice E'},
      ],
    },
    {
      'question': 'fourth question',
      'options': [
        {'label': 'A', 'text': 'answer A'},
        {'label': 'B', 'text': 'answer B'},
        {'label': 'C', 'text': 'answer C'},
        {'label': 'D', 'text': 'answer D'},
        {'label': 'E', 'text': 'answer E'},
      ],
    },
    {
      'question':
          'පහත දැක්වෙන කුමන පයිතන් (Python) ක්‍රමලේඛ ඛණ්ඩය කාරක නීති අනුව නිවැරදි (Syntactically correct) වේ ද?',
      'options': [
        {'label': 'A', 'text': 'selection A'},
        {'label': 'B', 'text': 'selection B'},
        {'label': 'C', 'text': 'selection C'},
        {'label': 'D', 'text': 'selection D'},
        {'label': 'E', 'text': 'selection E'},
      ],
    },
  ];

  int get answeredCount => answers.values.where((v) => v != null).length;

  String? get selectedAnswer => answers[currentQuestion];

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.blue[50],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.blue),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Center(
          child: const Text(
            'Exam Paper 01',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                const Icon(Icons.access_time, color: Colors.blue, size: 20),
                const SizedBox(width: 4),
                Text(
                  formatTime(timeRemaining),
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: _buildQuestionNavigator(),
      body: Column(
        children: [
          // Progress Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${currentQuestion + 1} of $totalQuestions',
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                Text(
                  '$answeredCount/$totalQuestions Answered',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question Number Badge
                  Row(
                    children: [
                      Container(
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
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          questions[currentQuestion]['question'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Answer Options
                  ...questions[currentQuestion]['options'].map<Widget>((
                    option,
                  ) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            answers[currentQuestion] = option['label'];
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: selectedAnswer == option['label']
                                ? Colors.blue[50]
                                : Colors.white,
                            border: Border.all(
                              color: selectedAnswer == option['label']
                                  ? Colors.blue
                                  : Colors.grey[300]!,
                              width: selectedAnswer == option['label'] ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: selectedAnswer == option['label']
                                        ? Colors.blue
                                        : Colors.grey[400]!,
                                    width: 2,
                                  ),
                                  color: selectedAnswer == option['label']
                                      ? Colors.blue
                                      : Colors.transparent,
                                ),
                                child: selectedAnswer == option['label']
                                    ? const Icon(
                                        Icons.circle,
                                        size: 12,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                option['label'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: selectedAnswer == option['label']
                                      ? Colors.blue
                                      : Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  option['text'],
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: selectedAnswer == option['label']
                                        ? Colors.black87
                                        : Colors.black54,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),

          // Bottom Navigation
          Container(
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
                      onPressed: currentQuestion > 0
                          ? () {
                              setState(() {
                                currentQuestion--;
                              });
                            }
                          : null,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Previous'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                    Text(
                      'Question ${currentQuestion + 1} of $totalQuestions',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: currentQuestion < totalQuestions - 1
                          ? () {
                              setState(() {
                                currentQuestion++;
                              });
                            }
                          : null,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Next'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Center(child: const Text('Ready to Submit?')),
                          content: SizedBox(
                            height: 140,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'You have answered $answeredCount out of $totalQuestions questions.',
                                ),
                                SizedBox(height: 20),
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Color(0xFFFFFBEB),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Color(0xFFFEF08A),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Icon(
                                          Icons.warning_amber_rounded,
                                          size: 25,
                                          color: Colors.orange[700],
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          'Unanswered questions will be marked as incorrect.',
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          actions: [
                            Row(
                              children: [
                                for (int i = 0; i < 2; i++)
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        left: i == 1 ? 6 : 0,
                                        right: i == 0 ? 6 : 0,
                                      ),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          // Submit logic here
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.lightBlue,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 16,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          i == 0 ? 'Cancel' : 'Submit Paper',
                                          style: TextStyle(
                                            color: AppColors.lightBackground,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lightBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Submit Paper',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.lightBackground,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),

                if (answeredCount < totalQuestions)
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Color(0xFFFEF08A)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 12,
                            color: Colors.orange[700],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'You haven\'t answered all questions.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionNavigator() {
    return Drawer(
      backgroundColor: Colors.white,
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
                children: [
                  const Text(
                    'Question Navigator',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildLegendItem(Colors.blue, 'Current'),
                      const SizedBox(width: 16),
                      _buildLegendItem(Colors.green, 'Answered'),
                      const SizedBox(width: 16),
                      _buildLegendItem(Colors.grey[300]!, 'Unanswered'),
                    ],
                  ),
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
                      bool isCurrent = index == currentQuestion;
                      bool isAnswered = answers[index] != null;

                      Color backgroundColor;
                      Color textColor;

                      if (isCurrent) {
                        backgroundColor = Colors.blue;
                        textColor = Colors.white;
                      } else if (isAnswered) {
                        backgroundColor = Colors.green[50]!;
                        textColor = Colors.green[700]!;
                      } else {
                        backgroundColor = Colors.grey[200]!;
                        textColor = Colors.grey[700]!;
                      }

                      return InkWell(
                        onTap: () {
                          setState(() {
                            currentQuestion = index;
                          });
                          Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isCurrent
                                  ? Colors.blue[700]!
                                  : isAnswered
                                  ? Colors.green[200]!
                                  : Colors.grey[300]!,
                              width: isCurrent ? 2 : 1,
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
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard(
                        'Total',
                        totalQuestions.toString(),
                        Colors.blue,
                      ),
                      _buildStatCard(
                        'Answered',
                        answeredCount.toString(),
                        Colors.green,
                      ),
                      _buildStatCard(
                        'Remaining',
                        (totalQuestions - answeredCount).toString(),
                        Colors.orange,
                      ),
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

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }
}
