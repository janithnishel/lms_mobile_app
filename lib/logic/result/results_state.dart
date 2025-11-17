// results_state.dart
part of 'results_cubit.dart';

class ResultsState {
  final bool isLoading;
  final bool isPolling;
  final List<Map<String, dynamic>> results;
  final DateTime? lastUpdated;
  final String? errorMessage;

  // Calculated properties for easy access in UI
  int get papersCompleted => results.length;
  int get averageScore {
    if (results.isEmpty) return 0;
    // Calculate total percentage from all attempts
    final totalPercentage = results.map((r) => (r['percentage'] ?? 0) as num).reduce((a, b) => a + b);
    return (totalPercentage / results.length).round();
  }
  num get bestScore {
    if (results.isEmpty) return 0;
    return results.map((r) => (r['percentage'] ?? 0) as num).reduce((a, b) => a > b ? a : b);
  }

  const ResultsState({
    required this.isLoading,
    required this.isPolling,
    required this.results,
    this.lastUpdated,
    this.errorMessage,
  });

  factory ResultsState.initial() {
    return const ResultsState(
      isLoading: true,
      isPolling: false,
      results: [],
      lastUpdated: null,
      errorMessage: null,
    );
  }

  ResultsState copyWith({
    bool? isLoading,
    bool? isPolling,
    List<Map<String, dynamic>>? results,
    DateTime? lastUpdated,
    String? errorMessage,
  }) {
    return ResultsState(
      isLoading: isLoading ?? this.isLoading,
      isPolling: isPolling ?? this.isPolling,
      results: results ?? this.results,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      errorMessage: errorMessage, // Reset error on new successful state
    );
  }
}