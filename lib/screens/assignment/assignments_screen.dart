import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
// ⭐️ New Import: AuthRepository for token access
import 'package:lms_app/core/repositories/auth_repository.dart';
import 'package:lms_app/core/services/quiz_repository.dart';
import 'package:lms_app/logic/assignments/assignments_cubit.dart';
import 'package:lms_app/logic/assignments/assignments_state.dart';
import 'package:lms_app/models/exam_paper_card_model.dart';
import 'package:lms_app/utils/colors.dart';
import 'package:lms_app/widgets/assignments_screen/exam_paper_card.dart';
import 'package:lms_app/widgets/assignments_screen/exam_stats_card.dart';
import 'package:lms_app/widgets/shared/custom_app_bar.dart';

class AssignmentsScreen extends StatelessWidget {
  const AssignmentsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ⭐️ 1. Using FutureBuilder to load the Auth Token asynchronously
    return FutureBuilder<String?>(
      // 🔑 Reads the token using the readToken() method in AuthRepository
      future: AuthRepository().readToken(),
      builder: (context, snapshot) {
        // 1. Loading State: Shown until the token is loaded
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. Token Handling
        final String? authToken = snapshot.data;

        // ❌ Error: If the token is not found or is null
        if (authToken == null || authToken.isEmpty) {
          return const Scaffold(
            body: Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text(
                  '⚠️ Authorization Error: Login token not found. Please login again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          );
        }

        // ⭐️ 3. Loaded State: Creates the BLoC Provider after the token is received
        return BlocProvider(
          create: (context) => AssignmentsCubit(
            // 🔑 Injects the actual token into QuizRepository! (Resolves the Invalid Token error)
            QuizRepository(authToken),
          )..loadAssignments(),
          // 💡 Uses the previous UI as the AssignmentListBody within the BLoC Provider
          child: const AssignmentListBody(),
        );
      },
    );
  }
}

// 💡 4. Separating the Assignment UI Logic into a new Widget (AssignmentListBody)
// 💡 The body part of the Scaffold from the previous AssignmentsScreen has been moved here.
// Modify to support tabs
class AssignmentListBody extends StatefulWidget {
  const AssignmentListBody({super.key});

  @override
  State<AssignmentListBody> createState() => _AssignmentListBodyState();
}

class _AssignmentListBodyState extends State<AssignmentListBody> {
  // Tab management state
  String activeTab = 'not-answered'; // 'not-answered', 'answered', 'expired'

  // Helper method to build tabs
  Widget _buildTab(String title, String tabId, IconData icon) {
    final bool isSelected = activeTab == tabId;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => activeTab = tabId),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.blue[600] : Colors.grey[600],
              ),
              const SizedBox(height: 4),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? Colors.blue[600] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to check if a paper is expired
  bool _isExpired(ExamPaperCardModel paper) {
    final String display = paper.timeLeftDisplay;
    return display == 'Overdue'; // Based on the model logic
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: BlocBuilder<AssignmentsCubit, AssignmentsState>(
          builder: (context, state) {
            // -----------------------------------------------------------
            // 1. Loading State (BLoC Loading)
            // -----------------------------------------------------------
            if (state is AssignmentsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // --------------------------------------------------------------
            // 3. New AssignmentsWithStatusLoaded State (for tab filtering)
            // --------------------------------------------------------------

            if (state is AssignmentsWithStatusLoaded) {
              final allPapers = state.data.papers;
              final attemptedPapers = state.data.attemptedPapers;

              // Filter papers based on active tab (matching Next.js logic)
              final List<ExamPaperCardModel> filteredPapers = allPapers.where((paper) {
                final isAnswered = attemptedPapers.contains(paper.id);
                final isExpired = _isExpired(paper);

                switch (activeTab) {
                  case 'not-answered':
                    return !isAnswered && !isExpired;
                  case 'answered':
                    return isAnswered;
                  case 'expired':
                    return isExpired;
                  default:
                    return true;
                }
              }).toList();

              final List<Widget> paperCards = filteredPapers.map((paper) {
                return ExamPaperCard(paper: paper, currentTab: activeTab);
              }).toList();

              // Stats Calculations based on TAB-FILTERED papers
              final int availablePapers = filteredPapers.length;
              final int activePapers = filteredPapers
                  .where((p) => p.isAvailableToStart && !p.isCompleted)
                  .length;
              final int completedPapers = filteredPapers
                  .where((p) => p.isCompleted)
                  .length;

              final completedScores = filteredPapers
                  .where(
                    (p) => p.isCompleted && p.studentScorePercentage != null,
                  )
                  .map((p) {
                    final scoreString = p.studentScorePercentage!.replaceAll(
                      '%',
                      '',
                    );
                    return int.tryParse(scoreString) ?? 0;
                  })
                  .toList();

              final String averageScore = completedScores.isNotEmpty
                  ? '${(completedScores.reduce((a, b) => a + b) / completedScores.length).round()}%'
                  : '0%';

// UI Code Here>>
              // ⭐️ CustomScrollView (UI)
              return CustomScrollView(
                slivers: [
                  const CustomAppBar(),

                  // --- Header Section (Title, Button, Search) ---
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.lightBackground,
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
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.assignment,
                                  color: Colors.blue,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Flexible(
                                child: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Examination Hub',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Access your ICT A-Level examination papers',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.lightPrimary,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Navigate to results screen
                                context.pushNamed(
                                  'results',
                                  pathParameters: {'resultId': 'current'},
                                );
                              },
                              icon: const Icon(
                                Icons.emoji_events,
                                size: 18,
                                color: AppColors.lightBackground,
                              ),
                              label: const Text(
                                'My Results',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // My Results Button
                          // Search Bar
                          TextField(
                            decoration: InputDecoration(
                              hintText: 'Search papers...',
                              hintStyle: TextStyle(
                                color: AppColors.lightRing,
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: AppColors.lightRing,
                              ),
                              filled: true,
                              fillColor: AppColors.lightBackground,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.lightRing,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.lightBorder,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.blue,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Tabs
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                _buildTab('Not Answered', 'not-answered', Icons.assignment_outlined),
                                _buildTab('Answered', 'answered', Icons.check_circle_outline),
                                _buildTab('Expired', 'expired', Icons.schedule),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // --- Stats Cards Section (Live Data) ---
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: ExamStatsCard(
                                  title: 'Available Papers',
                                  value: availablePapers.toString(),
                                  icon: Icons.assignment,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ExamStatsCard(
                                  title: 'Active Papers',
                                  value: activePapers.toString(),
                                  icon: Icons.access_time,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ExamStatsCard(
                                  title: 'Completed',
                                  value: completedPapers.toString(),
                                  icon: Icons.check_circle,
                                  color: Colors.purple,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ExamStatsCard(
                                  title: 'Average Score',
                                  value: averageScore,
                                  icon: Icons.emoji_events,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // --- Exam Papers List Section (Live Data) ---
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver:
                        filteredPapers.isEmpty
                        ? SliverToBoxAdapter(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 40.0),
                                child: Text(
                                  'No papers in this category.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildListDelegate(paperCards),
                          ),
                  ),

                  const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
                ],
              );
// <<UI Code Ends
            }

            // --------------------------------------------------------------
            // Fallback: Old AssignmentsLoaded State (for backward compatibility)
            // --------------------------------------------------------------
            if (state is AssignmentsLoaded) {
              final List<ExamPaperCardModel> papers = state.papers;

              final List<Widget> paperCards = papers.map((paper) {
                return ExamPaperCard(paper: paper, currentTab: 'all');
              }).toList();

              // Stats Calculations (Same Mock Logic for Live Data)
              final int availablePapers = papers.length;
              final int activePapers = papers
                  .where((p) => p.isAvailableToStart && !p.isCompleted)
                  .length;
              final int completedPapers = papers
                  .where((p) => p.isCompleted)
                  .length;

              final completedScores = papers
                  .where(
                    (p) => p.isCompleted && p.studentScorePercentage != null,
                  )
                  .map((p) {
                    final scoreString = p.studentScorePercentage!.replaceAll(
                      '%',
                      '',
                    );
                    return int.tryParse(scoreString) ?? 0;
                  })
                  .toList();

              final String averageScore = completedScores.isNotEmpty
                  ? '${(completedScores.reduce((a, b) => a + b) / completedScores.length).round()}%'
                  : '0%';

              // ⭐️ CustomScrollView (UI)
              return CustomScrollView(
                slivers: [
                  const CustomAppBar(),

                  // --- Header Section (Title, Button, Search) ---
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.lightBackground,
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
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.assignment,
                                  color: Colors.blue,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Flexible(
                                child: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Examination Hub',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Access your ICT A-Level examination papers',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.lightPrimary,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Navigate to results screen
                                context.pushNamed(
                                  'results',
                                  pathParameters: {'resultId': 'current'},
                                );
                              },
                              icon: const Icon(
                                Icons.emoji_events,
                                size: 18,
                                color: AppColors.lightBackground,
                              ),
                              label: const Text(
                                'My Results',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // My Results Button
                          // Search Bar
                          TextField(
                            decoration: InputDecoration(
                              hintText: 'Search papers...',
                              hintStyle: TextStyle(
                                color: AppColors.lightRing,
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: AppColors.lightRing,
                              ),
                              filled: true,
                              fillColor: AppColors.lightBackground,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.lightRing,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.lightBorder,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.blue,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // --- Stats Cards Section (Live Data) ---
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: ExamStatsCard(
                                  title: 'Available Papers',
                                  value: availablePapers.toString(),
                                  icon: Icons.assignment,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ExamStatsCard(
                                  title: 'Active Papers',
                                  value: activePapers.toString(),
                                  icon: Icons.access_time,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ExamStatsCard(
                                  title: 'Completed',
                                  value: completedPapers.toString(),
                                  icon: Icons.check_circle,
                                  color: Colors.purple,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ExamStatsCard(
                                  title: 'Average Score',
                                  value: averageScore,
                                  icon: Icons.emoji_events,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // --- Exam Papers List Section (Live Data) ---
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver:
                        papers
                            .isEmpty // Check if papers list is empty here
                        ? SliverToBoxAdapter(
                            // If empty, display text in SliverToBoxAdapter
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 40.0,
                                ),
                                child: Text(
                                  'No Exam Papers.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : SliverList(
                            // If papers exist, display list as usual
                            delegate: SliverChildListDelegate(paperCards),
                          ),
                  ),

                  const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
                ],
              );
            }

            // 4. Default Case (No papers/Initial state when not loading)
            return const Center(child: Text('No Exam Papers.'));
          },
        ),
      ),
    );
  }
}
