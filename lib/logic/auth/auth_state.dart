import 'package:equatable/equatable.dart';
import 'package:lms_app/data/models/user_model.dart';

enum AuthStatus {
  initial, // Token check කරනවා
  authenticated,
  unauthenticated,
  loading,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final String? errorMessage;
  final bool isOnboarded;
  final User? user; // 💡 අලුතින් එකතු කළා

  const AuthState({
    this.status = AuthStatus.initial,
    this.errorMessage,
    this.isOnboarded = false,
    this.user, // 💡 default false
  });

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    bool? isOnboarded,
    User? user, // 💡 copyWith එකට එකතු කළා
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      isOnboarded: isOnboarded ?? this.isOnboarded,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, isOnboarded, user]; // 💡 props වලට එකතු කළා
}
