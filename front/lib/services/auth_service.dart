import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  User? _currentUser;
  bool _isLoggedIn = false;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;

  AuthService() {
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final isLoggedIn = await ApiService.isLoggedIn();
      if (isLoggedIn) {
        final response = await ApiService.getProfile();
        if (response.success && response.data != null) {
          _currentUser = response.data;
          _isLoggedIn = true;
        } else {
          _isLoggedIn = false;
          _currentUser = null;
        }
      }
    } catch (e) {
      _isLoggedIn = false;
      _currentUser = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<LoginResult> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.login(username, password);

      if (response.success && response.data != null) {
        _currentUser = User(
          id: response.data!.id,
          username: response.data!.username,
          email: response.data!.email,
          role: response.data!.role,
          createdAt: response.data!.createdAt,
          updatedAt: response.data!.updatedAt,
        );
        _isLoggedIn = true;

        // Sauvegarder les informations utilisateur localement
        await _saveUserData();

        _isLoading = false;
        notifyListeners();
        return LoginResult.success();
      } else {
        _isLoading = false;
        notifyListeners();
        return LoginResult.error(response.message ?? 'Erreur de connexion');
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return LoginResult.error('Erreur de connexion au serveur');
    }
  }

  Future<RegisterResult> register(
    String username,
    String email,
    String password,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.register(username, email, password);

      if (response.success && response.data != null) {
        _isLoading = false;
        notifyListeners();
        return RegisterResult.success();
      } else {
        _isLoading = false;
        notifyListeners();
        return RegisterResult.error(
          response.message ?? 'Erreur d\'inscription',
        );
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return RegisterResult.error('Erreur de connexion au serveur');
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await ApiService.logout();
    } catch (e) {
      // Continuer la déconnexion même si l'API échoue
    }

    _currentUser = null;
    _isLoggedIn = false;
    await _clearUserData();

    _isLoading = false;
    notifyListeners();
  }

  Future<UpdateProfileResult> updateProfile({
    String? username,
    String? email,
    String? password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.updateProfile(
        username: username,
        email: email,
        password: password,
      );

      if (response.success && response.data != null) {
        _currentUser = response.data!.user;
        await _saveUserData();

        _isLoading = false;
        notifyListeners();
        return UpdateProfileResult.success();
      } else {
        _isLoading = false;
        notifyListeners();
        return UpdateProfileResult.error(
          response.message ?? 'Erreur de mise à jour',
        );
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return UpdateProfileResult.error('Erreur de connexion au serveur');
    }
  }

  Future<void> _saveUserData() async {
    if (_currentUser != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', _currentUser!.username);
      await prefs.setString('email', _currentUser!.email);
      await prefs.setString('login_date', DateTime.now().toString());
    }
  }

  Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('email');
    await prefs.remove('login_date');
  }
}

// Classes de résultats
class LoginResult {
  final bool success;
  final String? errorMessage;

  LoginResult.success() : success = true, errorMessage = null;
  LoginResult.error(this.errorMessage) : success = false;
}

class RegisterResult {
  final bool success;
  final String? errorMessage;

  RegisterResult.success() : success = true, errorMessage = null;
  RegisterResult.error(this.errorMessage) : success = false;
}

class UpdateProfileResult {
  final bool success;
  final String? errorMessage;

  UpdateProfileResult.success() : success = true, errorMessage = null;
  UpdateProfileResult.error(this.errorMessage) : success = false;
}
