import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
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

  // Advanced filters
  List<String> _selectedPlotTypes = [];
  List<String> _selectedFacings = [];
  double? _minPrice;
  double? _maxPrice;

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
  }) : _projectService = projectService,
       _inventoryService = inventoryService {
    if (_projectService != null) {
      loadProjects();
    }
    if (_inventoryService != null) {
      loadInventory();
    }
  }

  Future<void> loadInventory({
    bool reset = false,
    bool isSilent = false,
  }) async {
    if (_inventoryService == null) return;

    if (reset) {
      _currentPage = 1;
      _hasMore = true;
    }

    if (!_hasMore || _isLoading) return;

    _isLoading = true;
    if (!isSilent && _units.isEmpty) {
      notifyListeners();
    }
    try {
      final fetchedUnits = await _inventoryService.getInventory(
        page: _currentPage,
        limit: 1000,
        q: '',
        status: null,
        projectId: (_selectedProjectId != null && _selectedProjectId != -1)
            ? _selectedProjectId.toString()
            : null,
      );

      if (fetchedUnits.length < 1000) {
        _hasMore = false;
      }

      if (reset || _currentPage == 1) {
        _units.clear();
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

  List<String> get selectedPlotTypes => _selectedPlotTypes;
  List<String> get selectedFacings => _selectedFacings;
  double? get minPrice => _minPrice;
  double? get maxPrice => _maxPrice;

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
        final filterLower = _selectedStatusFilter.toLowerCase().trim();
        final unitLower = unit.status.toLowerCase().trim();
        if (filterLower == 'available') {
          if (unitLower != 'available' && unitLower != 'on_hold' && unitLower != 'on hold') {
            return false;
          }
        } else if (filterLower == 'booked') {
          if (unitLower != 'booked' && unitLower != 'approved') {
            return false;
          }
        } else if (filterLower == 'on hold' || filterLower == 'on_hold') {
          if (unitLower != 'on_hold' && unitLower != 'on hold' && unitLower != 'hold' && unitLower != 'blocked') {
            return false;
          }
        } else if (unitLower != filterLower) {
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

      // Advanced filters
      if (_selectedPlotTypes.isNotEmpty) {
        if (!_selectedPlotTypes.contains(unit.plotType)) {
          return false;
        }
      }

      if (_selectedFacings.isNotEmpty) {
        if (unit.facing == null || !_selectedFacings.contains(unit.facing)) {
          return false;
        }
      }

      if (_minPrice != null && unit.price < _minPrice!) {
        return false;
      }

      if (_maxPrice != null && unit.price > _maxPrice!) {
        return false;
      }

      return true;
    }).toList();
  }

  // Counts for selected project or all projects
  int get countAll => _getFilteredCount(null);
  int get countAvailable => _getFilteredCount('Available');
  int get countRegistered => _getFilteredCount('Registered');
  int get countBooked => _getFilteredCount('Booked');
  int get countOnHold => _getFilteredCount('On Hold');

  int get totalInventoryCount => _units.length;
  int get totalAvailableCount =>
      _units.where((u) => u.status.toLowerCase() == 'available').length;
  int get totalRegisteredCount =>
      _units.where((u) => u.status.toLowerCase() == 'registered').length;
  int get totalBookedCount =>
      _units.where((u) => u.status.toLowerCase() == 'booked').length;
  int get totalOnHoldCount =>
      _units.where((u) {
        final s = u.status.toLowerCase().trim();
        return s == 'on_hold' || s == 'on hold' || s == 'hold' || s == 'blocked';
      }).length;

  int _getFilteredCount(String? status) {
    final matchingUnits = _units.where((unit) {
      if (_selectedProjectId != null && _selectedProjectId != -1) {
        if (unit.projectId != _selectedProjectId) return false;
      }
      if (status == null) return true;
      final statusLower = status.toLowerCase().trim();
      final unitLower = unit.status.toLowerCase().trim();
      if (statusLower == 'available') {
        return unitLower == 'available' || unitLower == 'on_hold' || unitLower == 'on hold';
      }
      if (statusLower == 'booked') {
        return unitLower == 'booked' || unitLower == 'approved';
      }
      if (statusLower == 'on hold' || statusLower == 'on_hold') {
        return unitLower == 'on_hold' || unitLower == 'on hold' || unitLower == 'hold' || unitLower == 'blocked';
      }
      return unitLower == statusLower;
    }).length;

    // Fallback to project metadata if units haven't loaded into provider memory yet
    if (matchingUnits == 0 && _units.isEmpty) {
      final proj = selectedProject;
      if (proj != null) {
        if (status == null) return proj.totalUnits;
        final s = status.toLowerCase();
        if (s == 'available') return proj.availableUnits;
        if (s == 'booked') return proj.bookedUnits;
        if (s == 'registered') return proj.registeredUnits;
        if (s == 'on hold' || s == 'on_hold') return 0;
      }
    }

    return matchingUnits;
  }

  void setSelectedProject(int? projectId) {
    if (_selectedProjectId == projectId && _units.isNotEmpty) return;
    _selectedProjectId = projectId;
    notifyListeners();
    loadInventory(reset: true);
  }

  void setStatusFilter(String status) {
    if (_selectedStatusFilter == status) return;
    _selectedStatusFilter = status;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    notifyListeners();
  }

  void setAdvancedFilters({
    List<String>? plotTypes,
    List<String>? facings,
    double? minPrice,
    double? maxPrice,
  }) {
    if (plotTypes != null) _selectedPlotTypes = plotTypes;
    if (facings != null) _selectedFacings = facings;
    _minPrice = minPrice;
    _maxPrice = maxPrice;
    notifyListeners();
  }

  void clearAdvancedFilters() {
    _selectedPlotTypes = [];
    _selectedFacings = [];
    _minPrice = null;
    _maxPrice = null;
    notifyListeners();
  }

  int get activeAdvancedFiltersCount {
    int count = 0;
    if (_selectedPlotTypes.isNotEmpty) count++;
    if (_selectedFacings.isNotEmpty) count++;
    if (_minPrice != null || _maxPrice != null) count++;
    return count;
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

  Future<bool> addProject(ProjectModel project, {XFile? imageFile}) async {
    if (_projectService != null) {
      _isLoading = true;
      notifyListeners();
      try {
        final createdProject = await _projectService.createProject(
          project,
          imageFile: imageFile,
        );
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

  Future<bool> updateProject(
    int id,
    ProjectModel project, {
    XFile? imageFile,
  }) async {
    if (_projectService != null) {
      _isLoading = true;
      notifyListeners();
      try {
        final updatedProject = await _projectService.updateProject(
          id,
          project,
          imageFile: imageFile,
        );
        final projToSave = updatedProject ?? project;
        final index = _projects.indexWhere((p) => p.id == id);
        if (index != -1) {
          _projects[index] = projToSave;
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } catch (e) {
        debugPrint('Error updating project: $e');
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } else {
      final index = _projects.indexWhere((p) => p.id == id);
      if (index != -1) {
        _projects[index] = project;
      }
      notifyListeners();
      return true;
    }
  }

  Future<bool> deleteProject(int id) async {
    if (_projectService != null) {
      _isLoading = true;
      notifyListeners();
      try {
        final success = await _projectService.deleteProject(id);
        if (success) {
          _projects.removeWhere((p) => p.id == id);
          if (_selectedProjectId == id) {
            _selectedProjectId = _projects.isNotEmpty
                ? _projects.first.id
                : null;
          }
          _isLoading = false;
          notifyListeners();
          return true;
        }
      } catch (e) {
        debugPrint('Error deleting project: $e');
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } else {
      _projects.removeWhere((p) => p.id == id);
      if (_selectedProjectId == id) {
        _selectedProjectId = _projects.isNotEmpty ? _projects.first.id : null;
      }
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
      final booked = projUnits.where((u) => u.status == 'Booked').length;
      final registered = projUnits
          .where((u) => u.status == 'Registered')
          .length;

      _projects[projectIndex] = _projects[projectIndex].copyWith(
        totalUnits: total > 0 ? total : _projects[projectIndex].totalUnits,
        availableUnits: available,
        bookedUnits: booked,
        registeredUnits: registered,
      );
    }
  }
}
