

class ExamPaperModel {
  final String id; // _id (Paper ID)
  final String title;
  final String? description;
  final int totalQuestions;
  final int timeLimitMinutes; // Corresponds to Backend 'timeLimit'
  final DateTime deadline; // Corresponds to Backend 'deadline'

  const ExamPaperModel({
    required this.id,
    required this.title,
    this.description,
    required this.totalQuestions,
    required this.timeLimitMinutes,
    required this.deadline,
  });

  factory ExamPaperModel.fromJson(Map<String, dynamic> json) {
    return ExamPaperModel(
      id: json['_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      totalQuestions: json['totalQuestions'] as int,
      timeLimitMinutes: json['timeLimit'] as int,
      deadline: DateTime.parse(json['deadline'] as String), 
    );
  }
}