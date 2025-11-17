import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_app/core/services/quiz_repository.dart';
import 'package:lms_app/logic/assignments/assignments_state.dart'; // 🔑 අලුත් State file එක Import කරයි

// ----------------------------------------------------------------------
// Cubit
// ----------------------------------------------------------------------
class AssignmentsCubit extends Cubit<AssignmentsState> {
  final QuizRepository _repository;

  // Constructor එකේදී Repository එක ලබාගෙන Initial State එකට යවයි.
  AssignmentsCubit(this._repository) : super(AssignmentsInitial());

  /// Assignments List එක Backend එකෙන් ලබා ගනියි.
  Future<void> loadAssignments() async {
    // 1. Loading State එකට මාරු කරයි.
    emit(AssignmentsLoading());
    try {
      // 2. Repository හරහා Backend එකෙන් දත්ත ලබා ගනියි.
      final papers = await _repository.fetchAllExamPapers();

      // 3. සාර්ථකව Load වූ State එකට මාරු කරයි.
      emit(AssignmentsLoaded(papers));
    } catch (e) {
      // 4. දෝෂයක් ඇති වූ විට Error State එකට මාරු කරයි.
      emit(AssignmentsError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
