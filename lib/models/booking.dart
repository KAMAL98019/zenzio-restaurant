class Booking {
  final String id;
  final String bookingId;
  final String restaurantId;
  final String? userId;
  final String customerName;
  final String customerPhone;
  final DateTime bookingDate;
  final String bookingTime;
  final int guests;
  final String status; // Pending, Confirmed, Seated, Completed, Cancelled
  final String? specialRequests;
  final String? tableNumber;
  final String? diningArea;
  final String? purpose;
  final DateTime? createdAt;

  Booking({
    required this.id,
    required this.bookingId,
    required this.restaurantId,
    this.userId,
    required this.customerName,
    required this.customerPhone,
    required this.bookingDate,
    required this.bookingTime,
    required this.guests,
    required this.status,
    this.specialRequests,
    this.tableNumber,
    this.diningArea,
    this.purpose,
    this.createdAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id']?.toString() ?? '',
      bookingId: json['bookingId'] ?? json['booking_id'] ?? '',
      restaurantId: json['restaurantId']?.toString() ?? json['restaurant_id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? json['user_id']?.toString(),
      customerName: json['customerName'] ?? json['customer_name'] ?? json['name'] ?? '',
      customerPhone: json['customerPhone'] ?? json['customer_phone'] ?? json['phone'] ?? '',
      bookingDate: json['bookingDate'] != null
          ? DateTime.parse(json['bookingDate'])
          : json['booking_date'] != null
              ? DateTime.parse(json['booking_date'])
              : DateTime.now(),
      bookingTime: json['bookingTime'] ?? json['booking_time'] ?? '',
      guests: int.tryParse(json['guests']?.toString() ?? '0') ??
          int.tryParse(json['number_of_guests']?.toString() ?? '0') ??
          0,
      status: json['status'] ?? 'Pending',
      specialRequests: json['specialRequests'] ?? json['special_requests'],
      tableNumber: json['tableNumber'] ?? json['table_number'],
      diningArea: json['diningArea'] ?? json['dining_area'],
      purpose: json['purpose'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'restaurantId': restaurantId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'bookingDate': bookingDate.toIso8601String(),
      'bookingTime': bookingTime,
      'guests': guests,
      'status': status,
      if (specialRequests != null) 'specialRequests': specialRequests,
      if (tableNumber != null) 'tableNumber': tableNumber,
      if (diningArea != null) 'diningArea': diningArea,
      if (purpose != null) 'purpose': purpose,
    };
  }

  String getFormattedDate() {
    return '${_getMonthName(bookingDate.month)} ${bookingDate.day}, ${bookingDate.year}';
  }

  String getFormattedTime() {
    return bookingTime;
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}

