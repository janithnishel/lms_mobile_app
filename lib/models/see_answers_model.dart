// lms_app/models/see_answers_model.dart

import 'package:equatable/equatable.dart';

// --- 1. Attempt Summary ---
class AttemptSummary extends Equatable {
  final int score;
  final int totalQuestions;
  final double percentage;
  final String timeSpent;

  const AttemptSummary({
    required this.score,
    required this.totalQuestions,
    required this.percentage,
    required this.timeSpent,
  });

  @override
  List<Object> get props => [score, totalQuestions, percentage, timeSpent];
}

// --- 2. Paper Details ---
class PaperDetails extends Equatable {
  final String title;
  final String description;

  const PaperDetails({required this.title, required this.description});

  @override
  List<Object> get props => [title, description];
}

// --- 3. Single Question Data ---
class QuestionData extends Equatable {
  final String questionText;
  final List<dynamic> options; 
  final int correctAnswerIndex;
  final int userAnswerIndex;
  final String? explanation;
  final String? visualExplanationUrl;

  const QuestionData({
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
    required this.userAnswerIndex,
    this.explanation,
    this.visualExplanationUrl,
  });

  @override
  List<Object?> get props => [
    questionText,
    options,
    correctAnswerIndex,
    userAnswerIndex,
    explanation,
    visualExplanationUrl
    ];
}

// --- 4. 🚀 REVIEW DATA MASTER MODEL (New addition) ---
/// This model combines all pieces of data required for the SeeAnswers screen.
class ReviewData extends Equatable {
  final PaperDetails paperDetails;
  final AttemptSummary summary;
  final List<QuestionData> questions;

  const ReviewData({
    required this.paperDetails,
    required this.summary,
    required this.questions,
  });

  @override
  List<Object> get props => [paperDetails, summary, questions];
}
