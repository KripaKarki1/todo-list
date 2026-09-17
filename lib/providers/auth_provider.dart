import 'package:flutter/material.dart';
import 'package:ncmt_kripa/services/auth/auth_service.dart';

sealed class AuthResult {}

class AuthSuccess extends AuthResult {}
class AuthFailure extends AuthResult {
  final String message;
  AuthFailure(this.message);
}



class AuthenticationProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<AuthResult> register({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.register(
        email: email,
        password: password,
      );

      return AuthSuccess();
    } catch (e) {
      return AuthFailure(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.login(
        email: email,
        password: password,
      );

      return AuthSuccess();
    } catch (e) {
      return AuthFailure(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
  }
}