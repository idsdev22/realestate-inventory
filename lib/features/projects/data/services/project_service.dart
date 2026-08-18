import 'package:realestate_inventory/core/network/api_service.dart';
import 'package:realestate_inventory/features/projects/data/models/project_model.dart';

class ProjectService {
  final ApiService _apiService;

  ProjectService(this._apiService);

  Future<List<ProjectModel>> getProjects() async {
    final response = await _apiService.get('/projects');
    if (response is List) {
      return response
          .whereType<Map<String, dynamic>>()
          .map((e) => ProjectModel.fromJson(e))
          .toList();
    }
    if (response is Map<String, dynamic>) {
      var data = response['data'] ?? response['projects'] ?? response['list'];
      if (data is Map<String, dynamic>) {
        data = data['items'] ?? data['projects'] ?? data['data'] ?? data['list'];
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

  Future<ProjectModel?> createProject(ProjectModel project) async {
    final response = await _apiService.post('/projects', body: project.toJson());
    if (response is Map<String, dynamic>) {
      final data = response['data'] ?? response['project'] ?? response;
      if (data is Map<String, dynamic>) {
        return ProjectModel.fromJson(data);
      }
    }
    return null;
  }

  Future<ProjectModel?> updateProject(int id, ProjectModel project) async {
    final response = await _apiService.put('/projects/$id', body: project.toJson());
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
