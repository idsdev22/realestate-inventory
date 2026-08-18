class UserModel {
  final int? id;
  final String? role;
  final String? email;

  UserModel({
    this.id,
    this.role,
    this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? ''),
      role: json['role'] as String?,
      email: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'email': email,
    };
  }

  UserModel copyWith({
    int? id,
    String? role,
    String? email,
  }) {
    return UserModel(
      id: id ?? this.id,
      role: role ?? this.role,
      email: email ?? this.email,
    );
  }
}

class AuthResponseModel {
  final bool success;
  final String? token;
  final UserModel? user;
  final String? message;

  AuthResponseModel({
    required this.success,
    this.token,
    this.user,
    this.message,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    UserModel? parsedUser;
    String? parsedToken;

    if (json['data'] is Map<String, dynamic>) {
      final dataMap = json['data'] as Map<String, dynamic>;
      parsedToken = dataMap['token']?.toString();
      if (dataMap['user'] is Map<String, dynamic>) {
        parsedUser = UserModel.fromJson(dataMap['user'] as Map<String, dynamic>);
      }
    }

    return AuthResponseModel(
      success: json['success'] == true,
      token: parsedToken,
      user: parsedUser,
      message: json['message'] as String?,
    );
  }
}
