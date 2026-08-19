import 'package:flutter/foundation.dart';
import 'package:realestate_inventory/features/inventory/data/models/unit_model.dart';
import 'package:realestate_inventory/features/projects/data/models/project_model.dart';
import 'package:realestate_inventory/features/projects/data/services/project_service.dart';
import 'package:realestate_inventory/features/inventory/data/services/inventory_service.dart';

class InventoryProvider extends ChangeNotifier {
  final List<ProjectModel> _projects = [];
  final List<UnitModel> _units = [];
  int? _selectedProjectId;
  String _selectedStatusFilter = 'All';
  String _searchQuery = '';
  final Set<int> _selectedUnitIds = {};
  bool _isLoading = false;
  int _currentPage = 1;
  bool _hasMore = true;
  int _currentProjectPage = 1;
  bool _hasMoreProjects = true;
  final ProjectService? _projectService;
  final InventoryService? _inventoryService;

  InventoryProvider({
    ProjectService? projectService,
    InventoryService? inventoryService,
  })  : _projectService = projectService,
        _inventoryService = inventoryService {
    if (_projectService != null) {
      loadProjects();
    }
    if (_inventoryService != null) {
      loadInventory();
    }
  }

  Future<void> loadInventory({bool reset = false}) async {
    if (_inventoryService == null) return;
    
    if (reset) {
      _currentPage = 1;
      _hasMore = true;
      _units.clear();
    }
    
    if (!_hasMore || _isLoading) return;

    _isLoading = true;
    notifyListeners();
    try {
      final fetchedUnits = await _inventoryService.getInventory(
        page: _currentPage,
        limit: 1000,
        q: _searchQuery,
        status: _selectedStatusFilter,
        projectId: _selectedProjectId?.toString(),
      );
      
      if (fetchedUnits.length < 1000) {
        _hasMore = false;
      }
      
      _units.addAll(fetchedUnits);
      _currentPage++;
    } catch (e) {
      debugPrint('Error loading inventory: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadProjects({bool reset = false}) async {
    if (_projectService == null) return;
    
    if (reset) {
      _currentProjectPage = 1;
      _hasMoreProjects = true;
      _projects.clear();
    }
    
    if (!_hasMoreProjects || _isLoading) return;
    
    _isLoading = true;
    notifyListeners();
    try {
      final fetchedProjects = await _projectService.getProjects(
        page: _currentProjectPage,
        limit: 1000,
      );
      
      if (fetchedProjects.length < 1000) {
        _hasMoreProjects = false;
      }
      
      _projects.addAll(fetchedProjects);
      _currentProjectPage++;
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
  bool get hasMore => _hasMore;
  bool get hasMoreProjects => _hasMoreProjects;

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
        final matchBlock =
            unit.blockPhase?.toLowerCase().contains(query) ?? false;
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
  int get totalAvailableCount =>
      _units.where((u) => u.status == 'Available').length;
  int get totalBlockedCount =>
      _units.where((u) => u.status == 'Blocked').length;
  int get totalBookedCount => _units.where((u) => u.status == 'Booked').length;
  int get totalRegisteredCount =>
      _units.where((u) => u.status == 'Registered').length;

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
    loadInventory(reset: true);
  }

  void setStatusFilter(String status) {
    _selectedStatusFilter = status;
    notifyListeners();
    loadInventory(reset: true);
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
    loadInventory(reset: true);
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

  Future<bool> bulkUpdateStatus(
    List<int> unitIds,
    String newStatus, {
    String? remarks,
  }) async {
    if (_inventoryService != null) {
      _isLoading = true;
      notifyListeners();
      try {
        final success = await _inventoryService.bulkUpdateStatus(
          unitIds,
          'change_status',
          newStatus,
          remarks: remarks,
        );
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
      final registered = projUnits
          .where((u) => u.status == 'Registered')
          .length;

      _projects[projectIndex] = _projects[projectIndex].copyWith(
        totalUnits: total > 0 ? total : _projects[projectIndex].totalUnits,
        availableUnits: available,
        blockedUnits: blocked,
        bookedUnits: booked,
        registeredUnits: registered,
      );
    }
  }

}
