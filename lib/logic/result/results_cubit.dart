// results_cubit.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_app/core/repositories/auth_repository.dart'; // Adjust Path
import 'package:lms_app/core/services/quiz_repository.dart'; // Adjust Path

part 'results_state.dart';

class ResultsCubit extends Cubit<ResultsState> {
  final AuthRepository _authRepository;
  QuizRepository? _quizRepository;
  Timer? _pollTimer;

  ResultsCubit(this._authRepository) : super(ResultsState.initial()) {
    _initAndFetch();
  }

  // --- Core Logic ---

  Future<void> _initAndFetch() async {
    final token = await _authRepository.readToken();
    // ⚠️ isClosed check එක මෙතනත් වැදගත්, නමුත් token read එක Synchronous බැවින් එතරම් හදිසි නැත.
    if (isClosed) return;

    if (token == null || token.isEmpty) {
      if (isClosed) return; // 🔑 ආරක්ෂිත check එක
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'User not authenticated.',
        ),
      );
      return;
    }

    _quizRepository = QuizRepository(token);
    await fetchResults();

    if (isClosed) return; // 🔑 fetchResults පසු Timer එකට පෙර check කරන්න

    // Start polling every 5 seconds (Real-time update)
    _pollTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => fetchResults(isPolling: true),
    );
  }

  Future<void> fetchResults({bool isPolling = false}) async {
    if (_quizRepository == null) return;

    // Loading/Polling states emit කිරීමට පෙර isClosed check අවශ්‍ය නැත.

    if (!isPolling) {
      emit(state.copyWith(isLoading: true, errorMessage: null));
    } else {
      emit(state.copyWith(isPolling: true));
    }

    try {
      final items = await _quizRepository!.fetchStudentResults();

      // 🚀 FIX: await call එකෙන් පසු Cubit එක close ද කියා පරීක්ෂා කරන්න
      if (isClosed) return;

      emit(
        state.copyWith(
          results: items,
          isLoading: false,
          isPolling: false,
          lastUpdated: DateTime.now(),
          errorMessage: null,
        ),
      );
    } catch (e) {
      // 🚀 FIX: catch block එක තුළදීත් Cubit එක close ද කියා පරීක්ෂා කරන්න
      if (isClosed) return;

      emit(
        state.copyWith(
          isLoading: false,
          isPolling: false,
          errorMessage: 'Failed to load results: ${e.toString()}',
        ),
      );
    }
  }

  // --- Utility Methods for UI (Kept in Cubit for separation) ---

  String gradeFromPercentage(num p) {
    final perc = p.toDouble();
    if (perc >= 90) return 'A+';
    if (perc >= 75) return 'A';
    if (perc >= 60) return 'B';
    if (perc >= 40) return 'C';
    return 'F';
  }

  Color gradeColor(String grade) {
    switch (grade) {
      case 'A+':
      case 'A':
        return Colors.green;
      case 'B':
        return Colors.orange;
      case 'C':
        return Colors.blue;
      default:
        return Colors.red;
    }
  }

  // Clean up timer when Cubit is closed
  @override
  Future<void> close() {
    // 🔑 Polling Timer එක cancel කරයි
    _pollTimer?.cancel();
    return super.close();
  }
}
