import 'package:dio/dio.dart';
import '../models/experience.dart';

/// API Service for handling network requests
class ApiService {
  final Dio _dio;

  ApiService() : _dio = Dio() {
    _dio.options.baseUrl = 'https://staging.chamberofsecrets.8club.co/v1';
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  /// Fetch experiences from API
  Future<List<Experience>> getExperiences({bool active = true}) async {
    try {
      final response = await _dio.get(
        '/experiences',
        queryParameters: {'active': active},
      );

      if (response.statusCode == 200) {
        final experienceResponse = ExperienceResponse.fromJson(response.data);
        return experienceResponse.data.experiences;
      } else {
        throw Exception('Failed to load experiences: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          'Failed to load experiences: ${e.response?.statusCode}',
        );
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
