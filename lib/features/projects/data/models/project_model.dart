class ProjectModel {
  final int id;
  final String name;
  final String location;
  final String city;
  final String projectType;
  final String? description;
  final String? approvalDetails;
  final String? contactName;
  final String? contactPhone;
  final String? contactEmail;
  final String? coverImage;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  // Aggregated or derived fields that might not be in the base DB schema but are useful in UI
  final int totalUnits;
  final int availableUnits;
  final int blockedUnits;
  final int bookedUnits;
  final int registeredUnits;
  final List<String> blocks;

  ProjectModel({
    required this.id,
    required this.name,
    required this.location,
    required this.city,
    this.projectType = 'Residential Plot',
    this.description,
    this.approvalDetails,
    this.contactName,
    this.contactPhone,
    this.contactEmail,
    this.coverImage,
    this.status = 'active',
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.totalUnits = 0,
    this.availableUnits = 0,
    this.blockedUnits = 0,
    this.bookedUnits = 0,
    this.registeredUnits = 0,
    this.blocks = const [],
  });

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    final counts = json['counts'] is Map<String, dynamic>
        ? json['counts'] as Map<String, dynamic>
        : (json['counts'] is Map ? Map<String, dynamic>.from(json['counts']) : null);

    return ProjectModel(
      id: _parseInt(json['id']),
      name: (json['name'] ?? json['project_name'] ?? json['title'] ?? '').toString(),
      location: (json['location'] ?? json['project_location'] ?? json['address'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
      projectType: (json['project_type'] ?? json['type'] ?? 'Residential Plot').toString(),
      description: json['description']?.toString(),
      approvalDetails: (json['approval_details'] ?? json['approval'] ?? json['approval_status'])?.toString(),
      contactName: json['contact_name']?.toString(),
      contactPhone: json['contact_phone']?.toString(),
      contactEmail: json['contact_email']?.toString(),
      coverImage: (json['cover_image_url'] ?? json['cover_image'] ?? json['image'] ?? json['image_url'])?.toString(),
      status: (json['status'] ?? 'active').toString(),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
      deletedAt: json['deleted_at'] != null ? DateTime.tryParse(json['deleted_at'].toString()) : null,
      totalUnits: _parseInt(counts?['total'] ?? json['total_units'] ?? json['totalUnits']),
      availableUnits: _parseInt(counts?['available'] ?? json['available_units'] ?? json['availableUnits']),
      blockedUnits: _parseInt(counts?['blocked'] ?? json['blocked_units'] ?? json['blockedUnits']),
      bookedUnits: _parseInt(counts?['booked'] ?? json['booked_units'] ?? json['bookedUnits']),
      registeredUnits: _parseInt(counts?['registered'] ?? json['registered_units'] ?? json['registeredUnits']),
      blocks: json['blocks'] is List
          ? List<String>.from((json['blocks'] as List).map((e) => e.toString()))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'city': city,
      'project_type': projectType,
      'description': description,
      'approval_details': approvalDetails,
      'contact_name': contactName,
      'contact_phone': contactPhone,
      'contact_email': contactEmail,
      'cover_image': coverImage,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  ProjectModel copyWith({
    int? id,
    String? name,
    String? location,
    String? city,
    String? projectType,
    String? description,
    String? approvalDetails,
    String? contactName,
    String? contactPhone,
    String? contactEmail,
    String? coverImage,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    int? totalUnits,
    int? availableUnits,
    int? blockedUnits,
    int? bookedUnits,
    int? registeredUnits,
    List<String>? blocks,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      city: city ?? this.city,
      projectType: projectType ?? this.projectType,
      description: description ?? this.description,
      approvalDetails: approvalDetails ?? this.approvalDetails,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
      contactEmail: contactEmail ?? this.contactEmail,
      coverImage: coverImage ?? this.coverImage,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      totalUnits: totalUnits ?? this.totalUnits,
      availableUnits: availableUnits ?? this.availableUnits,
      blockedUnits: blockedUnits ?? this.blockedUnits,
      bookedUnits: bookedUnits ?? this.bookedUnits,
      registeredUnits: registeredUnits ?? this.registeredUnits,
      blocks: blocks ?? this.blocks,
    );
  }

  // Getter for backward compatibility and UI usage
  String get imageUrl => coverImage ?? 'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=600&auto=format&fit=crop&q=80';
  String get approval => approvalDetails ?? 'DTCP Approved';
}
