import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_app/models/exam_paper_card_model.dart';
import 'package:lms_app/models/paper_intro_details_model.dart';
import 'package:lms_app/utils/colors.dart';
// Note: Your PaperIntroDetails and DetailCardModel files should be imported here.

class ExamPaperCard extends StatelessWidget {
  final ExamPaperCardModel paper;

  const ExamPaperCard({Key? key, required this.paper}) : super(key: key);

  // Helper function to decide button text based on status
  String _getButtonText() {
    if (paper.isCompleted) {
      return 'View Results';
    } else if (paper.studentStatus == 'started') {
      return 'Continue';
    } else {
      return 'Start Paper';
    }
  }

  // Helper function to decide button color based on status
  Color _getButtonColor() {
    if (paper.isCompleted) {
      return Colors.purple;
    } else if (paper.studentStatus == 'started') {
      return Colors.amber[700]!;
    } else {
      return Colors.blue;
    }
  }

  // 🔑 KEY FUNCTION: Navigation Logic
  void _handleNavigation(BuildContext context) {
    if (paper.isCompleted) {
      // 1. Completed Paper: Navigate to Results Screen
      // Passing path parameters according to your AppRouter
      context.goNamed('results', pathParameters: {'resultId': paper.id});
    } else {
      // 2. Start/Continue Paper: Navigate to Instruction Screen

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
      // Provides all data required for PaperInstructionScreen.
      // (Sends default/mock data for other required fields in your PaperIntroDetails Model)
      final PaperIntroDetailsModel details = PaperIntroDetailsModel(
        paperId: paper.id,
        paperTitle: paper.title,
        paperDescription: paper.description,
        detailCards: cards,
        timeLimitMinutes: paper.timeLimitMinutes,
        // Necessary Mock Data (if your Model has non-nullable fields)
      );

      // Navigation using GoRouter
      // Sends PaperIntroDetails object as extra via pushNamed to 'paperInstruction' route name.
      context.pushNamed('paperInstruction', extra: details);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String statusMessage = paper.isCompleted
        ? 'Completed'
        : paper.timeLeftDisplay;

    final bool isActionEnabled = paper.isAvailableToStart || paper.isCompleted;

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
            // Title & Score
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
            const SizedBox(height: 8),
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
                      'Due: ${paper.dueDateDisplay}',
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
                        // 🔑 Navigation Function Call
                        _handleNavigation(context);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getButtonColor(),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _getButtonText(),
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
