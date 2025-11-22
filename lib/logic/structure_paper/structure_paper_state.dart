import 'package:equatable/equatable.dart';
import 'package:lms_app/models/structure_paper_model.dart';

abstract class StructurePaperState extends Equatable {
  const StructurePaperState();

  @override
  List<Object?> get props => [];
}

class StructurePaperLoading extends StructurePaperState {}

class StructurePaperLoaded extends StructurePaperState {
  final StructurePaperModel paper;

  const StructurePaperLoaded({required this.paper});

  @override
  List<Object?> get props => [paper];
}

class StructurePaperSubmissionLoading extends StructurePaperState {}

class StructurePaperSubmissionSuccess extends StructurePaperState {
  final Map<String, dynamic> result;

  const StructurePaperSubmissionSuccess(this.result);

  @override
  List<Object?> get props => [result];
}

class StructurePaperFailure extends StructurePaperState {
  final String error;

  const StructurePaperFailure(this.error);

  @override
  List<Object?> get props => [error];
}
