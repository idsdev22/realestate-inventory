class UnitModel {
  final int id;
  final int projectId;
  final String projectName;
  final String unitNo;
  final String? blockPhase;
  final String plotType;
  final double areaSqFt;
  final String? facing;
  final double? roadWidthFt;
  final String? dimensions;
  final double price;
  final double pricePerSqFt;
  final bool isPremium;
  final bool isCorner;
  final String? approvalDetails;
  final String status; // 'available', 'on_hold', 'blocked', 'booked', 'registered'
  final String? remarks;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  
  // These are UI-only fields that might not be in this table but used locally
  final bool isFavorite;
  final String? customerName;
  final String? customerPhone;

  UnitModel({
    required this.id,
    required this.projectId,
    required this.projectName,
    required this.unitNo,
    this.blockPhase,
    this.plotType = 'Residential Plot',
    required this.areaSqFt,
    this.facing,
    this.roadWidthFt,
    this.dimensions,
    required this.price,
    required this.pricePerSqFt,
    this.isPremium = false,
    this.isCorner = false,
    this.approvalDetails,
    this.status = 'available',
    this.remarks,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.isFavorite = false,
    this.customerName,
    this.customerPhone,
  });

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      projectId: json['project_id'] is int ? json['project_id'] : int.tryParse(json['project_id']?.toString() ?? '') ?? 0,
      projectName: json['project_name'] ?? 'Unknown Project',
      unitNo: json['unit_no'] ?? '',
      blockPhase: json['block_phase'],
      plotType: json['plot_type'] ?? 'Residential Plot',
      areaSqFt: double.tryParse(json['area_sqft']?.toString() ?? '0') ?? 0.0,
      facing: json['facing'],
      roadWidthFt: double.tryParse(json['road_width_ft']?.toString() ?? ''),
      dimensions: json['dimensions'],
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      pricePerSqFt: double.tryParse(json['price_per_sqft']?.toString() ?? '0') ?? 0.0,
      isPremium: json['is_premium'] == 1 || json['is_premium'] == true,
      isCorner: json['is_corner'] == 1 || json['is_corner'] == true,
      approvalDetails: json['approval_details'],
      status: json['status'] ?? 'available',
      remarks: json['remarks'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
      deletedAt: json['deleted_at'] != null ? DateTime.tryParse(json['deleted_at']) : null,
      isFavorite: json['is_favorite'] == 1 || json['is_favorite'] == true,
      customerName: json['customer_name'],
      customerPhone: json['customer_phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'unit_no': unitNo,
      'block_phase': blockPhase,
      'plot_type': plotType,
      'area_sqft': areaSqFt,
      'facing': facing,
      'road_width_ft': roadWidthFt,
      'dimensions': dimensions,
      'price': price,
      'price_per_sqft': pricePerSqFt,
      'is_premium': isPremium ? 1 : 0,
      'is_corner': isCorner ? 1 : 0,
      'approval_details': approvalDetails,
      'status': status,
      'remarks': remarks,
    };
  }

  String get formattedPrice {
    final priceInt = price.toInt();
    final priceStr = priceInt.toString();
    if (priceStr.length <= 3) return '₹$priceStr';

    final lastThree = priceStr.substring(priceStr.length - 3);
    final rest = priceStr.substring(0, priceStr.length - 3);
    final buffer = StringBuffer();

    for (int i = 0; i < rest.length; i++) {
      if (i > 0 && (rest.length - i) % 2 == 0) {
        buffer.write(',');
      }
      buffer.write(rest[i]);
    }
    return '₹${buffer.toString()},$lastThree';
  }

  String get formattedPricePerSqFt {
    final intVal = pricePerSqFt.toInt();
    return '₹${intVal.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  UnitModel copyWith({
    int? id,
    int? projectId,
    String? projectName,
    String? unitNo,
    String? blockPhase,
    String? plotType,
    double? areaSqFt,
    String? facing,
    double? roadWidthFt,
    String? dimensions,
    double? price,
    double? pricePerSqFt,
    bool? isPremium,
    bool? isCorner,
    String? approvalDetails,
    String? status,
    String? remarks,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool? isFavorite,
    String? customerName,
    String? customerPhone,
  }) {
    return UnitModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
      unitNo: unitNo ?? this.unitNo,
      blockPhase: blockPhase ?? this.blockPhase,
      plotType: plotType ?? this.plotType,
      areaSqFt: areaSqFt ?? this.areaSqFt,
      facing: facing ?? this.facing,
      roadWidthFt: roadWidthFt ?? this.roadWidthFt,
      dimensions: dimensions ?? this.dimensions,
      price: price ?? this.price,
      pricePerSqFt: pricePerSqFt ?? this.pricePerSqFt,
      isPremium: isPremium ?? this.isPremium,
      isCorner: isCorner ?? this.isCorner,
      approvalDetails: approvalDetails ?? this.approvalDetails,
      status: status ?? this.status,
      remarks: remarks ?? this.remarks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
    );
  }
}
