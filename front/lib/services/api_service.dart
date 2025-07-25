import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/api.dart';
import '../models/like.dart';
import '../models/user.dart';
import '../models/view.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';

  static Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> _saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> _removeAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
  };

  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _getAuthToken();
    final headers = Map<String, String>.from(_headers);
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<ApiResponse<T>> _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>)? fromJson,
  ) async {
    try {
      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.success(
          data: fromJson != null ? fromJson(data) : data as T,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse.error(
          message: data['error'] ?? 'Une erreur est survenue',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Erreur de connexion au serveur',
        statusCode: response.statusCode,
      );
    }
  }

  // Méthodes d'authentification
  static Future<ApiResponse<LoginResponse>> login(
    String username,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _headers,
        body: jsonEncode({'username': username, 'password': password}),
      );

      final result = await _handleResponse<LoginResponse>(
        response,
        (data) => LoginResponse.fromJson(data),
      );

      if (result.success && result.data != null) {
        await _saveAuthToken(result.data!.authToken);
      }

      return result;
    } catch (e) {
      return ApiResponse.error(message: 'Erreur de connexion');
    }
  }

  static Future<ApiResponse<User>> register(
    String username,
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: _headers,
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      return await _handleResponse<User>(
        response,
        (data) => User.fromJson(data),
      );
    } catch (e) {
      return ApiResponse.error(message: 'Erreur de connexion');
    }
  }

  static Future<ApiResponse<LogoutResponse>> logout() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/auth/logout'),
        headers: headers,
      );

      final result = await _handleResponse<LogoutResponse>(
        response,
        (data) => LogoutResponse.fromJson(data),
      );

      if (result.success) {
        await _removeAuthToken();
      }

      return result;
    } catch (e) {
      return ApiResponse.error(message: 'Erreur de déconnexion');
    }
  }

  // Méthodes utilisateur
  static Future<ApiResponse<User>> getProfile() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/user/profile'),
        headers: headers,
      );

      return await _handleResponse<User>(
        response,
        (data) => User.fromJson(data),
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Erreur lors de la récupération du profil',
      );
    }
  }

  static Future<ApiResponse<UpdateUserResponse>> updateProfile({
    String? username,
    String? email,
    String? password,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final body = <String, dynamic>{};

      if (username != null) body['username'] = username;
      if (email != null) body['email'] = email;
      if (password != null) body['password'] = password;

      final response = await http.put(
        Uri.parse('$baseUrl/user/'),
        headers: headers,
        body: jsonEncode(body),
      );

      return await _handleResponse<UpdateUserResponse>(
        response,
        (data) => UpdateUserResponse.fromJson(data),
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Erreur lors de la mise à jour du profil',
      );
    }
  }

  static Future<bool> isLoggedIn() async {
    final token = await _getAuthToken();
    return token != null;
  }

  // Méthodes pour les likes
  static Future<ApiResponse<List<Like>>> getLikes() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/like'),
        headers: headers,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List<dynamic> data = jsonDecode(response.body);
        final likes = data.map((json) => Like.fromJson(json)).toList();
        return ApiResponse.success(
          data: likes,
          statusCode: response.statusCode,
        );
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return ApiResponse.error(
          message: errorData['error'] ?? 'Une erreur est survenue',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Erreur lors de la récupération des likes',
      );
    }
  }

  static Future<ApiResponse<List<View>>> getViews() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/view'),
        headers: headers,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List<dynamic> data = jsonDecode(response.body);
        final views = data.map((json) => View.fromJson(json)).toList();
        return ApiResponse.success(
          data: views,
          statusCode: response.statusCode,
        );
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return ApiResponse.error(
          message: errorData['error'] ?? 'Une erreur est survenue',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Erreur lors de la récupération des vues',
      );
    }
  }

  static Future<ApiResponse<Like>> likePokemon(int pokemonId) async {
    try {
      final headers = await _getAuthHeaders();
      final profile = await getProfile();

      if (!profile.success || profile.data == null) {
        return ApiResponse.error(message: 'Utilisateur non connecté');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/like'),
        headers: headers,
        body: jsonEncode({'pokemonId': pokemonId}),
      );

      return await _handleResponse<Like>(
        response,
        (data) => Like.fromJson(data),
      );
    } catch (e) {
      return ApiResponse.error(message: 'Erreur lors de l\'ajout du like');
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> unlikePokemon(
    int pokemonId,
  ) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/like/$pokemonId'),
        headers: headers,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return ApiResponse.success(data: data, statusCode: response.statusCode);
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return ApiResponse.error(
          message: errorData['error'] ?? 'Une erreur est survenue',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Erreur lors de la suppression du like',
      );
    }
  }

  static Future<ApiResponse<View>> createView(int pokemonId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/view'),
        headers: headers,
        body: jsonEncode({'pokemonId': pokemonId}),
      );

      return await _handleResponse<View>(
        response,
        (data) => View.fromJson(data),
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Erreur lors de l\'enregistrement de la vue',
      );
    }
  }
}
