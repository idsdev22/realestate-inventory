class CompanyProject {
  final int id;
  final String name;
  final String? city;

  const CompanyProject({
    required this.id,
    required this.name,
    this.city,
  });

  factory CompanyProject.fromJson(Map<String, dynamic> json) {
    return CompanyProject(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      city: json['city']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (city != null) 'city': city,
  };
}

class CompanyModel {
  final int? id;
  final String name;
  final String email;
  final String phone;
  final String city;
  final String address;
  final String status;
  final List<String> permissions;
  final List<int> projectIds;
  final String? fcmToken;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? userCount;
  final int? projectCount;
  final List<CompanyProject>? projects;
  final List<String>? projectNames;

  const CompanyModel({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.city,
    required this.address,
    this.status = 'active',
    this.permissions = const [
      'view_inventory',
      'submit_block_requests',
      'manage_users',
    ],
    this.projectIds = const [],
    this.fcmToken,
    this.createdAt,
    this.updatedAt,
    this.userCount,
    this.projectCount,
    this.projects,
    this.projectNames,
  });

  bool get isActive => status.toLowerCase() == 'active';

  bool hasPermission(String permission) => permissions.contains(permission);

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedPermissions = [];
    if (json['permissions'] != null) {
      if (json['permissions'] is List) {
        parsedPermissions = (json['permissions'] as List)
            .map((e) => e.toString())
            .toList();
      }
    }

    List<CompanyProject>? parsedProjects;
    List<String>? parsedProjectNames;
    List<int> parsedProjectIds = [];

    if (json['projects'] != null && json['projects'] is List) {
      parsedProjects = [];
      parsedProjectNames = [];
      for (final p in json['projects']) {
        if (p is Map) {
          final mapped = Map<String, dynamic>.from(p);
          final cp = CompanyProject.fromJson(mapped);
          parsedProjects.add(cp);
          if (cp.id > 0) parsedProjectIds.add(cp.id);
          if (cp.name.isNotEmpty) parsedProjectNames.add(cp.name);
        } else if (p is int) {
          parsedProjectIds.add(p);
        }
      }
    }

    if (json['project_ids'] != null && json['project_ids'] is List) {
      for (final e in (json['project_ids'] as List)) {
        final pId = e is int ? e : int.tryParse(e.toString()) ?? 0;
        if (pId > 0 && !parsedProjectIds.contains(pId)) {
          parsedProjectIds.add(pId);
        }
      }
    }

    if (json['project_names'] != null && json['project_names'] is List) {
      parsedProjectNames ??= [];
      for (final name in json['project_names']) {
        final str = name.toString();
        if (!parsedProjectNames.contains(str)) {
          parsedProjectNames.add(str);
        }
      }
    }

    final int? parsedProjectCount = json['project_count'] is int
        ? json['project_count']
        : (int.tryParse(json['project_count']?.toString() ?? '') ??
            (parsedProjects?.isNotEmpty == true
                ? parsedProjects!.length
                : (parsedProjectIds.isNotEmpty ? parsedProjectIds.length : null)));

    return CompanyModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      status: json['status']?.toString() ?? 'active',
      permissions: parsedPermissions.isNotEmpty
          ? parsedPermissions
          : const ['view_inventory', 'submit_block_requests', 'manage_users'],
      projectIds: parsedProjectIds,
      fcmToken: json['fcm_token']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      userCount: json['user_count'] is int
          ? json['user_count']
          : int.tryParse(json['user_count']?.toString() ?? ''),
      projectCount: parsedProjectCount,
      projects: parsedProjects,
      projectNames: parsedProjectNames,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'city': city,
      'address': address,
      'status': status,
      'permissions': permissions,
      'project_ids': projectIds,
      if (fcmToken != null && fcmToken!.isNotEmpty) 'fcm_token': fcmToken,
    };
  }

  CompanyModel copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? city,
    String? address,
    String? status,
    List<String>? permissions,
    List<int>? projectIds,
    String? fcmToken,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? userCount,
    int? projectCount,
    List<CompanyProject>? projects,
    List<String>? projectNames,
  }) {
    return CompanyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      address: address ?? this.address,
      status: status ?? this.status,
      permissions: permissions ?? this.permissions,
      projectIds: projectIds ?? this.projectIds,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userCount: userCount ?? this.userCount,
      projectCount: projectCount ?? this.projectCount,
      projects: projects ?? this.projects,
      projectNames: projectNames ?? this.projectNames,
    );
  }

  static const List<Map<String, String>> availablePermissions = [
    {
      'key': 'view_inventory',
      'label': 'View Inventory',
      'description': 'Access unit listings, status map and layout plans',
    },
    {
      'key': 'submit_block_requests',
      'label': 'Submit Block Requests',
      'description': 'Place temporary reservation holds on available plots',
    },
    {
      'key': 'manage_users',
      'label': 'Manage Team Users',
      'description': 'Create and manage sales executives and marketing staff',
    },
    {
      'key': 'edit_inventory',
      'label': 'Edit Inventory',
      'description': 'Modify pricing and plot specification details',
    },
    {
      'key': 'view_reports',
      'label': 'View Sales Reports',
      'description': 'Access detailed booking and performance analytics',
    },
  ];
}
