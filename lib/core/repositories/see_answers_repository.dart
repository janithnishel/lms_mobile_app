import 'package:lms_app/core/services/see_answers_api_service.dart';
import 'package:lms_app/models/see_answers_model.dart';
import 'package:lms_app/core/errors/exception.dart';

class SeeAnswersRepository {
  final SeeAnswersApiService _apiService;

  SeeAnswersRepository(this._apiService);

  String _formatTime(num timeInSeconds) {
    final minutes = (timeInSeconds.toInt() / 60).floor();
    final seconds = timeInSeconds.toInt() % 60;
    return minutes > 0 ? '$minutes min $seconds sec' : '$seconds sec';
  }

  int _parseInt(dynamic value, int defaultValue) {
    if (value == null) return defaultValue;
    if (value is num) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }

  // Main method that the cubit calls
  Future<ReviewData> getReviewData({
    required String attemptId,
    required Map<String, dynamic> localAttemptData,
    required String paperTitle,
  }) async {
    print('DEBUG SeeAnswersRepository: getReviewData called with attemptId=$attemptId, title=$paperTitle');
    print('DEBUG SeeAnswersRepository: localAttemptData keys: ${localAttemptData.keys}');
    // Extract paperId from attempt data
    final paperId = (localAttemptData['paperId'] is Map
        ? localAttemptData['paperId']['_id']?.toString()
        : localAttemptData['paperId']?.toString()) ??
        '';

    if (paperId.isEmpty) {
      throw Exception('Paper ID not found in attempt data');
    }

    // Fetch paper data with answers from API
    final responseData = await _apiService.fetchReviewData(paperId, attemptId);
    print('DEBUG: API responseData keys: ${responseData.keys}');
    print('DEBUG: API responseData: $responseData');
    final paperData = (responseData['paper'] as Map<String, dynamic>);

    // Parse data from both sources
    return _createReviewData(localAttemptData, paperData, paperTitle);
  }

  ReviewData _createReviewData(
    Map<String, dynamic> attemptData,
    Map<String, dynamic> paperData,
    String paperTitle,
  ) {
    print('DEBUG _createReviewData: paperData keys=${paperData.keys}');
    print('DEBUG _createReviewData: paperData=${paperData}');
    // 1. Create attempt summary
    final score = _parseInt(attemptData['score'], 0);
    final totalQuestions = _parseInt(attemptData['totalQuestions'], 0);
    final timeSpent = attemptData['timeSpent'] as num? ?? 0;
    final percentage = totalQuestions > 0 ? (score / totalQuestions) * 100 : 0.0;

    final summary = AttemptSummary(
      score: score,
      totalQuestions: totalQuestions,
      percentage: percentage,
      timeSpent: _formatTime(timeSpent),
    );

    // 2. Create paper details
    final paperObj = paperData.isNotEmpty ? paperData : (attemptData['paperId'] ?? {});
    final description = paperObj is Map
        ? (paperObj['description'] ?? attemptData['paperDescription'] ?? '')
        : (attemptData['paperDescription'] ?? '');

    final paperDetails = PaperDetails(
      title: paperTitle,
      description: description.toString(),
    );

    // 3. Create questions list by merging data
    final List<QuestionData> questions = [];

    if (paperData.isNotEmpty) {
      final paperQuestions = paperData['questions'] as List<dynamic>? ?? [];

      // Create map of user's answers
      final userAnswers = (attemptData['answers'] as List<dynamic>? ?? []);
      final Map<String, dynamic> answerMap = {};
      for (var answer in userAnswers) {
        if (answer is Map && answer['questionId'] != null) {
          answerMap[answer['questionId'].toString()] = answer;
        }
      }

      for (var question in paperQuestions) {
        if (question is Map) {
          final Map<String, dynamic> q = Map<String, dynamic>.from(question);
          final questionId = q['_id']?.toString() ?? '';
          final userAnswer = answerMap[questionId];

          questions.add(_createQuestionData(q, userAnswer));
        }
      }
    }

    return ReviewData(
      summary: summary,
      paperDetails: paperDetails,
      questions: questions,
    );
  }

  QuestionData _createQuestionData(Map<String, dynamic> question, dynamic userAnswer) {
    final questionText = question['questionText'] ?? question['text'] ?? '';
    final rawImageUrl = question['imageUrl'] ?? '';
    String? imageUrl;
    if (rawImageUrl.isNotEmpty) {
      // If it's already a full URL, use as is, otherwise prepend base URL
      imageUrl = rawImageUrl.startsWith('http')
          ? rawImageUrl
          : 'http://10.0.2.2:5000$rawImageUrl';
    }
    print('DEBUG _createQuestionData: question has imageUrl field? ${question.containsKey('imageUrl')}, raw: $rawImageUrl, processed: $imageUrl');

    final options = question['options'] as List<dynamic>? ?? [];
    // Filter out invalid/empty options like quiz screen does - keep only options with meaningful text
    final filteredOptions = options.where((opt) => opt is Map).where((opt) {
      final text = opt['text']?.toString() ?? '';
      final choiceText = opt['optionText']?.toString() ?? '';
      final hasContent = (text.isNotEmpty && text.length > 1) || (choiceText.isNotEmpty && choiceText.length > 1);
      return hasContent;
    }).toList();

    final optionTexts = filteredOptions.map((opt) => opt is Map ? (opt['text']?.toString() ?? opt['optionText']?.toString() ?? '') : opt.toString()).toList();

    // Find correct answer index in filtered options
    int correctIndex = -1;
    String? correctOptionId;
    for (int i = 0; i < filteredOptions.length; i++) {
      if (filteredOptions[i] is Map && (filteredOptions[i]['isCorrect'] == true || filteredOptions[i]['correct'] == true)) {
        correctIndex = i;
        correctOptionId = filteredOptions[i]['_id']?.toString();
        break;
      }
    }

    // Find user's answer index in filtered options
    int userIndex = -2;
    if (userAnswer != null && userAnswer is Map) {
      final selectedOptionId = userAnswer['selectedOptionId']?.toString();
      if (selectedOptionId != null) {
        for (int i = 0; i < filteredOptions.length; i++) {
          if (filteredOptions[i] is Map && filteredOptions[i]['_id']?.toString() == selectedOptionId) {
            userIndex = i;
            break;
          }
        }
      }
    }

    // Extract explanation
    String? explanation;
    String? visualUrl;
    final explanationObj = question['explanation'];
    if (explanationObj is Map) {
      explanation = explanationObj['text']?.toString();
      final rawVisualUrl = explanationObj['imageUrl']?.toString() ?? '';
      if (rawVisualUrl.isNotEmpty) {
        visualUrl = rawVisualUrl.startsWith('http')
            ? rawVisualUrl
            : 'http://10.0.2.2:5000$rawVisualUrl';
      }
    }

    return QuestionData(
      questionText: questionText.toString(),
      imageUrl: imageUrl,
      options: optionTexts,
      correctAnswerIndex: correctIndex,
      userAnswerIndex: userIndex,
      explanation: explanation,
      visualExplanationUrl: visualUrl,
    );
  }
}
