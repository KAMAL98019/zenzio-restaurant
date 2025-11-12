class DiningSpace {
  final String? id;
  final String? restaurantId;
  final String areaName;
  final int seatingCapacity;
  final String? description;
  final List<String>? photos;

  DiningSpace({
    this.id,
    this.restaurantId,
    required this.areaName,
    required this.seatingCapacity,
    this.description,
    this.photos,
  });

  factory DiningSpace.fromJson(Map<String, dynamic> json) {
    print('DiningSpace.fromJson: Parsing dining space');
    print('  JSON keys: ${json.keys.toList()}');
    
    final id = json['id']?.toString() ?? json['_id']?.toString();
    final restaurantId = json['restaurantId']?.toString() ?? json['restaurant_id']?.toString();
    final areaName = json['areaName'] ?? json['area_name'] ?? 'Unknown';
    final seatingCapacity = json['seatingCapacity'] ?? json['seating_capacity'] ?? 0;
    
    print('  Parsed: id=$id, restaurantId=$restaurantId, areaName=$areaName, capacity=$seatingCapacity');

    return DiningSpace(
      id: id,
      restaurantId: restaurantId,
      areaName: areaName,
      seatingCapacity: seatingCapacity,
      description: json['description'],
      photos: json['photos'] != null
          ? List<String>.from(json['photos'] as List)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (restaurantId != null) 'restaurantId': restaurantId,
      'areaName': areaName,
      'seatingCapacity': seatingCapacity,
      if (description != null && description!.isNotEmpty) 'description': description,
    };
  }
}
