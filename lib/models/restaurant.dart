import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:zenzio_restaurant/models/operational_hours.dart';

class Restaurant {
  final String id;
  final String restName;
  final String restAddress;
  final String avgCostTwo; // Changed to String
  final String restLogo;
  final String contactPersonName;
  final String contactEmail;
  final String contactNumber;
  final List<OperationalHours> operationalHours;
  final String fssaiCertificate;
  final String gstCertificate;
  final String bankAccountName;
  final String accountNumber;
  final String ifscCode;
  final bool agreeToTerms;
  final String status;
  final String deliveryType;
  final double? deliveryRadius;
  final String? deliveryZones;
  final double? restaurantLatitude;
  final double? restaurantLongitude;
  final String? minOrderAmount;
  final String? baseDeliveryFee;
  final String? otp;
  final String? otpExpiry;
  final bool otpVerified;
  final String createdAt;
  final String updatedAt;

  Restaurant({
    required this.id,
    required this.restName,
    required this.restAddress,
    required this.avgCostTwo,
    required this.restLogo,
    required this.contactPersonName,
    required this.contactEmail,
    required this.contactNumber,
    required this.operationalHours,
    required this.fssaiCertificate,
    required this.gstCertificate,
    required this.bankAccountName,
    required this.accountNumber,
    required this.ifscCode,
    required this.agreeToTerms,
    required this.status,
    required this.deliveryType,
    this.deliveryRadius,
    this.deliveryZones,
    this.restaurantLatitude,
    this.restaurantLongitude,
    this.minOrderAmount,
    this.baseDeliveryFee,
    this.otp,
    this.otpExpiry,
    required this.otpVerified,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] ?? '',
      restName: json['rest_name'] ?? '',
      restAddress: json['rest_address'] ?? '',
      avgCostTwo: json['avg_cost_two']?.toString() ?? '0.00',
      restLogo: json['rest_logo'] ?? '',
      contactPersonName: json['contact_person_name'] ?? '',
      contactEmail: json['contact_email'] ?? '',
      contactNumber: json['contact_number'] ?? '',
      operationalHours: _parseOperationalHours(json['operational_hours']),
      fssaiCertificate: json['fssai_certificate'] ?? '',
      gstCertificate: json['gst_certificate'] ?? '',
      bankAccountName: json['bank_account_name'] ?? '',
      accountNumber: json['account_number'] ?? '',
      ifscCode: json['ifsc_code'] ?? '',
      agreeToTerms: json['agree_to_terms'] ?? false,
      status: json['status'] ?? 'inactive',
      deliveryType: json['deliveryType'] ?? 'RADIUS',
      deliveryRadius: (json['deliveryRadius'] as num?)?.toDouble(),
      deliveryZones: json['deliveryZones'],
      restaurantLatitude: (json['restaurantLatitude'] as num?)?.toDouble(),
      restaurantLongitude: (json['restaurantLongitude'] as num?)?.toDouble(),
      minOrderAmount: json['minOrderAmount']?.toString(),
      baseDeliveryFee: json['baseDeliveryFee']?.toString(),
      otp: json['otp'],
      otpExpiry: json['otpExpiry'],
      otpVerified: json['otpVerified'] ?? false,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rest_name': restName,
      'rest_address': restAddress,
      'avg_cost_two': avgCostTwo,
      'rest_logo': restLogo,
      'contact_person_name': contactPersonName,
      'contact_email': contactEmail,
      'contact_number': contactNumber,
      'operational_hours': operationalHours.map((e) => e.toJson()).toList(),
      'fssai_certificate': fssaiCertificate,
      'gst_certificate': gstCertificate,
      'bank_account_name': bankAccountName,
      'account_number': accountNumber,
      'ifsc_code': ifscCode,
      'agree_to_terms': agreeToTerms,
      'status': status,
      'deliveryType': deliveryType,
      'deliveryRadius': deliveryRadius,
      'deliveryZones': deliveryZones,
      'restaurantLatitude': restaurantLatitude,
      'restaurantLongitude': restaurantLongitude,
      'minOrderAmount': minOrderAmount,
      'baseDeliveryFee': baseDeliveryFee,
      'otp': otp,
      'otpExpiry': otpExpiry,
      'otpVerified': otpVerified,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

List<OperationalHours> _parseOperationalHours(dynamic data) {
  if (data == null) {
    return [];
  }
  if (data is String) {
    try {
      final decoded = jsonDecode(data);
      if (decoded is List) {
        return decoded.map((e) => OperationalHours.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('Error decoding operational_hours string: $e');
    }
  }
  if (data is List) {
    return data.map((e) => OperationalHours.fromJson(e)).toList();
  }
  return [];
}
