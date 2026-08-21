import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../projects/data/models/project_model.dart';

import 'package:realestate_inventory/features/inventory/data/models/unit_model.dart';
import '../providers/inventory_provider.dart';

class AddEditUnitPage extends StatefulWidget {
  final UnitModel? unitToEdit;
  final ProjectModel? project;

  const AddEditUnitPage({super.key, this.unitToEdit, this.project});

  @override
  State<AddEditUnitPage> createState() => _AddEditUnitPageState();
}

class _AddEditUnitPageState extends State<AddEditUnitPage> {
  final _formKey = GlobalKey<FormState>();

  late String _selectedProject;
  late String _selectedBlock;
  late String _selectedPlotType;
  late String _selectedFacing;
  late String _selectedRoadWidth;
  late String _selectedStatus;

  late TextEditingController _projectController;
  late TextEditingController _unitNoController;
  late TextEditingController _plotAreaController;
  late TextEditingController _dimensionsController;
  late TextEditingController _priceController;
  late TextEditingController _pricePerSqFtController;
  late TextEditingController _remarksController;

  final List<String> _plotTypes = [
    'Residential Plot',
    'Commercial Plot',
    'Corner Plot',
    'Villa Plot',
  ];

  final List<String> _facings = [
    'East',
    'North',
    'West',
    'South',
    'North-East',
    'South-East',
    'North-West',
    'South-West',
  ];

  final List<String> _roadWidths = ['30 ft', '40 ft', '60 ft', '80 ft'];

  final List<String> _statuses = ['Available', 'Registered', 'Booked', 'On Hold'];

  final List<String> _blocks = ['A Block', 'B Block', 'C Block', 'D Block'];

  @override
  void initState() {
    super.initState();
    final edit = widget.unitToEdit;

    _selectedProject = edit?.projectName ?? widget.project?.name ?? '';
    _selectedBlock = edit?.blockPhase ?? _blocks.first;
    _selectedPlotType = edit?.plotType ?? _plotTypes.first;
    _selectedFacing = edit?.facing?.replaceAll(' Facing', '') ?? _facings.first;
    if (!_facings.contains(_selectedFacing)) _selectedFacing = _facings.first;
    _selectedRoadWidth = edit?.roadWidthFt?.toString() ?? '30';
    if (!_roadWidths.contains('$_selectedRoadWidth ft'))
      _selectedRoadWidth = '30';
    
    final editStatus = edit?.status;
    if (editStatus != null) {
      final lower = editStatus.toLowerCase().trim();
      if (lower == 'on_hold' || lower == 'on hold' || lower == 'hold' || lower == 'blocked') {
        _selectedStatus = 'On Hold';
      } else {
        _selectedStatus = _statuses.firstWhere(
          (s) => s.toLowerCase() == lower,
          orElse: () => _statuses.first,
        );
      }
    } else {
      _selectedStatus = _statuses.first;
    }

    _projectController = TextEditingController(text: _selectedProject);
    _unitNoController = TextEditingController(text: edit?.unitNo ?? '');
    _plotAreaController = TextEditingController(
      text: edit != null ? '${edit.areaSqFt}' : '',
    );
    _dimensionsController = TextEditingController(text: edit?.dimensions ?? '');
    _priceController = TextEditingController(
      text: edit != null ? '${edit.price.toInt()}' : '',
    );
    _pricePerSqFtController = TextEditingController(
      text: edit != null ? '${edit.pricePerSqFt.toInt()}' : '',
    );
    _remarksController = TextEditingController(text: edit?.remarks ?? '');

    _priceController.addListener(_calculatePricePerSqFt);
    _plotAreaController.addListener(_calculatePricePerSqFt);
  }

  void _calculatePricePerSqFt() {
    final totalPrice = double.tryParse(_priceController.text) ?? 0;
    final area = double.tryParse(_plotAreaController.text) ?? 0;
    if (area > 0 && totalPrice > 0) {
      final perSqFt = (totalPrice / area).round();
      if (_pricePerSqFtController.text != '$perSqFt') {
        _pricePerSqFtController.text = '$perSqFt';
      }
    }
  }

  @override
  void dispose() {
    _priceController.removeListener(_calculatePricePerSqFt);
    _plotAreaController.removeListener(_calculatePricePerSqFt);
    _projectController.dispose();
    _unitNoController.dispose();
    _plotAreaController.dispose();
    _dimensionsController.dispose();
    _priceController.dispose();
    _pricePerSqFtController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _saveUnit() {
    final auth = context.read<AuthProvider>();
    if (!auth.isPromoterAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Access Denied: Only Promoter Admins can create or edit units.',
          ),
          backgroundColor: AppColors.rejected,
        ),
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      final inventoryProvider = context.read<InventoryProvider>();

      final isEdit = widget.unitToEdit != null;
      final targetProjectId =
          widget.project?.id ??
          widget.unitToEdit?.projectId ??
          inventoryProvider.projects
              .firstWhere(
                (p) => p.name == _selectedProject,
                orElse: () => inventoryProvider.projects.first,
              )
              .id;

      final resolvedProjectName =
          inventoryProvider.projects.any((p) => p.name == _selectedProject)
          ? _selectedProject
          : (inventoryProvider.projects.isNotEmpty
                ? inventoryProvider.projects.first.name
                : '');

      final unit = UnitModel(
        id: isEdit ? widget.unitToEdit!.id : 0,
        projectId: targetProjectId,
        projectName: resolvedProjectName,
        blockPhase: _selectedBlock,
        unitNo: _unitNoController.text.trim(),
        plotType: _selectedPlotType,
        areaSqFt: double.tryParse(_plotAreaController.text.trim()) ?? 0.0,
        facing: '$_selectedFacing Facing',
        roadWidthFt:
            double.tryParse(_selectedRoadWidth.replaceAll(' ft', '')) ?? 0.0,
        dimensions: _dimensionsController.text.trim(),
        price: double.tryParse(_priceController.text.trim()) ?? 0.0,
        pricePerSqFt:
            double.tryParse(_pricePerSqFtController.text.trim()) ?? 0.0,
        status: _selectedStatus,
        remarks: _remarksController.text.trim().isNotEmpty
            ? _remarksController.text.trim()
            : null,
      );

      if (isEdit) {
        inventoryProvider.updateUnit(unit);
      } else {
        inventoryProvider.addUnit(unit);
      }

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.available,
          content: Text(
            isEdit
                ? 'Unit ${unit.unitNo} updated successfully!'
                : 'Unit ${unit.unitNo} added successfully!',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<InventoryProvider>();
    final isEdit = widget.unitToEdit != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEdit ? 'Edit Unit' : 'Add Unit',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Unit Information',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 18),

                // Project & Block/Phase Row
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        label: 'Project*',
                        controller: _projectController,
                        readOnly: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDropdown(
                        label: 'Block / Phase*',
                        value: _selectedBlock,
                        items: _blocks,
                        onChanged: (val) =>
                            setState(() => _selectedBlock = val!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Plot / Unit No & Plot Type Row
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        label: 'Plot / Unit No.*',
                        controller: _unitNoController,
                        hintText: 'A-125',
                        validator: (v) =>
                            v?.trim().isEmpty ?? true ? 'Enter Unit No' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDropdown(
                        label: 'Plot Type',
                        value: _selectedPlotType,
                        items: _plotTypes,
                        onChanged: (val) =>
                            setState(() => _selectedPlotType = val!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Plot Area (sq.ft) & Facing Row
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        label: 'Plot Area (sq.ft)*',
                        controller: _plotAreaController,
                        keyboardType: TextInputType.number,
                        hintText: '1500',
                        validator: (v) =>
                            v?.trim().isEmpty ?? true ? 'Enter area' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDropdown(
                        label: 'Facing*',
                        value: _selectedFacing,
                        items: _facings,
                        onChanged: (val) =>
                            setState(() => _selectedFacing = val!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Road Width & Dimensions Row
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(
                        label: 'Road Width*',
                        value: _selectedRoadWidth,
                        items: _roadWidths,
                        onChanged: (val) =>
                            setState(() => _selectedRoadWidth = val!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        label: 'Dimensions (ft)',
                        controller: _dimensionsController,
                        hintText: '30 x 50',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Price & Price / sq.ft Row
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        label: 'Price (₹)*',
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        hintText: '4500000',
                        validator: (v) =>
                            v?.trim().isEmpty ?? true ? 'Enter price' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        label: 'Price / sq.ft',
                        controller: _pricePerSqFtController,
                        keyboardType: TextInputType.number,
                        hintText: '3000',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Status Dropdown
                _buildDropdown(
                  label: 'Status*',
                  value: _selectedStatus,
                  items: _statuses,
                  onChanged: (val) => setState(() => _selectedStatus = val!),
                ),
                const SizedBox(height: 16),

                // Remarks TextField
                Text(
                  'Remarks',
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
                    hintText: 'Enter remarks (optional)',
                  ),
                ),
                const SizedBox(height: 32),

                // Action Buttons (Cancel / Save Unit)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.border),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveUnit,
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
                          isEdit ? 'Update Unit' : 'Save Unit',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.contains(value) ? value : items.first,
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
              items: items.map((val) {
                return DropdownMenuItem<String>(value: val, child: Text(val));
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          readOnly: readOnly,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: readOnly ? AppColors.textSecondary : AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            filled: readOnly,
            fillColor: readOnly ? AppColors.background : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}
