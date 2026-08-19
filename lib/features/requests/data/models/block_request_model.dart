class BlockRequestModel {
  final String id;
  final String unitNo;
  final String projectName;
  final int areaSqFt;
  final String facing;
  final String roadWidth;
  final String formattedPrice;
  final String customerName;
  final String customerPhone;
  final String? customerEmail;
  final String expectedBookingDate;
  final String? remarks;
  final String status; // 'Pending', 'Approved', 'Rejected'
  final String requestedDate;

  BlockRequestModel({
    required this.id,
    required this.unitNo,
    required this.projectName,
    required this.areaSqFt,
    required this.facing,
    required this.roadWidth,
    required this.formattedPrice,
    required this.customerName,
    required this.customerPhone,
    this.customerEmail,
    required this.expectedBookingDate,
    this.remarks,
    this.status = 'Pending',
    required this.requestedDate,
  });

  BlockRequestModel copyWith({
    String? id,
    String? unitNo,
    String? projectName,
    int? areaSqFt,
    String? facing,
    String? roadWidth,
    String? formattedPrice,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    String? expectedBookingDate,
    String? remarks,
    String? status,
    String? requestedDate,
  }) {
    return BlockRequestModel(
      id: id ?? this.id,
      unitNo: unitNo ?? this.unitNo,
      projectName: projectName ?? this.projectName,
      areaSqFt: areaSqFt ?? this.areaSqFt,
      facing: facing ?? this.facing,
      roadWidth: roadWidth ?? this.roadWidth,
      formattedPrice: formattedPrice ?? this.formattedPrice,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerEmail: customerEmail ?? this.customerEmail,
      expectedBookingDate: expectedBookingDate ?? this.expectedBookingDate,
      remarks: remarks ?? this.remarks,
      status: status ?? this.status,
      requestedDate: requestedDate ?? this.requestedDate,
    );
  }

  factory BlockRequestModel.fromJson(Map<String, dynamic> json) {
    // If the API returns nested unit/plot data
    final unitData = json['unit'] ?? json['plot'] ?? <String, dynamic>{};
    
    // Helper to extract first non-null value from multiple keys
    String? getValue(List<String> keys, [Map<String, dynamic>? source]) {
      final src = source ?? json;
      for (var key in keys) {
        if (src[key] != null) return src[key].toString();
      }
      return null;
    }

    return BlockRequestModel(
      id: json['id']?.toString() ?? '',
      unitNo: getValue(['unit_no', 'plot_no'], json) ?? getValue(['unit_no', 'plot_no'], unitData) ?? 'N/A',
      projectName: getValue(['project_name'], json) ?? getValue(['project_name'], unitData) ?? 'Unknown Project',
      areaSqFt: int.tryParse(getValue(['area_sq_ft', 'area'], json) ?? getValue(['area_sq_ft', 'area'], unitData) ?? '0') ?? 0,
      facing: getValue(['facing'], json) ?? getValue(['facing'], unitData) ?? 'N/A',
      roadWidth: getValue(['road_width'], json) ?? getValue(['road_width'], unitData) ?? 'N/A',
      formattedPrice: getValue(['formatted_price', 'price'], json) ?? getValue(['formatted_price', 'price'], unitData) ?? '0',
      customerName: json['customer_name']?.toString() ?? 'Unknown Customer',
      customerPhone: json['customer_phone']?.toString() ?? 'N/A',
      customerEmail: json['customer_email']?.toString(),
      expectedBookingDate: json['expected_booking_date']?.toString() ?? 'N/A',
      remarks: json['remarks']?.toString(),
      status: _capitalize(json['status']?.toString() ?? 'Pending'),
      requestedDate: json['created_at']?.toString() ?? json['requested_date']?.toString() ?? 'N/A',
    );
  }

  static String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}
