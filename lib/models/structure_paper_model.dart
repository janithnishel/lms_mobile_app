// Model for Structure Paper data
import 'package:equatable/equatable.dart';

class StructurePaperModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final String fileUrl;
  final DateTime? deadline;
  final int? timeLimitMinutes;
  final bool hasSubmitted;

  const StructurePaperModel({
    required this.id,
    required this.title,
    required this.description,
    required this.fileUrl,
    this.deadline,
    this.timeLimitMinutes,
    required this.hasSubmitted,
  });

  factory StructurePaperModel.fromJson(Map<String, dynamic> json) {
    return StructurePaperModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? 'Untitled Paper',
      description: json['description'] ?? 'No description',
      fileUrl: json['fileUrl'] ?? '',
      deadline: json['deadline'] != null ? DateTime.tryParse(json['deadline']) : null,
      timeLimitMinutes: json['timeLimit'],
      hasSubmitted: json['hasSubmitted'] ?? false,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    fileUrl,
    deadline,
    timeLimitMinutes,
    hasSubmitted
  ];
}

// Model for submission response
class StructurePaperSubmission extends Equatable {
  final String attemptId;
  final String status;
  final String message;

  const StructurePaperSubmission({
    required this.attemptId,
    required this.status,
    required this.message,
  });

  factory StructurePaperSubmission.fromJson(Map<String, dynamic> json) {
    return StructurePaperSubmission(
      attemptId: json['_id'] ?? json['attempt']?['_id'] ?? '',
      status: json['status'] ?? json['attempt']?['status'] ?? 'submitted',
      message: json['message'] ?? 'Submitted successfully',
    );
  }

  @override
  List<Object> get props => [attemptId, status, message];
}
