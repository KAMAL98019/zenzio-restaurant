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
          // ❗ REMOVE Content-Type HERE
          'Accept': 'application/json',
          'platform': 'Android',
          'User-Agent': 'Android',
          'mode': 'development',
          'clientId': ApiConstants.clientId,
        },
      ),
    );

    // Logging
    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true, error: true),
    );
  }

  // Set token
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void removeAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  // GET
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
      final dynamic extractedData = _extractData(response.data);

      return ApiResponse.success(
        data: fromJson != null ? fromJson(extractedData) : extractedData as T,
        message: response.data?['message'] ?? 'Success',
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // ----------------------------------------------------------------
  // POST (AUTO HANDLE JSON OR FORMDATA)
  // ----------------------------------------------------------------
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    dynamic data, // JSON map or FormData
    T Function(dynamic)? fromJson,
  }) async {
    try {
      // AUTO FIX CONTENT-TYPE
      if (data is FormData) {
        _dio.options.headers.remove('Content-Type'); // allow multipart
      } else {
        _dio.options.headers['Content-Type'] = 'application/json';
      }

      final response = await _dio.post(endpoint, data: data);

      final dynamic extractedData = _extractData(response.data);

      return ApiResponse.success(
        data: fromJson != null ? fromJson(extractedData) : extractedData as T,
        message: response.data?['message'] ?? 'Success',
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // PUT
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
      final dynamic extractedData = _extractData(response.data);

      return ApiResponse.success(
        data: fromJson != null ? fromJson(extractedData) : extractedData as T,
        message: response.data?['message'] ?? 'Success',
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // PATCH
  Future<ApiResponse<T>> patch<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.patch(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
      final dynamic extractedData = _extractData(response.data);

      return ApiResponse.success(
        data: fromJson != null ? fromJson(extractedData) : extractedData as T,
        message: response.data?['message'] ?? 'Success',
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // DELETE
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
      final dynamic extractedData = _extractData(response.data);

      return ApiResponse.success(
        data: fromJson != null ? fromJson(extractedData) : extractedData as T,
        message: response.data?['message'] ?? 'Success',
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // File Upload
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

      _dio.options.headers.remove('Content-Type');

      final response = await _dio.post(endpoint, data: formData);

      final dynamic extractedData = _extractData(response.data);

      return ApiResponse.success(
        data: fromJson != null ? fromJson(extractedData) : extractedData as T,
        message: response.data?['message'] ?? 'Success',
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  dynamic _extractData(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('data')) {
      return data['data'];
    }
    return data;
  }

  ApiResponse<T> _handleError<T>(DioException error) {
    String message = "An unexpected error occurred";

    if (error.response?.data is Map) {
      message = error.response?.data['message'] ?? message;
    }

    return ApiResponse.error(error: error, message: message);
  }
}
