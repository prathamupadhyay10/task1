import 'package:equatable/equatable.dart';
import '../../../../models/app_user.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState extends Equatable {
  final AuthStatus status;
  final AppUser? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  const AuthState.initial()
      : status = AuthStatus.initial,
        user = null,
        errorMessage = null;

  const AuthState.loading()
      : status = AuthStatus.loading,
        user = null,
        errorMessage = null;

  factory AuthState.authenticated(AppUser user) {
    return AuthState(
      status: AuthStatus.authenticated,
      user: user,
      errorMessage: null,
    );
  }

  factory AuthState.unauthenticated() {
    return const AuthState(
      status: AuthStatus.unauthenticated,
      user: null,
      errorMessage: null,
    );
  }

  factory AuthState.authError(String message) {
    return AuthState(
      status: AuthStatus.error,
      user: null,
      errorMessage: message,
    );
  }

  bool get isAuthenticated => user != null;
  bool get isAdmin => user?.isAdmin ?? false;

  @override
  List<Object?> get props => [status, user, errorMessage];

  AuthState copyWith({
    AuthStatus? status,
    AppUser? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
