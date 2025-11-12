import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/restaurant.dart';
import '../services/auth_service.dart';
import '../services/order_service.dart';
import '../services/restaurant_service.dart';
import '../models/order.dart';

class DashboardViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isOnline = false;
  bool _isLoading = false;
  String? _restaurantId;
  Restaurant? _currentRestaurant;
  List<Order> _currentOrders = [];
  List<Order> _recentActivity = [];

  final OrderService _orderService = OrderService();
  final RestaurantService _restaurantService = RestaurantService();

  bool get isOnline => _isOnline;
  bool get isLoading => _isLoading;
  String? get restaurantId => _restaurantId;
  Restaurant? get currentRestaurant => _currentRestaurant;
  List<Order> get currentOrders => _currentOrders;
  List<Order> get recentActivity => _recentActivity;

  Future<void> initialize() async {
    _restaurantId = await _authService.getRestaurantId();
    print('DashboardViewModel: Retrieved restaurantId: $_restaurantId'); // Debug print
    if (_restaurantId != null) {
      await Future.wait([
        fetchRestaurantDetails(),
        fetchCurrentOrders(),
        fetchRecentActivity(),
      ]);
    }
    notifyListeners();
  }

  Future<void> fetchRestaurantDetails() async {
    if (_restaurantId == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _restaurantService.getRestaurantById(_restaurantId!);
      if (response.success && response.data != null) {
        _currentRestaurant = response.data;
      } else {
        _currentRestaurant = null;
      }
    } catch (e) {
      print('DashboardViewModel: Error fetching restaurant details: $e');
      _currentRestaurant = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCurrentOrders() async {
    if (_restaurantId == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _orderService.getAllOrders(
        restaurantId: _restaurantId!,
        status: 'Pending', // Assuming 'Pending' orders are current orders
      );
      if (response.success && response.data != null) {
        _currentOrders = response.data!;
      } else {
        _currentOrders = [];
      }
    } catch (e) {
      print('DashboardViewModel: Error fetching current orders: $e');
      _currentOrders = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRecentActivity() async {
    if (_restaurantId == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _orderService.getAllOrders(
        restaurantId: _restaurantId!,
        limit: 5, // Fetch a limited number of recent activities
      );
      if (response.success && response.data != null) {
        _recentActivity = response.data!;
      } else {
        _recentActivity = [];
      }
    } catch (e) {
      print('DashboardViewModel: Error fetching recent activity: $e');
      _recentActivity = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleOnlineStatus() async {
    if (_restaurantId == null) {
      Fluttertoast.showToast(msg: 'Restaurant ID not found');
      return;
    }

    _isLoading = true;
    notifyListeners();

    final response = await _authService.updateRestaurantStatus(
      restaurantId: _restaurantId!,
      isOnline: !_isOnline,
    );

    _isLoading = false;

    if (response.success) {
      _isOnline = !_isOnline;
      Fluttertoast.showToast(
        msg: 'Status updated to ${_isOnline ? 'ONLINE' : 'OFFLINE'}',
        backgroundColor: _isOnline ? Colors.green : Colors.grey,
      );
    } else {
      Fluttertoast.showToast(
        msg: response.message ?? 'Failed to update status',
        backgroundColor: Colors.red,
      );
    }

    notifyListeners();
  }

  Future<void> logout(BuildContext context) async {
    await _authService.logout();
    Fluttertoast.showToast(msg: 'Logged out successfully');
  }
}
