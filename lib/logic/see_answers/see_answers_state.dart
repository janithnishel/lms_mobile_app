import 'package:equatable/equatable.dart';
import 'package:lms_app/models/see_answers_model.dart';


abstract class SeeAnswersState extends Equatable {
  const SeeAnswersState();
  @override
  List<Object> get props => [];
}

class SeeAnswersInitial extends SeeAnswersState {}

class SeeAnswersLoading extends SeeAnswersState {}

class SeeAnswersLoaded extends SeeAnswersState {
  final PaperDetails paperDetails;
  final AttemptSummary summary;
  final List<QuestionData> questions; // Updated to QuestionData
  final int currentQuestionIndex;

  const SeeAnswersLoaded({
    required this.paperDetails,
    required this.summary,
    required this.questions,
    this.currentQuestionIndex = 0,
  });

  SeeAnswersLoaded copyWith({
    PaperDetails? paperDetails,
    AttemptSummary? summary,
    List<QuestionData>? questions,
    int? currentQuestionIndex,
  }) {
    return SeeAnswersLoaded(
      paperDetails: paperDetails ?? this.paperDetails,
      summary: summary ?? this.summary,
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
    );
  }

  @override
  List<Object> get props => [
    paperDetails,
    summary,
    questions,
    currentQuestionIndex,
  ];
}

class SeeAnswersError extends SeeAnswersState {
  final String message;
  const SeeAnswersError(this.message);
  @override
  List<Object> get props => [message];
}
