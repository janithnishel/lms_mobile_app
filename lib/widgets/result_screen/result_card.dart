// import 'package:flutter/material.dart';

// class ResultCard extends StatelessWidget {
//   final String paperTitle;
//   final String submittedInfo;
//   final String scoreFraction;
//   final int percentage;
//   final String timeSpent;
//   final String correctCount;
//   final String grade;
//   final Color gradeColor;
//   final VoidCallback onSeeAnswers;

//   const ResultCard({
//     Key? key,
//     required this.paperTitle,
//     required this.submittedInfo,
//     required this.scoreFraction,
//     required this.percentage,
//     required this.timeSpent,
//     required this.correctCount,
//     required this.grade,
//     required this.gradeColor,
//     required this.onSeeAnswers,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: EdgeInsets.zero,
//       elevation: 3,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Header Row: Title and Grade Badge
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         paperTitle,
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       const SizedBox(height: 4),
//                       Row(
//                         children: [
//                           const Icon(
//                             Icons.access_time,
//                             size: 14,
//                             color: Colors.grey,
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             submittedInfo,
//                             style: const TextStyle(
//                               fontSize: 12,
//                               color: Colors.grey,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 // Grade Badge
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 10,
//                     vertical: 4,
//                   ),
//                   decoration: BoxDecoration(
//                     color: gradeColor.withOpacity(0.15),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Text(
//                     grade,
//                     style: TextStyle(
//                       color: gradeColor,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 14,
//                     ),
//                   ),
//                 ),
//               ],
//             ),

//             const Divider(height: 30),

//             // Score/Stats Row
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 _buildStatItem('Score', scoreFraction, Colors.blue),
//                 _buildStatItem('Percentage', '$percentage%', Colors.orange),
//                 _buildStatItem('Time Spent', timeSpent, Colors.purple),
//                 _buildStatItem('Correct', correctCount, Colors.green),
//               ],
//             ),

//             const SizedBox(height: 20),

//             // Progress Bar and See Answers Button
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Progress Bar
//                 LinearProgressIndicator(
//                   value: percentage / 100,
//                   backgroundColor: Colors.grey[200],
//                   color: gradeColor,
//                   minHeight: 8,
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   '$percentage% Achieved',
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: gradeColor,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 10),

//             Align(
//               alignment: Alignment.centerRight,
//               child: TextButton(
//                 onPressed: onSeeAnswers,
//                 child: const Text(
//                   'See Answers',
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStatItem(String title, String value, Color color) {
//     return Column(
//       children: [
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w900,
//             color: color,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           title,
//           style: const TextStyle(
//             fontSize: 12,
//             color: Colors.black54,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_app/widgets/result_screen/result_info_column.dart';
import 'package:lms_app/screens/assignment/see_answers_screen.dart';

class ResultCard extends StatelessWidget {
  final String title;
  final String description;
  final String submittedDate;
  final String score;
  final String percentage;
  final String timeSpent;
  final int questions;
  final String grade;
  final Color gradeColor;
  final double progressValue;
  final bool showTrophy;
  final bool showFailIcon;
  final VoidCallback? onSeeAnswers;
  final Map<String, dynamic>? attempt;
  final String? paperId;

  const ResultCard({
    Key? key,
    required this.title,
    required this.description,
    required this.submittedDate,
    required this.score,
    required this.percentage,
    required this.timeSpent,
    required this.questions,
    required this.grade,
    required this.gradeColor,
    required this.progressValue,
    this.showTrophy = false,
    this.showFailIcon = false,
    this.onSeeAnswers,
    this.attempt,
    this.paperId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with title and grade
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: gradeColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            grade,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: gradeColor,
                            ),
                          ),
                        ),
                        if (showTrophy) ...[
                          const SizedBox(height: 8),
                          Icon(
                            Icons.emoji_events,
                            color: Colors.amber[700],
                            size: 24,
                          ),
                        ],
                        if (showFailIcon) ...[
                          const SizedBox(height: 8),
                          Icon(Icons.cancel, color: Colors.red[400], size: 24),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Submitted date
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey[500]),
                    const SizedBox(width: 6),
                    Text(
                      'Submitted: $submittedDate',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Stats Row
                Row(
                  children: [
                    Expanded(
                      child: ResultInfoColumn(title: 'Score', value: score),
                    ),
                    Expanded(
                      child: ResultInfoColumn(
                        title: 'Percentage',
                        value: percentage,
                      ),
                    ),
                    Expanded(
                      child: ResultInfoColumn(
                        title: 'Time Spent',
                        value: timeSpent,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        questions.toString(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // See Answers Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      // if (onSeeAnswers != null) {
                      //   onSeeAnswers!();
                      //   return;
                      // }
                      // // If attempt data available, navigate to ResultReviewScreen
                      // if (attempt != null) {
                      //   Navigator.of(context).push(
                      //     MaterialPageRoute(
                      //       builder: (_) => SeeAnswersScreen(
                      //         attempt: attempt!,
                      //         paperId: paperId ?? '',
                      //       ),
                      //     ),
                      //   );
                      //   return;
                      // }
                      // // Fallback to named route
                      context.goNamed(
                        'see-answers',
                        pathParameters: {'paperId': paperId ?? 'N/A'},
                        extra: attempt,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'See Answers',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Progress Bar with Animation
          AnimatedContainer(
            height: 12, // Increased from 6 to 12 for better visibility
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: AnimatedFractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progressValue.clamp(0.0, 1.0),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.elasticOut,
              child: Container(
                decoration: BoxDecoration(
                  color: progressValue >= 0.7
                      ? Colors.green
                      : progressValue >= 0.4
                      ? Colors.orange
                      : Colors.red,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (progressValue >= 0.7
                              ? Colors.green
                              : progressValue >= 0.4
                              ? Colors.orange
                              : Colors.red)
                          .withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
