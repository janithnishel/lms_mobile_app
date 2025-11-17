import 'package:lms_app/models/exam_paper_model.dart';
import 'package:lms_app/models/quiz_models.dart';
// File containing models like QuizQuestion, QuizOption.

// ----------------------------------------------------------------------
// A. UserQuizState Model (User's state during Quiz)
// ----------------------------------------------------------------------
class UserQuizState {
  final List<QuizQuestion> questions;
  final Map<String, String?> userAnswers; // {'questionId': 'selectedOptionId'}
  final int timeRemainingSeconds;
  final int totalTimeSeconds;
  final int currentQuestionIndex;

  UserQuizState({
    required this.questions,
    required this.userAnswers,
    required this.timeRemainingSeconds,
    required this.totalTimeSeconds,
    this.currentQuestionIndex = 0,
  });

  UserQuizState copyWith({
    List<QuizQuestion>? questions,
    Map<String, String?>? userAnswers,
    int? timeRemainingSeconds,
    int? totalTimeSeconds,
    int? currentQuestionIndex,
  }) {
    return UserQuizState(
      questions: questions ?? this.questions,
      userAnswers: userAnswers ?? this.userAnswers,
      timeRemainingSeconds: timeRemainingSeconds ?? this.timeRemainingSeconds,
      totalTimeSeconds: totalTimeSeconds ?? this.totalTimeSeconds,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
    );
  }
}

// ----------------------------------------------------------------------
// B. Quiz States (Bloc States)
// ----------------------------------------------------------------------

/// Basic Abstract State
abstract class QuizState {}

/// When data is loading
class QuizLoading extends QuizState {}

/// When an error occurs
class QuizFailure extends QuizState {
  final String error;
  QuizFailure(this.error);
}

/// When the exam is active (with questions and answers)
class QuizActive extends QuizState {
  final ExamPaperModel paperDetails; // Basic exam details
  final UserQuizState userState;  // User's progress

  QuizActive({required this.paperDetails, required this.userState});

  QuizActive copyWith({
    ExamPaperModel? paperDetails,
    UserQuizState? userState,
  }) {
    return QuizActive(
      paperDetails: paperDetails ?? this.paperDetails,
      userState: userState ?? this.userState,
    );
  }
}

/// After the exam is successfully submitted (Submit)
class QuizSubmissionSuccess extends QuizState {
  final Map<String, dynamic> resultDetails;
  QuizSubmissionSuccess(this.resultDetails);
}
