import 'package:lms_app/models/exam_paper_card_model.dart';

// ----------------------------------------------------------------------
// A. Abstract State
// ----------------------------------------------------------------------

/// Assignments Cubit එකේ සියලුම States සඳහා පොදු මව් class එක
abstract class AssignmentsState {}

// ----------------------------------------------------------------------
// B. Concrete States
// ----------------------------------------------------------------------

/// Initial state
class AssignmentsInitial extends AssignmentsState {}

/// Data loading
class AssignmentsLoading extends AssignmentsState {}

/// Data loaded successfully (Home Screen එකට අවශ්‍ය ExamPaperCard List එක)
class AssignmentsLoaded extends AssignmentsState {
  final List<ExamPaperCardModel> papers;
  AssignmentsLoaded(this.papers);
}

/// Error occurred while loading data
class AssignmentsError extends AssignmentsState {
  final String message;
  AssignmentsError(this.message);
}