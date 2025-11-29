import 'category.dart';

class Cuisine {
  final int id; // Changed to int for consistency with Category enum
  final String name;
  final int fatherId; // Added for enum logic
  final int parentId; // Added for enum logic

  Cuisine({
    required this.id,
    required this.name,
    this.fatherId = 0, // Default for non-enum use
    this.parentId = 0, // Default for non-enum use
  });

  factory Cuisine.fromJson(Map<String, dynamic> json) {
    return Cuisine(
      id: (json['id'] is String ? int.tryParse(json['id']) : json['id'] as int?) ?? 0,
      name: json['name'] as String? ?? '',
      fatherId: json['father_id'] as int? ?? 0,
      parentId: json['parent_id'] as int? ?? 0,
    );
  }
  
  // Factory to convert from Category to Cuisine (for enum fetching)
  factory Cuisine.fromCategory(Category category) {
    return Cuisine(
      id: category.id,
      name: category.name,
      fatherId: category.fatherId,
      parentId: category.parentId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'father_id': fatherId,
      'parent_id': parentId,
    };
  }
}