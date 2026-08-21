import 'package:flutter/foundation.dart';
import '../../data/models/block_request_model.dart';
import '../../data/services/request_service.dart';
import '../../../../core/network/api_exception.dart';

class RequestsProvider extends ChangeNotifier {
  final RequestService _requestService;

  List<BlockRequestModel> _requests = [];
  String _selectedTab = 'All';
  bool _isLoading = false;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMore = true;

  RequestsProvider({required RequestService requestService}) 
      : _requestService = requestService;

  List<BlockRequestModel> get requests => _requests;
  String get selectedTab => _selectedTab;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;

  List<BlockRequestModel> get filteredRequests {
    if (_selectedTab == 'All') return _requests;
    final tabLower = _selectedTab.toLowerCase().trim();
    if (tabLower == 'booked' || tabLower == 'approved') {
      return _requests.where((r) => r.status.toLowerCase() == 'booked' || r.status.toLowerCase() == 'approved').toList();
    }
    if (tabLower == 'on hold' || tabLower == 'on_hold') {
      return _requests.where((r) => r.status.toLowerCase() == 'on_hold' || r.status.toLowerCase() == 'on hold').toList();
    }
    return _requests.where((r) => r.status.toLowerCase() == tabLower).toList();
  }

  int get countAll => _requests.length;
  int get countPending => _requests.where((r) => r.status.toLowerCase() == 'pending').length;
  int get countBooked => _requests.where((r) => r.status.toLowerCase() == 'booked' || r.status.toLowerCase() == 'approved').length;
  int get countRejected => _requests.where((r) => r.status.toLowerCase() == 'rejected').length;
  int get countOnHold => _requests.where((r) => r.status.toLowerCase() == 'on_hold' || r.status.toLowerCase() == 'on hold').length;

  void setSelectedTab(String tab) {
    if (_selectedTab != tab) {
      _selectedTab = tab;
      notifyListeners();
      // Since filtering is client-side for these tabs according to the old logic:
      // If we want server-side filtering we would fetch here, but I will keep it client-side
      // or fetch it if needed. Let's just fetch all and filter locally for now to preserve old behavior,
      // or we can just fetch according to the tab.
      // Let's stick to the previous behavior where `filteredRequests` does client-side filtering on all loaded items.
    }
  }

  Future<void> fetchRequests({bool refresh = false, int? userId}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _requests.clear();
      _errorMessage = null;
    }

    if (!_hasMore || _isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      final newRequests = await _requestService.getRequests(
        status: '', // Fetch all for "My Requests" and filter locally
        page: _currentPage,
        limit: 20, // slightly higher limit to ensure enough for local filtering
        userId: userId,
      );

      if (newRequests.isEmpty) {
        _hasMore = false;
      } else {
        _requests.addAll(newRequests);
        _currentPage++;
        if (newRequests.length < 10) {
          _hasMore = false;
        }
      }
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Failed to load requests.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createRequest(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final newRequest = await _requestService.createRequest(data);
      _requests.insert(0, newRequest);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Failed to create request';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addRequest(BlockRequestModel request) {
    _requests.insert(0, request);
    notifyListeners();
  }

  Future<bool> updateRequest(String id, Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final updatedRequest = await _requestService.updateRequest(id, data);
      final index = _requests.indexWhere((r) => r.id == id);
      if (index != -1) {
        _requests[index] = updatedRequest;
      }
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Failed to update request';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteRequest(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _requestService.deleteRequest(id);
      _requests.removeWhere((r) => r.id == id);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Failed to delete request';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> reviewRequest(String id, String decision, {String? reviewNotes}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final reviewed = await _requestService.reviewRequest(
        id: id,
        decision: decision,
        reviewNotes: reviewNotes,
      );
      final finalStatus = decision.toLowerCase() == 'approved' ? 'Booked' : decision.toLowerCase() == 'rejected' ? 'Rejected' : reviewed.status;
      final index = _requests.indexWhere((r) => r.id == id);
      if (index != -1) {
        _requests[index] = reviewed.copyWith(status: finalStatus);
      }
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Failed to review request';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
