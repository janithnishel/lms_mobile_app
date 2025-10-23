// ... (Imports)
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_app/data/repositories/auth_repository.dart';
import 'package:lms_app/data/services/auth_api_service.dart';
import 'package:lms_app/logic/auth/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final AuthApiService _authApiService;

  // 💡 නිවැරදි කළ Constructor: Dependencies ලබා ගෙන, super constructor එකට
  //    (Cubit<AuthState> එකට) ආරම්භක State එක යවයි.
  AuthCubit(this._authRepository, this._authApiService)
    : super(const AuthState(status: AuthStatus.initial));

  // 1. App එක ආරම්භයේදී Auth Status එක check කිරීම (Splash Screen එකේදී)
  Future<void> checkAuthStatus() async {
    // 1. Onboarding Status එක කියවා ගැනීම
    final bool hasSeenOnboarding = await _authRepository.hasSeenOnboarding();

    // 2. Local Token එක කියවා ගැනීම
    final token = await _authRepository.readToken();

    if (token == null) {
      // ⚠️ Token එකක් නැත්නම්, Onboarding Status එකත් එක්ක Unauthenticated කරන්න
      emit(
        AuthState(
          status: AuthStatus.unauthenticated,
          isOnboarded: hasSeenOnboarding, // 💡 Onboarding status එක save කරන්න
        ),
      );
      return;
    }

    // 3. Token එකක් තිබේ නම්, Server එකෙන් Valid ද කියලා check කරන්න
    try {
      final isValid = await _authApiService.checkTokenValidity();

      if (isValid) {
        // ✅ Server එකත් Valid, Home එකට යවන්න
        emit(
          AuthState(
            status: AuthStatus.authenticated,
            isOnboarded: hasSeenOnboarding, // 💡
          ),
        );
      } else {
        // ❌ Token Expired / Invalid - Login Page එකට යවන්න
        await _authRepository.deleteToken();
        emit(
          AuthState(
            status: AuthStatus.unauthenticated,
            isOnboarded: hasSeenOnboarding, // 💡
          ),
        );
      }
    } catch (e) {
      // Network Error හෝ වෙනත් Server error එකක්
      emit(
        AuthState(
          status: AuthStatus.unauthenticated,
          isOnboarded: hasSeenOnboarding,
          errorMessage: 'Auth check failed: ${e.toString()}',
        ),
      );
    }
  }

  // ----------------------------------------------------
  // 🆕 Onboarding Seen Logic
  // ----------------------------------------------------
  Future<void> completeOnboarding() async {
    await _authRepository.setOnboardingSeen();
    // Local state එක update කරන්න
    emit(state.copyWith(isOnboarded: true));
  }

  // me code eka ona weida danne na

  Future<void> login(String username, String password) async {
    // 1. Loading State එකට යන්න (Loader පෙන්වීමට)
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));

    try {
      // 2. 🔑 API Call එක සහ 300ms Delay එක එකවර ක්‍රියාත්මක කරන්න
      final results = await Future.wait([
        _authApiService.login(username, password), // ⬅️ සැබෑ API Call
        Future.delayed(
          const Duration(milliseconds: 300),
        ), // ⬅️ අවම Loader Delay
      ]);

      final token = results[0] as String;

      // 3. Token Save කරන්න
      await _authRepository.saveToken(token);

      // 4. ✅ Success: Home වෙත යවන්න
      emit(const AuthState(status: AuthStatus.authenticated));
    } catch (e) {
      // 5. ❌ Failure: Login Page එකේම තියාගෙන Error එක පෙන්වන්න
      // print("[AuthCubit] Login Failed: ${e.toString()}");

      emit(
        AuthState(
          status: AuthStatus
              .unauthenticated, // ⬅️ වැරදුණොත් unauthenticated වෙත යන්න
          errorMessage: e.toString().contains('Exception: ')
              ? e.toString().replaceFirst('Exception: ', '')
              : 'Login failed: Network Error',
        ),
      );
    }
  }

  //danata tiyenna ona code eka

  // Future<void> login(String username, String password) async {
  //   // 💡 Note: Your backend login requires username and password
  //   emit(
  //     state.copyWith(status: AuthStatus.loading, errorMessage: null),
  //   ); // Loading/Initial State
  //   try {
  //     final token = await _authApiService.login(username, password);
  //     await _authRepository.saveToken(token); // Token එක ආරක්ෂිතව save කිරීම

  //     // සාර්ථකව Login වූ පසු Authenticated තත්ත්වයට යන්න
  //     emit(const AuthState(status: AuthStatus.authenticated));
  //   } catch (e) {
  //     // Login අසාර්ථක වූ පසු, Error Message එකක් සමග Unauthenticated තත්ත්වයට යන්න
  //     emit(
  //       AuthState(
  //         status: AuthStatus.unauthenticated,
  //         errorMessage: e.toString().contains('Exception: ')
  //             ? e.toString().replaceFirst('Exception: ', '')
  //             : 'Login failed: Network Error',
  //       ),
  //     );
  //   }
  // }

  // ---------------  meka conection status eka hoyaganna damme
  // Future<void> login(String username, String password) async {
  //     // 💡 නිවැරදි කිරීම: Loading state එක පෙන්වන්න
  //     emit(
  //       state.copyWith(status: AuthStatus.loading, errorMessage: null),
  //     );

  //     try {
  //       // 💡 DEBUG LOG: API Call එක පටන් ගන්නා බව සටහන් කරන්න
  //       print("[AuthCubit] 🚀 Starting Login API Call for: $username");

  //       final token = await _authApiService.login(username, password);
  //       await _authRepository.saveToken(token); // Token එක ආරක්ෂිතව save කිරීම

  //       // 💡 DEBUG LOG: API Call එක සාර්ථකයි
  //       print("[AuthCubit] ✅ Login Successful. Token saved.");

  //       // සාර්ථකව Login වූ පසු Authenticated තත්ත්වයට යන්න
  //       emit(const AuthState(status: AuthStatus.authenticated));

  //     } catch (e) {
  //       // 💡 DEBUG LOG: API Call එක අසාර්ථකයි
  //       print("[AuthCubit] ❌ Login Failed with Error: $e");

  //       // Login අසාර්ථක වූ පසු, Error Message එකක් සමග Unauthenticated තත්ත්වයට යන්න
  //       emit(
  //         AuthState(
  //           status: AuthStatus.unauthenticated,
  //           errorMessage: e.toString().contains('Exception: ')
  //               ? e.toString().replaceFirst('Exception: ', '')
  //               : 'Login failed: Network Error',
  //         ),
  //       );
  //     }
  //   }
  //----------------------------------------------------
  //   Future<void> completeRegistration(String username, String password) async {
  //     // 💡 Note: ඔබගේ backend එකට email අවශ්‍ය නොවන නිසා, username සහ password පමණක් යවයි.
  //     emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
  //     try {
  //       // 1. Registration API Call කරන්න
  //       // 💡 AuthApiService එකේ register method එකට email අවශ්‍ය නැති බවට අපි යාවත්කාලීන කළා.
  //       await _authApiService.register(username, password);

  //       // 2. Registration සාර්ථක නම්, කෙලින්ම Login කරන්න
  //       // මේකෙන් Token එක Save වෙලා State එක Authenticated වෙනවා
  //       await login(username, password);
  //     } catch (e) {
  //       // Registration අසාර්ථක වූ පසු
  //       emit(
  //         AuthState(
  //           status: AuthStatus.unauthenticated,
  //           // isOnboarded: true ලෙස තබයි (user register වෙන්න උත්සාහ කළ නිසා)
  //           errorMessage: e.toString().contains('Exception: ')
  //               ? e.toString().replaceFirst('Exception: ', 'Registration Error: ')
  //               : 'Registration failed: Network Error',
  //         ),
  //       );
  //     }
  //   }
  // }

  Future<void> completeRegistration(String username, String password) async {
    // 1. Loading State එකට යන්න (Loader පෙන්වීමට)
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));

    try {
      // 2. 🔑 API Call එක සහ 300ms Delay එක එකවර ක්‍රියාත්මක කරන්න
      final results = await Future.wait([
        _authApiService.register(username, password), // ⬅️ සැබෑ API Call
        Future.delayed(
          const Duration(milliseconds: 300),
        ), // ⬅️ අවම Loader Delay
      ]);

      await completeOnboarding();
      // 3. Registration සාර්ථක වූ පසු (Token එකක් අවශ්‍ය නම් results[0] වෙතින් ලබාගත හැකිය)
      // අපි මෙහිදී Success Message එකක් පෙන්වා Login Screen එකට Redirect කරමු.

      // 4. ✅ Success: Login Screen එකට Redirect කරන්න
      emit(
        state.copyWith(
          status:
              AuthStatus.unauthenticated, // ⬅️ Logged out status එකේම තියාගෙන
          errorMessage:
              "Registration successful! Please log in.", // Success Message
        ),
      );
    } catch (e) {
      // 5. ❌ Failure: Register Page එකේම තියාගෙන Error එක පෙන්වන්න
      // print("[AuthCubit] Registration Failed: ${e.toString()}");

      emit(
        state.copyWith(
          status:
              AuthStatus.unauthenticated, // ⬅️ Logged out status එකේම තියාගෙන
          errorMessage: e.toString().contains('Exception: ')
              ? e.toString().replaceFirst('Exception: ', '')
              : 'Registration failed: Network Error',
        ),
      );
    }
  }

  Future<void> logout() async {
    // 1. Local Storage එකෙන් Token එක Delete කිරීම
    await _authRepository.deleteToken();

    // 2. State එක යාවත්කාලීන කිරීම
    emit(
      state.copyWith(
        status: AuthStatus.unauthenticated, // ⬅️ Logout වූ පසු unauthenticated තත්ත්වයට පත් කරයි
        user: null, // ⬅️ User data ඉවත් කරයි (අවශ්‍ය නම්)
        errorMessage: null, // Error එකක් තිබුණා නම් එය ඉවත් කරයි
      ),
    );
    // GoRouter විසින් unauthenticated තත්ත්වය දැක, User ව Login Page එකට redirect කරනු ඇත.
  }

  // ... (other methods)
}
