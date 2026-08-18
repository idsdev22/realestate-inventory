import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../storage/storage_service.dart';
import '../utils/app_logger.dart';
import 'api_exception.dart';

class ApiService {
  final http.Client _client;
  final StorageService _storageService;

  ApiService({http.Client? client, required StorageService storageService})
    : _client = client ?? http.Client(),
      _storageService = storageService;

  Map<String, String> _buildHeaders({Map<String, String>? extraHeaders}) {
    final headers = Map<String, String>.from(ApiConstants.defaultHeaders);
    final token = _storageService.getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    if (extraHeaders != null) {
      headers.addAll(extraHeaders);
    }
    return headers;
  }

  Future<dynamic> get(String endpoint, {Map<String, String>? headers}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    AppLogger.i('GET Request: $uri');
    try {
      final response = await _client
          .get(uri, headers: _buildHeaders(extraHeaders: headers))
          .timeout(ApiConstants.timeout);

      AppLogger.d('GET Response [${response.statusCode}]: $uri');
      return _handleResponse(response, endpoint: endpoint);
    } on SocketException catch (e) {
      AppLogger.e('Network error for GET $endpoint', e);
      throw ApiException(
        message:
            'No internet connection. Please check your network and try again.',
      );
    } on http.ClientException catch (e) {
      AppLogger.e('ClientException for GET $endpoint', e);
      throw ApiException(message: 'Unable to connect to server: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      AppLogger.e('Exception for GET $endpoint', e);
      throw ApiException(message: 'Unexpected error: $e');
    }
  }

  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    AppLogger.i('POST Request: $uri\nBody: $body');
    try {
      final response = await _client
          .post(
            uri,
            headers: _buildHeaders(extraHeaders: headers),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConstants.timeout);

      AppLogger.d('POST Response [${response.statusCode}]: $uri');
      return _handleResponse(response, endpoint: endpoint);
    } on SocketException catch (e) {
      AppLogger.e('Network error for POST $endpoint', e);
      throw ApiException(
        message:
            'No internet connection. Please check your network and try again.',
      );
    } on http.ClientException catch (e) {
      AppLogger.e('ClientException for POST $endpoint', e);
      throw ApiException(message: 'Unable to connect to server: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      AppLogger.e('Exception for POST $endpoint', e);
      throw ApiException(message: 'Unexpected error: $e');
    }
  }

  Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    AppLogger.i('PUT Request: $uri\nBody: $body');
    try {
      final response = await _client
          .put(
            uri,
            headers: _buildHeaders(extraHeaders: headers),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConstants.timeout);

      AppLogger.d('PUT Response [${response.statusCode}]: $uri');
      return _handleResponse(response, endpoint: endpoint);
    } on SocketException catch (e) {
      AppLogger.e('Network error for PUT $endpoint', e);
      throw ApiException(
        message:
            'No internet connection. Please check your network and try again.',
      );
    } on http.ClientException catch (e) {
      AppLogger.e('ClientException for PUT $endpoint', e);
      throw ApiException(message: 'Unable to connect to server: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      AppLogger.e('Exception for PUT $endpoint', e);
      throw ApiException(message: 'Unexpected error: $e');
    }
  }

  Future<dynamic> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    AppLogger.i('DELETE Request: $uri');
    try {
      final response = await _client
          .delete(uri, headers: _buildHeaders(extraHeaders: headers))
          .timeout(ApiConstants.timeout);

      AppLogger.d('DELETE Response [${response.statusCode}]: $uri');
      return _handleResponse(response, endpoint: endpoint);
    } on SocketException catch (e) {
      AppLogger.e('Network error for DELETE $endpoint', e);
      throw ApiException(
        message:
            'No internet connection. Please check your network and try again.',
      );
    } on http.ClientException catch (e) {
      AppLogger.e('ClientException for DELETE $endpoint', e);
      throw ApiException(message: 'Unable to connect to server: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      AppLogger.e('Exception for DELETE $endpoint', e);
      throw ApiException(message: 'Unexpected error: $e');
    }
  }

  dynamic _handleResponse(http.Response response, {required String endpoint}) {
    dynamic responseData;
    try {
      if (response.body.isNotEmpty) {
        responseData = jsonDecode(response.body);
      } else {
        responseData = {
          'success': response.statusCode >= 200 && response.statusCode < 300,
        };
      }
    } catch (e) {
      AppLogger.w(
        'Non-JSON response received for $endpoint (Status: ${response.statusCode})',
      );
      // If it's not a successful status, we can proceed to throw the ApiException below.
      // If it is successful but not JSON, we throw here.
      if (response.statusCode >= 200 && response.statusCode < 300) {
        throw ApiException(
          message: 'Invalid response format from server.',
          statusCode: response.statusCode,
        );
      }
      responseData = response.body; // Pass the raw body instead
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      AppLogger.v('Response Data ($endpoint): $responseData');
      return responseData;
    } else {
      final message = responseData is Map<String, dynamic>
          ? (responseData['message'] ??
                responseData['error'] ??
                'Request failed with status ${response.statusCode}')
          : 'Request failed with status ${response.statusCode}';

      AppLogger.w('API Error ($endpoint) [${response.statusCode}]: $message');
      throw ApiException(
        message: message.toString(),
        statusCode: response.statusCode,
        data: responseData,
      );
    }
  }
}
