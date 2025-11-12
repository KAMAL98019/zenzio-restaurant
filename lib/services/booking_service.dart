import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:zenzio_restaurant/models/dining_space.dart';
import '../models/api_response.dart';
import '../models/booking.dart';
import '../core/constant/api_constant.dart';
import 'api_service.dart';

class BookingService {
  final ApiService _apiService = ApiService();

  // Get dining spaces
  Future<ApiResponse<dynamic>> getDiningSpaces(String restaurantId) async {
    try {
      print('BookingService: Getting dining spaces for restaurant: $restaurantId');
      
      final response = await _apiService.get(
        ApiConstants.diningSpaces(restaurantId),
        fromJson: (data) {
          if (data is Map && data.containsKey('data') && data['data'] is Map && data['data'].containsKey('spaces')) {
            return data['data']['spaces'];
          } else if (data is Map && data.containsKey('spaces') && data['spaces'] is List) {
            return data['spaces'];
          }
          return [];
        },
      );
      return response;
    } catch (e) {
      print('BookingService: Error getting dining spaces: $e');
      return ApiResponse.error(
        error: e,
        message: 'Failed to get dining spaces: $e',
      );
    }
  }

  // Create dining space
  Future<ApiResponse<dynamic>> createDiningSpace({
    required DiningSpace diningSpace,
    List<File>? photos,
  }) async {
    try {
      print('BookingService: Creating dining space');
      
      FormData formData = FormData.fromMap(diningSpace.toJson());

      if (photos != null && photos.isNotEmpty) {
        for (int i = 0; i < photos.length; i++) {
          formData.files.add(
            MapEntry(
              'photos',
              await MultipartFile.fromFile(photos[i].path),
            ),
          );
        }
      }

      final response = await _apiService.post(
        ApiConstants.createDiningSpace,
        data: formData,
      );

      if (response.success) {
        return response;
      } else {
        return ApiResponse.error(
          error: response.error,
          message: response.message ?? 'Failed to create dining space',
        );
      }
    } catch (e) {
      print('BookingService: Error creating dining space: $e');
      return ApiResponse.error(
        error: e,
        message: 'Failed to create dining space: $e',
      );
    }
  }

  // Update dining space
  Future<ApiResponse<dynamic>> updateDiningSpace({
    required String id,
    required DiningSpace diningSpace,
    List<File>? photos,
  }) async {
    try {
      print('BookingService: Updating dining space: $id');
      
      FormData formData = FormData.fromMap(diningSpace.toJson());

      if (photos != null && photos.isNotEmpty) {
        for (int i = 0; i < photos.length; i++) {
          formData.files.add(
            MapEntry(
              'photos',
              await MultipartFile.fromFile(photos[i].path),
            ),
          );
        }
      }

      final response = await _apiService.put(
        ApiConstants.updateDiningSpace(id),
        data: formData,
      );

      if (response.success) {
        return response;
      } else {
        return ApiResponse.error(
          error: response.error,
          message: response.message ?? 'Failed to update dining space',
        );
      }
    } catch (e) {
      print('BookingService: Error updating dining space: $e');
      return ApiResponse.error(
        error: e,
        message: 'Failed to update dining space: $e',
      );
    }
  }

  // Delete dining space
  Future<ApiResponse<dynamic>> deleteDiningSpace(String id) async {
    try {
      print('BookingService: Deleting dining space: $id');
      
      final response = await _apiService.delete(
        ApiConstants.deleteDiningSpace(id),
      );

      if (response.success) {
        return response;
      } else {
        return ApiResponse.error(
          error: response.error,
          message: response.message ?? 'Failed to delete dining space',
        );
      }
    } catch (e) {
      print('BookingService: Error deleting dining space: $e');
      return ApiResponse.error(
        error: e,
        message: 'Failed to delete dining space: $e',
      );
    }
  }

  // Get all bookings
  Future<ApiResponse<List<Booking>>> getAllBookings({
    required String restaurantId,
    String? status,
    DateTime? date,
  }) async {


    try {

      debugPrint("$status");
      print('BookingService: Getting bookings for: $restaurantId');
      
      final Map<String, dynamic> queryParams = {
        'restaurantId': restaurantId,
        if (status != null) 'status': status,
        if (date != null) 'date': date.toIso8601String().split('T').first,
      };

      final response = await _apiService.get(
        ApiConstants.bookings,
        queryParameters: queryParams,
        fromJson: (data) {
          List<dynamic> dataList = [];
          if (data is List) {
            dataList = data;
          } else if (data is Map) {
            final map = data as Map<String, dynamic>;
            if (map.containsKey('data') && map['data'] is List) {
              dataList = map['data'] as List;
            } else if (map.containsKey('bookings') && map['bookings'] is List) {
              dataList = map['bookings'] as List;
            }
          }
          return dataList
              .map((json) => Booking.fromJson(json))
              .whereType<Booking>()
              .toList();
        },
      );
      return response as ApiResponse<List<Booking>>;
    } catch (e) {
      print('BookingService: Error getting bookings: $e');
      return ApiResponse.error(
        error: e,
        message: 'Failed to get bookings: $e',
      );
    }
  }

  // Accept booking
  Future<ApiResponse<dynamic>> acceptBooking({
    required String bookingId,
    String? tableNumber,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.acceptBooking(bookingId),
        data: {'tableNumber': tableNumber},
      );
      return response;
    } catch (e) {
      return ApiResponse.error(error: e, message: 'Failed to accept booking');
    }
  }

  // Reject booking
  Future<ApiResponse<dynamic>> rejectBooking({
    required String bookingId,
    required String reason,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.rejectBooking(bookingId),
        data: {'reason': reason},
      );
      return response;
    } catch (e) {
      return ApiResponse.error(error: e, message: 'Failed to reject booking');
    }
  }

  // Cancel booking
  Future<ApiResponse<dynamic>> cancelBooking(String bookingId) async {
    try {
      final response = await _apiService.post(
        ApiConstants.cancelBooking(bookingId),
      );
      return response;
    } catch (e) {
      return ApiResponse.error(error: e, message: 'Failed to cancel booking');
    }
  }

  // Mark as seated
  Future<ApiResponse<dynamic>> markAsSeated(String bookingId) async {
    try {
      final response = await _apiService.post(
        ApiConstants.markAsSeated(bookingId),
      );
      return response;
    } catch (e) {
      return ApiResponse.error(error: e, message: 'Failed to mark as seated');
    }
  }
}
