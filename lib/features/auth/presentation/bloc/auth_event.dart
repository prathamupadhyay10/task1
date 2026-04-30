import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  AuthLoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String role;

  AuthSignUpRequested({
    required this.email,
    required this.password,
    required this.name,
    this.role = 'user',
  });

  @override
  List<Object?> get props => [email, password, name, role];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthCheckRequested extends AuthEvent {}

class AuthRoleCheckRequested extends AuthEvent {
  final String uid;

  AuthRoleCheckRequested({required this.uid});

  @override
  List<Object?> get props => [uid];
}
