// lib/models/quiz_models.dart

// ----------------------------------------------------------------------
// 0. API Structures (Options and Questions)
// ----------------------------------------------------------------------

/// Directly maps to Backend's Paper.questions.options.
class OptionModel {
  final String id;
  final String optionText;
  final String? optionImageUrl;

  const OptionModel({
    required this.id,
    required this.optionText,
    this.optionImageUrl,
  });

  factory OptionModel.fromJson(Map<String, dynamic> json) {
    return OptionModel(
      id: json['_id'] as String,
      optionText: json['optionText'] as String,
      // Reading the image URL for the option
      optionImageUrl: json['imageUrl'] as String?,
    );
  }
}

/// Directly maps to Backend's Paper.questions.
class QuizQuestion {
  final String questionId;
  final String questionText;
  final String?
  questionImageUrl; // 🔑 NEW: Field to hold the main question image URL
  final int order;
  final List<OptionModel> options;

  const QuizQuestion({
    required this.questionId,
    required this.questionText,
    this.questionImageUrl, // 🔑 NEW: Adding to the constructor
    required this.order,
    required this.options,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      questionId: json['_id'] as String,
      questionText: json['questionText'] as String,
      // 🔑 NEW: Reading the question image URL from the JSON
      questionImageUrl: json['imageUrl'] as String?,
      order: json['order'] as int,
      options: (json['options'] as List)
          .map((i) => OptionModel.fromJson(i as Map<String, dynamic>))
          .toList(),
    );
  }
}
