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

  // Dummy Data for demonstration
  final List<Order> _dummyOrders = [
    Order(
      id: '1',
      orderId: 'ORD12345',
      userName: 'John Doe',
      userPhone: '987XXXXXXX',
      userAddress: '123 Main Street, Apt 4B, New York, NY 10001',
      latitude: 40.7128, // Example latitude for customer
      longitude: -74.0060, // Example longitude for customer
      items: [
        OrderItem(
          id: 'item1',
          name: 'Chicken Burger',
          quantity: 1,
          price: 9.99,
          customizations: ['No onions', 'Extra cheese'],
        ),
        OrderItem(
          id: 'item2',
          name: 'Classic Fries',
          quantity: 2,
          price: 3.99,
          customizations: ['Extra salt'],
        ),
        OrderItem(
          id: 'item3',
          name: 'Chocolate Milkshake',
          quantity: 1,
          price: 6.99,
        ),
      ],
      itemTotal: 24.95,
      deliveryCharge: 2.99,
      taxes: 2.80,
      grandTotal: 30.74,
      status: 'New',
      paymentStatus: 'Paid Online',
      paymentMethod: 'Credit Card',
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      estimatedPreparationTime: 30,
    ),
    Order(
      id: '2',
      orderId: 'ORD12344',
      userName: 'Jane Smith',
      userPhone: '987XXXXXXX',
      userAddress: '456 Oak Avenue, Suite 101, Los Angeles, CA 90001',
      latitude: 34.0522,
      longitude: -118.2437,
      items: [
        OrderItem(id: 'item4', name: 'Butter Chicken', quantity: 1, price: 15.00),
        OrderItem(id: 'item5', name: 'Garlic Naan', quantity: 2, price: 3.00),
        OrderItem(id: 'item6', name: 'Mango Lassi', quantity: 2, price: 4.00),
      ],
      itemTotal: 29.00,
      deliveryCharge: 2.50,
      taxes: 2.00,
      grandTotal: 33.50,
      status: 'Preparing',
      paymentStatus: 'Paid Online',
      paymentMethod: 'Credit Card',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      estimatedPreparationTime: 40,
      deliveryPartner: DeliveryPartner(
        id: 'dp1',
        name: 'Alex Johnson',
        phone: '987XXXXXXX',
        vehicleType: 'Scooter',
        currentLatitude: 34.0550,
        currentLongitude: -118.2450,
      ),
    ),
    Order(
      id: '3',
      orderId: 'ORD12343',
      userName: 'Mike Johnson',
      userPhone: '765XXXXXXX',
      userAddress: '789 Pine Lane, Apt 2C, Chicago, IL 60601',
      latitude: 41.8781,
      longitude: -87.6298,
      items: [
        OrderItem(id: 'item7', name: 'Paneer Tikka', quantity: 1, price: 18.00),
        OrderItem(id: 'item8', name: 'Roti', quantity: 4, price: 2.00),
        OrderItem(id: 'item9', name: 'Dal Makhani', quantity: 1, price: 12.00),
      ],
      itemTotal: 38.00,
      deliveryCharge: 3.00,
      taxes: 3.50,
      grandTotal: 44.50,
      status: 'Ready',
      paymentStatus: 'Paid Online',
      paymentMethod: 'Credit Card',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      estimatedPreparationTime: 15,
      deliveryPartner: DeliveryPartner(
        id: 'dp2',
        name: 'Sarah Lee',
        phone: '987XXXXXXX',
        vehicleType: 'Bike',
        currentLatitude: 41.8800,
        currentLongitude: -87.6300,
      ),
    ),
    Order(
      id: '4',
      orderId: 'ORD12342',
      userName: 'Emily White',
      userPhone: '123XXXXXXX',
      userAddress: '101 Elm Street, Boston, MA 02108',
      latitude: 42.3601,
      longitude: -71.0589,
      items: [
        OrderItem(id: 'item10', name: 'Veggie Burger', quantity: 1, price: 10.00),
        OrderItem(id: 'item11', name: 'Sweet Potato Fries', quantity: 1, price: 4.50),
      ],
      itemTotal: 14.50,
      deliveryCharge: 2.00,
      taxes: 1.50,
      grandTotal: 18.00,
      status: 'Completed',
      paymentStatus: 'Paid Online',
      paymentMethod: 'Credit Card',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      estimatedDelivery: DateTime.now().subtract(const Duration(hours: 23)),
      estimatedPreparationTime: 20,
    ),
    Order(
      id: '5',
      orderId: 'ORD12341',
      userName: 'David Green',
      userPhone: '456XXXXXXX',
      userAddress: '202 Maple Avenue, Seattle, WA 98101',
      latitude: 47.6062,
      longitude: -122.3321,
      items: [
        OrderItem(id: 'item12', name: 'Sushi Combo', quantity: 1, price: 25.00),
        OrderItem(id: 'item13', name: 'Miso Soup', quantity: 2, price: 3.00),
      ],
      itemTotal: 31.00,
      deliveryCharge: 3.00,
      taxes: 2.50,
      grandTotal: 36.50,
      status: 'Cancelled',
      paymentStatus: 'Refunded',
      paymentMethod: 'Credit Card',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      rejectionReason: 'Restaurant too busy',
    ),
  ];

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

    // Simulate API call with dummy data
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

    _orders = _dummyOrders;
    _filteredOrders = _orders
        .where((order) => order.status == (status ?? _selectedStatus))
        .toList();

    _isLoading = false;

    notifyListeners();
  }

  void filterByStatus(String status) {
    _selectedStatus = status;
    loadOrders(status: status);
  }

  Future<bool> acceptOrder(String orderId, int estimatedTime) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 0)); // Simulate network delay

    final index = _dummyOrders.indexWhere((order) => order.id == orderId);
    if (index != -1) {
      final originalOrder = _dummyOrders[index];
      _dummyOrders[index] = Order(
        id: originalOrder.id,
        orderId: originalOrder.orderId,
        userName: originalOrder.userName,
        userPhone: originalOrder.userPhone,
        userAddress: originalOrder.userAddress,
        latitude: originalOrder.latitude,
        longitude: originalOrder.longitude,
        items: originalOrder.items,
        itemTotal: originalOrder.itemTotal,
        deliveryCharge: originalOrder.deliveryCharge,
        taxes: originalOrder.taxes,
        grandTotal: originalOrder.grandTotal,
        status: 'Preparing',
        paymentStatus: originalOrder.paymentStatus,
        paymentMethod: originalOrder.paymentMethod,
        createdAt: originalOrder.createdAt,
        estimatedDelivery: DateTime.now().add(Duration(minutes: estimatedTime)),
        estimatedPreparationTime: estimatedTime,
        deliveryPartner: originalOrder.deliveryPartner,
      );
      Fluttertoast.showToast(
        msg: 'Order accepted successfully!',
        backgroundColor: Colors.green,
      );
      await loadOrders();
      return true;
    } else {
      Fluttertoast.showToast(
        msg: 'Failed to accept order',
        backgroundColor: Colors.red,
      );
      return false;
    }
  }

  Future<bool> rejectOrder(String orderId, String reason) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 0)); // Simulate network delay

    final index = _dummyOrders.indexWhere((order) => order.id == orderId);
    if (index != -1) {
      final originalOrder = _dummyOrders[index];
      _dummyOrders[index] = Order(
        id: originalOrder.id,
        orderId: originalOrder.orderId,
        userName: originalOrder.userName,
        userPhone: originalOrder.userPhone,
        userAddress: originalOrder.userAddress,
        latitude: originalOrder.latitude,
        longitude: originalOrder.longitude,
        items: originalOrder.items,
        itemTotal: originalOrder.itemTotal,
        deliveryCharge: originalOrder.deliveryCharge,
        taxes: originalOrder.taxes,
        grandTotal: originalOrder.grandTotal,
        status: 'Cancelled',
        paymentStatus: originalOrder.paymentStatus,
        paymentMethod: originalOrder.paymentMethod,
        createdAt: originalOrder.createdAt,
        estimatedDelivery: originalOrder.estimatedDelivery,
        estimatedPreparationTime: originalOrder.estimatedPreparationTime,
        rejectionReason: reason,
        deliveryPartner: originalOrder.deliveryPartner,
      );
      Fluttertoast.showToast(
        msg: 'Order rejected',
        backgroundColor: Colors.orange,
      );
      await loadOrders();
      return true;
    } else {
      Fluttertoast.showToast(
        msg: 'Failed to reject order',
        backgroundColor: Colors.red,
      );
      return false;
    }
  }

  Future<bool> updateOrderStatus(String orderId, String status) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 0)); // Simulate network delay

    final index = _dummyOrders.indexWhere((order) => order.id == orderId);
    if (index != -1) {
      final originalOrder = _dummyOrders[index];
      _dummyOrders[index] = Order(
        id: originalOrder.id,
        orderId: originalOrder.orderId,
        userName: originalOrder.userName,
        userPhone: originalOrder.userPhone,
        userAddress: originalOrder.userAddress,
        latitude: originalOrder.latitude,
        longitude: originalOrder.longitude,
        items: originalOrder.items,
        itemTotal: originalOrder.itemTotal,
        deliveryCharge: originalOrder.deliveryCharge,
        taxes: originalOrder.taxes,
        grandTotal: originalOrder.grandTotal,
        status: status,
        paymentStatus: originalOrder.paymentStatus,
        paymentMethod: originalOrder.paymentMethod,
        createdAt: originalOrder.createdAt,
        estimatedDelivery: originalOrder.estimatedDelivery,
        estimatedPreparationTime: originalOrder.estimatedPreparationTime,
        rejectionReason: originalOrder.rejectionReason,
        deliveryPartner: originalOrder.deliveryPartner,
      );
      Fluttertoast.showToast(
        msg: 'Order status updated!',
        backgroundColor: Colors.green,
      );
      await loadOrders();
      return true;
    } else {
      Fluttertoast.showToast(
        msg: 'Failed to update order',
        backgroundColor: Colors.red,
      );
      return false;
    }
  }

  Order? getOrderById(String orderId) {
    try {
      return _dummyOrders.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
