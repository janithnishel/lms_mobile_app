import 'package:dio/dio.dart';
import 'package:lms_app/core/errors/exception.dart';
import 'package:lms_app/core/repositories/auth_repository.dart';
import 'dart:developer';

const String _BASE_URL = 'http://10.0.2.2:5000';

class SeeAnswersApiService {
  final Dio _dio;

  SeeAnswersApiService(AuthRepository authRepository)
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

  Future<Map<String, dynamic>> fetchReviewData(
    String paperId,
    String attemptId,
  ) async {
    try {
      log(
        'API DEBUG: Attempting to fetch review data for paperId: $paperId, attemptId: $attemptId',
      );

      // Use the correct endpoint: GET /:id where :id is paperId with showAnswers=true
      final url = '/api/papers/$paperId?showAnswers=true';

      log('API DEBUG: Calling endpoint: $url');

      final response = await _dio.get(url);

      // final response = await _dio.get('/attempts/$attemptId/review');

      log('API DEBUG: Received Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
      // 🚀 FIX: Data Type check එක තවදුරටත් ආරක්ෂිත කරන්න.
        if (response.data is Map) {
          log('API DEBUG: SUCCESS - Returning data. Keys: ${(response.data as Map).keys}');
          log('API DEBUG: Response data: ${response.data}');
          return response.data as Map<String, dynamic>;
        } else {
          // 200 ආවත් data යනු Map එකක් නොවේ නම් (e.g. Empty string, List, etc.)
          log('API DEBUG: ERROR - Response data type: ${response.data.runtimeType}, value: ${response.data}');
          throw ServerException(
            message: 'Unexpected non-map data received for review.',
            statusCode: 200,
          );
        }
      }

      // Handle non-200 status codes
      final statusCode = response.statusCode ?? 500;

      // 🚀 FIX APPLIED: response.data Map එකක් නොවේ නම් String එකක් ලෙස කියවන්න
      final responseMessage = _safeExtractMessage(
        response.data,
        'Failed to fetch review data (Status $statusCode).',
      );

      log('API DEBUG: FAILED - Status: $statusCode, Message: $responseMessage');

      throw ServerException(message: responseMessage, statusCode: statusCode);
    } on DioException catch (e) {
      // Handle network errors or specific API errors
      final statusCode = e.response?.statusCode;

      // 🚀 FIX APPLIED: Dio Error Response එකත් safe කරන්න
      final errorMessage = _safeExtractMessage(
        e.response?.data,
        e.message ?? 'Unknown Dio Error.',
      );

      log(
        'API DEBUG: DIO EXCEPTION - Status: $statusCode, Error: $errorMessage',
      );

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
}
