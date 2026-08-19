import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../company_admin/presentation/providers/company_provider.dart';
import '../../../inventory/presentation/providers/inventory_provider.dart';
import '../../../projects/data/models/project_model.dart';
import '../providers/user_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class AddEditUserPage extends StatefulWidget {
  final UserModel? user;

  const AddEditUserPage({super.key, this.user});

  bool get isEditing => user != null;

  @override
  State<AddEditUserPage> createState() => _AddEditUserPageState();
}

class _AddEditUserPageState extends State<AddEditUserPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;

  String _selectedRole =
      'marketing_team_user'; // 'promoter_admin', 'marketing_team_admin', 'marketing_team_user'
  int? _selectedCompanyId;
  List<int> _selectedProjectIds = [];
  bool _isActive = true;
  bool _obscurePassword = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    final authProvider = context.read<AuthProvider>();

    _nameController = TextEditingController(text: u?.name ?? '');
    _emailController = TextEditingController(text: u?.email ?? '');
    _phoneController = TextEditingController(text: u?.phone ?? '');
    _passwordController = TextEditingController();

    if (u != null) {
      _selectedRole = u.role ?? 'marketing_team_user';
      if (!_roleOptions.any((r) => r['value'] == _selectedRole)) {
        _selectedRole = 'marketing_team_user';
      }
      _selectedCompanyId = u.companyId;
      _selectedProjectIds = List<int>.from(u.projectIds);
      _isActive = u.isActive;
    } else {
      _selectedCompanyId = authProvider.user?.companyId;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CompanyProvider>().fetchCompanies(reset: true);
      context.read<InventoryProvider>().loadProjects();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  static const List<Map<String, dynamic>> _roleOptions = [
    {
      'value': 'promoter_admin',
      'label': 'Promoter Admin',
      'desc':
          'Full administrative control over all companies, projects & units',
      'icon': Icons.admin_panel_settings_rounded,
      'color': Color(0xFF635BFF),
    },
    {
      'value': 'marketing_team_admin',
      'label': 'Marketing Team Admin',
      'desc': 'Agency team manager, can view inventory & assign members',
      'icon': Icons.manage_accounts_rounded,
      'color': Color(0xFF0284C7),
    },
    {
      'value': 'marketing_team_user',
      'label': 'Marketing Team User',
      'desc': 'Sales executive / agent who can request blocks and bookings',
      'icon': Icons.person_outline_rounded,
      'color': Color(0xFF10B981),
    },
  ];

  bool get _requiresCompany =>
      _selectedRole == 'marketing_team_admin' ||
      _selectedRole == 'marketing_team_user';

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_requiresCompany && _selectedCompanyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a Marketing Company for this role.'),
          backgroundColor: AppColors.rejected,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final payload = <String, dynamic>{
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'role': _selectedRole,
      'status': _isActive ? 'active' : 'inactive',
      'project_ids': _selectedProjectIds,
    };

    if (_phoneController.text.trim().isNotEmpty) {
      payload['phone'] = _phoneController.text.trim();
    }

    if (_requiresCompany && _selectedCompanyId != null) {
      payload['company_id'] = _selectedCompanyId;
    }

    if (_passwordController.text.isNotEmpty || !widget.isEditing) {
      payload['password'] = _passwordController.text;
    }

    final userProvider = context.read<UserProvider>();
    bool success;

    if (widget.isEditing) {
      success = await userProvider.updateUser(widget.user!.id!, payload);
    } else {
      success = await userProvider.createUser(payload);
    }

    setState(() => _isSaving = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.available,
            content: Text(
              widget.isEditing
                  ? 'User "${_nameController.text.trim()}" updated successfully!'
                  : 'User "${_nameController.text.trim()}" created successfully!',
            ),
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.rejected,
            content: Text(
              userProvider.errorMessage ??
                  'Operation failed. Please try again.',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final companyProvider = context.watch<CompanyProvider>();
    final inventoryProvider = context.watch<InventoryProvider>();
    final authProvider = context.watch<AuthProvider>();

    final companies = companyProvider.companies;
    final projects = inventoryProvider.projects;

    return Scaffold(
      backgroundColor: AppColors.background,
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
          widget.isEditing ? 'Edit User' : 'Add New User',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: TextButton.icon(
              onPressed: _isSaving ? null : _submitForm,
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
              label: Text(
                widget.isEditing ? 'Update' : 'Save',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information Section
              _buildSectionHeader(
                'Basic Details',
                Icons.person_outline_rounded,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name *',
                        hintText: 'e.g. Ramesh Kumar',
                        prefixIcon: Icon(Icons.badge_outlined, size: 20),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter user full name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email Address *',
                        hintText: 'e.g. ramesh@syncr.test',
                        prefixIcon: Icon(Icons.email_outlined, size: 20),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter email address';
                        }
                        if (!val.contains('@') || !val.contains('.')) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number (Optional)',
                        hintText: 'e.g. +91 9876543210',
                        prefixIcon: Icon(Icons.phone_outlined, size: 20),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: widget.isEditing
                            ? 'Password (Leave blank to keep current)'
                            : 'Password *',
                        hintText: widget.isEditing
                            ? '••••••••'
                            : 'Enter login password',
                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                          size: 20,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                      ),
                      validator: (val) {
                        if (!widget.isEditing &&
                            (val == null || val.trim().isEmpty)) {
                          return 'Password is required for new users';
                        }
                        if (val != null && val.isNotEmpty && val.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Role Selection
              _buildSectionHeader('Role & Permissions', Icons.shield_outlined),
              const SizedBox(height: 12),
              Column(
                children: _roleOptions.map((role) {
                  final isSelected = _selectedRole == role['value'];
                  final color = role['color'] as Color;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withValues(alpha: 0.05)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? color : AppColors.borderLight,
                        width: isSelected ? 1.8 : 1,
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedRole = role['value'] as String;
                          if (!_requiresCompany) {
                            _selectedCompanyId = null;
                          } else if (!context.read<AuthProvider>().isAdmin) {
                            _selectedCompanyId = context
                                .read<AuthProvider>()
                                .user
                                ?.companyId;
                          }
                        });
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                role['icon'] as IconData,
                                color: color,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    role['label'] as String,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? color
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    role['desc'] as String,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Radio<String>(
                              value: role['value'] as String,
                              groupValue: _selectedRole,
                              activeColor: color,
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _selectedRole = val;
                                    if (!_requiresCompany) {
                                      _selectedCompanyId = null;
                                    } else if (_selectedCompanyId == null) {
                                      _selectedCompanyId = context
                                          .read<AuthProvider>()
                                          .user
                                          ?.companyId;
                                    }
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Company Selection (if required)
              if (_requiresCompany) ...[
                _buildSectionHeader(
                  'Marketing Company *',
                  Icons.business_rounded,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: companyProvider.isLoading && companies.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.apartment_rounded,
                                size: 18,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  companies.any(
                                        (c) => c.id == _selectedCompanyId,
                                      )
                                      ? companies
                                            .firstWhere(
                                              (c) => c.id == _selectedCompanyId,
                                            )
                                            .name
                                      : authProvider.user?.companyName ??
                                            'Unknown Company',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
                const SizedBox(height: 24),
              ],

              // Project Assignment Section
              _buildSectionHeader(
                'Assigned Projects',
                Icons.folder_special_outlined,
              ),
              const SizedBox(height: 6),
              Text(
                'Select projects this user can access to view or sell inventory',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: projects.isEmpty
                    ? Text(
                        'No projects available to assign',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                      )
                    : Wrap(
                        spacing: 8,
                        runSpacing: 10,
                        children: projects.map((ProjectModel project) {
                          final isAssigned = _selectedProjectIds.contains(
                            project.id,
                          );
                          return FilterChip(
                            selected: isAssigned,
                            label: Text(project.name),
                            labelStyle: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: isAssigned
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isAssigned
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                            ),
                            selectedColor: AppColors.primarySurface,
                            checkmarkColor: AppColors.primary,
                            backgroundColor: AppColors.background,
                            side: BorderSide(
                              color: isAssigned
                                  ? AppColors.primary
                                  : AppColors.borderLight,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedProjectIds.add(project.id);
                                } else {
                                  _selectedProjectIds.remove(project.id);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
              ),
              const SizedBox(height: 24),

              // Status Toggle
              _buildSectionHeader('Account Status', Icons.toggle_on_outlined),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isActive ? 'Active User' : 'Inactive User',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _isActive
                                ? AppColors.available
                                : AppColors.textMuted,
                          ),
                        ),
                        Text(
                          _isActive
                              ? 'User can log in and perform actions'
                              : 'User access is suspended',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: _isActive,
                      activeTrackColor: AppColors.available,
                      onChanged: (val) => setState(() => _isActive = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          widget.isEditing ? 'Update User' : 'Create User',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
