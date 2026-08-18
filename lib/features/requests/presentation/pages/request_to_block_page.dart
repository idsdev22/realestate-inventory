import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/syncr_badge.dart';
import '../../../activity/data/models/activity_log_model.dart';
import 'package:realestate_inventory/features/inventory/data/models/unit_model.dart';
import 'package:realestate_inventory/features/inventory/presentation/providers/inventory_provider.dart';
import 'package:realestate_inventory/features/requests/data/models/block_request_model.dart';
import 'package:realestate_inventory/features/teams/presentation/providers/teams_provider.dart';
import '../providers/requests_provider.dart';
import 'my_requests_page.dart';

class RequestToBlockPage extends StatefulWidget {
  final UnitModel unit;

  const RequestToBlockPage({
    super.key,
    required this.unit,
  });

  @override
  State<RequestToBlockPage> createState() => _RequestToBlockPageState();
}

class _RequestToBlockPageState extends State<RequestToBlockPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dateController = TextEditingController(text: '12 Aug 2024');
  final TextEditingController _remarksController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _dateController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 2)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      setState(() {
        _dateController.text = '${picked.day.toString().padLeft(2, '0')} ${months[picked.month - 1]} ${picked.year}';
      });
    }
  }

  void _submitRequest() {
    if (_formKey.currentState?.validate() ?? false) {
      final requestsProvider = context.read<RequestsProvider>();
      final inventoryProvider = context.read<InventoryProvider>();
      final teamsProvider = context.read<TeamsProvider>();

      final newRequest = BlockRequestModel(
        id: 'req_${DateTime.now().millisecondsSinceEpoch}',
        unitNo: widget.unit.unitNo,
        projectName: widget.unit.projectName,
        areaSqFt: widget.unit.areaSqFt.toInt(),
        facing: widget.unit.facing ?? '',
        roadWidth: '${widget.unit.roadWidthFt ?? 30} ft Road',
        formattedPrice: widget.unit.formattedPrice,
        customerName: _nameController.text.trim(),
        customerPhone: _phoneController.text.trim(),
        customerEmail: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
        expectedBookingDate: _dateController.text.trim(),
        remarks: _remarksController.text.trim().isNotEmpty ? _remarksController.text.trim() : null,
        status: 'Pending',
        requestedDate: 'Today',
      );

      requestsProvider.addRequest(newRequest);

      // Update unit status to Blocked
      inventoryProvider.updateUnit(
        widget.unit.copyWith(
          status: 'Blocked',
          remarks: 'Blocked for ${_nameController.text.trim()}',
        ),
      );

      // Log activity
      teamsProvider.addActivity(
        ActivityLogModel(
          id: 'act_${DateTime.now().millisecondsSinceEpoch}',
          description: '${widget.unit.unitNo} block requested for ${_nameController.text.trim()} by ABC Marketing',
          actor: 'ABC Marketing',
          time: 'Just now',
          group: 'Today',
          type: ActivityType.statusBlocked,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MyRequestsPage()),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.available,
          content: Text('Block request submitted for unit ${widget.unit.unitNo}!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final unit = widget.unit;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Request to Block',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mini Unit Header Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            unit.unitNo,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SyncrBadge.fromStatus(unit.status),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${unit.areaSqFt} sq.ft  •  ${unit.facing}',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${unit.roadWidthFt ?? 30} ft Road',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            unit.formattedPrice,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Icon(
                            unit.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: unit.isFavorite ? AppColors.rejected : AppColors.textMuted,
                            size: 20,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Customer Name
                Text(
                  'Customer Name*',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameController,
                  style: GoogleFonts.poppins(fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Enter customer name',
                  ),
                  validator: (v) => v?.trim().isEmpty ?? true ? 'Please enter customer name' : null,
                ),
                const SizedBox(height: 16),

                // Customer Phone
                Text(
                  'Customer Phone*',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: GoogleFonts.poppins(fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Enter phone number',
                  ),
                  validator: (v) => v?.trim().isEmpty ?? true ? 'Please enter customer phone' : null,
                ),
                const SizedBox(height: 16),

                // Customer Email
                Text(
                  'Customer Email',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: GoogleFonts.poppins(fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Enter email (optional)',
                  ),
                ),
                const SizedBox(height: 16),

                // Expected Booking Date
                Text(
                  'Expected Booking Date*',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  onTap: _selectDate,
                  style: GoogleFonts.poppins(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Select date',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today_outlined, size: 20, color: AppColors.iconColor),
                      onPressed: _selectDate,
                    ),
                  ),
                  validator: (v) => v?.trim().isEmpty ?? true ? 'Please select expected booking date' : null,
                ),
                const SizedBox(height: 16),

                // Remarks (Optional)
                Text(
                  'Remarks (Optional)',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _remarksController,
                  maxLines: 3,
                  style: GoogleFonts.poppins(fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Add any remarks',
                  ),
                ),
                const SizedBox(height: 32),

                // Submit Request Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Submit Request',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
