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
}
