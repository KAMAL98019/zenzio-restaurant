import 'package:zenzio_restaurant/core/constant/api_constant.dart';

import '../models/api_response.dart';
import '../models/order.dart';
import 'api_service.dart';

class OrderService {
  final ApiService _apiService = ApiService();

  // Get all orders
  Future<ApiResponse<List<Order>>> getAllOrders({
    required String restaurantId,
    String? status,
    String? sortBy = 'createdAt',
    String? order = 'DESC',
    String? search,
    String? userId,
    int? limit,
  }) async {
    final queryParameters = {
      'restaurantId': restaurantId,
      if (status != null) 'status': status,
      if (sortBy != null) 'sortBy': sortBy,
      if (order != null) 'order': order,
      if (search != null && search.isNotEmpty) 'search': search,
      if (userId != null) 'userId': userId,
      if (limit != null) 'limit': limit.toString(),
    };

    return await _apiService.get(
      ApiConstants.orders,
      queryParameters: queryParameters,
      fromJson: (data) {
        if (data is List) {
          return data.map((json) => Order.fromJson(json)).toList();
        }
        return [];
      },
    );
  }

  // Accept order
  Future<ApiResponse<Order>> acceptOrder({
    required String orderId,
    required String restaurantId,
    required int estimatedPreparationTime,
  }) async {
    return await _apiService.post(
      ApiConstants.acceptOrder(orderId),
      data: {
        'restaurantId': restaurantId,
        'estimatedPreparationTime': estimatedPreparationTime,
      },
      fromJson: (data) => Order.fromJson(data),
    );
  }

  // Reject order
  Future<ApiResponse<dynamic>> rejectOrder({
    required String orderId,
    required String restaurantId,
    required String reason,
  }) async {
    return await _apiService.post(
      ApiConstants.rejectOrder(orderId),
      data: {
        'restaurantId': restaurantId,
        'reason': reason,
      },
    );
  }

  // Update order status
  Future<ApiResponse<Order>> updateOrderStatus({
    required String orderId,
    required String restaurantId,
    required String status,
    int? additionalPreparationTime,
  }) async {
    return await _apiService.post(
      ApiConstants.updateOrderStatus(orderId),
      data: {
        'restaurantId': restaurantId,
        'status': status,
        if (additionalPreparationTime != null)
          'additionalPreparationTime': additionalPreparationTime,
      },
      fromJson: (data) => Order.fromJson(data),
    );
  }

  // Track order
  Future<ApiResponse<Order>> trackOrder(String orderId) async {
    return await _apiService.get(
      ApiConstants.trackOrder(orderId),
      fromJson: (data) => Order.fromJson(data),
    );
  }
}
