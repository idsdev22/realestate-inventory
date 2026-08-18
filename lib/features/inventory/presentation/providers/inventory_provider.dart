import 'package:flutter/foundation.dart';
import 'package:realestate_inventory/features/inventory/data/models/unit_model.dart';
import 'package:realestate_inventory/features/projects/data/models/project_model.dart';
import 'package:realestate_inventory/features/projects/data/services/project_service.dart';
import 'package:realestate_inventory/features/inventory/data/services/inventory_service.dart';

class InventoryProvider extends ChangeNotifier {
  List<ProjectModel> _projects = [];
  List<UnitModel> _units = [];
  int? _selectedProjectId;
  String _selectedStatusFilter = 'All';
  String _searchQuery = '';
  final Set<int> _selectedUnitIds = {};
  bool _isLoading = false;
  final ProjectService? _projectService;
  final InventoryService? _inventoryService;

  InventoryProvider({
    ProjectService? projectService,
    InventoryService? inventoryService,
  })  : _projectService = projectService,
        _inventoryService = inventoryService {
    _initializeDefaultData();
    if (_projectService != null) {
      loadProjects();
    }
    if (_inventoryService != null) {
      loadInventory();
    }
  }

  Future<void> loadInventory() async {
    if (_inventoryService == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      final fetchedUnits = await _inventoryService.getInventory();
      if (fetchedUnits.isNotEmpty) {
        _units = fetchedUnits;
      }
    } catch (e) {
      debugPrint('Error loading inventory: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadProjects() async {
    if (_projectService == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      final fetchedProjects = await _projectService.getProjects();
      if (fetchedProjects.isNotEmpty) {
        _projects = fetchedProjects;
      }
    } catch (e) {
      debugPrint('Error loading projects: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<ProjectModel> get projects => _projects;
  List<UnitModel> get units => _units;
  int? get selectedProjectId => _selectedProjectId;
  String get selectedStatusFilter => _selectedStatusFilter;
  String get searchQuery => _searchQuery;
  Set<int> get selectedUnitIds => _selectedUnitIds;
  bool get isLoading => _isLoading;

  ProjectModel? get selectedProject {
    if (_selectedProjectId == null) {
      return _projects.isNotEmpty ? _projects.first : null;
    }
    return _projects.firstWhere(
      (p) => p.id == _selectedProjectId,
      orElse: () => _projects.first,
    );
  }

  // Filtered units based on project, status, and search query
  List<UnitModel> get filteredUnits {
    return _units.where((unit) {
      // Project filter
      if (_selectedProjectId != null && _selectedProjectId != -1) {
        if (unit.projectId != _selectedProjectId) return false;
      }

      // Status filter
      if (_selectedStatusFilter != 'All') {
        if (unit.status.toLowerCase() != _selectedStatusFilter.toLowerCase()) {
          return false;
        }
      }

      // Search query
      if (_searchQuery.trim().isNotEmpty) {
        final query = _searchQuery.toLowerCase().trim();
        final matchUnit = unit.unitNo.toLowerCase().contains(query);
        final matchBlock = unit.blockPhase?.toLowerCase().contains(query) ?? false;
        final matchType = unit.plotType.toLowerCase().contains(query);
        final matchFacing = unit.facing?.toLowerCase().contains(query) ?? false;
        if (!matchUnit && !matchBlock && !matchType && !matchFacing) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  // Counts for selected project or all projects
  int get countAll => _getFilteredCount(null);
  int get countAvailable => _getFilteredCount('Available');
  int get countBlocked => _getFilteredCount('Blocked');
  int get countBooked => _getFilteredCount('Booked');
  int get countRegistered => _getFilteredCount('Registered');

  int get totalInventoryCount => _units.length;
  int get totalAvailableCount => _units.where((u) => u.status == 'Available').length;
  int get totalBlockedCount => _units.where((u) => u.status == 'Blocked').length;
  int get totalBookedCount => _units.where((u) => u.status == 'Booked').length;
  int get totalRegisteredCount => _units.where((u) => u.status == 'Registered').length;

  int _getFilteredCount(String? status) {
    return _units.where((unit) {
      if (_selectedProjectId != null && _selectedProjectId != -1) {
        if (unit.projectId != _selectedProjectId) return false;
      }
      if (status == null) return true;
      return unit.status.toLowerCase() == status.toLowerCase();
    }).length;
  }

  void setSelectedProject(int? projectId) {
    _selectedProjectId = projectId;
    notifyListeners();
  }

  void setStatusFilter(String status) {
    _selectedStatusFilter = status;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void toggleFavorite(int unitId) {
    final index = _units.indexWhere((u) => u.id == unitId);
    if (index != -1) {
      _units[index] = _units[index].copyWith(
        isFavorite: !_units[index].isFavorite,
      );
      notifyListeners();
    }
  }

  void toggleSelection(int unitId) {
    if (_selectedUnitIds.contains(unitId)) {
      _selectedUnitIds.remove(unitId);
    } else {
      _selectedUnitIds.add(unitId);
    }
    notifyListeners();
  }

  void selectAll(List<int> unitIds) {
    _selectedUnitIds.addAll(unitIds);
    notifyListeners();
  }

  void clearSelection() {
    _selectedUnitIds.clear();
    notifyListeners();
  }

  Future<bool> addUnit(UnitModel unit) async {
    if (_inventoryService != null) {
      _isLoading = true;
      notifyListeners();
      try {
        final createdUnit = await _inventoryService.createUnit(unit);
        if (createdUnit != null) {
          _units.insert(0, createdUnit);
          _updateProjectUnitCounts(unit.projectId);
          _isLoading = false;
          notifyListeners();
          return true;
        }
      } catch (e) {
        debugPrint('Error adding unit: $e');
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } else {
      _units.insert(0, unit);
      _updateProjectUnitCounts(unit.projectId);
      notifyListeners();
      return true;
    }
  }

  Future<bool> updateUnit(UnitModel unit) async {
    if (_inventoryService != null) {
      _isLoading = true;
      notifyListeners();
      try {
        final updatedUnit = await _inventoryService.updateUnit(unit.id, unit);
        if (updatedUnit != null) {
          final index = _units.indexWhere((u) => u.id == unit.id);
          if (index != -1) {
            _units[index] = updatedUnit;
            _updateProjectUnitCounts(unit.projectId);
          }
          _isLoading = false;
          notifyListeners();
          return true;
        }
      } catch (e) {
        debugPrint('Error updating unit: $e');
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } else {
      final index = _units.indexWhere((u) => u.id == unit.id);
      if (index != -1) {
        _units[index] = unit;
        _updateProjectUnitCounts(unit.projectId);
        notifyListeners();
      }
      return true;
    }
  }

  Future<bool> bulkUpdateStatus(List<int> unitIds, String newStatus, {String? remarks}) async {
    if (_inventoryService != null) {
      _isLoading = true;
      notifyListeners();
      try {
        final success = await _inventoryService.bulkUpdateStatus(unitIds, 'change_status', newStatus, remarks: remarks);
        if (success) {
          for (int i = 0; i < _units.length; i++) {
            if (unitIds.contains(_units[i].id)) {
              _units[i] = _units[i].copyWith(
                status: newStatus,
                remarks: remarks ?? _units[i].remarks,
              );
            }
          }
          for (final project in _projects) {
            _updateProjectUnitCounts(project.id);
          }
          _selectedUnitIds.clear();
          _isLoading = false;
          notifyListeners();
          return true;
        }
      } catch (e) {
        debugPrint('Error bulk updating units: $e');
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } else {
      for (int i = 0; i < _units.length; i++) {
        if (unitIds.contains(_units[i].id)) {
          _units[i] = _units[i].copyWith(
            status: newStatus,
            remarks: remarks ?? _units[i].remarks,
          );
        }
      }
      for (final project in _projects) {
        _updateProjectUnitCounts(project.id);
      }
      _selectedUnitIds.clear();
      notifyListeners();
      return true;
    }
  }

  Future<bool> addProject(ProjectModel project) async {
    if (_projectService != null) {
      _isLoading = true;
      notifyListeners();
      try {
        final createdProject = await _projectService.createProject(project);
        if (createdProject != null) {
          _projects.insert(0, createdProject);
          _isLoading = false;
          notifyListeners();
          return true;
        }
      } catch (e) {
        debugPrint('Error adding project: $e');
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } else {
      _projects.insert(0, project);
      notifyListeners();
      return true;
    }
  }

  void _updateProjectUnitCounts(int projectId) {
    final projectIndex = _projects.indexWhere((p) => p.id == projectId);
    if (projectIndex != -1) {
      final projUnits = _units.where((u) => u.projectId == projectId).toList();
      final total = projUnits.length;
      final available = projUnits.where((u) => u.status == 'Available').length;
      final blocked = projUnits.where((u) => u.status == 'Blocked').length;
      final booked = projUnits.where((u) => u.status == 'Booked').length;
      final registered = projUnits.where((u) => u.status == 'Registered').length;

      _projects[projectIndex] = _projects[projectIndex].copyWith(
        totalUnits: total > 0 ? total : _projects[projectIndex].totalUnits,
        availableUnits: available,
        blockedUnits: blocked,
        bookedUnits: booked,
        registeredUnits: registered,
      );
    }
  }

  void _initializeDefaultData() {
    _projects = [
      ProjectModel(
        id: 1,
        name: 'Royal City',
        location: 'Coimbatore',
        city: 'Coimbatore',
        totalUnits: 250,
        availableUnits: 128,
        blockedUnits: 15,
        bookedUnits: 82,
        registeredUnits: 25,
        coverImage: 'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=600&auto=format&fit=crop&q=80',
        approvalDetails: 'DTCP Approved',
        description: 'Premium gated community township situated in prime Coimbatore corridor.',
      ),
      ProjectModel(
        id: 2,
        name: 'Garden City',
        location: 'Coimbatore',
        city: 'Coimbatore',
        totalUnits: 190,
        availableUnits: 64,
        blockedUnits: 10,
        bookedUnits: 70,
        registeredUnits: 56,
        coverImage: 'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=600&auto=format&fit=crop&q=80',
        approvalDetails: 'DTCP & RERA Approved',
        description: 'Serene eco-living with lush gardens and world-class road infrastructure.',
      ),
      ProjectModel(
        id: 3,
        name: 'Green County',
        location: 'Coimbatore',
        city: 'Coimbatore',
        totalUnits: 320,
        availableUnits: 36,
        blockedUnits: 8,
        bookedUnits: 200,
        registeredUnits: 76,
        coverImage: 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=600&auto=format&fit=crop&q=80',
        approvalDetails: 'DTCP Approved',
        description: 'Elite villa plots surrounded by green landscaping and sports avenues.',
      ),
      ProjectModel(
        id: 4,
        name: 'Vishakha Township',
        location: 'Coimbatore',
        city: 'Coimbatore',
        totalUnits: 150,
        availableUnits: 12,
        blockedUnits: 5,
        bookedUnits: 50,
        registeredUnits: 83,
        coverImage: 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=600&auto=format&fit=crop&q=80',
        approvalDetails: 'DTCP Approved',
        description: 'Fast developing residential sector with underground utilities.',
      ),
    ];

    _selectedProjectId = 1;

    // Populate Units for Royal City & others
    _units = [
      UnitModel(
        id: 101,
        projectId: 1,
        projectName: 'Royal City',
        blockPhase: 'A Block',
        unitNo: 'A-101',
        plotType: 'Residential Plot',
        areaSqFt: 1200,
        facing: 'East Facing',
        roadWidthFt: 30,
        dimensions: '30 x 40',
        price: 3600000,
        pricePerSqFt: 3000,
        status: 'Available',
        remarks: 'Direct access to park, DTCP approved clear title.',
        approvalDetails: 'DTCP Approved',
      ),
      UnitModel(
        id: 102,
        projectId: 1,
        projectName: 'Royal City',
        blockPhase: 'A Block',
        unitNo: 'A-102',
        plotType: 'Residential Plot',
        areaSqFt: 1500,
        facing: 'North Facing',
        roadWidthFt: 40,
        dimensions: '30 x 50',
        price: 4500000,
        pricePerSqFt: 3000,
        status: 'Available',
        remarks: 'Wide 40 ft avenue road facing.',
        approvalDetails: 'DTCP Approved',
      ),
      UnitModel(
        id: 103,
        projectId: 1,
        projectName: 'Royal City',
        blockPhase: 'A Block',
        unitNo: 'A-103',
        plotType: 'Residential Plot',
        areaSqFt: 1200,
        facing: 'West Facing',
        roadWidthFt: 30,
        dimensions: '30 x 40',
        price: 3600000,
        pricePerSqFt: 3000,
        status: 'Blocked',
        remarks: 'Blocked for client token verification.',
        approvalDetails: 'DTCP Approved',
      ),
      UnitModel(
        id: 104,
        projectId: 1,
        projectName: 'Royal City',
        blockPhase: 'A Block',
        unitNo: 'A-104',
        plotType: 'Corner Plot',
        areaSqFt: 1800,
        facing: 'North-East Facing',
        roadWidthFt: 40,
        dimensions: '40 x 45',
        price: 5800000,
        pricePerSqFt: 3222,
        isCorner: true,
        status: 'Booked',
        remarks: 'Prime dual-road corner unit.',
        approvalDetails: 'DTCP Approved',
      ),
      UnitModel(
        id: 105,
        projectId: 1,
        projectName: 'Royal City',
        blockPhase: 'A Block',
        unitNo: 'A-105',
        plotType: 'Residential Plot',
        areaSqFt: 1200,
        facing: 'East Facing',
        roadWidthFt: 30,
        dimensions: '30 x 40',
        price: 3600000,
        pricePerSqFt: 3000,
        status: 'Available',
        approvalDetails: 'DTCP Approved',
      ),
      UnitModel(
        id: 106,
        projectId: 1,
        projectName: 'Royal City',
        blockPhase: 'A Block',
        unitNo: 'A-106',
        plotType: 'Residential Plot',
        areaSqFt: 1500,
        facing: 'South Facing',
        roadWidthFt: 30,
        dimensions: '30 x 50',
        price: 4500000,
        pricePerSqFt: 3000,
        status: 'Available',
        approvalDetails: 'DTCP Approved',
      ),
      UnitModel(
        id: 107,
        projectId: 1,
        projectName: 'Royal City',
        blockPhase: 'B Block',
        unitNo: 'B-201',
        plotType: 'Residential Plot',
        areaSqFt: 1200,
        facing: 'East Facing',
        roadWidthFt: 30,
        dimensions: '30 x 40',
        price: 3600000,
        pricePerSqFt: 3000,
        status: 'Available',
        approvalDetails: 'DTCP Approved',
      ),
      UnitModel(
        id: 108,
        projectId: 1,
        projectName: 'Royal City',
        blockPhase: 'B Block',
        unitNo: 'B-202',
        plotType: 'Residential Plot',
        areaSqFt: 2400,
        facing: 'North Facing',
        roadWidthFt: 60,
        dimensions: '40 x 60',
        price: 7800000,
        pricePerSqFt: 3250,
        status: 'Registered',
        approvalDetails: 'DTCP Approved',
      ),
      // Garden City units
      UnitModel(
        id: 201,
        projectId: 2,
        projectName: 'Garden City',
        blockPhase: 'A Block',
        unitNo: 'GC-101',
        plotType: 'Residential Plot',
        areaSqFt: 1500,
        facing: 'East Facing',
        roadWidthFt: 40,
        dimensions: '30 x 50',
        price: 4800000,
        pricePerSqFt: 3200,
        status: 'Available',
        approvalDetails: 'DTCP Approved',
      ),
      UnitModel(
        id: 202,
        projectId: 2,
        projectName: 'Garden City',
        blockPhase: 'A Block',
        unitNo: 'GC-102',
        plotType: 'Commercial Plot',
        areaSqFt: 2000,
        facing: 'North Facing',
        roadWidthFt: 60,
        dimensions: '40 x 50',
        price: 7200000,
        pricePerSqFt: 3600,
        status: 'Blocked',
        approvalDetails: 'DTCP Approved',
      ),
    ];
  }
}
