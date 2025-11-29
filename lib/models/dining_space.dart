import 'package:flutter/foundation.dart';

class DiningSpace {
  final String? id;
  final String restaurantId;
  final String areaName;
  final int seatingCapacity;
  final String? description;
  final List<String>? photoUrls;

  DiningSpace({
    this.id,
    required this.restaurantId,
    required this.areaName,
    required this.seatingCapacity,
    this.description,
    this.photoUrls,
  });

  factory DiningSpace.fromJson(Map<String, dynamic> json) {
    return DiningSpace(
      id: json['id'] ?? json['_id'],
      restaurantId: json['restaurantId'] ?? '',
      areaName: json['areaName'] ?? '',
      seatingCapacity: json['seatingCapacity'] ?? 0,
      description: json['description'],
      photoUrls: json['photoUrls'] != null
          ? List<String>.from(json['photoUrls'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'restaurantId': restaurantId,
      'areaName': areaName,
      'seatingCapacity': seatingCapacity,
      'description': description,
      'photoUrls': photoUrls,
    };
  }
}
