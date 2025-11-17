import 'package:equatable/equatable.dart';
import 'package:lms_app/models/user_model.dart';

// Auth Status පෙන්වන Enums
enum AuthStatus {
  initial, // Splash screen එකේදී Token check කරනවා
  authenticated, // Logged in
  unauthenticated, // Logged out
  loading, // Operation එකක් සිදු වෙමින් පවතී
}

class AuthState extends Equatable {
  final AuthStatus status;
  final String? errorMessage;
  final bool isOnboarded;
  final UserModel? user; // Logged in User ගේ data

  const AuthState({
    this.status = AuthStatus.initial,
    this.errorMessage,
    this.isOnboarded = false, // Default: Onboarding සම්පූර්ණ කර නැත
    this.user,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    bool? isOnboarded,
    UserModel? user,
  }) {
    // errorMessage: null ලබා දීමෙන් Error එක clear කළ හැක
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      isOnboarded: isOnboarded ?? this.isOnboarded,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, isOnboarded, user];
}
