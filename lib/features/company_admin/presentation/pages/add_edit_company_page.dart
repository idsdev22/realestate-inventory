import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../inventory/presentation/providers/inventory_provider.dart';
import '../../data/models/company_model.dart';
import '../providers/company_provider.dart';

class AddEditCompanyPage extends StatefulWidget {
  final CompanyModel? company;

  const AddEditCompanyPage({super.key, this.company});

  @override
  State<AddEditCompanyPage> createState() => _AddEditCompanyPageState();
}

class _AddEditCompanyPageState extends State<AddEditCompanyPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _cityController;
  late TextEditingController _addressController;
  late TextEditingController _projectFilterController;

  late String _status;
  late Set<String> _selectedPermissions;
  late Set<int> _selectedProjectIds;
  String _projectSearchText = '';

  bool get isEditing => widget.company != null;

  @override
  void initState() {
    super.initState();
    final company = widget.company;

    _nameController = TextEditingController(text: company?.name ?? '');
    _emailController = TextEditingController(text: company?.email ?? '');
    _phoneController = TextEditingController(text: company?.phone ?? '');
    _cityController = TextEditingController(text: company?.city ?? 'Chennai');
    _addressController = TextEditingController(text: company?.address ?? '');
    _projectFilterController = TextEditingController();

    _status = company?.status ?? 'active';
    _selectedPermissions = Set<String>.from(
      company?.permissions ?? ['view_inventory', 'submit_block_requests', 'manage_users'],
    );
    _selectedProjectIds = Set<int>.from(company?.projectIds ?? [1]);

    // Ensure projects are loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final invProvider = context.read<InventoryProvider>();
      if (invProvider.projects.isEmpty) {
        invProvider.loadProjects(reset: true);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _projectFilterController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Access Denied: Only Promoter Admins can manage companies.'),
          backgroundColor: AppColors.rejected,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    if (_selectedProjectIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one assigned project.'),
          backgroundColor: AppColors.blockedDark,
        ),
      );
      return;
    }

    final companyModel = CompanyModel(
      id: widget.company?.id,
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      city: _cityController.text.trim(),
      address: _addressController.text.trim(),
      status: _status,
      permissions: _selectedPermissions.toList(),
      projectIds: _selectedProjectIds.toList(),
    );

    final companyProvider = context.read<CompanyProvider>();
    bool success;

    if (isEditing) {
      success = await companyProvider.updateCompany(widget.company!.id!, companyModel);
    } else {
      success = await companyProvider.createCompany(companyModel);
    }

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Marketing company "${companyModel.name}" updated successfully!'
                : 'Marketing company "${companyModel.name}" created successfully!',
          ),
          backgroundColor: AppColors.available,
        ),
      );
      Navigator.pop(context, true);
    } else {
      final error = companyProvider.errorMessage ?? 'Operation failed. Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.rejected,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final companyProvider = context.watch<CompanyProvider>();
    final invProvider = context.watch<InventoryProvider>();
    final authProvider = context.watch<AuthProvider>();
    final isPromoterAdmin = authProvider.isAdmin;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? 'Edit Marketing Company' : 'New Marketing Company',
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          if (isPromoterAdmin)
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: TextButton.icon(
                onPressed: companyProvider.isSubmitting ? null : _submitForm,
                icon: companyProvider.isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                      )
                    : const Icon(Icons.check_rounded, size: 18, color: AppColors.primary),
                label: Text(
                  isEditing ? 'Save' : 'Create',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: !isPromoterAdmin
          ? _buildAccessRestrictedView()
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Card
                    _buildHeaderBanner(),
                    const SizedBox(height: 20),

                    // Section 1: Company Profile Info
                    _buildSectionContainer(
                      title: 'Company Profile',
                      subtitle: 'Basic contact & registration particulars',
                      icon: Icons.business_rounded,
                      children: [
                        _buildInputField(
                          controller: _nameController,
                          label: 'Company Name',
                          hint: 'e.g. Zenith Realty',
                          icon: Icons.domain_rounded,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter company name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInputField(
                                controller: _emailController,
                                label: 'Email Address',
                                hint: 'zenith@test.com',
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Please enter email';
                                  }
                                  if (!val.contains('@') || !val.contains('.')) {
                                    return 'Enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildInputField(
                                controller: _phoneController,
                                label: 'Phone Number',
                                hint: '9843000000',
                                icon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Please enter phone';
                                  }
                                  if (val.trim().length < 8) {
                                    return 'Valid phone required';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInputField(
                                controller: _cityController,
                                label: 'City',
                                hint: 'e.g. Chennai',
                                icon: Icons.location_city_rounded,
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Please enter city';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildInputField(
                                controller: _addressController,
                                label: 'Address / Area',
                                hint: 'e.g. OMR',
                                icon: Icons.pin_drop_outlined,
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Please enter address';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Section 2: Account Status
                    _buildSectionContainer(
                      title: 'Account Status',
                      subtitle: 'Control whether this marketing agency can log in',
                      icon: Icons.toggle_on_rounded,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatusOption(
                                label: 'Active',
                                subtitle: 'Full access granted',
                                isSelected: _status == 'active',
                                color: AppColors.available,
                                icon: Icons.check_circle_rounded,
                                onTap: () => setState(() => _status = 'active'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatusOption(
                                label: 'Inactive',
                                subtitle: 'Suspended login',
                                isSelected: _status == 'inactive',
                                color: AppColors.rejected,
                                icon: Icons.cancel_rounded,
                                onTap: () => setState(() => _status = 'inactive'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Section 3: Permissions Matrix
                    _buildSectionContainer(
                      title: 'Access Permissions',
                      subtitle: 'Select specific operational capabilities for this company',
                      icon: Icons.shield_outlined,
                      children: [
                        ...CompanyModel.availablePermissions.map((perm) {
                          final key = perm['key']!;
                          final label = perm['label']!;
                          final desc = perm['description']!;
                          final isChecked = _selectedPermissions.contains(key);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: isChecked ? AppColors.primarySurface : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isChecked ? AppColors.primary : AppColors.borderLight,
                                width: isChecked ? 1.5 : 1,
                              ),
                            ),
                            child: CheckboxListTile(
                              value: isChecked,
                              activeColor: AppColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              title: Text(
                                label,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isChecked ? AppColors.primaryDark : AppColors.textPrimary,
                                ),
                              ),
                              subtitle: Text(
                                desc,
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              secondary: Icon(
                                _getPermissionIcon(key),
                                color: isChecked ? AppColors.primary : AppColors.textMuted,
                                size: 22,
                              ),
                              onChanged: (bool? val) {
                                setState(() {
                                  if (val == true) {
                                    _selectedPermissions.add(key);
                                  } else {
                                    _selectedPermissions.remove(key);
                                  }
                                });
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Section 4: Assign Projects
                    _buildSectionContainer(
                      title: 'Assigned Projects',
                      subtitle: 'Allocate projects whose inventory this company can access',
                      icon: Icons.apartment_rounded,
                      children: [
                        // Search & Quick Select bar
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.borderLight),
                                ),
                                child: TextField(
                                  controller: _projectFilterController,
                                  onChanged: (val) {
                                    setState(() {
                                      _projectSearchText = val.toLowerCase().trim();
                                    });
                                  },
                                  style: GoogleFonts.poppins(fontSize: 12.5),
                                  decoration: InputDecoration(
                                    hintText: 'Filter projects...',
                                    hintStyle: GoogleFonts.poppins(
                                      color: AppColors.textMuted,
                                      fontSize: 12,
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.search_rounded,
                                      size: 18,
                                      color: AppColors.textMuted,
                                    ),
                                    suffixIcon: _projectFilterController.text.isNotEmpty
                                        ? IconButton(
                                            icon: const Icon(Icons.clear_rounded, size: 16),
                                            onPressed: () {
                                              _projectFilterController.clear();
                                              setState(() => _projectSearchText = '');
                                            },
                                          )
                                        : null,
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 10,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  if (_selectedProjectIds.length == invProvider.projects.length) {
                                    _selectedProjectIds.clear();
                                  } else {
                                    _selectedProjectIds = invProvider.projects.map((p) => p.id).toSet();
                                  }
                                });
                              },
                              style: TextButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              ),
                              child: Text(
                                _selectedProjectIds.length == invProvider.projects.length
                                    ? 'Clear All'
                                    : 'Select All',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Selected count indicator
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_outline_rounded, size: 14, color: AppColors.primary),
                              const SizedBox(width: 6),
                              Text(
                                '${_selectedProjectIds.length} of ${invProvider.projects.length} projects assigned',
                                style: GoogleFonts.poppins(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        if (invProvider.projects.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else
                          ...invProvider.projects
                              .where((p) =>
                                  _projectSearchText.isEmpty ||
                                  p.name.toLowerCase().contains(_projectSearchText) ||
                                  p.city.toLowerCase().contains(_projectSearchText) ||
                                  p.location.toLowerCase().contains(_projectSearchText))
                              .map((proj) {
                            final isAssigned = _selectedProjectIds.contains(proj.id);
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: isAssigned ? AppColors.primarySurface : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isAssigned ? AppColors.primary : AppColors.borderLight,
                                  width: isAssigned ? 1.5 : 1,
                                ),
                              ),
                              child: CheckboxListTile(
                                value: isAssigned,
                                activeColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                secondary: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: isAssigned
                                        ? AppColors.primary
                                        : AppColors.borderLight,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.business_center_rounded,
                                    color: isAssigned ? Colors.white : AppColors.textSecondary,
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  proj.name,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                subtitle: Text(
                                  '${proj.city} • ${proj.location} (ID: ${proj.id})',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                onChanged: (bool? val) {
                                  setState(() {
                                    if (val == true) {
                                      _selectedProjectIds.add(proj.id);
                                    } else {
                                      _selectedProjectIds.remove(proj.id);
                                    }
                                  });
                                },
                              ),
                            );
                          }),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: companyProvider.isSubmitting ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: companyProvider.isSubmitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    isEditing ? Icons.save_rounded : Icons.add_business_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isEditing
                                        ? 'Update Company Particulars'
                                        : 'Create Marketing Company',
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeaderBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.corporate_fare_rounded, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Promoter Admin Console',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.8),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isEditing ? 'Modify Agency Access' : 'Register New Partner Agency',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionContainer({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.borderLight),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.poppins(fontSize: 13.5, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.iconColor, size: 19),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusOption({
    required String label,
    required String subtitle,
    required bool isSelected,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppColors.borderLight,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? color : AppColors.textMuted, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? color : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPermissionIcon(String key) {
    switch (key) {
      case 'view_inventory':
        return Icons.grid_view_rounded;
      case 'submit_block_requests':
        return Icons.lock_clock_rounded;
      case 'manage_users':
        return Icons.people_alt_rounded;
      case 'edit_inventory':
        return Icons.edit_note_rounded;
      case 'view_reports':
        return Icons.analytics_outlined;
      default:
        return Icons.check_circle_outline_rounded;
    }
  }

  Widget _buildAccessRestrictedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.rejectedLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_outline_rounded, color: AppColors.rejected, size: 48),
            ),
            const SizedBox(height: 20),
            Text(
              'Promoter Admin Role Required',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Only users with the "promoter_admin" role are permitted to create or modify marketing companies.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
