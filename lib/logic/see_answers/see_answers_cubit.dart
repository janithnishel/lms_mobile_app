// See answers cubit with repository injection
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_app/core/repositories/see_answers_repository.dart';
import 'package:lms_app/models/see_answers_model.dart';
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

  /// Load attempt data for a paper and then fetch the full review data
  void loadAttemptDataByPaperId(String paperId) async {
    emit(SeeAnswersLoading());

    try {
      // Fetch attempt data using the existing SeeAnswersRepository method
      // This uses the already authenticated SeeAnswersApiService
      final attemptData = await _repository.fetchStudentAttemptForPaper(paperId);

      if (attemptData == null) {
        emit(const SeeAnswersError('No attempt data found for this paper.'));
        return;
      }

      // Now we have attempt data, extract required info and load full review data
      final attemptId = (attemptData['_id'] as String?) ?? (attemptData['id'] as String?) ?? '';

      if (attemptId.isEmpty) {
        emit(const SeeAnswersError('Invalid attempt data received.'));
        return;
      }

      // Load the full review data using the existing method
      loadAnswers(attemptData, 'Review Answers', attemptId);
    } catch (e) {
      emit(SeeAnswersError('Failed to load attempt data: ${e.toString()}'));
    }
  }
}
