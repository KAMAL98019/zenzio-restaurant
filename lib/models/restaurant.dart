import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:zenzio_restaurant/models/operational_hours.dart';
import 'package:zenzio_restaurant/models/documents.dart';
import 'package:zenzio_restaurant/models/bank_details.dart';
import 'package:zenzio_restaurant/models/cuisine.dart';
import 'package:zenzio_restaurant/models/category.dart' as rest_category;
import 'package:zenzio_restaurant/models/address.dart';

class Restaurant {
  final String id;
  final String restaurantName;
  final String avgCostTwo; // Changed to String
  final String restLogo;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber; // Personal phone number
  final String restContactNumber; // Restaurant contact number
  final String restEmail;
  final Address address; // Added Address object
  final String? restWebsite;
  final List<Cuisine> cuisines;
  final List<rest_category.Category> categories;
  final String? socialMedia;
  final List<OperationalHours> operationalHours;
  final Documents documents;
  final BankDetails bankDetails;
  final bool agreeToTerms;
  final String status;
  final String deliveryType;
  final double? deliveryRadius;
  final String? deliveryZones;
  final String? minOrderAmount;
  final String? baseDeliveryFee;
  final String? otp;
  final String? otpExpiry;
  final bool otpVerified;
  final String createdAt;
  final String updatedAt;

  Restaurant({
    required this.id,
    required this.restaurantName,
    required this.avgCostTwo,
    required this.restLogo,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.restContactNumber,
    required this.restEmail,
    this.restWebsite,
    required this.cuisines,
    required this.categories,
    this.socialMedia,
    required this.operationalHours,
    required this.documents,
    required this.bankDetails,
    required this.agreeToTerms,
    required this.status,
    required this.deliveryType,
    this.deliveryRadius,
    this.deliveryZones,
    this.minOrderAmount,
    this.baseDeliveryFee,
    this.otp,
    this.otpExpiry,
    required this.otpVerified,
    required this.createdAt,
    required this.updatedAt,
    required this.address, // Added Address object
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] ?? '',
      restaurantName: json['restaurant_name'] ?? '',
      avgCostTwo: json['avg_cost_two']?.toString() ?? '0.00',
      restLogo: json['photo'] ?? '', // Mapped from 'photo'
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '', // Personal phone number
      restContactNumber: json['phoneNumber'] ?? '', // Mapped from 'phoneNumber'
      restEmail: json['email'] ?? '', // Mapped from 'email'
      restWebsite: json['rest_website'],
      cuisines: _parseCuisines(json['cuisines']),
      categories: _parseCategories(json['categories']),
      socialMedia: json['social_media'],
      operationalHours: _parseOperationalHours(json['operational_hours']),
      documents: Documents.fromJson(json['documents'] ?? {}),
      bankDetails: BankDetails.fromJson(json['bank_details'] ?? {}), // Mapped from 'bank_details'
      agreeToTerms: json['agree_to_terms'] ?? false,
      status: json['status'] ?? 'inactive',
      deliveryType: json['deliveryType'] ?? 'RADIUS',
      deliveryRadius: (json['deliveryRadius'] as num?)?.toDouble(),
      deliveryZones: json['deliveryZones'],
      minOrderAmount: json['minOrderAmount']?.toString(),
      baseDeliveryFee: json['baseDeliveryFee']?.toString(),
      otp: json['otp'],
      otpExpiry: json['otpExpiry'],
      otpVerified: json['otpVerified'] ?? false,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      address: Address.fromJson(json['address'] ?? {}), // Mapped from 'address'
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurant_name': restaurantName,
      'avg_cost_two': avgCostTwo,
      'photo': restLogo,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'rest_contact_number': restContactNumber,
      'rest_email': restEmail,
      'rest_website': restWebsite,
      'cuisines': cuisines.map((e) => e.toJson()).toList(),
      'categories': categories.map((e) => e.toJson()).toList(),
      'social_media': socialMedia,
      'operational_hours': operationalHours.map((e) => e.toJson()).toList(),
      'documents': documents.toJson(),
      'bank_details': bankDetails.toJson(),
      'agree_to_terms': agreeToTerms,
      'status': status,
      'deliveryType': deliveryType,
      'deliveryRadius': deliveryRadius,
      'deliveryZones': deliveryZones,
      'minOrderAmount': minOrderAmount,
      'baseDeliveryFee': baseDeliveryFee,
      'otp': otp,
      'otpExpiry': otpExpiry,
      'otpVerified': otpVerified,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'address': address.toJson(),
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

List<Cuisine> _parseCuisines(dynamic data) {
  if (data == null) {
    return [];
  }
  if (data is String) {
    try {
      final decoded = jsonDecode(data);
      if (decoded is List) {
        return decoded.map((e) => Cuisine.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('Error decoding cuisines string: $e');
    }
  }
  if (data is List) {
    return data.map((e) => Cuisine.fromJson(e)).toList();
  }
  return [];
}

List<rest_category.Category> _parseCategories(dynamic data) {
  if (data == null) {
    return [];
  }
  if (data is String) {
    try {
      final decoded = jsonDecode(data);
      if (decoded is List) {
        return decoded.map((e) => rest_category.Category.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('Error decoding categories string: $e');
    }
  }
  if (data is List) {
    return data.map((e) => rest_category.Category.fromJson(e)).toList();
  }
  return [];
}
