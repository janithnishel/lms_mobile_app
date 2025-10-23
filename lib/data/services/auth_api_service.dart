// import 'package:dio/dio.dart';
// import '../repositories/auth_repository.dart'; // කලින් හදපු AuthRepository එක

// class AuthApiService {
//   final Dio _dio;
//   final AuthRepository _authRepository;

//   AuthApiService(this._authRepository)
//     : _dio = Dio(
//         BaseOptions(
//           // 🌐 BASE URL එක: http://localhost:5000/api/auth
//           // 💡 සටහන: Live වෙද්දී 'http://localhost:5000' වෙනුවට Domain Name එක යොදන්න.
//           baseUrl: 'http://10.0.2.2:5000/api',
//           connectTimeout: const Duration(seconds: 5),
//           receiveTimeout: const Duration(seconds: 3),
//         ),
//       ) {
//     // 🌐 Interceptor: හැම request එකකටම Token එක add කරන්න
//     _dio.interceptors.add(
//       InterceptorsWrapper(
//         onRequest: (options, handler) async {
//           final token = await _authRepository.readToken();
//           if (token != null) {
//             // Authorization Header එක: 'Bearer <token>' format එක
//             options.headers['Authorization'] = 'Bearer $token';
//           }
//           return handler.next(options);
//         },
//         // ⚠️ Response එක 401 (Unauthorized) හෝ 403 (Forbidden) නම්
//         onError: (DioException e, handler) async {
//           if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
//             // Token Expired හෝ Invalid නම්, Local token එක Delete කරන්න
//             await _authRepository.deleteToken();
//             // මේකෙන් Cubit එකට කියවෙන්නේ නැවත login වෙන්න ඕනේ කියලා.
//           }
//           return handler.next(e);
//         },
//       ),
//     );
//   }

//   // 1. 🆕 Registration API Call (Path: /register)
//   // 💡 Backend එකට අනුව, මේ method එකට email අවශ්‍ය නැත. username සහ password පමණයි.
//   Future<Map<String, dynamic>> register(
//     String username,
//     String password,
//   ) async {
//     try {
//       final response = await _dio.post(
//         '/register', // සම්පූර්ණ path: BASE_URL + /register
//         data: {'username': username, 'password': password},
//       );
//       return response.data;
//     } on DioException catch (e) {
//       throw Exception(e.response?.data['message'] ?? 'Registration Failed');
//     }
//   }

//   // 2. 🔑 Login API Call (Path: /login)
//   Future<String> login(String username, String password) async {
//     await Future.delayed(const Duration(seconds: 1));
//     try {
//       final response = await _dio.post(
//         '/login', // සම්පූර්ණ path: BASE_URL + /login
//         data: {'username': username, 'password': password},
//       );

//       // ✅ සාර්ථක නම්, response එකෙන් Token එක extract කරලා return කරන්න
//       // ⚠️ වැදගත්: ඔබගේ backend එක Token එක cookie එකක් ලෙස පමණක් එවන නිසා,
//       // Flutter App එකට Token එක ලැබීමට නම්, backend login controller එක token එක JSON body එකේත් return කරන්න වෙනවා.
//       // (උදා: res.json({... , token: token}))
//       final token = response.data['token'] as String;
//       return token;
//     } on DioException catch (e) {
//       // API call failed
//       throw Exception(e.response?.data['message'] ?? 'Login Failed');
//     }
//   }

//   // 3. ♻️ Token Validity Check (Path: /me)
//   // මේ call එක සාර්ථක නම් (200 OK), Token එක Valid
//   Future<bool> checkTokenValidity() async {
//     try {
//       // මේ call එකේදී Interceptor එකෙන් Token එක Header එකට එකතු කරයි.
//       await _dio.get('/me');
//       return true; // call එක සාර්ථකයි
//     } on DioException catch (e) {
//       // 401/403 එනවා නම්, Interceptor එකෙන් deleteToken() call වෙලා ඇති, අපි false return කරනවා.
//       if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
//         return false;
//       }
//       // වෙනත් error එකක් (Network/Server) නම්, අපි සාමාන්‍යයෙන් false කියලා හිතනවා.
//       return false;
//     }
//   }
// }

import 'package:dio/dio.dart';
import '../repositories/auth_repository.dart';

// 🔑 BASE URL CONSTANT එක නිවැරදිව define කිරීම
// 💡 Base URL එක '/api' දක්වා පමණක් සීමා කරයි.
const String _BASE_URL = 'http://10.0.2.2:5000/api';

class AuthApiService {
  final Dio _dio;
  final AuthRepository _authRepository;

  AuthApiService(this._authRepository)
    : _dio = Dio(
        BaseOptions(
          // 🌐 Base URL එක දැන් http://10.0.2.2:5000/api ලෙස සීමා වී ඇත.
          baseUrl: _BASE_URL,
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 3),
        ),
      ) {
    // ... (Interceptors Logic)
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

  // 1. 🆕 Registration API Call
  // 💡 Full URL: http://10.0.2.2:5000/api/auth/register
  Future<Map<String, dynamic>> register(
    String username,
    String password,
  ) async {
    try {
      final response = await _dio.post(
        '/auth/register', // ⬅️ මෙහිදී 'auth' කියන කොටස ඇතුළත් කරයි.
        data: {'username': username, 'password': password},
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Registration Failed');
    }
  }

  // 2. 🔑 Login API Call
  // 💡 Full URL: http://10.0.2.2:5000/api/auth/login
  Future<String> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login', // ⬅️ මෙහිදී 'auth' කියන කොටස ඇතුළත් කරයි.
        data: {'username': username, 'password': password},
      );

      final token = response.data['token'] as String;
      return token;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Login Failed');
    }
  }

  // 3. ♻️ Token Validity Check
  // 💡 Full URL: http://10.0.2.2:5000/api/auth/me
  Future<bool> checkTokenValidity() async {
    try {
      await _dio.get('/auth/me'); // ⬅️ මෙහිදී 'auth' කියන කොටස ඇතුළත් කරයි.
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        return false;
      }
      return false;
    }
  }
}
