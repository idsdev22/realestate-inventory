import 'package:realestate_inventory/core/network/api_service.dart';
import 'package:realestate_inventory/features/projects/data/models/project_model.dart';

class ProjectService {
  final ApiService _apiService;

  ProjectService(this._apiService);

  Future<List<ProjectModel>> getProjects() async {
    final response = await _apiService.get('/projects');
    if (response != null && response['success'] == true && response['data'] != null) {
      return (response['data'] as List).map((e) => ProjectModel.fromJson(e)).toList();
    }
    // Fallback or error return
    return [];
  }

  Future<ProjectModel?> getProjectById(int id) async {
    final response = await _apiService.get('/projects/$id');
    if (response != null && response['success'] == true && response['data'] != null) {
      return ProjectModel.fromJson(response['data']);
    }
    return null;
  }

  Future<ProjectModel?> createProject(ProjectModel project) async {
    final response = await _apiService.post('/projects', body: project.toJson());
    if (response != null && response['success'] == true && response['data'] != null) {
      return ProjectModel.fromJson(response['data']);
    }
    return null;
  }

  Future<ProjectModel?> updateProject(int id, ProjectModel project) async {
    final response = await _apiService.put('/projects/$id', body: project.toJson());
    if (response != null && response['success'] == true && response['data'] != null) {
      return ProjectModel.fromJson(response['data']);
    }
    return null;
  }

  Future<bool> deleteProject(int id) async {
    final response = await _apiService.delete('/projects/$id');
    return response != null && response['success'] == true;
  }
}
