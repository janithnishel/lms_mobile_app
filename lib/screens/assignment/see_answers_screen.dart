import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_app/core/repositories/see_answers_repository.dart';
import 'package:lms_app/logic/see_answers/see_answers_cubit.dart';
import 'package:lms_app/logic/see_answers/see_answers_state.dart';
// BLoC/Cubit Imports

// New Reusable Widgets
import 'package:lms_app/widgets/see_answer_screen/review_info_banner.dart';
import 'package:lms_app/widgets/see_answer_screen/score_summary_card.dart';
import 'package:lms_app/widgets/see_answer_screen/question_display_card.dart';
import 'package:lms_app/widgets/see_answer_screen/explanation_expansion_tile.dart';
import 'package:lms_app/widgets/see_answer_screen/question_navigation_footer.dart';
// Existing Widgets
import 'package:lms_app/widgets/see_answer_screen/question_navigator_drawer.dart';

// 🚀 SeeAnswersScreen: Now StatelessWidget with multiple constructors
class SeeAnswersScreen extends StatelessWidget {
  final Map<String, dynamic>? attemptData;
  final String? paperTitle;
  final String paperId;

  // Constructor when we have full attempt data (legacy support)
  const SeeAnswersScreen({
    Key? key,
    required this.attemptData,
    required this.paperTitle,
    required this.paperId,
  }) : super(key: key);

  // Constructor when we only have paperId - screen will fetch attempt data itself
  const SeeAnswersScreen.fromPaperId({
    Key? key,
    required this.paperId,
  }) : attemptData = null,
       paperTitle = null,
       super(key: key);

  // Constructor when we have paperId and want to show actual paper title
  const SeeAnswersScreen.fromPaperIdWithTitle({
    Key? key,
    required this.paperId,
    required this.paperTitle,
  }) : attemptData = null,
       super(key: key);

  @override
  // Cubit Provider: Initializes the cubit and loads data once.
  Widget build(BuildContext context) {
    // If we only have paperId, create a placeholder screen that fetches data
    if (attemptData == null) {
      return BlocProvider(
        create: (context) {
          final repository = context.read<SeeAnswersRepository>();
          final cubit = SeeAnswersCubit(repository);

          // Load the attempt data by paperId
          cubit.loadAttemptDataByPaperId(paperId);

          return cubit;
        },
        child: _SeeAnswersView(paperTitle:paperTitle??'Review Answers', attemptData: const {}),
      );
    }

    // Extract attempt ID from attemptData for /papers/{attemptId}/review endpoint
    // Try multiple possible field names for the ID
    final String attemptId =
        (attemptData!['_id'] as String?) ?? (attemptData!['id'] as String?) ?? '';

    debugPrint(
      'SeeAnswersScreen - attemptData keys: ${attemptData!.keys.toList()}',
    );
    debugPrint('SeeAnswersScreen - attemptData: $attemptData');
    debugPrint('SeeAnswersScreen - extracted attemptId: $attemptId');
    debugPrint('SeeAnswersScreen - paperId: $paperId');

    // Validate attemptId format (MongoDB ObjectIds are 24 hex characters)
    if (attemptId.isEmpty) {
      debugPrint('ERROR: Attempt ID is empty');
      return const Scaffold(
        body: Center(
          child: Text(
            'Error: Attempt ID not found in attempt data.\nPlease refresh your results and try again.',
          ),
        ),
      );
    }

    // MongoDB ObjectId validation (24 hex characters)
    final RegExp objectIdRegex = RegExp(r'^[0-9a-fA-F]{24}$');
    if (!objectIdRegex.hasMatch(attemptId)) {
      debugPrint('ERROR: Invalid attemptId format: $attemptId');
      return Scaffold(
        body: Center(
          child: Text(
            'Error: Invalid attempt ID format.\nID: $attemptId\nPlease contact support.',
          ),
        ),
      );
    }

    debugPrint('DEBUG: Attempt ID validation passed: $attemptId');

    // Cubit Provider: Initializes the cubit and loads data once.
    return BlocProvider(
      create: (context) {
        // Repository එක දැන් ඉහළින් Provider කර ඇති නිසා, read() ක්‍රියාත්මක වේ.
        final repository = context.read<SeeAnswersRepository>();

        final cubit = SeeAnswersCubit(repository);

        // Use attemptId for the /attempts/{attemptId}/review endpoint
        cubit.loadAnswers(
          attemptData!,
          paperTitle ?? 'Review Answers',
          attemptId, // Use attemptData['_id'] for /attempts/{id}/review endpoint
        );

        return cubit;
      },
      child: _SeeAnswersView(paperTitle: paperTitle ?? 'Review Answers', attemptData: attemptData!),
    );
  }
}

//  The actual UI is built in this view, reacting to state changes.
class _SeeAnswersView extends StatelessWidget {
  final String paperTitle;
  final Map<String, dynamic> attemptData;
  const _SeeAnswersView({required this.paperTitle, required this.attemptData});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SeeAnswersCubit>();
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              // If can't pop, navigate to home or results
              context.go('/mainscreen'); // or results page
            }
          },
        ),
        title: const Text(
          'My Answers',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          // Menu icon opens the endDrawer
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87),
            onPressed: () {
              scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
      ),

      // End Drawer uses BlocBuilder to get current question count
      endDrawer: BlocBuilder<SeeAnswersCubit, SeeAnswersState>(
        buildWhen: (previous, current) => current is SeeAnswersLoaded,
        builder: (context, state) {
          if (state is SeeAnswersLoaded) {
            return QuestionNavigatorDrawer(
              currentQuestion: state.currentQuestionIndex,
              totalQuestions: state.questions.length,
              onQuestionTap: (index) {
                cubit.goToQuestion(index);
                context.pop(); // Close drawer after tapping a question
              },
              questions: state
                  .questions, // Pass questions data for explanation indicators
            );
          }
          return const SizedBox.shrink(); // Show nothing while loading/error
        },
      ),

      // Body uses BlocBuilder to render the content based on state
      body: BlocBuilder<SeeAnswersCubit, SeeAnswersState>(
        builder: (context, state) {
          if (state is SeeAnswersLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SeeAnswersError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          if (state is SeeAnswersLoaded) {
            final currentQuestionIndex = state.currentQuestionIndex;
            final totalQuestions = state.questions.length;

            if (totalQuestions == 0) {
              return const Center(
                child: Text('No questions found for this attempt.'),
              );
            }

            final currentQuestionData = state.questions[currentQuestionIndex];
            final summary = state.summary;

            // Check if time remaining is less than 5 minutes (standard LMS behavior)
            // For demo purposes, show warning when there's time data
            final bool showTimeWarning = true; // Simplified for demo
            // Real logic: final bool showTimeWarning = (quizTimeLimit - int.parse(summary.timeSpent ?? '0')) <= 300;

            return SingleChildScrollView(
              child: AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeIn,
                child: AnimatedPadding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                  child: Column(
                    children: [
                      // 1. Review Info Banner with enhanced animation
                      AnimatedScale(
                        scale: 1.0,
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.elasticOut,
                        child: AnimatedOpacity(
                          opacity: 1.0,
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeIn,
                          child: const ReviewInfoBanner(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 2. Score Summary Card with slide-in
                      AnimatedSlide(
                        offset: Offset.zero,
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.elasticOut,
                        child: ScoreSummaryCard(
                          score: summary.score,
                          total: summary.totalQuestions,
                          percentage: summary.percentage,
                          timeSpent: summary.timeSpent,
                          onBackToResults: () {
                            // Extract result ID from attemptData to navigate to specific result
                            final String resultId = (attemptData['_id'] as String?) ??
                                                    (attemptData['id'] as String?) ??
                                                    (attemptData['resultId'] as String?) ?? 'default';
                            context.go('/results/$resultId');
                          },
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 3. Question Display Card with scale animation
                      AnimatedScale(
                        scale: 1.0,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.elasticOut,
                        child: QuestionDisplayCard(
                          questionIndex: currentQuestionIndex,
                          totalQuestions: totalQuestions,
                          questionText: currentQuestionData.questionText,
                          paperTitle: paperTitle,
                          imageUrl: currentQuestionData.imageUrl,
                          explanation: currentQuestionData.explanation,
                          visualExplanationUrl:
                              currentQuestionData.visualExplanationUrl,
                          options: currentQuestionData.options,
                          correctAnswerIndex:
                              currentQuestionData.correctAnswerIndex,
                          userAnswerIndex: currentQuestionData.userAnswerIndex,
                        ),
                      ),

                      // 4. Detailed Explanation Block with fade-in
                      AnimatedOpacity(
                        opacity: 1.0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                        child: ExplanationExpansionTile(
                          explanation: currentQuestionData.explanation,
                          visualExplanationUrl:
                              currentQuestionData.visualExplanationUrl,
                        ),
                      ),

                      // 5. Navigation Buttons with slide-up
                      AnimatedSlide(
                        offset: Offset.zero,
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOut,
                        child: QuestionNavigationFooter(
                          currentQuestionIndex: currentQuestionIndex,
                          totalQuestions: totalQuestions,
                          onPrevious: currentQuestionIndex > 0
                              ? () =>
                                    cubit.goToQuestion(currentQuestionIndex - 1)
                              : null,
                          onNext: currentQuestionIndex < totalQuestions - 1
                              ? () =>
                                    cubit.goToQuestion(currentQuestionIndex + 1)
                              : null,
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
