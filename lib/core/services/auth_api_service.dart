// 💡 අවශ්‍ය Imports
import 'dart:io';
import 'package:dio/dio.dart';
import '../repositories/auth_repository.dart';
// import 'package:http_parser/http_parser.dart'; // ❌ Remove this import - Dio handles MimeType automatically

// 🔑 BASE URL CONSTANT එක
const String _BASE_URL = 'http://10.0.2.2:5000';

class AuthApiService {
  final Dio _dio;
  final AuthRepository _authRepository;

  AuthApiService(this._authRepository)
    : _dio = Dio(
        BaseOptions(
          baseUrl: _BASE_URL,
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 3),
        ),
      ) {
    // --------------------------------
    // Interceptors Logic
    // --------------------------------
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _authRepository.readToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
            await _authRepository.deleteToken();
          }
          return handler.next(e);
        },
      ),
    );
  }

  // 1. 🆕 Registration API Call with Files (Multipart)
  Future<Map<String, dynamic>> registerWithFiles({
    required String username,
    required String password,
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    String? address,
    String? whatsappNumber,
    String? telegram,
    required File frontIdImage,
    required File backIdImage,
  }) async {
    try {
      // 1. Files ටික MultipartFile බවට පත් කිරීම
      final frontPart = await MultipartFile.fromFile(
        frontIdImage.path,
        filename: frontIdImage.path.split('/').last,
        // ❌ contentType: MediaType('image', 'jpeg'), // Remove this line
      );

      final backPart = await MultipartFile.fromFile(
        backIdImage.path,
        filename: backIdImage.path.split('/').last,
        // ❌ contentType: MediaType('image', 'jpeg'), // Remove this line
      );

      // 2. FormData සකස් කිරීම (Keys Backend එකට ගැලපිය යුතුය)
      final formData = FormData.fromMap({
        'username': username,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phoneNumber': phoneNumber,
        'address': address ?? '',
        'whatsappNumber': whatsappNumber ?? '',
        'telegram': telegram ?? '',

        // 🎯 File Keys must match backend
        'idCardFront': frontPart,
        'idCardBack': backPart,
      });

      // 3. API Call
      final response = await _dio.post(
        '/api/auth/register',
        data:
            formData, // Dio will automatically set Content-Type: multipart/form-data
      );

      return response.data;
    } on DioException catch (e) {
      // ❌ Error handling
      throw Exception(
        e.response?.data['message'] ??
            'Registration Failed. Please check all fields.',
      );
    }
  }

  // 2. 🔑 Login API Call
  Future<String> login(String identifier, String password) async {
    try {
      final response = await _dio.post(
        '/api/auth/login',
        data: {'identifier': identifier, 'password': password},
      );

      final token = response.data['token'] as String;
      return token;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Login Failed');
    }
  }

  // 3. ♻️ Token Validity Check
  Future<bool> checkTokenValidity() async {
    try {
      await _dio.get('/api/auth/me');
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        return false;
      }
      return false;
    }
  }

  Future<bool> checkUsername(String username) async {
    print('DEBUG: Checking username: $username');

    try {
      final response = await _dio.post(
        '/api/auth/check-username',
        data: {'username': username},
      );

      print('DEBUG: API Response Status: ${response.statusCode}');
      print(
        'DEBUG: API Response Body: ${response.data}',
      ); // {available: false, message: ...}

      final int statusCode = response.statusCode ?? 0;

      if (statusCode >= 200 && statusCode < 300) {
        final Map<String, dynamic>? data =
            response.data as Map<String, dynamic>?;

        if (data != null) {
          // 🚨 FIX: 'is_available' වෙනුවට 'available' Key එක පරීක්ෂා කිරීම.
          if (data.containsKey('available')) {
            final isAvailable = data['available'] as bool? ?? true;
            print(
              'DEBUG: Determined availability from key "available": $isAvailable',
            );
            return isAvailable; // ⬅️ Taken නම් false return කරයි.
          }

          print(
            'DEBUG: "available" key not found in 2xx response. Assuming available (true).',
          );
          return true;
        }

        print(
          'DEBUG: 2xx response received, but data is null. Assuming available (true).',
        );
        return true;
      }

      print('DEBUG: Status code is not 2xx. Returning false.');
      return false;
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode ?? 0;
      print('DEBUG: DioException caught. Status Code: $statusCode');

      if (statusCode == 409 || statusCode == 400 || statusCode == 422) {
        print('DEBUG: Status code is 409/400/422. Returning false (TAKEN).');
        return false; // **Username is NOT Available (Taken)**
      }

      print('DEBUG: Other Dio error. Returning false.');
      return false;
    }
  }

  // ... [End of AuthApiService Class]
}
