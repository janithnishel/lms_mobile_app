import 'package:lms_app/core/errors/exception.dart';
import 'package:lms_app/core/services/structure_paper_api_service.dart';
import 'package:lms_app/models/structure_paper_model.dart';

class StructurePaperRepository {
  final StructurePaperApiService _apiService;

  StructurePaperRepository(this._apiService);

  Future<StructurePaperModel> fetchPaperById(String paperId) async {
    try {
      final paperData = await _apiService.fetchPaperById(paperId);

      // Check if student has already submitted
      final attempts = await _apiService.checkStudentAttempt(paperId);
      final hasSubmitted = attempts != null;

      // Create the enhanced paper data with hasSubmitted field
      final enhancedPaperData = Map<String, dynamic>.from(paperData)
        ..['hasSubmitted'] = hasSubmitted;

      return StructurePaperModel.fromJson(enhancedPaperData);
    } catch (e) {
      throw ServerException(message: 'Failed to load paper: $e', statusCode: 500);
    }
  }

  Future<Map<String, dynamic>> submitPaper(String paperId, String fileUrl) async {
    try {
      return await _apiService.submitStructurePaper(paperId, fileUrl);
    } catch (e) {
      throw ServerException(message: 'Submission failed: $e', statusCode: 500);
    }
  }
}
