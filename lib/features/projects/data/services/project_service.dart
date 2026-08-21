import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:realestate_inventory/core/network/api_service.dart';
import 'package:realestate_inventory/features/projects/data/models/project_model.dart';

class ProjectService {
  final ApiService _apiService;

  ProjectService(this._apiService);

  Future<List<ProjectModel>> getProjects({
    int page = 1,
    int limit = 1000,
    String q = '',
  }) async {
    final queryParams = '?page=$page&limit=$limit&q=$q';
    final response = await _apiService.get('/projects$queryParams');
    if (response is List) {
      return response
          .whereType<Map<String, dynamic>>()
          .map((e) => ProjectModel.fromJson(e))
          .toList();
    }
    if (response is Map<String, dynamic>) {
      var data = response['data'] ?? response['projects'] ?? response['list'];
      if (data is Map<String, dynamic>) {
        data =
            data['items'] ?? data['projects'] ?? data['data'] ?? data['list'];
      }
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map((e) => ProjectModel.fromJson(e))
            .toList();
      }
    }
    return [];
  }

  Future<ProjectModel?> getProjectById(int id) async {
    final response = await _apiService.get('/projects/$id');
    if (response is Map<String, dynamic>) {
      final data = response['data'] ?? response['project'] ?? response;
      if (data is Map<String, dynamic>) {
        return ProjectModel.fromJson(data);
      }
    }
    return null;
  }

  Future<ProjectModel?> createProject(
    ProjectModel project, {
    XFile? imageFile,
  }) async {
    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes(
        'cover_image',
        bytes,
        filename: imageFile.name,
      );
      final fields = <String, String>{
        'name': project.name,
        'city': project.city,
        'location': project.location,
        'project_type': project.projectType,
        if (project.description != null && project.description!.isNotEmpty)
          'description': project.description!,
        if (project.approvalDetails != null &&
            project.approvalDetails!.isNotEmpty)
          'approval_details': project.approvalDetails!,
        'status': project.status,
      };

      final response = await _apiService.postMultipart(
        '/projects',
        method: 'POST',
        fields: fields,
        files: [multipartFile],
      );
      if (response is Map<String, dynamic>) {
        final data = response['data'] ?? response['project'] ?? response;
        if (data is Map<String, dynamic>) {
          return ProjectModel.fromJson(data);
        }
      }
      return null;
    }

    final response = await _apiService.post(
      '/projects',
      body: project.toJson(),
    );
    if (response is Map<String, dynamic>) {
      final data = response['data'] ?? response['project'] ?? response;
      if (data is Map<String, dynamic>) {
        return ProjectModel.fromJson(data);
      }
    }
    return null;
  }

  Future<ProjectModel?> updateProject(
    int id,
    ProjectModel project, {
    XFile? imageFile,
  }) async {
    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes(
        'cover_image',
        bytes,
        filename: imageFile.name,
      );
      final fields = <String, String>{
        'id': id.toString(),
        'name': project.name,
        'city': project.city,
        'location': project.location,
        'project_type': project.projectType,
        if (project.description != null && project.description!.isNotEmpty)
          'description': project.description!,
        if (project.approvalDetails != null &&
            project.approvalDetails!.isNotEmpty)
          'approval_details': project.approvalDetails!,
        'status': project.status,
      };

      final response = await _apiService.postMultipart(
        '/projects/$id',
        method: 'PUT',
        fields: fields,
        files: [multipartFile],
      );
      if (response is Map<String, dynamic>) {
        final data = response['data'] ?? response['project'] ?? response;
        if (data is Map<String, dynamic>) {
          return ProjectModel.fromJson(data);
        }
      }
      return null;
    }

    final response = await _apiService.put(
      '/projects/$id',
      body: project.toJson(),
    );
    if (response is Map<String, dynamic>) {
      final data = response['data'] ?? response['project'] ?? response;
      if (data is Map<String, dynamic>) {
        return ProjectModel.fromJson(data);
      }
    }
    return null;
  }

  Future<bool> deleteProject(int id) async {
    final response = await _apiService.delete('/projects/$id');
    if (response is Map<String, dynamic>) {
      return response['success'] == true || response['status'] == 'success';
    }
    return response != null;
  }
}
