import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';

class Booking {
  final String id;
  final String restaurantId;
  final String customerName;
  final String customerPhone;
  final DateTime bookingDate;
  final String bookingTime;
  final int guests;
  final String status;
  final String? specialRequests;
  final String? tableNumber;

  String get bookingId => id;

  String getFormattedDate() {
    return DateFormat('MMM dd, yyyy').format(bookingDate);
  }

  Booking({
    required this.id,
    required this.restaurantId,
    required this.customerName,
    required this.customerPhone,
    required this.bookingDate,
    required this.bookingTime,
    required this.guests,
    required this.status,
    this.specialRequests,
    this.tableNumber,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? json['_id'] ?? '',
      restaurantId: json['restaurantId'] ?? '',
      customerName: json['customerName'] ?? '',
      customerPhone: json['customerPhone'] ?? '',
      bookingDate: DateTime.parse(json['bookingDate']),
      bookingTime: json['bookingTime'] ?? '',
      guests: json['guests'] ?? 0,
      status: json['status'] ?? 'Pending',
      specialRequests: json['specialRequests'],
      tableNumber: json['tableNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurantId': restaurantId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'bookingDate': bookingDate.toIso8601String(),
      'bookingTime': bookingTime,
      'guests': guests,
      'status': status,
      'specialRequests': specialRequests,
      'tableNumber': tableNumber,
    };
  }
}
