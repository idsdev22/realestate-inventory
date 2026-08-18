class UserModel {
  final int? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? avatar;
  final String? avatarUrl;
  final String? role;
  final String? status;
  final int? companyId;
  final String? companyName;
  final String? initials;
  final List<dynamic>? projects;

  UserModel({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.avatar,
    this.avatarUrl,
    this.role,
    this.status,
    this.companyId,
    this.companyName,
    this.initials,
    this.projects,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      avatar: json['avatar'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      role: json['role'] as String?,
      status: json['status'] as String?,
      companyId: json['company_id'] is int ? json['company_id'] as int : int.tryParse(json['company_id']?.toString() ?? ''),
      companyName: json['company_name'] as String?,
      initials: json['initials'] as String?,
      projects: json['projects'] as List<dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'avatar_url': avatarUrl,
      'role': role,
      'status': status,
      'company_id': companyId,
      'company_name': companyName,
      'initials': initials,
      'projects': projects,
    };
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? avatar,
    String? avatarUrl,
    String? role,
    String? status,
    int? companyId,
    String? companyName,
    String? initials,
    List<dynamic>? projects,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      status: status ?? this.status,
      companyId: companyId ?? this.companyId,
      companyName: companyName ?? this.companyName,
      initials: initials ?? this.initials,
      projects: projects ?? this.projects,
    );
  }
}

class AuthResponseModel {
  final bool success;
  final String? token;
  final int? expiresIn;
  final UserModel? user;
  final String? message;

  AuthResponseModel({
    required this.success,
    this.token,
    this.expiresIn,
    this.user,
    this.message,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    UserModel? parsedUser;
    String? parsedToken;
    int? parsedExpiresIn;

    if (json['data'] is Map<String, dynamic>) {
      final dataMap = json['data'] as Map<String, dynamic>;
      parsedToken = dataMap['token']?.toString();
      parsedExpiresIn = dataMap['expires_in'] is int ? dataMap['expires_in'] as int : int.tryParse(dataMap['expires_in']?.toString() ?? '');
      if (dataMap['user'] is Map<String, dynamic>) {
        parsedUser = UserModel.fromJson(dataMap['user'] as Map<String, dynamic>);
      }
    }

    return AuthResponseModel(
      success: json['success'] == true,
      token: parsedToken,
      expiresIn: parsedExpiresIn,
      user: parsedUser,
      message: json['message'] as String?,
    );
  }
}
