import 'package:flutter/foundation.dart';
import '../../data/models/block_request_model.dart';
import '../../data/services/request_service.dart';
import '../../../../core/network/api_exception.dart';

class AllRequestsProvider extends ChangeNotifier {
  final RequestService _requestService;

  List<BlockRequestModel> _requests = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMore = true;
  String _selectedTab = 'All';

  AllRequestsProvider({required RequestService requestService}) 
      : _requestService = requestService;

  List<BlockRequestModel> get requests => _requests;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;
  String get selectedTab => _selectedTab;

  // Counts based on current loaded list. This might not reflect total count on server.
  int get countAll => _requests.length;
  int get countPending => _requests.where((r) => r.status.toLowerCase() == 'pending').length;
  int get countBooked => _requests.where((r) => r.status.toLowerCase() == 'booked' || r.status.toLowerCase() == 'approved').length;
  int get countRejected => _requests.where((r) => r.status.toLowerCase() == 'rejected').length;
  int get countOnHold => _requests.where((r) => r.status.toLowerCase() == 'on_hold' || r.status.toLowerCase() == 'on hold').length;

  void setSelectedTab(String tab) {
    if (_selectedTab != tab) {
      _selectedTab = tab;
      fetchRequests(refresh: true);
    }
  }

  Future<void> fetchRequests({bool refresh = false}) async {
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
      String statusParam = '';
      if (_selectedTab != 'All') {
        if (_selectedTab.toLowerCase() == 'booked') {
          statusParam = 'approved';
        } else {
          statusParam = _selectedTab.toLowerCase();
        }
      }
      final newRequests = await _requestService.getRequests(
        status: statusParam,
        page: _currentPage,
        limit: 1000,
      );

      if (newRequests.isEmpty) {
        _hasMore = false;
      } else {
        _requests.addAll(newRequests);
        _currentPage++;
        if (newRequests.length < 1000) {
          _hasMore = false; // Assuming limit is 1000
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

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
