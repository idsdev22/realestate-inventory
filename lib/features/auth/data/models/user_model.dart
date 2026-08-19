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
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLoginAt;

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
    this.createdAt,
    this.updatedAt,
    this.lastLoginAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    List<dynamic>? parsedProjects;
    if (json['project_ids'] != null && json['project_ids'] is List) {
      parsedProjects = json['project_ids'] as List<dynamic>;
    } else if (json['projects'] != null && json['projects'] is List) {
      parsedProjects = json['projects'] as List<dynamic>;
    }

    return UserModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      avatar: json['avatar'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      role: json['role'] as String?,
      status: json['status'] as String? ?? 'active',
      companyId: json['company_id'] is int ? json['company_id'] as int : int.tryParse(json['company_id']?.toString() ?? ''),
      companyName: json['company_name'] as String? ?? json['company']?['name']?.toString(),
      initials: json['initials'] as String?,
      projects: parsedProjects,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
      lastLoginAt: json['last_login_at'] != null ? DateTime.tryParse(json['last_login_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (avatar != null) 'avatar': avatar,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (role != null) 'role': role,
      if (status != null) 'status': status,
      if (companyId != null) 'company_id': companyId,
      if (companyName != null) 'company_name': companyName,
      if (initials != null) 'initials': initials,
      if (projects != null) 'projects': projects,
      if (projectIds.isNotEmpty) 'project_ids': projectIds,
      if (createdAt != null) 'created_at': createdAt?.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt?.toIso8601String(),
    };
  }

  List<int> get projectIds {
    if (projects == null) return [];
    return projects!.map((p) {
      if (p is int) return p;
      if (p is Map<String, dynamic> && p['id'] != null) {
        return p['id'] is int ? p['id'] as int : int.tryParse(p['id'].toString()) ?? 0;
      }
      return int.tryParse(p.toString()) ?? 0;
    }).where((id) => id > 0).toList();
  }

  List<String> get projectNames {
    if (projects == null) return [];
    return projects!.map((p) {
      if (p is Map<String, dynamic>) {
        return (p['name'] ?? p['project_name'] ?? '').toString();
      }
      return '';
    }).where((n) => n.isNotEmpty).toList();
  }

  String get roleFormatted {
    switch (role?.toLowerCase()) {
      case 'promoter_admin':
        return 'Promoter Admin';
      case 'marketing_team_admin':
        return 'Marketing Team Admin';
      case 'marketing_team_user':
        return 'Marketing Team User';
      case 'staff':
      case 'staffs':
        return 'Staff';
      default:
        if (role == null || role!.isEmpty) return 'User';
        return role!.split('_').map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '').join(' ');
    }
  }

  bool get isActive => (status ?? 'active').toLowerCase() == 'active';

  String get userInitials {
    if (initials != null && initials!.isNotEmpty) return initials!;
    if (name != null && name!.trim().isNotEmpty) {
      final parts = name!.trim().split(RegExp(r'\s+'));
      if (parts.length > 1 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return name!.trim()[0].toUpperCase();
    }
    return 'U';
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
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
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
