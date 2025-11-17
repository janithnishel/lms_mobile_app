// import 'package:flutter/material.dart';
// import 'package:lms_app/widgets/see_answer_screen/answer_option.dart';
// import 'package:lms_app/widgets/see_answer_screen/question_navigator_drawer.dart';

// /// Single clean SeeAnswersScreen implementation.
// class SeeAnswersScreen extends StatefulWidget {
//   final Map<String, dynamic>? attempt;
//   final String? paperId;

//   const SeeAnswersScreen({Key? key, this.attempt, this.paperId}) : super(key: key);

//   @override
//   State<SeeAnswersScreen> createState() => _SeeAnswersScreenState();
// }

// class _SeeAnswersScreenState extends State<SeeAnswersScreen> {
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//   int currentQuestion = 0;

//   @override
//   Widget build(BuildContext context) {
//     final attempt = widget.attempt ?? <String, dynamic>{};

//     final scoreText = '${attempt['score'] ?? 0}/${attempt['totalQuestions'] ?? 0}';
//     final percentageText = '${attempt['percentage'] ?? 0}%';
//     final timeUsedText = '${attempt['timeSpent'] ?? 0} min';

//     final paperObj = attempt['paperId'] ?? attempt['paper'] ?? <String, dynamic>{};
//     final String paperTitle = paperObj is Map ? (paperObj['title'] ?? attempt['paperTitle'] ?? '') : (attempt['paperTitle'] ?? '');
//     final String paperDescription = paperObj is Map ? (paperObj['description'] ?? attempt['paperDescription'] ?? '') : (attempt['paperDescription'] ?? '');

//     List<dynamic> questionsList = [];
//     if (attempt['questions'] is List) {
//       questionsList = List.from(attempt['questions']);
//     } else if (paperObj is Map && paperObj['questions'] is List) {
//       questionsList = List.from(paperObj['questions']);
//     }

//     final List<dynamic> answersList = attempt['answers'] is List
//         ? List.from(attempt['answers'])
//         : (attempt['userAnswers'] is List ? List.from(attempt['userAnswers']) : <dynamic>[]);

//     Map<String, dynamic>? findAnswerForQuestion(dynamic question, int qIndex) {
//       if (answersList.isEmpty) return null;
//       final qId = (question is Map) ? (question['id'] ?? question['_id'] ?? question['questionId']) : null;
//       if (qId != null) {
//         for (var a in answersList) {
//           if (a is Map) {
//             final aid = a['questionId'] ?? a['question'] ?? a['qId'];
//             if (aid != null && aid == qId) return Map<String, dynamic>.from(a);
//           }
//         }
//       }
//       if (qIndex < answersList.length && answersList[qIndex] is Map) return Map<String, dynamic>.from(answersList[qIndex]);
//       return null;
//     }

//     String questionText(dynamic q) {
//       if (q == null) return '';
//       if (q is Map) return (q['text'] ?? q['question'] ?? q['title'] ?? '').toString();
//       return q.toString();
//     }

//     List<Map<String, dynamic>> optionsForQuestion(dynamic q) {
//       final List<Map<String, dynamic>> opts = [];
//       if (q is! Map) return opts;
//       final raw = q['options'] ?? q['choices'] ?? q['answers'];
//       if (raw is List) {
//         var labelCode = 'A'.codeUnitAt(0);
//         for (var opt in raw) {
//           String text = '';
//           bool isCorrect = false;
//           if (opt is Map) {
//             text = (opt['text'] ?? opt['content'] ?? opt['label'] ?? '').toString();
//             isCorrect = (opt['isCorrect'] == true) || (opt['correct'] == true);
//             if (opt['label'] != null) {
//               opts.add({'label': opt['label'].toString(), 'text': text, 'isCorrect': isCorrect});
//               continue;
//             }
//           } else {
//             text = opt.toString();
//           }
//           final label = String.fromCharCode(labelCode);
//           opts.add({'label': label, 'text': text, 'isCorrect': isCorrect});
//           labelCode++;
//         }
//       }
//       return opts;
//     }

//     return Scaffold(
//       key: _scaffoldKey,
//       backgroundColor: const Color(0xFFF5F5F5),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 1,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black87),
//           onPressed: () => Navigator.maybePop(context),
//         ),
//         title: const Text('Review Answers', style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w600)),
//         actions: [
//           IconButton(icon: const Icon(Icons.menu, color: Colors.black87), onPressed: () => _scaffoldKey.currentState?.openEndDrawer()),
//         ],
//       ),
//       endDrawer: QuestionNavigatorDrawer(
//         currentQuestion: currentQuestion,
//         totalQuestions: questionsList.isEmpty ? 1 : questionsList.length,
//         onQuestionTap: (index) {
//           setState(() => currentQuestion = index);
//           Navigator.pop(context);
//         },
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             const SizedBox(height: 16),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                 Text(paperTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
//                 const SizedBox(height: 6),
//                 if (paperDescription.isNotEmpty) Text(paperDescription, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
//               ]),
//             ),
//             const SizedBox(height: 12),

//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
//                 child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//                   Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                     Row(children: [
//                       const Text('Score: ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87)),
//                       Text(scoreText, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.blue)),
//                       const SizedBox(width: 16),
//                       const Text('Percentage: ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87)),
//                       Text(percentageText, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.blue)),
//                     ]),
//                     const SizedBox(height: 8),
//                     Text('Time Used: $timeUsedText', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
//                   ]),
//                   OutlinedButton(onPressed: () => Navigator.maybePop(context), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), side: BorderSide(color: Colors.grey[400]!), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text('Back to Results', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)))
//                 ]),
//               ),
//             ),
//             const SizedBox(height: 20),

//             if (questionsList.isEmpty) ...[
//               Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[300]!), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))]), child: const Text('No questions available for this attempt.', style: TextStyle(color: Colors.grey)))),
//               const SizedBox(height: 20),
//             ] else ...[
//               for (var entry in questionsList.asMap().entries) ...[
//                 (() {
//                   final qIndex = entry.key;
//                   final q = entry.value;
//                   final qText = questionText(q);
//                   final opts = optionsForQuestion(q);
//                   final userAns = findAnswerForQuestion(q, qIndex);
//                   String? userSelected;
//                   if (userAns != null) {
//                     userSelected = (userAns['selected'] ?? userAns['answer'] ?? userAns['option'] ?? userAns['label'])?.toString();
//                   }

//                   return Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     child: Container(
//                       padding: const EdgeInsets.all(24),
//                       decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[300]!), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))]),
//                       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                         Row(children: [
//                           Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(20)), child: Center(child: Text('${qIndex + 1}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1976D2))))),
//                           const SizedBox(width: 16),
//                           Expanded(child: Text(qText, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87))),
//                         ]),
//                         const SizedBox(height: 24),
//                         for (var o in opts) ...[
//                           AnswerOption(label: (o['label'] ?? '').toString(), text: (o['text'] ?? '').toString(), isCorrect: (o['isCorrect'] == true), isUserAnswer: userSelected != null && ((userSelected == o['label']) || (userSelected == o['text']))),
//                           const SizedBox(height: 12),
//                         ],
//                         if ((q is Map) && (q['explanation'] != null)) ...[
//                           const SizedBox(height: 8),
//                           Text('Explanation', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.grey[800])),
//                           const SizedBox(height: 6),
//                           Text(q['explanation'].toString(), style: TextStyle(fontSize: 14, color: Colors.grey[700])),
//                         ],
//                       ]),
//                     ),
//                   );
//                 })(),
//                 const SizedBox(height: 20),
//               ],
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }

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

// 🚀 SeeAnswersScreen: Now StatelessWidget
class SeeAnswersScreen extends StatelessWidget {
  final Map<String, dynamic> attemptData;
  final String paperTitle;
  final String paperId;

  const SeeAnswersScreen({
    Key? key,
    required this.attemptData,
    required this.paperTitle,
    required this.paperId,
  }) : super(key: key);

  @override
  // Cubit Provider: Initializes the cubit and loads data once.
  Widget build(BuildContext context) {
    // Extract attempt ID from attemptData for /papers/{attemptId}/review endpoint
    // Try multiple possible field names for the ID
    final String attemptId = (attemptData['_id'] as String?) ??
                             (attemptData['id'] as String?) ??
                             '';

    debugPrint('SeeAnswersScreen - attemptData keys: ${attemptData.keys.toList()}');
    debugPrint('SeeAnswersScreen - attemptData: $attemptData');
    debugPrint('SeeAnswersScreen - extracted attemptId: $attemptId');
    debugPrint('SeeAnswersScreen - paperId: $paperId');

    // Validate attemptId format (MongoDB ObjectIds are 24 hex characters)
    if (attemptId.isEmpty) {
      debugPrint('ERROR: Attempt ID is empty');
      return const Scaffold(
        body: Center(child: Text('Error: Attempt ID not found in attempt data.\nPlease refresh your results and try again.')),
      );
    }

    // MongoDB ObjectId validation (24 hex characters)
    final RegExp objectIdRegex = RegExp(r'^[0-9a-fA-F]{24}$');
    if (!objectIdRegex.hasMatch(attemptId)) {
      debugPrint('ERROR: Invalid attemptId format: $attemptId');
      return Scaffold(
        body: Center(child: Text('Error: Invalid attempt ID format.\nID: $attemptId\nPlease contact support.')),
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
          attemptData,
          paperTitle,
          attemptId, // Use attemptData['_id'] for /attempts/{id}/review endpoint
        );

        return cubit;
      },
      child: _SeeAnswersView(paperTitle: paperTitle),
    );
  }
}

//  The actual UI is built in this view, reacting to state changes.
class _SeeAnswersView extends StatelessWidget {
  final String paperTitle;
  const _SeeAnswersView({required this.paperTitle});

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
        title: Text(
          paperTitle,
          style: const TextStyle(
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
              questions: state.questions, // Pass questions data for explanation indicators
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

            return SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // 1. Review Info Banner
                  const ReviewInfoBanner(),
                  const SizedBox(height: 16),

                  // 2. Score Summary Card
                  ScoreSummaryCard(
                    score: summary.score,
                    total: summary.totalQuestions,
                    percentage: summary.percentage,
                    timeSpent: summary.timeSpent,
                    onBackToResults: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/mainscreen');
                      }
                    },
                  ),
                  const SizedBox(height: 20),

                  // 3. Question Display Card (Uses data from Cubit)
                  QuestionDisplayCard(
                    questionIndex: currentQuestionIndex,
                    questionText: currentQuestionData.questionText,
                    imageUrl: currentQuestionData.imageUrl,
                    explanation: currentQuestionData.explanation,
                    visualExplanationUrl: currentQuestionData.visualExplanationUrl,
                    options: currentQuestionData.options,
                    correctAnswerIndex: currentQuestionData.correctAnswerIndex,
                    userAnswerIndex: currentQuestionData.userAnswerIndex,
                  ),

                  // 4. Detailed Explanation Block
                  ExplanationExpansionTile(
                    explanation: currentQuestionData.explanation,
                    visualExplanationUrl:
                        currentQuestionData.visualExplanationUrl,
                  ),

                  // 5. Navigation Buttons (Calls cubit to change index)
                  QuestionNavigationFooter(
                    currentQuestionIndex: currentQuestionIndex,
                    totalQuestions: totalQuestions,
                    onPrevious: currentQuestionIndex > 0
                        ? () => cubit.goToQuestion(currentQuestionIndex - 1)
                        : null,
                    onNext: currentQuestionIndex < totalQuestions - 1
                        ? () => cubit.goToQuestion(currentQuestionIndex + 1)
                        : null,
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
