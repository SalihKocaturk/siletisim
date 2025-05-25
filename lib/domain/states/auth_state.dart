part of '../cubits/auth_cubit.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final String message;
  AuthSuccess(this.message);
}

class AuthFailure extends AuthState {
  final String error;
  AuthFailure(this.error);
}

class AuthEmailIn extends AuthState {
  final String email;
  AuthEmailIn({required this.email});
}

class AuthLoggedIn extends AuthState {
  final String email;
  final String name;
  final String uid;
  final String role;
  final String? accessToken; // ✅ bunu ekle

  AuthLoggedIn({
    required this.email,
    required this.name,
    required this.uid,
    required this.role,
    this.accessToken,
  });
}
