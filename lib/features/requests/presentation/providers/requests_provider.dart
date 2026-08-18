import 'package:flutter/foundation.dart';
import 'package:realestate_inventory/features/requests/data/models/block_request_model.dart';

class RequestsProvider extends ChangeNotifier {
  List<BlockRequestModel> _requests = [];
  String _selectedTab = 'All';

  RequestsProvider() {
    _initializeDefaultRequests();
  }

  List<BlockRequestModel> get requests => _requests;
  String get selectedTab => _selectedTab;

  List<BlockRequestModel> get filteredRequests {
    if (_selectedTab == 'All') return _requests;
    return _requests.where((r) => r.status.toLowerCase() == _selectedTab.toLowerCase()).toList();
  }

  int get countAll => _requests.length;
  int get countPending => _requests.where((r) => r.status.toLowerCase() == 'pending').length;
  int get countApproved => _requests.where((r) => r.status.toLowerCase() == 'approved').length;
  int get countRejected => _requests.where((r) => r.status.toLowerCase() == 'rejected').length;

  void setSelectedTab(String tab) {
    _selectedTab = tab;
    notifyListeners();
  }

  void addRequest(BlockRequestModel request) {
    _requests.insert(0, request);
    notifyListeners();
  }

  void updateRequestStatus(String requestId, String newStatus) {
    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      _requests[index] = _requests[index].copyWith(status: newStatus);
      notifyListeners();
    }
  }

  void _initializeDefaultRequests() {
    _requests = [
      BlockRequestModel(
        id: 'req_1',
        unitNo: 'A-101',
        projectName: 'Royal City',
        areaSqFt: 1200,
        facing: 'East Facing',
        roadWidth: '30 ft Road',
        formattedPrice: '₹36,00,000',
        customerName: 'Raj Kumar',
        customerPhone: '+91 98401 23456',
        customerEmail: 'rajkumar@gmail.com',
        expectedBookingDate: '10 Aug 2024',
        remarks: 'Client paying 10% token within 2 days.',
        status: 'Pending',
        requestedDate: '10 Aug 2024',
      ),
      BlockRequestModel(
        id: 'req_2',
        unitNo: 'A-205',
        projectName: 'Royal City',
        areaSqFt: 1500,
        facing: 'North Facing',
        roadWidth: '40 ft Road',
        formattedPrice: '₹45,00,000',
        customerName: 'Suresh B',
        customerPhone: '+91 94432 78901',
        customerEmail: 'suresh.b@gmail.com',
        expectedBookingDate: '09 Aug 2024',
        remarks: 'Direct referral customer.',
        status: 'Approved',
        requestedDate: '09 Aug 2024',
      ),
      BlockRequestModel(
        id: 'req_3',
        unitNo: 'A-110',
        projectName: 'Royal City',
        areaSqFt: 1200,
        facing: 'West Facing',
        roadWidth: '30 ft Road',
        formattedPrice: '₹36,00,000',
        customerName: 'Manoj M',
        customerPhone: '+91 97890 12345',
        customerEmail: 'manoj.m@gmail.com',
        expectedBookingDate: '08 Aug 2024',
        remarks: 'Expired reservation window.',
        status: 'Rejected',
        requestedDate: '08 Aug 2024',
      ),
      BlockRequestModel(
        id: 'req_4',
        unitNo: 'A-303',
        projectName: 'Royal City',
        areaSqFt: 1800,
        facing: 'Corner Plot',
        roadWidth: '40 ft Road',
        formattedPrice: '₹58,00,000',
        customerName: 'Arjun N',
        customerPhone: '+91 98840 55678',
        customerEmail: 'arjun.n@gmail.com',
        expectedBookingDate: '07 Aug 2024',
        remarks: 'Corner plot verified with registry.',
        status: 'Approved',
        requestedDate: '07 Aug 2024',
      ),
      BlockRequestModel(
        id: 'req_5',
        unitNo: 'B-104',
        projectName: 'Royal City',
        areaSqFt: 1500,
        facing: 'East Facing',
        roadWidth: '30 ft Road',
        formattedPrice: '₹45,00,000',
        customerName: 'Kavitha R',
        customerPhone: '+91 91760 99887',
        customerEmail: 'kavitha.r@gmail.com',
        expectedBookingDate: '06 Aug 2024',
        remarks: 'Site visit completed, awaiting agreement draft.',
        status: 'Approved',
        requestedDate: '06 Aug 2024',
      ),
      BlockRequestModel(
        id: 'req_6',
        unitNo: 'B-205',
        projectName: 'Royal City',
        areaSqFt: 1200,
        facing: 'North Facing',
        roadWidth: '30 ft Road',
        formattedPrice: '₹36,00,000',
        customerName: 'Dinesh Kumar',
        customerPhone: '+91 96001 22334',
        customerEmail: 'dinesh.k@gmail.com',
        expectedBookingDate: '05 Aug 2024',
        remarks: 'Under review by admin.',
        status: 'Pending',
        requestedDate: '05 Aug 2024',
      ),
      BlockRequestModel(
        id: 'req_7',
        unitNo: 'A-108',
        projectName: 'Royal City',
        areaSqFt: 1500,
        facing: 'South Facing',
        roadWidth: '40 ft Road',
        formattedPrice: '₹45,00,000',
        customerName: 'Praveen S',
        customerPhone: '+91 95000 11223',
        customerEmail: 'praveen.s@gmail.com',
        expectedBookingDate: '04 Aug 2024',
        remarks: 'Document verification pending.',
        status: 'Pending',
        requestedDate: '04 Aug 2024',
      ),
      BlockRequestModel(
        id: 'req_8',
        unitNo: 'GC-105',
        projectName: 'Garden City',
        areaSqFt: 2000,
        facing: 'East Facing',
        roadWidth: '60 ft Road',
        formattedPrice: '₹72,00,000',
        customerName: 'Naveen Raj',
        customerPhone: '+91 98845 66778',
        customerEmail: 'naveen.raj@gmail.com',
        expectedBookingDate: '03 Aug 2024',
        remarks: 'Approved by management.',
        status: 'Approved',
        requestedDate: '03 Aug 2024',
      ),
    ];
  }
}
