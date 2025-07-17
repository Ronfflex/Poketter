class User {
  final int id;
  final String username;
  final String email;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      role: json['role'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class LoginResponse {
  final int id;
  final String username;
  final String email;
  final String role;
  final String authToken;
  final DateTime createdAt;
  final DateTime updatedAt;

  LoginResponse({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.authToken,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      role: json['role'],
      authToken: json['authToken'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class LogoutResponse {
  final String message;
  final User user;

  LogoutResponse({required this.message, required this.user});

  factory LogoutResponse.fromJson(Map<String, dynamic> json) {
    return LogoutResponse(
      message: json['message'],
      user: User.fromJson(json['user']),
    );
  }
}

class UpdateUserResponse {
  final String message;
  final User user;

  UpdateUserResponse({required this.message, required this.user});

  factory UpdateUserResponse.fromJson(Map<String, dynamic> json) {
    return UpdateUserResponse(
      message: json['message'],
      user: User.fromJson(json['user']),
    );
  }
}
