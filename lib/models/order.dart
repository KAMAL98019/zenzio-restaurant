class Order {
  final String id;
  final String orderId;
  final String? userId;
  final String? userName;
  final String? userPhone;
  final String? userAddress;
  final double? latitude;
  final double? longitude;
  final List<OrderItem> items;
  final double itemTotal;
  final double deliveryCharge;
  final double taxes;
  final double grandTotal;
  final String status; // New, Preparing, Ready, Completed, Cancelled
  final String? paymentStatus;
  final String? paymentMethod;
  final DateTime createdAt;
  final DateTime? estimatedDelivery;
  final int? estimatedPreparationTime;
  final String? rejectionReason;
  final DeliveryPartner? deliveryPartner;

  double get totalAmount => grandTotal;

  Order({
    required this.id,
    required this.orderId,
    this.userId,
    this.userName,
    this.userPhone,
    this.userAddress,
    this.latitude,
    this.longitude,
    required this.items,
    required this.itemTotal,
    required this.deliveryCharge,
    required this.taxes,
    required this.grandTotal,
    required this.status,
    this.paymentStatus,
    this.paymentMethod,
    required this.createdAt,
    this.estimatedDelivery,
    this.estimatedPreparationTime,
    this.rejectionReason,
    this.deliveryPartner,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id']?.toString() ?? '',
      orderId: json['orderId'] ?? json['order_id'] ?? '',
      userId: json['userId']?.toString(),
      userName: json['userName'] ?? json['user_name'] ?? json['customerName'],
      userPhone: json['userPhone'] ?? json['user_phone'] ?? json['customerPhone'],
      userAddress: json['userAddress'] ?? json['user_address'] ?? json['address'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromJson(item))
              .toList() ??
          [],
      itemTotal: (json['itemTotal'] ?? json['item_total'] ?? 0).toDouble(),
      deliveryCharge: (json['deliveryCharge'] ?? json['delivery_charge'] ?? 0).toDouble(),
      taxes: (json['taxes'] ?? json['tax'] ?? 0).toDouble(),
      grandTotal: (json['grandTotal'] ?? json['grand_total'] ?? json['total'] ?? 0).toDouble(),
      status: json['status'] ?? 'New',
      paymentStatus: json['paymentStatus'] ?? json['payment_status'],
      paymentMethod: json['paymentMethod'] ?? json['payment_method'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      estimatedDelivery: json['estimatedDelivery'] != null
          ? DateTime.parse(json['estimatedDelivery'])
          : null,
      estimatedPreparationTime: json['estimatedPreparationTime'] ?? json['estimated_preparation_time'],
      rejectionReason: json['rejectionReason'] ?? json['rejection_reason'],
      deliveryPartner: json['deliveryPartner'] != null
          ? DeliveryPartner.fromJson(json['deliveryPartner'])
          : null,
    );
  }

  String getStatusDisplayText() {
    switch (status) {
      case 'New':
        return 'New Order';
      case 'Preparing':
        return 'Preparing';
      case 'Ready':
        return 'Ready';
      case 'Completed':
        return 'Completed';
      case 'Cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  String getTimeAgo() {
    final difference = DateTime.now().difference(createdAt);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes} minutes ago';
    if (difference.inHours < 24) return '${difference.inHours} hours ago';
    return '${difference.inDays} days ago';
  }
}

class OrderItem {
  final String id;
  final String name;
  final int quantity;
  final double price;
  final List<String>? customizations;
  final String? notes;

  OrderItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
    this.customizations,
    this.notes,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? json['itemName'] ?? '',
      quantity: json['quantity'] ?? 1,
      price: (json['price'] ?? 0).toDouble(),
      customizations: json['customizations'] != null
          ? List<String>.from(json['customizations'])
          : null,
      notes: json['notes'],
    );
  }
}

class DeliveryPartner {
  final String id;
  final String name;
  final String phone;
  final String? vehicleType;
  final double? currentLatitude;
  final double? currentLongitude;

  DeliveryPartner({
    required this.id,
    required this.name,
    required this.phone,
    this.vehicleType,
    this.currentLatitude,
    this.currentLongitude,
  });

  factory DeliveryPartner.fromJson(Map<String, dynamic> json) {
    return DeliveryPartner(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? json['phoneNumber'] ?? '',
      vehicleType: json['vehicleType'] ?? json['vehicle_type'],
      currentLatitude: json['currentLatitude']?.toDouble() ?? json['latitude']?.toDouble(),
      currentLongitude: json['currentLongitude']?.toDouble() ?? json['longitude']?.toDouble(),
    );
  }
}
