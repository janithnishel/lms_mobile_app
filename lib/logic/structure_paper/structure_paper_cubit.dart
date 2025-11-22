import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_app/core/repositories/structure_paper_repository.dart';
import 'package:lms_app/logic/structure_paper/structure_paper_state.dart';

class StructurePaperCubit extends Cubit<StructurePaperState> {
  final String paperId;
  final StructurePaperRepository _repository;

  StructurePaperCubit({
    required this.paperId,
    required StructurePaperRepository repository
  }) : _repository = repository,
       super(StructurePaperLoading()) {
    _loadPaper();
  }

  Future<void> _loadPaper() async {
    try {
      final paper = await _repository.fetchPaperById(paperId);
      emit(StructurePaperLoaded(paper: paper));
    } catch (e) {
      emit(StructurePaperFailure('Failed to load paper: $e'));
    }
  }

  Future<void> submitAnswerFile(String fileUrl) async {
    if (state is! StructurePaperLoaded) return;

    emit(StructurePaperSubmissionLoading());

    try {
      final result = await _repository.submitPaper(paperId, fileUrl);
      emit(StructurePaperSubmissionSuccess(result));
    } catch (e) {
      emit(StructurePaperFailure('Submission failed: $e'));
    }
  }

  void downloadPaper() {
    // This would typically open the file URL in a browser or download manager
    // For now, just emit success
  }

  void retryLoad() {
    emit(StructurePaperLoading());
    _loadPaper();
  }
}
