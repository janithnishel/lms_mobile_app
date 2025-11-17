import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_app/core/services/quiz_repository.dart';
import 'package:lms_app/logic/quiz/quiz_state.dart';
import 'package:lms_app/models/exam_paper_model.dart';
import 'package:lms_app/models/quiz_models.dart';

class QuizCubit extends Cubit<QuizState> {
  final String paperId;
  final QuizRepository _repository;
  // 🔑 නිවැරදි කිරීම: 'LateInitializationError' වලකා ගැනීමට nullable (?) ලෙස පවතී.
  // මෙම නිර්වචනය දැනටමත් නිවැරදියි!
  Timer? _timer; 

  QuizCubit({required this.paperId, required QuizRepository repository})
    : _repository = repository,
      super(QuizLoading()) {
    _loadQuiz();
  }

  // ----------------------------------------------------------------------
  // A. Load Quiz Data
  // ----------------------------------------------------------------------
  Future<void> _loadQuiz() async {
    if (isClosed) return;
    emit(QuizLoading());

    try {
      final paperData = await _repository.fetchPaperDetails(paperId);

      final ExamPaperModel loadedPaper = ExamPaperModel.fromJson(paperData);
      final List<QuizQuestion> questions = (paperData['questions'] as List)
          .map((q) => QuizQuestion.fromJson(q as Map<String, dynamic>))
          .toList();

      final int initialTimeSeconds = loadedPaper.timeLimitMinutes * 60;

      if (isClosed) return;
      emit(
        QuizActive(
          paperDetails: loadedPaper,
          userState: UserQuizState(
            questions: questions,
            userAnswers: {},
            timeRemainingSeconds: initialTimeSeconds,
            totalTimeSeconds: initialTimeSeconds,
          ),
        ),
      );

      // 🔑 1. සාර්ථකව Load වූ පසු පමණක් Timer එක පටන් ගනියි
      _startTimer(initialTimeSeconds);
    } catch (e) {
      // If load fails, timer will not start.
      if (isClosed) return;
      emit(
        QuizFailure(
          'Paper Load Error: ${e.toString().replaceFirst('Exception: ', '')}',
        ),
      );
    }
  }

  // ----------------------------------------------------------------------
  // B. Answer Question & Submit Paper
  // ----------------------------------------------------------------------
  void answerQuestion(String questionId, String selectedOptionId) {
    if (state is QuizActive) {
      final activeState = state as QuizActive;
      final currentAnswers = Map<String, String?>.from(
        activeState.userState.userAnswers,
      );

      // Toggle logic
      if (currentAnswers[questionId] == selectedOptionId) {
        currentAnswers.remove(questionId);
      } else {
        currentAnswers[questionId] = selectedOptionId;
      }

      emit(
        activeState.copyWith(
          userState: activeState.userState.copyWith(
            userAnswers: currentAnswers,
          ),
        ),
      );
    }
  }

  void submitPaper({bool isAuto = false}) async {
    if (state is! QuizActive) return;

    // Cancel timer
    _timer?.cancel();
    final activeState = state as QuizActive;
    final timeSpent =
        activeState.userState.totalTimeSeconds -
        activeState.userState.timeRemainingSeconds;

    final submissionAnswers = activeState.userState.userAnswers.entries
        .where((entry) => entry.value != null)
        .map(
          (entry) => {
            'questionId': entry.key,
            'selectedOptionId': entry.value!,
          },
        )
        .toList();

    try {
      final result = await _repository.submitPaper(
        paperId,
        submissionAnswers,
        timeSpent,
      );
      if (isClosed) return;
      emit(QuizSubmissionSuccess(result));
    } catch (e) {
      if (isClosed) return;
      emit(
        QuizFailure(
          'Submission Error: ${e.toString().replaceFirst('Exception: ', '')}',
        ),
      );
    }
  }

  // ----------------------------------------------------------------------
  // D. Timer & Navigation (Question)
  // ----------------------------------------------------------------------

  void _startTimer(int initialTime) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (isClosed) {
        t.cancel();
        return;
      }

      if (state is QuizActive) {
        final activeState = state as QuizActive;
        final newTime = activeState.userState.timeRemainingSeconds - 1;

        if (newTime > 0) {
          emit(
            activeState.copyWith(
              userState: activeState.userState.copyWith(
                timeRemainingSeconds: newTime,
              ),
            ),
          );
        } else {
          t.cancel();
          // Auto submit when time is up
          submitPaper(isAuto: true);
        }
      } else {
        t.cancel();
      }
    });
  }

  void nextQuestion() {
    if (state is QuizActive) {
      final activeState = state as QuizActive;
      final totalQuestions = activeState.userState.questions.length;
      final nextIndex = activeState.userState.currentQuestionIndex + 1;

      if (nextIndex < totalQuestions) {
        emit(
          activeState.copyWith(
            userState: activeState.userState.copyWith(
              currentQuestionIndex: nextIndex,
            ),
          ),
        );
      }
    }
  }

  void previousQuestion() {
    if (state is QuizActive) {
      final activeState = state as QuizActive;
      final prevIndex = activeState.userState.currentQuestionIndex - 1;

      if (prevIndex >= 0) {
        emit(
          activeState.copyWith(
            userState: activeState.userState.copyWith(
              currentQuestionIndex: prevIndex,
            ),
          ),
        );
      }
    }
  }

  void jumpToQuestion(int index) {
    if (state is QuizActive) {
      final activeState = state as QuizActive;
      if (index >= 0 && index < activeState.userState.questions.length) {
        emit(
          activeState.copyWith(
            userState: activeState.userState.copyWith(
              currentQuestionIndex: index,
            ),
          ),
        );
      }
    }
  }

  // ----------------------------------------------------------------------
  // E. Resource Cleanup
  // ----------------------------------------------------------------------
  @override
  Future<void> close() {
  // Safely cancel timer even if null.
  _timer?.cancel();
    return super.close();
  }
}
