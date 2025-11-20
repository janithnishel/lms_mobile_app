import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_app/models/exam_paper_card_model.dart';
import 'package:lms_app/models/paper_intro_details_model.dart';
import 'package:lms_app/utils/colors.dart';
// Note: Your PaperIntroDetails and DetailCardModel files should be imported here.
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_app/logic/assignments/assignments_state.dart';
import 'package:lms_app/logic/assignments/assignments_cubit.dart';

class ExamPaperCard extends StatelessWidget {
  final ExamPaperCardModel paper;
  final String currentTab; // 'not-answered', 'answered', 'expired'

  const ExamPaperCard({Key? key, required this.paper, required this.currentTab}) : super(key: key);

  // Helper function to check if this paper was answered/attempted
  // This matches the Next.js logic where answeredPapers.includes(paper._id)
  bool _isAnswered(BuildContext context) {
    final assignmentsCubit = BlocProvider.of<AssignmentsCubit>(context);
    if (assignmentsCubit.state is AssignmentsWithStatusLoaded) {
      final state = assignmentsCubit.state as AssignmentsWithStatusLoaded;
      return state.data.attemptedPapers.contains(paper.id);
    }
    return false;
  }

  // Helper function to decide button text based on status (matching Next.js logic)
  String _getButtonText(BuildContext context) {
    final isAnswered = _isAnswered(context);

    // Special handling for STRUCTURE papers
    if (paper.paperType.toUpperCase() == 'STRUCTURE') {
      return 'View Paper';
    }

    // Special handling for expired tab - check if attempted or not
    if (currentTab == 'expired') {
      // Show "See Answer" if the student attempted the paper before it expired
      if (isAnswered) {
        return 'See Answer';
      }
      // Show "Expired" if the student never attempted the paper
      return 'Expired';
    }

    // Next.js logic: if answeredPapers.includes(paper._id), show See Answer
    if (isAnswered) {
      return 'See Answer';
    }

    // Default logic for other tabs
    if (paper.isCompleted) {
      return 'View Results';
    } else if (paper.studentStatus == 'started') {
      return 'Continue';
    } else {
      return 'Start Paper';
    }
  }

  // Helper function to decide button color based on status (matching Next.js styling)
  Color _getButtonColor(BuildContext context) {
    final isAnswered = _isAnswered(context);

    // Special handling for STRUCTURE papers
    if (paper.paperType.toUpperCase() == 'STRUCTURE') {
      return Colors.purple;
    }

    // Special handling for expired tab - distinguish between See Answer and Expired
    if (currentTab == 'expired') {
      // Only papers that were answered get green "See Answer" button
      if (isAnswered) {
        return Colors.green;
      }
      // Papers that were never answered get grey "Expired" button
      return Colors.grey[400]!;
    }

    // Next.js styling: answered papers get green button
    if (isAnswered) {
      return Colors.green;
    }

    // Default logic for other cases
    if (paper.isCompleted) {
      return Colors.purple;
    } else if (paper.studentStatus == 'started') {
      return Colors.amber[700]!;
    } else {
      return Colors.blue;
    }
  }

  // Helper function to get button icon based on status (matching Next.js Trophy icon)
  IconData? _getButtonIcon(BuildContext context) {
    final isAnswered = _isAnswered(context);

    // Special handling for STRUCTURE papers
    if (paper.paperType.toUpperCase() == 'STRUCTURE') {
      return Icons.remove_red_eye; // Eye icon for "View Paper"
    }

    // Next.js uses Trophy icon for See Answer
    if (isAnswered) {
      return Icons.emoji_events; // Trophy icon (emoji_events is trophy)
    }
    return null; // No icon for other cases
  }

  // Helper function to get the appropriate due date label
  String _getDueDateLabel() {
    // If the paper shows "Overdue" status, change label to "Overdue:"
    if (paper.timeLeftDisplay == 'Overdue') {
      return 'Overdue';
    }
    // Otherwise show "Due:"
    return 'Due';
  }

  // 🔑 KEY FUNCTION: Navigation Logic (matching Next.js logic)
  void _handleNavigation(BuildContext context) {
    final isAnswered = _isAnswered(context);

    // Special handling for STRUCTURE papers
    if (paper.paperType.toUpperCase() == 'STRUCTURE') {
      if (isAnswered) {
        // Navigate to see answers screen for STRUCTURE papers that have been attempted
        context.pushNamed('see-answers',
          pathParameters: {'paperId': paper.id},
          extra: paper.title); // Pass actual paper title
      } else {
        // For active STRUCTURE papers, navigate to structure paper screen
        // Pass paper details to the screen
        final structurePaperData = {
          'paperId': paper.id,
          'paperTitle': paper.title,
          'paperDescription': paper.description,
          'totalQuestions': paper.totalQuestions,
          'timeLimitMinutes': paper.timeLimitMinutes,
          'dueDateDisplay': paper.dueDateDisplay,
        };
        context.pushNamed('structurePaper', extra: structurePaperData);
      }
      return;
    }

    // Special handling for expired tab
    if (currentTab == 'expired') {
      // For answered papers in expired tab: navigate to see answers with actual title
      if (isAnswered) {
        context.pushNamed('see-answers',
          pathParameters: {'paperId': paper.id},
          extra: paper.title); // Pass actual paper title
      } else {
        // For unattempted papers in expired tab: show info dialog
        _showExpiredPaperInfo(context);
      }
      return;
    }

    // Next.js logic: if answeredPapers.includes(paper._id), navigate to see answers
    if (isAnswered) {
      // Navigate to see answers screen with actual paper title
      context.pushNamed('see-answers',
        pathParameters: {'paperId': paper.id},
        extra: paper.title); // Pass actual paper title
    } else if (paper.isCompleted) {
      // Navigate to Results Screen for completed but not attempted papers
      context.goNamed('results', pathParameters: {'resultId': paper.id});
    } else {
      // Navigate to Instruction Screen for papers that haven't been started
      // Create a list of DetailCardModel using data from ExamPaperCardModel
      final List<DetailCardModel> cards = [
        DetailCardModel(
          boxColor: const Color(0xFFEFF6FF),
          contentColor: const Color(0xFF2563EB),
          icon: Icons.subject_outlined,
          title: "Total Questions",
          value: "${paper.totalQuestions} Questions",
        ),
        DetailCardModel(
          boxColor: const Color(0xFFECFDF5),
          contentColor: const Color(0xFF059669),
          icon: Icons.timer,
          title: "Time Limit",
          value: "${paper.timeLimitMinutes} mins",
        ),
        DetailCardModel(
          boxColor: const Color(0xFFFFF7ED),
          contentColor: const Color(0xFFF97316),
          icon: Icons.calendar_today_outlined,
          title: "Due Date",
          value: paper.dueDateDisplay,
        ),
      ];

      // Create PaperIntroDetails Object
      final PaperIntroDetailsModel details = PaperIntroDetailsModel(
        paperId: paper.id,
        paperTitle: paper.title,
        paperDescription: paper.description,
        detailCards: cards,
        timeLimitMinutes: paper.timeLimitMinutes,
      );

      // Navigation using GoRouter
      context.pushNamed('paperInstruction', extra: details);
    }
  }

  // Show information dialog for expired papers that were never attempted
  void _showExpiredPaperInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.access_time, color: Colors.orange),
              const SizedBox(width: 10),
              Text(paper.title),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This exam paper has expired and is no longer available for submission.',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              _buildInfoRow('Due Date:', paper.dueDateDisplay),
              _buildInfoRow('Questions:', '${paper.totalQuestions}'),
              _buildInfoRow('Time Limit:', '${paper.timeLimitMinutes} minutes'),
              const SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This paper expired without being started. You can no longer access or submit this exam.',
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String statusMessage = paper.isCompleted
        ? 'Completed'
        : paper.timeLeftDisplay;

    final bool isActionEnabled = paper.isAvailableToStart || paper.isCompleted || (currentTab == 'expired');

    return Card(
      color: AppColors.lightBackground,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TOP STATUS ROW: Logo, Paper Type, and Availability Status
            Row(
              children: [
                // Paper-appropriate Logo/Icon
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.teal[600]!, Colors.teal[800]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.article, // More paper-like icon
                    color: Colors.white,
                    size: 18,
                  ),
                ),
            
                const SizedBox(width: 12),
            
                // Widened MCQ/Structure Indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: paper.paperType.toUpperCase() == 'MCQ'
                        ? Colors.blue[50]
                        : Colors.amber[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: paper.paperType.toUpperCase() == 'MCQ'
                          ? Colors.blue[200]!
                          : Colors.amber[200]!,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        paper.paperType.toUpperCase() == 'MCQ'
                            ? Icons.quiz_outlined
                            : Icons.article_outlined,
                        size: 16,
                        color: paper.paperType.toUpperCase() == 'MCQ'
                            ? Colors.blue[700]
                            : Colors.amber[700],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        paper.paperType.toUpperCase() == 'MCQ' ? 'MCQ' : 'STRUCTURE',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: paper.paperType.toUpperCase() == 'MCQ'
                              ? Colors.blue[700]
                              : Colors.amber[700],
                        ),
                      ),
                    ],
                  ),
                ),
            
                const SizedBox(width: 8),
            
                // Available/Expired Indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: paper.timeLeftDisplay == 'Overdue'
                        ? Colors.red[50]
                        : Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: paper.timeLeftDisplay == 'Overdue'
                          ? Colors.red[200]!
                          : Colors.green[200]!,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        paper.timeLeftDisplay == 'Overdue'
                            ? Icons.access_time
                            : Icons.check_circle_outline,
                        size: 16,
                        color: paper.timeLeftDisplay == 'Overdue'
                            ? Colors.red[700]
                            : Colors.green[700],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        paper.timeLeftDisplay == 'Overdue' ? 'Expired' : 'Available',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: paper.timeLeftDisplay == 'Overdue'
                              ? Colors.red[700]
                              : Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // TITLE ROW: Title & Score
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    paper.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                if (paper.isCompleted && paper.studentScorePercentage != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      paper.studentScorePercentage!,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),
            // Description
            Text(
              paper.description,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            // Details (Questions, Duration)
            Row(
              children: [
                const Icon(Icons.list_alt, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${paper.totalQuestions} Questions',
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
                const SizedBox(width: 15),
                const Icon(Icons.timer_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${paper.timeLimitMinutes} Mins',
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Due Date / Time Left
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${_getDueDateLabel()}: ${paper.dueDateDisplay}',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: paper.timeLeftColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusMessage,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: paper.timeLeftColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isActionEnabled
                    ? () {
                        _handleNavigation(context);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getButtonColor(context),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: _getButtonIcon(context) != null
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_getButtonIcon(context), size: 18),
                          const SizedBox(width: 8),
                          Text(
                            _getButtonText(context),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        _getButtonText(context),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
