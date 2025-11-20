import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lms_app/models/exam_paper_card_model.dart';
import 'package:lms_app/models/exam_paper_model.dart';

// ----------------------------------------------------------------------
// API Configuration (⚠️ Replace these with your actual values)
// ----------------------------------------------------------------------

// https://lms-backend-app.azurewebsites.net
const String _BASE_API_URL = 'http://10.0.2.2:5000';

class QuizRepository {
  // ⭐️ 1. Final Variable to store Authentication Token
  final String _authToken;

  // ⭐️ 2. Constructor receives the Token
  QuizRepository(this._authToken) {
    print('QuizRepository Initialized with Token: $_authToken');
  }

  // ⭐️ 3. Headers Map Getter using the Token
  Map<String, String> get _HEADERS => {
    'Content-Type': 'application/json',
    // 🔑 Send token in headers even if empty or null
    'Authorization': 'Bearer $_authToken',
  };

  // ----------------------------------------------------------------------
  // 1. Fetch Paper Instructions (for QuizPaperCubit)
  // ----------------------------------------------------------------------
  Future<ExamPaperModel> fetchPaperInstructions(String paperId) async {
    final url = Uri.parse('$_BASE_API_URL/api/papers/$paperId');
    final response = await http.get(url, headers: _HEADERS);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final paperData = data['paper'] as Map<String, dynamic>;
      return ExamPaperModel.fromJson(paperData);
    } else if (response.statusCode == 401) {
      // 🔑 Handle 401 Unauthorized Error clearly
      throw Exception('Invalid Token: User is not authorized. Please login again.');
    } else {
      final errorBody = json.decode(response.body);
      throw Exception(
        errorBody['message'] ??
            'Instructions loading error: ${response.statusCode}',
      );
    }
  }

  // ----------------------------------------------------------------------
  // 2. Fetch Paper Details (for QuizCubit - complete data as Map)
  // ----------------------------------------------------------------------
  Future<Map<String, dynamic>> fetchPaperDetails(String paperId) async {
    final url = Uri.parse('$_BASE_API_URL/api/papers/$paperId');
    final response = await http.get(url, headers: _HEADERS);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data['paper'] as Map<String, dynamic>;
    } else if (response.statusCode == 401) {
      // 🔑 Handle 401 Unauthorized Error clearly (Invalid Token)
      throw Exception(
        'Quiz Paper Loading Error: Loading error: Invalid Token',
      );
    } else {
      final errorBody = json.decode(response.body);
      throw Exception(
        errorBody['message'] ??
            'Quiz Paper loading error: ${response.statusCode}',
      );
    }
  }

  // ----------------------------------------------------------------------
  // 3. Submit Paper
  // ----------------------------------------------------------------------
  Future<Map<String, dynamic>> submitPaper(
    String paperId,
    List<Map<String, dynamic>> answers,
    int timeSpent,
  ) async {
    final submissionData = {'answers': answers, 'timeSpent': timeSpent};

    final url = Uri.parse('$_BASE_API_URL/api/papers/$paperId/submit');
    final response = await http.post(
      url,
      headers: _HEADERS,
      body: json.encode(submissionData),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> result = json.decode(response.body);
      // Server may return the created attempt under different keys depending
      // on backend implementation. Support both 'result' and 'attempt'.
      if (result.containsKey('result') && result['result'] is Map<String, dynamic>) {
        return result['result'] as Map<String, dynamic>;
      }
      if (result.containsKey('attempt') && result['attempt'] is Map<String, dynamic>) {
        return result['attempt'] as Map<String, dynamic>;
      }

      // Fallback: if the whole response body is itself the attempt/result map
      if (result.isNotEmpty) return result;

      throw Exception('Server returned unexpected response for submission');
    } else if (response.statusCode == 401) {
      // 🔑 Handle 401 Unauthorized Error
      throw Exception('Invalid Token: Please login again.');
    } else {
      final errorBody = json.decode(response.body);
      throw Exception(
        errorBody['message'] ?? 'Submission error: ${response.statusCode}',
      );
    }
  }

  // ----------------------------------------------------------------------
  // 3.5 Fetch Student Results (New)
  // ----------------------------------------------------------------------
  Future<List<Map<String, dynamic>>> fetchStudentResults() async {
    final url = Uri.parse('$_BASE_API_URL/api/papers/results/my-results');
    final response = await http.get(url, headers: _HEADERS);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List items = data['results'] as List? ?? [];

      // Debug: Log what we're receiving
      print('QUIZ REPO DEBUG: Student results API returned ${items.length} items');
      items.take(2).forEach((item) {
        final Map<String, dynamic> itemMap = Map<String, dynamic>.from(item as Map);
        print('QUIZ REPO DEBUG: Result item keys: ${itemMap.keys.toList()}, _id: ${itemMap['_id']}');
      });

      return items.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map)).toList();
    } else if (response.statusCode == 401) {
      throw Exception('Invalid Token: Please login again.');
    } else {
      final errorBody = json.decode(response.body);
      throw Exception(
        errorBody['message'] ?? 'Results fetch error: ${response.statusCode}',
      );
    }
  }

  // ----------------------------------------------------------------------
  // 4. Fetch All Exam Papers for the List View (Updated for tabs functionality)
  // ----------------------------------------------------------------------
  Future<Map<String, dynamic>> fetchAllExamPapersWithStatus() async {
    final url = Uri.parse('$_BASE_API_URL/api/papers/student/all');
    final response = await http.get(url, headers: _HEADERS);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List paperList = data['papers'] as List? ?? [];

      // More defensive casting for attemptedPapers array
      final List<dynamic> attemptedPapersList = data['attemptedPapers'] ?? [];
      final List<String> attemptedPapers = attemptedPapersList
          .where((id) => id != null)  // Filter out null values
          .map((id) => id.toString())
          .toList();

      final List<ExamPaperCardModel> papers = paperList
          .where((item) => item != null) // Filter out null papers
          .map(
            (json) => _transformToExamPaperCard(json as Map<String, dynamic>),
          )
          .where((model) => model != null) // Filter out failed transformations
          .whereType<ExamPaperCardModel>() // Ensure correct type
          .toList();

      return {
        'papers': papers,
        'attemptedPapers': attemptedPapers,
      };
    } else if (response.statusCode == 401) {
      // 🔑 Handle 401 Unauthorized Error
      throw Exception('Invalid Token: Not authorized to load list.');
    } else {
      final errorBody = json.decode(response.body);
      throw Exception(
        errorBody['message'] ??
            'Exam papers list loading error: ${response.statusCode}',
      );
    }
  }

  // Get specific student attempt for a paper
  Future<Map<String, dynamic>?> fetchStudentAttemptForPaper(String paperId) async {
    final url = Uri.parse('$_BASE_API_URL/api/papers/$paperId/attempt');
    final response = await http.get(url, headers: _HEADERS);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final attemptData = data['studentAttempt'] as Map<String, dynamic>?;
      return attemptData;
    } else if (response.statusCode == 404) {
      // No attempt found for this paper - this is expected for papers that haven't been attempted
      return null;
    } else if (response.statusCode == 401) {
      throw Exception('Invalid Token: Please login again.');
    } else {
      final errorBody = json.decode(response.body);
      throw Exception(
        errorBody['message'] ?? 'Failed to get attempt data: ${response.statusCode}',
      );
    }
  }

  // Legacy method for backward compatibility
  Future<List<ExamPaperCardModel>> fetchAllExamPapers() async {
    final result = await fetchAllExamPapersWithStatus();
    return result['papers'] as List<ExamPaperCardModel>;
  }

  // ----------------------------------------------------------------------
  // Data Transformation Function
  // ----------------------------------------------------------------------

  ExamPaperCardModel? _transformToExamPaperCard(Map<String, dynamic> json) {
    // Defensive null checking for required fields
    if (json['_id'] == null || json['title'] == null || json['deadline'] == null) {
      print('QUIZ REPO: Skipping paper with missing required fields: _id=${json['_id']}, title=${json['title']}, deadline=${json['deadline']}');
      return null; // This will be filtered out
    }

    final paperId = json['_id'].toString();
    final title = json['title'].toString();
    final description =
        json['description']?.toString() ?? 'No description provided.';
    final totalQuestions = json['totalQuestions'] as int? ?? 0;
    final timeLimitMinutes = json['timeLimit'] as int? ?? 0;
    final deadline = DateTime.tryParse(json['deadline'].toString()) ?? DateTime.now();

    final Map<String, dynamic>? attempt =
        json['attempt'] as Map<String, dynamic>?;

    final bool isCompleted =
        attempt != null && attempt['status'] == 'submitted';
    final bool isAvailableToStart = !isCompleted;

    final now = DateTime.now();
    final bool isOverdue = now.isAfter(deadline) && !isCompleted;
    final Duration remaining = deadline.difference(now);

    String dueDateDisplay =
        "${deadline.day}th ${DateFormat('MMM yyyy').format(deadline)}";
    String timeLeftDisplay;
    Color timeLeftColor;

    if (isCompleted) {
      timeLeftDisplay = "Completed";
      timeLeftColor = Colors.green;
    } else if (isOverdue) {
      timeLeftDisplay = "Overdue";
      timeLeftColor = Colors.red;
    } else if (remaining.inDays > 0) {
      timeLeftDisplay = "${remaining.inDays} Days Left";
      timeLeftColor = Colors.orange;
    } else if (remaining.inHours > 0) {
      timeLeftDisplay = "${remaining.inHours} Hours Left";
      timeLeftColor = Colors.orange.shade800;
    } else {
      timeLeftDisplay = "Ending Soon!";
      timeLeftColor = Colors.red.shade700;
    }

    return ExamPaperCardModel(
      id: paperId,
      title: title,
      description: description,
      totalQuestions: totalQuestions,
      timeLimitMinutes: timeLimitMinutes,
      dueDateDisplay: dueDateDisplay,
      timeLeftDisplay: timeLeftDisplay,
      timeLeftColor: timeLeftColor,
      isAvailableToStart: isAvailableToStart,
      isCompleted: isCompleted,
      studentScorePercentage: isCompleted ? '${attempt!['score']}%' : null,
      studentStatus: attempt?['status'] as String?,
      paperType: json['paperType'] as String? ?? 'MCQ',
    );
  }
}
