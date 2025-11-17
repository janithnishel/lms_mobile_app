// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:lms_app/models/see_answers_model';
// // Note: Adjust import paths based on your actual structure (e.g., using package:lms_app/...)
// import 'see_answers_state.dart';

// class SeeAnswersCubit extends Cubit<SeeAnswersState> {
//   SeeAnswersCubit() : super(SeeAnswersInitial());

//   String _formatTime(num timeInSeconds) {
//     final minutes = (timeInSeconds.toInt() / 60).floor();
//     final seconds = timeInSeconds.toInt() % 60;
//     return minutes > 0 ? '$minutes min $seconds sec' : '$seconds sec';
//   }

//   void loadAnswers(Map<String, dynamic> attemptData, String paperTitle) {
//     emit(SeeAnswersLoading());

//     // 1. **SHINY FIX: Implement robust question fetching logic**
//     List<dynamic> questionsRaw =
//         attemptData['questions'] as List<dynamic>? ?? [];

//     // Check for questions within the 'paper' object if 'questions' is empty in the attempt.
//     if (questionsRaw.isEmpty) {
//       final paperObj =
//           attemptData['paperId'] ?? attemptData['paper'] ?? <String, dynamic>{};
//       if (paperObj is Map && paperObj['questions'] is List) {
//         questionsRaw = List.from(paperObj['questions']);
//       }
//     }
//     // END SHINY FIX

//     if (questionsRaw.isEmpty) {
//       emit(const SeeAnswersError('No questions found for this attempt.'));
//       return;
//     }

//     try {
//       // 2. Attempt Summary Parse (Same as before)
//       final score = attemptData['score'] as int? ?? 0;
//       final total = attemptData['totalQuestions'] as int? ?? 0;
//       final timeSpentRaw = attemptData['timeSpent'] as num? ?? 0;
//       final percentage = total > 0 ? (score / total) * 100 : 0.0;

//       final summary = AttemptSummary(
//         score: score,
//         totalQuestions: total,
//         percentage: percentage,
//         timeSpent: _formatTime(timeSpentRaw),
//       );

//       // 3. Paper Details (Fetch description using fallback logic)
//       final paperObj =
//           attemptData['paperId'] ?? attemptData['paper'] ?? <String, dynamic>{};
//       final String paperDescription = paperObj is Map
//           ? (paperObj['description'] ?? attemptData['paperDescription'] ?? '')
//           : (attemptData['paperDescription'] ?? '');

//       final paperDetails = PaperDetails(
//         title: paperTitle,
//         description: paperDescription,
//       );

//       // 4. Questions Parsing
//       final List<QuestionData>
//       questionDataList = questionsRaw.asMap().entries.map((entry) {
//         final qIndex = entry.key;
//         final q = entry.value;

//         final qMap = q is Map ? q : <String, dynamic>{};

//         // **Note:** Your new model expects questions to have 'questionText', 'options', etc.
//         // If your database uses the *old format* (Question data in one place, answers in 'answers' array),
//         // you might need a much more complex mapping function here, similar to the one commented out in your old screen code.

//         // For now, let's assume the question data (including user answer) is merged into qMap:

//         // --- If using the structure from the old StatefulWidget ---
//         // This is complex, but required if data isn't pre-processed.

//         String questionText(dynamic q) {
//           if (q == null) return '';
//           if (q is Map) {
//             return (q['text'] ??
//                     q['question'] ??
//                     q['title'] ??
//                     q['questionText'] ??
//                     '')
//                 .toString();
//           }
//           return q.toString();
//         }

//         // Temporary placeholders if full data mapping is not yet done in the API/backend
//         final correctAnsIndex = qMap['correctAnswerIndex'] is num
//             ? qMap['correctAnswerIndex'].toInt()
//             : -1;
//         final userAnsIndex = qMap['userAnswerIndex'] is num
//             ? qMap['userAnswerIndex'].toInt()
//             : -2;

//         return QuestionData(
//           questionText: questionText(q),
//           options: qMap['options'] as List<dynamic>? ?? [],
//           correctAnswerIndex: correctAnsIndex,
//           userAnswerIndex: userAnsIndex,
//           explanation: qMap['explanation'] as String?,
//           visualExplanationUrl: qMap['visualExplanation'] as String?,
//         );
//       }).toList();

//       // 5. Emit Loaded State
//       emit(
//         SeeAnswersLoaded(
//           paperDetails: paperDetails,
//           summary: summary,
//           questions: questionDataList,
//           currentQuestionIndex: 0,
//         ),
//       );
//     } catch (e) {
//       emit(SeeAnswersError('දත්ත සැකසීමේදී දෝෂයක් ඇති විය: ${e.toString()}'));
//     }
//   }

//   void goToQuestion(int index) {
//     if (state is SeeAnswersLoaded) {
//       final currentState = state as SeeAnswersLoaded;
//       if (index >= 0 && index < currentState.questions.length) {
//         emit(currentState.copyWith(currentQuestionIndex: index));
//       }
//     }
//   }
// }
// lib/application/see_answers/see_answers_cubit.dart

// lib/application/see_answers/see_answers_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_app/core/repositories/see_answers_repository.dart';
import 'package:lms_app/models/see_answers_model.dart';
// Import Repository Class
import 'see_answers_state.dart';

class SeeAnswersCubit extends Cubit<SeeAnswersState> {
  // Repository Injection
  final SeeAnswersRepository _repository;

  SeeAnswersCubit(this._repository) : super(SeeAnswersInitial());

  String _formatTime(num timeInSeconds) {
    final minutes = (timeInSeconds.toInt() / 60).floor();
    final seconds = timeInSeconds.toInt() % 60;
    return minutes > 0 ? '$minutes min $seconds sec' : '$seconds sec';
  }

  /// Loads all review data (summary, questions, paper details) by calling the Repository.
  void loadAnswers(
    Map<String, dynamic> attemptData,
    String paperTitle,
    String attemptId,
  ) async {
    emit(SeeAnswersLoading());

    try {
      // Get review data using attemptId for the /attempts/{attemptId}/review endpoint
      final ReviewData reviewData = await _repository.getReviewData(
        attemptId: attemptId, // Using attemptId for /attempts endpoint
        localAttemptData: attemptData,
        paperTitle: paperTitle,
      );

      // Emit Loaded State
      emit(
        SeeAnswersLoaded(
          paperDetails: reviewData.paperDetails,
          summary: reviewData.summary,
          questions: reviewData.questions,
          currentQuestionIndex: 0,
        ),
      );
    } on Exception catch (e) {
      // Errors from Repository/Service layer are handled here
      emit(
        SeeAnswersError(
          'Error occurred while retrieving or preparing data: ${e.toString()}',
        ),
      );
    }
  }

  void goToQuestion(int index) {
    if (state is SeeAnswersLoaded) {
      final currentState = state as SeeAnswersLoaded;
      if (index >= 0 && index < currentState.questions.length) {
        emit(currentState.copyWith(currentQuestionIndex: index));
      }
    }
  }
}
