import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:zenzio_restaurant/core/constant/api_constant.dart';
import '../models/api_response.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;

  void initialize() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectionTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'platform': 'Android',
          'User-Agent': 'Android',
          'mode': 'development',
          'clientId': ApiConstants.clientId,
        },
      ),
    );

    // Logging for debugging
    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true, error: true),
    );
  }

  // ✅ Set token globally
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // ✅ Remove token
  void removeAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  // ✅ Generic GET
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );

      return ApiResponse.success(
        data: fromJson != null ? fromJson(response.data) : response.data,
        message: response.data?['message'] ?? 'Success',
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // ✅ Generic POST (using Dio)
  // ✅ Generic POST (supports both JSON & FormData)
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    dynamic data, // can be Map<String, dynamic> or FormData
    T Function(dynamic)? fromJson,
  }) async {
    try {
      print('🌐 POST: ${_dio.options.baseUrl}$endpoint');
      print('📤 Headers: ${_dio.options.headers}');
      if (data is FormData) {
        print('📦 Body: [FormData with ${data.fields.length} fields]');
      } else {
        print('📦 Body: ${data != null ? data.toString() : "{}"}');
      }

      final response = await _dio.post(endpoint, data: data);

      print('📥 Response: ${response.statusCode} ${response.data}');

      return ApiResponse.success(
        data: fromJson != null ? fromJson(response.data) : response.data,
        message: response.data?['message'] ?? 'Success',
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // ✅ PUT
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
      return ApiResponse.success(
        data: fromJson != null ? fromJson(response.data) : response.data,
        message: response.data?['message'] ?? 'Success',
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // ✅ DELETE
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.delete(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
      return ApiResponse.success(
        data: fromJson != null ? fromJson(response.data) : response.data,
        message: response.data?['message'] ?? 'Success',
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // ✅ File Upload
  Future<ApiResponse<T>> uploadFile<T>(
    String endpoint, {
    required String filePath,
    required String fieldName,
    Map<String, dynamic>? additionalData,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
        ...?additionalData,
      });

      final response = await _dio.post(endpoint, data: formData);

      return ApiResponse.success(
        data: fromJson != null ? fromJson(response.data) : response.data,
        message: response.data?['message'] ?? 'Success',
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // ✅ Error Handler
  ApiResponse<T> _handleError<T>(DioException error) {
    String message = 'An unexpected error occurred';

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      message = 'Connection timeout. Please try again.';
    } else if (error.type == DioExceptionType.badResponse) {
      if (error.response?.data is Map &&
          error.response?.data['message'] != null) {
        message = error.response?.data['message'];
      } else {
        message = 'Server error: ${error.response?.statusCode}';
      }
    } else if (error.type == DioExceptionType.connectionError) {
      message = 'No internet connection';
    }

    return ApiResponse.error(error: error, message: message);
  }
}
