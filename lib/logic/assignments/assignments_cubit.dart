import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_app/core/services/quiz_repository.dart';
import 'package:lms_app/logic/assignments/assignments_state.dart'; // 🔑 අලුත් State file එක Import කරයි
import 'package:lms_app/models/exam_paper_card_model.dart';

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
    print('🏁 AssignmentsCubit: Starting load...');
    try {
      // 2. Repository හරහා Backend එකෙන් දත්ත සහ attemptedPapers ලබා ගනියි.
      print('📡 AssignmentsCubit: Calling repository...');
      final result = await _repository.fetchAllExamPapersWithStatus();
      print('✅ AssignmentsCubit: API response received: ${result.keys}');

      final List<ExamPaperCardModel> papers = result['papers'] as List<ExamPaperCardModel>;
      final List<String> attemptedPapers = result['attemptedPapers'] as List<String>;

      print('📊 AssignmentsCubit: Papers: ${papers.length}, Attempted: ${attemptedPapers.length}');

      final assignmentData = AssignmentDataWithStatus(
        papers: papers,
        attemptedPapers: attemptedPapers,
      );

      // 3. Check if cubit is still open before emitting
      if (!isClosed) {
        print('🚀 AssignmentsCubit: Emitting AssignmentsWithStatusLoaded');
        // සාර්ථකව Load වූ State එකට මාරු කරයි - new custom state for assignments with status
        emit(AssignmentsWithStatusLoaded(assignmentData));
      }
    } catch (e) {
      print('❌ AssignmentsCubit: Error - $e');
      // 4. Check if cubit is still open before emitting
      if (!isClosed) {
        // දෝෂයක් ඇති වූ විට Error State එකට මාරු කරයි.
        emit(AssignmentsError(e.toString().replaceFirst('Exception: ', '')));
      }
    }
  }
}
