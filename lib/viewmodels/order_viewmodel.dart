import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/order.dart';
import '../services/order_service.dart';
import '../services/auth_service.dart';

class OrderViewModel extends ChangeNotifier {
  final OrderService _orderService = OrderService();
  final AuthService _authService = AuthService();

  List<Order> _orders = [];
  List<Order> _filteredOrders = [];
  bool _isLoading = false;
  String _selectedStatus = 'New';
  String? _restaurantId;

  List<Order> get orders => _filteredOrders;
  bool get isLoading => _isLoading;
  String get selectedStatus => _selectedStatus;

  final List<String> orderStatuses = [
    'New',
    'Preparing',
    'Ready',
    'Completed',
    'Cancelled'
  ];

  Future<void> initialize() async {
    _restaurantId = await _authService.getRestaurantId();
    await loadOrders();
  }

  Future<void> loadOrders({String? status}) async {
    if (_restaurantId == null) return;

    _isLoading = true;
    notifyListeners();

    final response = await _orderService.getAllOrders(
      restaurantId: _restaurantId!,
      status: status ?? _selectedStatus,
    );

    _isLoading = false;

    if (response.success && response.data != null) {
      _orders = response.data!;
      _filteredOrders = _orders;
    } else {
      Fluttertoast.showToast(
        msg: response.message ?? 'Failed to load orders',
        backgroundColor: Colors.red,
      );
    }

    notifyListeners();
  }

  void filterByStatus(String status) {
    _selectedStatus = status;
    loadOrders(status: status);
  }

  Future<bool> acceptOrder(String orderId, int estimatedTime) async {
    if (_restaurantId == null) return false;

    _isLoading = true;
    notifyListeners();

    final response = await _orderService.acceptOrder(
      orderId: orderId,
      restaurantId: _restaurantId!,
      estimatedPreparationTime: estimatedTime,
    );

    _isLoading = false;
    notifyListeners();

    if (response.success) {
      Fluttertoast.showToast(
        msg: 'Order accepted successfully!',
        backgroundColor: Colors.green,
      );
      await loadOrders();
      return true;
    } else {
      Fluttertoast.showToast(
        msg: response.message ?? 'Failed to accept order',
        backgroundColor: Colors.red,
      );
      return false;
    }
  }

  Future<bool> rejectOrder(String orderId, String reason) async {
    if (_restaurantId == null) return false;

    _isLoading = true;
    notifyListeners();

    final response = await _orderService.rejectOrder(
      orderId: orderId,
      restaurantId: _restaurantId!,
      reason: reason,
    );

    _isLoading = false;
    notifyListeners();

    if (response.success) {
      Fluttertoast.showToast(
        msg: 'Order rejected',
        backgroundColor: Colors.orange,
      );
      await loadOrders();
      return true;
    } else {
      Fluttertoast.showToast(
        msg: response.message ?? 'Failed to reject order',
        backgroundColor: Colors.red,
      );
      return false;
    }
  }

  Future<bool> updateOrderStatus(String orderId, String status) async {
    if (_restaurantId == null) return false;

    _isLoading = true;
    notifyListeners();

    final response = await _orderService.updateOrderStatus(
      orderId: orderId,
      restaurantId: _restaurantId!,
      status: status,
    );

    _isLoading = false;
    notifyListeners();

    if (response.success) {
      Fluttertoast.showToast(
        msg: 'Order status updated!',
        backgroundColor: Colors.green,
      );
      await loadOrders();
      return true;
    } else {
      Fluttertoast.showToast(
        msg: response.message ?? 'Failed to update order',
        backgroundColor: Colors.red,
      );
      return false;
    }
  }

  Order? getOrderById(String orderId) {
    try {
      return _orders.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
