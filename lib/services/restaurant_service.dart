import 'dart:io';

import 'package:dio/dio.dart';
import '../models/restaurant.dart';
import 'api_service.dart';

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String message;

  ApiResponse({
    required this.success,
    this.data,
    required this.message,
  });
}

class RestaurantService {
  final ApiService _apiService = ApiService();
  final String baseUrl = 'https://backend.zenzio.in/api';

  Future<ApiResponse<Restaurant>> getRestaurantById(String restaurantId) async {
    try {
      final apiResponse = await _apiService.get<Map<String, dynamic>>(
        '$baseUrl/restaurants/$restaurantId',
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        final restaurant = Restaurant.fromJson(apiResponse.data!);
        return ApiResponse(
          success: true,
          data: restaurant,
          message: 'Restaurant fetched successfully',
        );
      } else {
        return ApiResponse(
          success: false,
          message: apiResponse.message ?? 'Failed to fetch restaurant data',
        );
      }
      
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: _getErrorMessage(e),
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<Restaurant>> updateRestaurant(
    String restaurantId,
    Restaurant restaurant,
  ) async {
    try {
      final apiResponse = await _apiService.put<Map<String, dynamic>>(
        '$baseUrl/restaurants/$restaurantId',
        data: restaurant.toJson(),
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        final updatedRestaurant = Restaurant.fromJson(apiResponse.data!);
        return ApiResponse(
          success: true,
          data: updatedRestaurant,
          message: apiResponse.message!,
        );
      } else {
        return ApiResponse(
          success: false,
          message: apiResponse.message!,
        );
      }
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: _getErrorMessage(e),
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error: ${e.toString()}',
      );
    }
  }

  /// Helper method to extract error messages from DioException
  String _getErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.badResponse:
        // Server responded with error status code
        final statusCode = e.response?.statusCode ?? 0;
        final statusMessage = e.response?.statusMessage ?? 'Unknown error';
        
        if (statusCode == 400) {
          return 'Invalid request. Please check your data.';
        } else if (statusCode == 401) {
          return 'Unauthorized. Please login again.';
        } else if (statusCode == 404) {
          return 'Restaurant not found.';
        } else if (statusCode == 500) {
          return 'Server error. Please try again later.';
        }
        return 'Error: $statusCode - $statusMessage';

      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet.';

      case DioExceptionType.receiveTimeout:
        return 'Request timeout. Please try again.';

      case DioExceptionType.sendTimeout:
        return 'Send timeout. Please try again.';

      case DioExceptionType.unknown:
        if (e.error is SocketException) {
          return 'No internet connection.';
        }
        return 'Unknown error occurred: ${e.message}';

      default:
        return 'Error: ${e.message}';
    }
  }
}
