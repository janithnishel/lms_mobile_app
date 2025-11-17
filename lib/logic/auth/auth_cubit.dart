// 💡 අවශ්‍ය Imports
import 'dart:async';
import 'dart:io'; // 💡 File import එක අවශ්‍යයි

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_app/core/repositories/auth_repository.dart';
import 'package:lms_app/core/services/auth_api_service.dart';
import 'package:lms_app/logic/auth/auth_state.dart';
// import 'package:lms_app/models/user_model.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final AuthApiService _authApiService;

  // Constructor
  AuthCubit(this._authRepository, this._authApiService)
    : super(const AuthState(status: AuthStatus.initial));

  // ----------------------------------------------------
  // 1. Initial Auth Check (Splash Screen)
  // ----------------------------------------------------
  Future<void> checkAuthStatus() async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
    await Future.delayed(const Duration(seconds: 5));

    try {
      final bool hasSeenOnboarding = await _authRepository.hasSeenOnboarding();
      final token = await _authRepository.readToken();

      if (token == null) {
        emit(
          state.copyWith(
            status: AuthStatus.unauthenticated,
            isOnboarded: hasSeenOnboarding,
            errorMessage: null,
            user: null,
          ),
        );
        return;
      }

      final isValid = await _authApiService.checkTokenValidity();

      if (isValid) {
        emit(
          state.copyWith(
            status: AuthStatus.authenticated,
            isOnboarded: true,
            errorMessage: null,
          ),
        );
      } else {
        await _authRepository.deleteToken();
        emit(
          state.copyWith(
            status: AuthStatus.unauthenticated,
            isOnboarded: hasSeenOnboarding,
            errorMessage: 'Session expired. Please log in again.',
            user: null,
          ),
        );
      }
    } catch (e) {
      await _authRepository.deleteToken();
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          isOnboarded: state.isOnboarded,
          errorMessage:
              'Could not connect to server. Please check your connection.',
          user: null,
        ),
      );
    }
  }

  // ----------------------------------------------------
  // 2. Clear Error Logic
  // ----------------------------------------------------
  void clearError() {
    if (state.errorMessage != null) {
      // තත්වය කුමක් වුවත් Error එක clear කරන්න
      emit(state.copyWith(errorMessage: null));
    }
  }

  // ----------------------------------------------------
  // 3. Onboarding
  // ----------------------------------------------------
  Future<void> completeOnboarding() async {
    await _authRepository.setOnboardingSeen();
    emit(state.copyWith(isOnboarded: true));
  }

  // ----------------------------------------------------
  // 4. Login
  // ----------------------------------------------------
  Future<void> login(String identifier, String password) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));

    try {
      final results = await Future.wait([
        _authApiService.login(identifier, password),
        Future.delayed(const Duration(milliseconds: 300)),
      ]);

      final token = results[0] as String;
      await _authRepository.saveToken(token);

      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          isOnboarded: true,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          isOnboarded: state.isOnboarded,
          errorMessage: e.toString().contains('Exception: ')
              ? e.toString().replaceFirst('Exception: ', '')
              : 'Login failed: Network Error',
        ),
      );
    }
  }

  // 5. 🔎 Username Availability Check - NEW!
  // ----------------------------------------------------
  // Registration Screen එකේ TextField Validator එකට අවශ්‍යයයි.
  Future<bool> checkUsernameAvailability(String username) async {
    // 💡 මෙය කෙලින්ම API Call එක යවා, එහි ප්‍රතිඵලය (true/false) return කරයි.
    try {
      final isAvailable = await _authApiService.checkUsername(username);
      return isAvailable;
    } catch (e) {
      // Network error වගේ දෙයක් ආවොත්, සරලවම false (Not Available) කියලා return කරන්න.
      return false;
    }
  }

  // ----------------------------------------------------
  // 6. Registration (File Upload සමග) - UPDATED
  // ----------------------------------------------------
  Future<void> completeRegistration({
    required String username,
    required String password,
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    String? address,
    String? whatsappNumber,
    String? telegram,
    required File frontIdImage, // 💡 File Object
    required File backIdImage, // 💡 File Object
  }) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));

    try {
      await Future.wait([
        // 🚀 New API call to register with all data and files
        _authApiService.registerWithFiles(
          username: username,
          password: password,
          firstName: firstName,
          lastName: lastName,
          email: email,
          phoneNumber: phoneNumber,
          address: address,
          whatsappNumber: whatsappNumber,
          telegram: telegram,
          frontIdImage: frontIdImage,
          backIdImage: backIdImage,
        ),
        Future.delayed(const Duration(milliseconds: 300)),
      ]);

      await _authRepository.setOnboardingSeen();

      // ✅ Success (Login Screen වෙත යවන්න)
      emit(
        state.copyWith(
          status: AuthStatus
              .unauthenticated, // තවම ලොග් වී නැත, Login Screen වෙත යයි
          isOnboarded: true,
          errorMessage:
              "Registration successful! Please log in.", // Success Message එකක් Snackbar හරහා පෙන්වීමට
        ),
      );
    } catch (e) {
      // ❌ Failure
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          isOnboarded: state.isOnboarded,
          errorMessage: e.toString().contains('Exception: ')
              ? e.toString().replaceFirst('Exception: ', '')
              : 'Registration failed: Network Error',
        ),
      );
    }
  }

  // ----------------------------------------------------
  // 6. Logout
  // ----------------------------------------------------
  Future<void> logout() async {
    await _authRepository.deleteToken();

    emit(
      AuthState(
        status: AuthStatus.unauthenticated,
        user: null,
        errorMessage: null,
        isOnboarded: true,
      ),
    );
  }
}
