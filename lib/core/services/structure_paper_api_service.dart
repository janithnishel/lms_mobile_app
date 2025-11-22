import 'package:dio/dio.dart';
import 'package:lms_app/core/errors/exception.dart';
import 'package:lms_app/core/repositories/auth_repository.dart';
import 'dart:developer';

const String _BASE_URL = 'http://10.0.2.2:5000';

class StructurePaperApiService {
  final Dio _dio;

  StructurePaperApiService(AuthRepository authRepository)
    : _dio = Dio(
        BaseOptions(
          baseUrl: _BASE_URL,
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 3),
        ),
      ) {
    // Add auth interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await authRepository.readToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
            await authRepository.deleteToken();
          }
          return handler.next(e);
        },
      ),
    );
  }

  // Helper to safely extract a message from response data
  String _safeExtractMessage(dynamic data, String defaultMessage) {
    if (data is Map && data.containsKey('message')) {
      return data['message'].toString();
    }
    return defaultMessage;
  }

  Future<Map<String, dynamic>> fetchPaperById(String paperId) async {
    try {
      log('API DEBUG: Attempting to fetch structure paper: $paperId');

      final response = await _dio.get('/api/papers/$paperId');

      if (response.statusCode == 200) {
        if (response.data is Map) {
          log('API DEBUG: SUCCESS - Structure paper fetched');
          return response.data as Map<String, dynamic>;
        } else {
          throw ServerException(
            message: 'Unexpected non-map data for paper.',
            statusCode: 200,
          );
        }
      }

      final statusCode = response.statusCode ?? 500;
      final responseMessage = _safeExtractMessage(
        response.data,
        'Failed to fetch paper (Status $statusCode).',
      );

      log('API DEBUG: FAILED - Status: $statusCode, Message: $responseMessage');

      throw ServerException(message: responseMessage, statusCode: statusCode);
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final errorMessage = _safeExtractMessage(
        e.response?.data,
        e.message ?? 'Unknown Dio Error.',
      );

      log('API DEBUG: DIO EXCEPTION - Status: $statusCode, Error: $errorMessage');

      throw ServerException(
        message: errorMessage,
        statusCode: statusCode ?? 503,
      );
    } catch (e) {
      log('API DEBUG: UNKNOWN EXCEPTION: ${e.toString()}');
      throw UnknownException(
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  Future<Map<String, dynamic>?> checkStudentAttempt(String paperId) async {
    try {
      log('API DEBUG: Checking attempt for paper: $paperId');

      final response = await _dio.get('/api/papers/$paperId/attempt');

      if (response.statusCode == 200) {
        if (response.data?['studentAttempt'] is Map) {
          return response.data['studentAttempt'] as Map<String, dynamic>?;
        }
        return response.data;
      } else if (response.statusCode == 404) {
        // No attempt found - this is expected
        return null;
      }

      throw ServerException(
        message: 'Failed to check attempt status',
        statusCode: response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // No attempt found - return null
        return null;
      }
      final errorMessage = _safeExtractMessage(
        e.response?.data,
        'Failed to check attempt',
      );
      throw ServerException(message: errorMessage, statusCode: e.response?.statusCode ?? 503);
    } catch (e) {
      throw UnknownException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> submitStructurePaper(
    String paperId,
    String answerFileUrl,
  ) async {
    try {
      log('API DEBUG: Submitting structure paper: $paperId');

      final submissionData = {
        'answers': [], // Structure papers don't have questions
        'timeSpent': 0, // No time limit for structure papers
        'answerFileUrl': answerFileUrl,
      };

      final response = await _dio.post(
        '/api/papers/$paperId/submit',
        data: submissionData,
      );

      if (response.statusCode == 200) {
        if (response.data is Map) {
          log('API DEBUG: SUCCESS - Structure paper submitted');
          return response.data as Map<String, dynamic>;
        } else {
          throw ServerException(
            message: 'Unexpected response format',
            statusCode: 200,
          );
        }
      }

      final responseMessage = _safeExtractMessage(
        response.data,
        'Failed to submit paper (Status ${response.statusCode}).',
      );

      throw ServerException(
        message: responseMessage,
        statusCode: response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      final errorMessage = _safeExtractMessage(
        e.response?.data,
        e.message ?? 'Submission failed',
      );

      log('API DEBUG: DIO EXCEPTION - Error: $errorMessage');

      throw ServerException(
        message: errorMessage,
        statusCode: e.response?.statusCode ?? 503,
      );
    } catch (e) {
      log('API DEBUG: UNKNOWN EXCEPTION: ${e.toString()}');
      throw UnknownException(
        message: 'Submission error: ${e.toString()}',
      );
    }
  }
}
