import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

// --- Adjust these import paths ---
import 'package:lms_app/core/repositories/auth_repository.dart';
import 'package:lms_app/logic/result/results_cubit.dart';
import 'package:lms_app/widgets/result_screen/result_card.dart';
import 'package:lms_app/widgets/result_screen/result_stat_card.dart';
import 'package:lms_app/screens/assignment/see_answers_screen.dart'; // Keep for context, though navigation is via GoRouter
// ---------------------------------

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({Key? key}) : super(key: key);

  // --- UI Utility Methods ---
  String _formatTime(double timeInSeconds) {
    final minutes = timeInSeconds ~/ 60;
    final seconds = (timeInSeconds % 60).toInt();
    return minutes > 0 ? '$minutes min $seconds sec' : '$seconds sec';
  }
  String _formatDate(String? iso) {
    if (iso == null) return '-';
    try {
      final dt = DateTime.parse(iso);
      return DateFormat('MMM d, yyyy, h:mm a').format(dt);
    } catch (_) {
      return iso;
    }
  }

  String _getLastUpdatedText(DateTime? lastUpdated, bool isLoading) {
    if (lastUpdated == null) return isLoading ? 'Loading...' : 'Not loaded yet';
    final diff = DateTime.now().difference(lastUpdated);

    if (diff.inSeconds < 60) {
      return 'Updated ${diff.inSeconds}s ago';
    } else if (diff.inMinutes < 60) {
      return 'Updated ${diff.inMinutes}m ago';
    } else {
      return 'Updated ${diff.inHours}h ago';
    }
  }

  // **********************************************
  // ** CORRECTED: Use GoRouter for navigation **
  // **********************************************
  // void _navigateToReviewScreen(
  //   BuildContext context,
  //   Map<String, dynamic> attempt,
  // ) {
  //   // Determine the paperId for the path
  //   final paperId = attempt['paperId'] is Map
  //       ? (attempt['paperId'] as Map)['_id']?.toString() ?? ''
  //       : attempt['paperId']?.toString() ?? '';

  //   if (paperId.isNotEmpty) {
  //     context.goNamed(
  //       'see-answers',
  //       pathParameters: {'paperId': paperId},
  //       extra: attempt, // Pass the entire attempt map via 'extra'
  //     );
  //   } else {
  //     // Handle the case where paperId could not be determined
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Cannot review: Paper ID not found.')),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    // Inject the Cubit at the top level of the screen
    return BlocProvider(
      // The Cubit will automatically start fetching data when created
      create: (context) => ResultsCubit(AuthRepository()),
      child: BlocConsumer<ResultsCubit, ResultsState>(
        // Listen for errors and show a Snackbar
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        builder: (context, state) {
          final cubit = context.read<ResultsCubit>();

          return Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            body: RefreshIndicator(
              // Call the Cubit's refresh method
              onRefresh: () => cubit.fetchResults(),
              color: Colors.green,
              child: SafeArea(
                child: CustomScrollView(
                  slivers: [
                    // --- AppBar ---
                    SliverAppBar(
                      floating: true,
                      backgroundColor: Colors.white,
                      elevation: 0,
                      leading: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.black87,
                        ),
                        onPressed: () => context.go('/mainscreen', extra: 2),
                      ),
                      title: const Text(
                        'My Results',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      actions: [
                        // Show polling indicator
                        if (state.isPolling)
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.green[600]!,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),

                    // --- Header/Stat Update Time ---
                    SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          // boxShadow: [/* ... */], // Commented out to reduce clutter
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ... (other header content)
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(
                                  Icons.sync,
                                  size: 14,
                                  color: Colors.grey[500],
                                ),
                                const SizedBox(width: 6),
                                // Display update time using state
                                Text(
                                  _getLastUpdatedText(
                                    state.lastUpdated,
                                    state.isLoading,
                                  ),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // --- Stat Cards (Using calculated state properties) ---
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: ResultStatCard(
                                    title: 'Papers Completed',
                                    value: state.papersCompleted.toString(),
                                    icon: Icons.assignment,
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ResultStatCard(
                                    title: 'Average Score',
                                    value: '${state.averageScore}%',
                                    icon: Icons.trending_up,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ResultStatCard(
                              title: 'Best Score',
                              value: '${state.bestScore}%',
                              icon: Icons.emoji_events,
                              color: Colors.purple,
                              showTrophy: true,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // --- Results List ---
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      // Show loading spinner if initially loading and no results
                      sliver: state.isLoading && state.results.isEmpty
                          ? const SliverToBoxAdapter(
                              child: SizedBox(
                                height: 200,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            )
                          // Show "No results" if list is empty
                          : (state.results.isEmpty
                                ? const SliverToBoxAdapter(
                                    child: Padding(
                                      padding: EdgeInsets.all(24.0),
                                      child: Center(
                                        child: Text('No results yet.'),
                                      ),
                                    ),
                                  )
                                // Build the list using state.results
                                : SliverList(
                                    delegate: SliverChildBuilderDelegate((
                                      context,
                                      index,
                                    ) {
                                      final attempt = state.results[index];

                                      final paper = attempt['paperId'];
                                      final paperIdStr = paper is Map
                                          ? (paper['_id']?.toString() ??
                                                '') // Assuming _id is the unique identifier
                                          : (attempt['paperId']?.toString() ??
                                                '');
                                      final title = paper is Map
                                          ? (paper['title'] ?? 'Untitled')
                                          : (attempt['paperTitle'] ??
                                                'Untitled');

                                      final submittedAt =
                                          attempt['submittedAt'] ??
                                          attempt['createdAt'];
                                      final submittedDateStr = _formatDate(
                                        submittedAt?.toString(),
                                      );

                                      final percentageNum =
                                          (attempt['percentage'] ?? 0) as num;

                                      // Use Cubit's utility methods
                                      // NOTE: ResultsCubit is not provided, assuming these methods exist
                                      final cubit = context
                                          .read<ResultsCubit>();
                                      final grade = cubit.gradeFromPercentage(
                                        percentageNum,
                                      );
                                      final gradeColor = cubit.gradeColor(
                                        grade,
                                      );

                                      return Column(
                                        children: [
                                          ResultCard(
                                            title: title,
                                            description: paper is Map
                                                ? (paper['description'] ?? '')
                                                : (attempt['paperDescription'] ??
                                                      ''),
                                            submittedDate: submittedDateStr,
                                            score:
                                                '${attempt['score'] ?? 0}/${attempt['totalQuestions'] ?? 0}',
                                            percentage:
                                                '${percentageNum.toString()}%',
                                            timeSpent: _formatTime((attempt['timeSpent'] ?? 0).toDouble()),
                                            questions:
                                                attempt['totalQuestions'] ?? 0,
                                            grade: grade,
                                            gradeColor: gradeColor,
                                            progressValue:
                                                (percentageNum.toDouble() /
                                                        100.0)
                                                    .clamp(0.0, 1.0),
                                            attempt: attempt,
                                            paperId: paperIdStr,
                                            showTrophy: percentageNum >= 90,
                                            showFailIcon: percentageNum < 40,
                                          ),
                                          const SizedBox(height: 16),
                                        ],
                                      );
                                    }, childCount: state.results.length),
                                  )),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
