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
  final String status; // 'available', 'on_hold', 'booked', 'registered'
  final String? remarks;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  // UI and request-related fields
  final bool isFavorite;
  final String? customerName;
  final String? customerPhone;
  final String? customerEmail;
  final String? expectedBookingDate;
  final String? requestDate;
  final bool hasBookingRequest;

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
    this.customerEmail,
    this.expectedBookingDate,
    this.requestDate,
    this.hasBookingRequest = false,
  });

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    final rawStatus = (json['status'] ?? 'available').toString();
    final customerName =
        json['customer_name'] ??
        json['requested_by'] ??
        json['customer']?['name'] ??
        json['request']?['customer_name'] ??
        json['active_request']?['customer_name'];
    final hasBookingReq =
        json['has_booking_request'] == 1 ||
        json['has_booking_request'] == true ||
        json['request'] != null ||
        json['active_request'] != null ||
        (customerName != null &&
            customerName.toString().trim().isNotEmpty &&
            rawStatus.toLowerCase() == 'available');

    // If unit has a pending request or was marked on_hold, ensure Available status is shown
    final normalizedStatus =
        (rawStatus.toLowerCase() == 'on_hold' ||
                rawStatus.toLowerCase() == 'on hold') &&
            (customerName != null || hasBookingReq)
        ? 'available'
        : rawStatus;

    return UnitModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      projectId: json['project_id'] is int
          ? json['project_id']
          : int.tryParse(json['project_id']?.toString() ?? '') ?? 0,
      projectName: json['project_name'] ?? 'Unknown Project',
      unitNo: json['unit_no'] ?? '',
      blockPhase: json['block_phase'],
      plotType: json['plot_type'] ?? 'Residential Plot',
      areaSqFt: double.tryParse(json['area_sqft']?.toString() ?? '0') ?? 0.0,
      facing: json['facing'],
      roadWidthFt: double.tryParse(json['road_width_ft']?.toString() ?? ''),
      dimensions: json['dimensions'],
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      pricePerSqFt:
          double.tryParse(json['price_per_sqft']?.toString() ?? '0') ?? 0.0,
      isPremium: json['is_premium'] == 1 || json['is_premium'] == true,
      isCorner: json['is_corner'] == 1 || json['is_corner'] == true,
      approvalDetails: json['approval_details'],
      status: normalizedStatus,
      remarks: json['remarks'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
      deletedAt: json['deleted_at'] != null
          ? DateTime.tryParse(json['deleted_at'])
          : null,
      isFavorite: json['is_favorite'] == 1 || json['is_favorite'] == true,
      customerName: customerName?.toString(),
      customerPhone:
          (json['customer_phone'] ??
                  json['customer']?['phone'] ??
                  json['request']?['customer_phone'])
              ?.toString(),
      customerEmail:
          (json['customer_email'] ??
                  json['customer']?['email'] ??
                  json['request']?['customer_email'])
              ?.toString(),
      expectedBookingDate:
          (json['expected_booking_date'] ??
                  json['booking_date'] ??
                  json['request']?['expected_booking_date'])
              ?.toString(),
      requestDate:
          (json['request_date'] ??
                  json['requested_date'] ??
                  json['request']?['created_at'])
              ?.toString(),
      hasBookingRequest: hasBookingReq,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
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
      if (customerName != null) 'customer_name': customerName,
      if (customerPhone != null) 'customer_phone': customerPhone,
      if (customerEmail != null) 'customer_email': customerEmail,
      if (expectedBookingDate != null)
        'expected_booking_date': expectedBookingDate,
      if (hasBookingRequest) 'has_booking_request': 1,
    };
    if (id != 0) {
      map['id'] = id;
    }
    return map;
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
    String? customerEmail,
    String? expectedBookingDate,
    String? requestDate,
    bool? hasBookingRequest,
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
      customerEmail: customerEmail ?? this.customerEmail,
      expectedBookingDate: expectedBookingDate ?? this.expectedBookingDate,
      requestDate: requestDate ?? this.requestDate,
      hasBookingRequest: hasBookingRequest ?? this.hasBookingRequest,
    );
  }
}
