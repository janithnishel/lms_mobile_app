import 'package:lms_app/models/paper_intro_details_model.dart';

// ----------------------------------------------------------------------
// A. Abstract State
// ----------------------------------------------------------------------

/// Paper Instruction Cubit එකේ සියලුම States සඳහා පොදු මව් class එක
abstract class PaperInstructionState {}

// ----------------------------------------------------------------------
// B. Concrete States
// ----------------------------------------------------------------------

/// Initial state
class PaperInstructionInitial extends PaperInstructionState {}

/// Data loading
class PaperInstructionLoading extends PaperInstructionState {}

/// Data loaded successfully
class PaperInstructionLoaded extends PaperInstructionState {
  final PaperIntroDetailsModel details;
  PaperInstructionLoaded(this.details);
}

/// Error occurred while loading data
class PaperInstructionError extends PaperInstructionState {
  final String message;
  PaperInstructionError(this.message);
}
