class Offer {
  final String? id;
  final String restaurantId;
  final String title;
  final String? description;
  final String discountType; // PERCENTAGE or FLAT
  final double discountValue;
  final double? minOrderValue;
  final DateTime startDate;
  final DateTime endDate;
  final String? startTime;
  final String? endTime;
  final List<String>? applicableItems;
  final String? termsConditions;
  final String? offerImage;
  final String? status; // ACTIVE, INACTIVE
  final String? approvalStatus; // PENDING, APPROVED, REJECTED
  final DateTime? createdAt;

  Offer({
    this.id,
    required this.restaurantId,
    required this.title,
    this.description,
    required this.discountType,
    required this.discountValue,
    this.minOrderValue,
    required this.startDate,
    required this.endDate,
    this.startTime,
    this.endTime,
    this.applicableItems,
    this.termsConditions,
    this.offerImage,
    this.status,
    this.approvalStatus,
    this.createdAt,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    // Parse applicableItems - can be string or array
    List<String>? parseApplicableItems(dynamic value) {
      if (value == null) return null;
      if (value is List) {
        return List<String>.from(value);
      }
      if (value is String && value.isNotEmpty) {
        // If it's a comma-separated string or single ID
        if (value.contains(',')) {
          return value.split(',').map((e) => e.trim()).toList();
        } else {
          return [value];
        }
      }
      return null;
    }

    // Parse dates safely
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          print('Error parsing date: $value');
          return DateTime.now();
        }
      }
      return DateTime.now();
    }

    return Offer(
      id: json['id']?.toString(),
      restaurantId:
          json['restaurantId']?.toString() ??
          json['restaurant_id']?.toString() ??
          '',
      title: json['title'] ?? '',
      description: json['description'],
      discountType:
          json['discountType'] ?? json['discount_type'] ?? 'PERCENTAGE',
      discountValue: _parseDouble(
          json['discountValue'] ?? json['discount_value']) ?? 0.0,
      minOrderValue: _parseDouble(
          json['minOrderValue'] ?? json['min_order_value']),
      startDate: parseDate(json['startDate'] ?? json['start_date']),
      endDate: parseDate(json['endDate'] ?? json['end_date']),
      startTime: json['startTime'] ?? json['start_time'],
      endTime: json['endTime'] ?? json['end_time'],
      applicableItems: parseApplicableItems(
        json['applicableItems'] ?? json['applicable_items'],
      ),
      termsConditions: json['termsConditions'] ?? json['terms_conditions'],
      offerImage: json['offerImage'] ?? json['offer_image'],
      status: json['status'],
      approvalStatus: json['approvalStatus'] ?? json['approval_status'],
      createdAt: json['createdAt'] != null
          ? parseDate(json['createdAt'])
          : json['created_at'] != null
          ? parseDate(json['created_at'])
          : null,
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is num) {
      return double.parse(value.toStringAsFixed(2));
    }
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'restaurantId': restaurantId,
      if (id != null) '_id': id, // Use _id for MongoDB compatibility
      'title': title,
      'description': description ?? '',
      'discountType': discountType,
      'discountValue': discountValue,
      if (minOrderValue != null) 'minOrderValue': minOrderValue,
      'startDate': startDate.toIso8601String().split('T').first,
      'endDate': endDate.toIso8601String().split('T').first,
      if (startTime != null) 'startTime': startTime,
      if (endTime != null) 'endTime': endTime,
      if (applicableItems != null)
        'applicableItems': applicableItems!.join(','),
      'termsConditions': termsConditions ?? '',
      if (status != null) 'status': status,
      if (approvalStatus != null) 'approvalStatus': approvalStatus,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }

  // Add this method to the Offer class
  Offer copyWith({
    String? id,
    String? restaurantId,
    String? title,
    String? description,
    String? discountType,
    double? discountValue,
    double? minOrderValue,
    DateTime? startDate,
    DateTime? endDate,
    String? startTime,
    String? endTime,
    List<String>? applicableItems,
    String? termsConditions,
    String? offerImage,
    String? status,
    String? approvalStatus,
    DateTime? createdAt,
  }) {
    return Offer(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      title: title ?? this.title,
      description: description ?? this.description,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      minOrderValue: minOrderValue ?? this.minOrderValue,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      applicableItems: applicableItems ?? this.applicableItems,
      termsConditions: termsConditions ?? this.termsConditions,
      offerImage: offerImage ?? this.offerImage,
      status: status ?? this.status,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String getDiscountDisplay() {
    if (discountType == 'PERCENTAGE') {
      return '${discountValue.toStringAsFixed(0)}% OFF';
    } else {
      return '₹${discountValue.toStringAsFixed(0)} OFF';
    }
  }

  String getValidityDisplay() {
    return 'Valid until: ${_formatDate(endDate)}';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  bool isActive() {
    final now = DateTime.now();
    return status == 'ACTIVE' &&
        now.isAfter(startDate) &&
        now.isBefore(endDate.add(const Duration(days: 1)));
  }

  bool isPending() {
    return approvalStatus == 'PENDING';
  }

  bool isExpired() {
    return DateTime.now().isAfter(endDate.add(const Duration(days: 1)));
  }
}
