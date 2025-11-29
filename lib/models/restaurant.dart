import 'package:zenzio_restaurant/models/address.dart';
import 'package:zenzio_restaurant/models/bank_details.dart';
import 'package:zenzio_restaurant/models/documents.dart';
import 'package:zenzio_restaurant/models/operational_hours.dart';

class Restaurant {
  final String? id;
  final String restaurantName;
  final String contactPerson;
  final String avgCostTwo;
  final List<String> photo;
  final String? firstName;
  final String? lastName;
  final String email;
  final String phoneNumber;
  final String restContactNumber;
  final String password;
  final String? restEmail;
  final Address address;
  final String? restWebsite;
  final String? socialMedia;
  final List<OperationalHours> operationalHours;
  final Documents documents;
  final BankDetails bankDetails;
  final bool? agreeToTerms;
  final String? status;
  final String? deliveryType;
  final double? deliveryRadius;
  final String? deliveryZones;
  final String? minOrderAmount;
  final String? baseDeliveryFee;
  final String? otp;
  final String? otpExpiry;
  final bool? otpVerified;
  final String? createdAt;
  final String? updatedAt;

  Restaurant({
    this.id,
    required this.restaurantName,
    required this.contactPerson,
    this.avgCostTwo = '',
    required this.photo,
    this.firstName,
    this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.restContactNumber,
    required this.password,
    this.restEmail,
    this.restWebsite,
    this.socialMedia,
    required this.operationalHours,
    required this.documents,
    required this.bankDetails,
    this.agreeToTerms,
    this.status,
    this.deliveryType,
    this.deliveryRadius,
    this.deliveryZones,
    this.minOrderAmount,
    this.baseDeliveryFee,
    this.otp,
    this.otpExpiry,
    this.otpVerified,
    this.createdAt,
    this.updatedAt,
    required this.address,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['_id'],
      restaurantName: json['restaurant_name'] ?? json['restaurantName'] ?? '',
      contactPerson: json['contact_person'] ?? json['contactPerson'] ?? '',
      avgCostTwo: json['avg_cost_for_two']?.toString() ?? '',
      photo: (json['photo'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      restContactNumber:
          json['contact_number'] ?? json['restContactNumber'] ?? '',
      password: json['password'] ?? '',
      restEmail: json['rest_email'] ?? json['restEmail'],
      address: json['address'] != null
          ? Address.fromJson(json['address'])
          : Address(
              city: '',
              state: '',
              pincode: '',
              address: '',
              lat: 0,
              lng: 0,
            ),
      restWebsite: json['rest_website'] ?? json['restWebsite'],
      socialMedia: json['social_media'] ?? json['socialMedia'],
      operationalHours: (json['operational_hours'] as List<dynamic>?)
              ?.map((e) => OperationalHours.fromJson(e))
              .toList() ??
          [],
      documents: json['documents'] != null
          ? Documents.fromJson(json['documents'])
          : Documents(
              fssaiNumber: '',
              fileFssai: [],
              gstNumber: '',
              fileGst: [],
              tradeLicenseNumber: '',
              fileTradeLicense: [],
              otherDocumentType: '',
              fileOtherDoc: [],
            ),
      bankDetails: json['bank_details'] != null
          ? BankDetails.fromJson(json['bank_details'])
          : BankDetails(
              bankName: '',
              accountNumber: '',
              ifscCode: '',
              accountType: '',
            ),
      agreeToTerms: json['agree_to_terms'],
      status: json['status'],
      deliveryType: json['deliveryType'],
      deliveryRadius: (json['deliveryRadius'] as num?)?.toDouble(),
      deliveryZones: json['deliveryZones'],
      minOrderAmount: json['minOrderAmount'],
      baseDeliveryFee: json['baseDeliveryFee'],
      otp: json['otp'],
      otpExpiry: json['otpExpiry'],
      otpVerified: json['otpVerified'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toRegistrationJson() {
    return {
      'restaurant_name': restaurantName,
      'contact_person': contactPerson,
      'contact_number': restContactNumber,
      'email': email,
      'phoneNumber': phoneNumber,
      'password': password,
      'avg_cost_for_two': avgCostTwo,
      'photo': photo,
      'bank_details': bankDetails.toJson(),
      'address': address.toJson(),
      'documents': documents.toJson(),
      'operational_hours': operationalHours.map((e) => e.toJson()).toList(),
    };
  }

  Map<String, dynamic> toJson() {
    return toRegistrationJson();
  }
}
