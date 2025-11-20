
import 'package:dio/dio.dart';
import '../repositories/auth_repository.dart';

// 🔑 BASE URL CONSTANT
const String BASE_URL = 'http://10.0.2.2:5000';

// Abstract base class for all API services
abstract class BaseApiService {
  final Dio _dio;
  final AuthRepository _authRepository;

  Dio get dio => _dio;

  BaseApiService(this._authRepository)
    : _dio = Dio(
        BaseOptions(
          baseUrl: BASE_URL,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 10),
        ),
      ) {
    // Common interceptors for all API services
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add authorization header if token exists
          final token = await _authRepository.readToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          // Handle auth errors globally
          if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
            await _authRepository.deleteToken();
          }
          return handler.next(e);
        },
      ),
    );
  }

  // Common error handling method
  Never handleApiError(DioException e, {String defaultMessage = 'API call failed'}) {
    final message = e.response?.data['message'] ?? defaultMessage;
    throw Exception(message);
  }

  // Helper method for standard Dio POST calls
  Future<Response<T>> post<T>(
    String path,
    {dynamic data, Map<String, dynamic>? queryParameters}
  ) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
      );
    } on DioException catch (e) {
      handleApiError(e);
    }
  }

  // Helper method for standard Dio GET calls
  Future<Response<T>> get<T>(
    String path,
    {Map<String, dynamic>? queryParameters}
  ) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
      );
    } on DioException catch (e) {
      handleApiError(e);
    }
  }

  // Helper method for standard Dio PUT calls
  Future<Response<T>> put<T>(
    String path,
    {dynamic data, Map<String, dynamic>? queryParameters}
  ) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
      );
    } on DioException catch (e) {
      handleApiError(e);
    }
  }

  // Helper method for standard Dio DELETE calls
  Future<Response<T>> delete<T>(
    String path,
    {Map<String, dynamic>? queryParameters}
  ) async {
    try {
      return await _dio.delete<T>(
        path,
        queryParameters: queryParameters,
      );
    } on DioException catch (e) {
      handleApiError(e);
    }
  }

  // Helper method for multipart/form-data POST calls
  Future<Response<T>> postMultipart<T>(
    String path,
    FormData formData,
  ) async {
    try {
      return await _dio.post<T>(
        path,
        data: formData,
      );
    } on DioException catch (e) {
      handleApiError(e);
    }
  }
}
