import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_app/core/services/quiz_repository.dart';
import 'package:lms_app/logic/paper_instructions/paper_instruction_state.dart';
import 'package:lms_app/models/exam_paper_model.dart';
import 'package:lms_app/models/paper_intro_details_model.dart';

// Cubit
class PaperInstructionCubit extends Cubit<PaperInstructionState> {
  final QuizRepository _repository;
  final String paperId;

  // Constructor
  PaperInstructionCubit({
    required QuizRepository repository,
    required this.paperId,
  }) : _repository = repository,
       super(PaperInstructionInitial()) {
    // Cubit එක ආරම්භයේදීම දත්ත Load කිරීම පටන් ගනියි.
    loadPaperInstructions(paperId);
  }

  /// Backend එකෙන් විභාගයේ උපදෙස් සහ මූලික විස්තර Load කරයි.
  Future<void> loadPaperInstructions(String paperId) async {
    // 1. Loading State එකට මාරු කරයි
    emit(PaperInstructionLoading());
    try {
      // 2. Repository හරහා Backend එකෙන් දත්ත ලබා ගනියි
      final ExamPaperModel sourcePaper = await _repository
          .fetchPaperInstructions(paperId);

      // 3. ExamPaperModel එක PaperIntroDetails Model එකට Map කරයි
      // 💡 Note: ඔබ PaperIntroDetails Model එකේ fromExamPaper factory/method එකක් නිර්මාණය කළ යුතුය.
      final PaperIntroDetailsModel details = PaperIntroDetailsModel.fromExamPaper(
        sourcePaper,
      );

      // 4. සාර්ථකව Load වූ State එකට මාරු කරයි
      emit(PaperInstructionLoaded(details));
    } catch (e) {
      // 5. දෝෂයක් ඇති වූ විට Error State එකට මාරු කරයි
      emit(PaperInstructionError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
