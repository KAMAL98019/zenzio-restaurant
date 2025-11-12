import 'dart:convert';

class FoodItem {
  final String? id;
  final String restId;
  final String? cuisineId;
  final String? categoryId;
  final String dishname;
  final String? description;
  final double price;
  final bool veg;
  final bool containAllergens;
  final String? specifyAllergence;
  final List<CustomizationOption>? customisedOptions;
  final String? dishimage;
  final bool isAvailable;
  final String? cuisineName;
  final String? categoryName;

  FoodItem({
    this.id,
    required this.restId,
    this.cuisineId,
    this.categoryId,
    required this.dishname,
    this.description,
    required this.price,
    this.veg = false,
    this.containAllergens = false,
    this.specifyAllergence,
    this.customisedOptions,
    this.dishimage,
    this.isAvailable = true,
    this.cuisineName,
    this.categoryName,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id']?.toString(),
      restId: json['rest_id']?.toString() ?? json['restId']?.toString() ?? '',
      cuisineId: json['cuisineId']?.toString(),
      categoryId: json['categoryId']?.toString(),
      dishname: json['dishname'] ?? json['dish_name'] ?? '',
      description: json['description'],
      price: (json['price'] ?? 0).toDouble(),
      veg: json['veg'] ?? false,
      containAllergens: json['contain_allergens'] ?? json['containAllergens'] ?? false,
      specifyAllergence: json['specify_allergence'] ?? json['specifyAllergence'],
      customisedOptions: json['customised_options'] != null
          ? _parseCustomizations(json['customised_options'])
          : null,
      dishimage: json['dishimage'] ?? json['dish_image'],
      isAvailable: json['is_available'] ?? json['isAvailable'] ?? true,
      cuisineName: json['cuisine'] != null ? json['cuisine']['name'] : (json['cuisine_name'] ?? json['cuisineName']),
      categoryName: json['category'] != null ? json['category']['name'] : (json['category_name'] ?? json['categoryName']),
    );
  }

  static List<CustomizationOption>? _parseCustomizations(dynamic data) {
    try {
      if (data is String) {
        if (data.isEmpty) {
          return null;
        }
        // Parse JSON string
        final parsed = jsonDecode(data);
        if (parsed is List) {
          return parsed.map((e) => CustomizationOption.fromJson(e)).toList();
        }
      } else if (data is List) {
        return data.map((e) => CustomizationOption.fromJson(e)).toList();
      }
    } catch (e) {
      print('Error parsing customizations: $e');
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'rest_id': restId,
      'cuisineId': cuisineId ?? '',
      'categoryId': categoryId ?? '',
      'dishname': dishname,
      'description': description ?? '',
      'price': price,
      'veg': veg,
      'contain_allergens': containAllergens,
      'specify_allergence': specifyAllergence ?? '',
      'customised_options': customisedOptions != null
          ? jsonEncode(customisedOptions!.map((e) => e.toJson()).toList())
          : '',
    };
  }

  String getCategoryDisplay() {
    return categoryName ?? 'Uncategorized';
  }
}

class CustomizationOption {
  final String name;
  final double price;

  CustomizationOption({
    required this.name,
    required this.price,
  });

  factory CustomizationOption.fromJson(Map<String, dynamic> json) {
    return CustomizationOption(
      name: json['name'] ?? json['label'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
    };
  }
}

