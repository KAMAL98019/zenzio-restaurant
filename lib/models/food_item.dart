import 'dart:convert';

class FoodItem {
  final String? id;
  final String? menuUid;
  final String? restaurantUid;
  final String menuName;
  final String category;
  final String? description;
  final double price;
  final String foodType;
  final String? cuisineType; // New field
  final bool containAllergence;
  final String? specifyAllergence;
  final List<CustomizationOption>? customizedOption;
  final List<CustomizationOption>? sizeOption; // New field
  final List<CustomizationOption>? topping; // New field
  final String? size;
  final int? qty;
  final List<String>? images;
  final int? discount;
  final double? rating;
  final int? orderedCount;
  final bool isActive;
  
  // Old API fields for compatibility
  final String? restId;
  final String? cuisineId;
  final String? categoryId;
  final String? dishimage;
  final bool? _veg; // Old veg field
  final bool? _containAllergens; // Old name
  final String? _specifyAllergens; // Old name
  final List<CustomizationOption>? _customisedOptions; // Old name
  final bool? _isAvailable; // Old name
  final String? cuisineName;
  final String? categoryName;

  FoodItem({
    this.id,
    this.menuUid,
    this.restaurantUid,
    required this.menuName,
    required this.category,
    this.description,
    required this.price,
    this.foodType = 'Non-Veg', // Default to 'Non-Veg' as an example
    this.cuisineType, // New field
    this.containAllergence = false,
    this.specifyAllergence,
    this.customizedOption,
    this.sizeOption, // New field
    this.topping, // New field
    this.size,
    this.qty = 1,
    this.images,
    this.discount,
    this.rating = 0.0,
    this.orderedCount = 0,
    this.isActive = true,
    // Old API fields for compatibility
    this.restId,
    this.cuisineId,
    this.categoryId,
    this.dishimage,
    bool? veg,
    bool? containAllergens,
    String? specifyAllergens,
    List<CustomizationOption>? customisedOptions,
    bool? isAvailable,
    this.cuisineName,
    this.categoryName,
  }) : _veg = veg,
       _containAllergens = containAllergens,
       _specifyAllergens = specifyAllergens,
       _customisedOptions = customisedOptions,
       _isAvailable = isAvailable;

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id']?.toString(),
      
      // New API fields (menu_uid, menu_name, etc.)
      menuUid: json['menu_uid']?.toString(),
      restaurantUid: json['restaurant_uid']?.toString(),
      menuName: json['menu_name'] ?? json['dishname'] ?? json['dish_name'] ?? '',
      category: json['category'] ?? json['categoryName'] ?? '',
      description: json['description'],
      price: (json['price'] is String)
          ? double.tryParse(json['price']) ?? 0.0
          : (json['price'] ?? 0).toDouble(),
      foodType: json['food_type'] ?? (json['veg'] == true ? 'Veg' : 'Non-Veg'),
      cuisineType: json['cuisine_type'], // New field
      containAllergence: json['contain_allergence'] ?? json['containAllergens'] ?? false,
      specifyAllergence: json['specify_allergence'] ?? json['specifyAllergens'],
      customizedOption: json['customized_option'] != null
          ? _parseCustomizations(json['customized_option'])
          : (json['customised_options'] != null ? _parseCustomizations(json['customised_options']) : null),
      sizeOption: json['size_option'] != null // New field
          ? _parseCustomizations(json['size_option'])
          : null,
      topping: json['topping'] != null // New field
          ? _parseCustomizations(json['topping'])
          : null,
      size: json['size'],
      qty: json['qty'] ?? 1,
      images: (json['images'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      discount: json['discount'],
      rating: (json['rating'] is num) ? (json['rating'] as num).toDouble() : null,
      orderedCount: json['orderedCount'],
      isActive: json['isActive'] ?? json['isAvailable'] ?? true,

      // Old API fields for compatibility (restId, dishimage, veg, etc.)
      restId: json['rest_id']?.toString() ?? json['restId']?.toString(),
      cuisineId: json['cuisineId']?.toString(),
      categoryId: json['categoryId']?.toString(),
      dishimage: json['dishimage'] ?? json['dish_image'],
      veg: json['veg'],
      containAllergens: json['contain_allergens'] ?? json['containAllergens'],
      specifyAllergens: json['specify_allergens'] ?? json['specifyAllergence'],
      customisedOptions: json['customised_options'] != null
          ? _parseCustomizations(json['customised_options'])
          : null,
      isAvailable: json['is_available'] ?? json['isAvailable'],
      cuisineName: json['cuisine'] is Map ? json['cuisine']['name'] : (json['cuisine_name'] ?? json['cuisineName']),
      categoryName: json['category'] is Map ? json['category']['name'] : (json['category_name'] ?? json['categoryName']),
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

  Map<String, dynamic> toJson({bool includeOldFields = false}) {
    // This is for the new /restaurant-menu API (POST)
    final jsonMap = <String, dynamic>{
      'menu_name': menuName,
      'category': category,
      'description': description,
      'price': price,
      'food_type': foodType,
      'cuisine_type': cuisineType, // New field
      'contain_allergence': containAllergence,
      'specify_allergence': specifyAllergence,
      'customized_option': customizedOption != null && customizedOption!.isNotEmpty
          ? customizedOption!.map((e) => e.toJson()).toList()
          : [],
      'size_option': sizeOption != null && sizeOption!.isNotEmpty
          ? sizeOption!.map((e) => e.toJson()).toList()
          : [],
      'topping': topping != null && topping!.isNotEmpty
          ? topping!.map((e) => e.toJson()).toList()
          : [],
      'size': size,
      'qty': qty,
      'discount': discount,
      'isActive': isActive,
    };
    // Include identifiers only if they are not null and for specific API calls (e.g., PUT/POST)
    // For PATCH, typically only send fields that are being updated.
    if (id != null) jsonMap['id'] = id; // Sometimes ID might be needed for internal tracking in update payloads
    if (restaurantUid != null) jsonMap['restaurant_uid'] = restaurantUid;

    // Images are handled by a separate upload endpoint in the new API, so they are not included in the main JSON payload for PATCH/PUT.
    // However, if the images field is explicitly being updated (e.g., clearing images), it might be handled differently by the API.
    // For now, we omit it from the default toJson, and let the image upload logic manage it.
    // The images field in the API example likely represents the *current* images returned by GET, not necessarily what's sent in PATCH.

    // Add old API fields only when explicitly requested (e.g., for deprecated endpoints)
    if (includeOldFields) {
      if (restId != null) jsonMap['rest_id'] = restId;
      if (cuisineId != null) jsonMap['cuisineId'] = cuisineId;
      if (categoryId != null) jsonMap['categoryId'] = categoryId;
      if (dishimage != null) jsonMap['dishimage'] = dishimage;
      if (_veg != null) jsonMap['veg'] = _veg;
      if (_containAllergens != null) jsonMap['contain_allergens'] = _containAllergens;
      if (_specifyAllergens != null) jsonMap['specify_allergens'] = _specifyAllergens;
      if (_customisedOptions != null) {
        // Old API expected JSON string for customised_options
        jsonMap['customised_options'] = jsonEncode(_customisedOptions!.map((e) => e.toJson()).toList());
      }
      // Old API key mappings for the new data
      jsonMap['dishname'] = menuName;
      jsonMap['is_available'] = isActive;
    }

    return jsonMap;
  }

  // Compatibility getters for old code using deprecated names
  String get dishname => menuName;
  bool get veg => _veg ?? foodType == 'Veg';
  bool get containAllergens => _containAllergens ?? containAllergence;
  String? get specifyAllergens => _specifyAllergens ?? specifyAllergence;
  List<CustomizationOption>? get customisedOptions => _customisedOptions ?? customizedOption;
  bool get isAvailable => _isAvailable ?? isActive;

  String getCategoryDisplay() {
    return categoryName ?? category;
  }

  FoodItem copyWith({
    String? id,
    String? menuUid,
    String? restaurantUid,
    String? menuName,
    String? category,
    String? description,
    double? price,
    String? foodType,
    String? cuisineType, // New field
    bool? containAllergence,
    String? specifyAllergence,
    List<CustomizationOption>? customizedOption,
    List<CustomizationOption>? sizeOption, // New field
    List<CustomizationOption>? topping, // New field
    String? size,
    int? qty,
    List<String>? images,
    int? discount,
    double? rating,
    int? orderedCount,
    bool? isActive,
    String? restId,
    String? cuisineId,
    String? categoryId,
    String? dishimage,
    bool? veg,
    bool? containAllergens,
    String? specifyAllergens,
    List<CustomizationOption>? customisedOptions,
    bool? isAvailable,
    String? cuisineName,
    String? categoryName,
  }) {
    return FoodItem(
      id: id ?? this.id,
      menuUid: menuUid ?? this.menuUid,
      restaurantUid: restaurantUid ?? this.restaurantUid,
      menuName: menuName ?? this.menuName,
      category: category ?? this.category,
      description: description ?? this.description,
      price: price ?? this.price,
      foodType: foodType ?? this.foodType,
      cuisineType: cuisineType ?? this.cuisineType, // New field
      containAllergence: containAllergence ?? this.containAllergence,
      specifyAllergence: specifyAllergence ?? this.specifyAllergence,
      customizedOption: customizedOption ?? this.customizedOption,
      sizeOption: sizeOption ?? this.sizeOption, // New field
      topping: topping ?? this.topping, // New field
      size: size ?? this.size,
      qty: qty ?? this.qty,
      images: images ?? this.images,
      discount: discount ?? this.discount,
      rating: rating ?? this.rating,
      orderedCount: orderedCount ?? this.orderedCount,
      isActive: isActive ?? this.isActive,
      restId: restId ?? this.restId,
      cuisineId: cuisineId ?? this.cuisineId,
      categoryId: categoryId ?? this.categoryId,
      dishimage: dishimage ?? this.dishimage,
      veg: veg ?? this._veg,
      containAllergens: containAllergens ?? this._containAllergens,
      specifyAllergens: specifyAllergens ?? this._specifyAllergens,
      customisedOptions: customisedOptions ?? this._customisedOptions,
      isAvailable: isAvailable ?? this._isAvailable,
      cuisineName: cuisineName ?? this.cuisineName,
      categoryName: categoryName ?? this.categoryName,
    );
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



class RestaurantMenusData {
  final List<FoodItem> restaurantMenus;
  
  RestaurantMenusData({required this.restaurantMenus});

  factory RestaurantMenusData.fromJson(Map<String, dynamic> json) {
    return RestaurantMenusData(
      restaurantMenus: (json['restaurant_menus'] as List<dynamic>?)
              ?.map((e) => FoodItem.fromJson(e))
              .toList() ??
          [],
    );
  }
}
