import '../models/api_response.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/food_item.dart';
import '../models/category.dart';
import '../models/cuisine.dart';
import '../services/menu_service.dart';
import '../services/auth_service.dart';

class MenuViewModel extends ChangeNotifier {
  final MenuService _menuService = MenuService();
  final AuthService _authService = AuthService();

  List<FoodItem> _foodItems = [];
  List<Category> _categories = [];
  List<Cuisine> _cuisines = [];
  bool _isLoading = false;
  String? _restaurantId;
  Cuisine? _selectedCuisine;
  Category? _selectedCategory;

  List<FoodItem> get foodItems => _foodItems;
  List<Category> get categories => _categories;
  List<Cuisine> get cuisines => _cuisines;
  bool get isLoading => _isLoading;
  Cuisine? get selectedCuisine => _selectedCuisine;
  Category? get selectedCategory => _selectedCategory;

  // Group items by category
  Map<String, List<FoodItem>> get groupedByCategory {
    Map<String, List<FoodItem>> grouped = {};
    for (var item in _foodItems) {
      final category = item.getCategoryDisplay();
      if (!grouped.containsKey(category)) {
        grouped[category] = [];
      }
      grouped[category]!.add(item);
    }
    print('MenuViewModel: Grouped ${_foodItems.length} items into ${grouped.length} categories');
    return grouped;
  }

  void setSelectedCuisine(Cuisine? cuisine) {
    _selectedCuisine = cuisine;
    notifyListeners();
  }

  void setSelectedCategory(Category? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> initialize() async {
    print('MenuViewModel: Initializing...');
    _restaurantId = await _authService.getRestaurantId();
    print('MenuViewModel: Restaurant ID: $_restaurantId');
    
    // The new API doesn't require restaurantId for menu fetching, but other initializers might.
    // Proceed with loading all necessary data.
    // Ensure enums are loaded first so categories and cuisines are available
    // for potential selection when loading food items.
    await loadEnums();
    await loadFoodItems();
  }

  Future<void> loadFoodItems() async {
    // The new API no longer requires restaurantId as a query parameter.
    // We can still log the restaurantId but proceed with the request.
    print('MenuViewModel: Loading food items');
    print('MenuViewModel: Selected Cuisine (before API call): ${_selectedCuisine?.id} - ${_selectedCuisine?.name}');
    print('MenuViewModel: Selected Category (before API call): ${_selectedCategory?.id} - ${_selectedCategory?.name}');
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _menuService.getAllFoodItems(
        cuisineId: _selectedCuisine?.id.toString(), // Convert int to String
        categoryId: _selectedCategory?.id.toString(),
      );

      _isLoading = false;

      print('MenuViewModel: Response success: ${response.success}');
      print('MenuViewModel: Response data is null: ${response.data == null}');
      print('MenuViewModel: Response data length: ${response.data?.length ?? 0}');

      if (response.success && response.data != null) {
        // Apply cache-busting to the image URLs on all loaded items
        final cacheBuster = DateTime.now().millisecondsSinceEpoch.toString();
        _foodItems = response.data!.map((item) {
          if (item.images?.isNotEmpty ?? false) {
            final newImages = item.images!.map((url) {
              return Uri.parse(url).replace(queryParameters: {'v': cacheBuster}).toString();
            }).toList();
            return item.copyWith(images: newImages);
          }
          return item;
        }).toList();

        print('MenuViewModel: Loaded ${_foodItems.length} food items.');
        for (var item in _foodItems) {
          print('  - ${item.dishname} (Category: ${item.getCategoryDisplay()})');
        }
      } else {
        _foodItems = [];
        print('MenuViewModel: Failed to load food items: ${response.message}');
        Fluttertoast.showToast(
          msg: response.message ?? 'Failed to load menu items',
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      _isLoading = false;
      _foodItems = [];
      print('MenuViewModel: Error loading food items: $e');
    }

    notifyListeners();
  }

  // New method to load both categories and cuisines from the /restaurant_enum endpoint
Future<void> loadEnums() async {
  print('MenuViewModel: Loading categories and cuisines from /restaurant_enum...');
  final response = await _menuService.getMenuEnums();

  if (response.success && response.data != null) {

    // ✅ response.data is already List<Category>
    final List<Category> allItems = response.data!;

    print("MenuViewModel: Enum raw count: ${allItems.length}");

    // ✅ fatherId == 0 → Category
    _categories = allItems.where((item) => item.fatherId == 0).toList();

    // ✅ fatherId != 0 → Cuisine (convert)
    _cuisines = allItems
        .where((item) => item.fatherId != 0)
        .map((item) => Cuisine.fromCategory(item))
        .toList();

    print('MenuViewModel: Loaded ${_categories.length} categories and ${_cuisines.length} cuisines.');
    notifyListeners();
  } else {
    print('MenuViewModel: Failed to load enums: ${response.message}');
    Fluttertoast.showToast(
      msg: response.message ?? 'Failed to load categories & cuisines',
      backgroundColor: Colors.red,
    );
  }
}


  // DEPRECATED: Old methods
  Future<void> loadCategories() async {}
  Future<void> loadCuisines() async {}

  Future<bool> addFoodItem(FoodItem foodItem, List<File>? imageFiles) async {
    _isLoading = true;
    notifyListeners();

    // Use the new service method for the /restaurant-menu API
    final response = await _menuService.addDish(
      foodItem: foodItem,
      imageFiles: imageFiles,
    );

    _isLoading = false;
    notifyListeners();

    if (response.success) {
      Fluttertoast.showToast(
        msg: 'Dish added successfully!',
        backgroundColor: Colors.green,
      );
      await loadFoodItems();
      return true;
    } else {
      Fluttertoast.showToast(
        msg: response.message ?? 'Failed to add dish',
        backgroundColor: Colors.red,
      );
      return false;
    }
  }

  // Update Food Item - Prioritize PATCH (New API) for partial updates
  Future<bool> updateFoodItem(String id, FoodItem foodItem, List<File>? imageFiles) async {
    _isLoading = true;
    notifyListeners();

    // --- NEW PATCH LOGIC (Preferred) ---
    if (foodItem.menuUid == null) {
      _isLoading = false;
      notifyListeners();
      Fluttertoast.showToast(
        msg: 'Cannot update dish: menuUid is missing. Please contact support.',
        backgroundColor: Colors.red,
      );
      return false;
    }
    
    final String uid = foodItem.menuUid!;

    // 1. Patch the data first
    final patchResponse = await _menuService.patchMenu(
      uid: uid,
      foodItem: foodItem,
    );

    if (!patchResponse.success) {
      _isLoading = false;
      notifyListeners();
      Fluttertoast.showToast(
        msg: patchResponse.message ?? 'Failed to update dish data',
        backgroundColor: Colors.red,
      );
      return false;
    }

    // 2. Handle image upload if files are provided
    FoodItem? updatedItem = patchResponse.data;
    
    // Defensive check to restore category/cuisine data if the patch response is incomplete.
    // This prevents the category/cuisine from being lost temporarily in the UI
    // before the final loadFoodItems() refresh.
    if (updatedItem != null) {
      updatedItem = updatedItem.copyWith(
        category: updatedItem.category.isEmpty ? foodItem.category : null,
        cuisineType: updatedItem.cuisineType ?? foodItem.cuisineType,
        categoryName: updatedItem.categoryName ?? foodItem.categoryName,
        cuisineName: updatedItem.cuisineName ?? foodItem.cuisineName,
        categoryId: updatedItem.categoryId ?? foodItem.categoryId,
        cuisineId: updatedItem.cuisineId ?? foodItem.cuisineId,
      );
    }

    if (imageFiles != null && imageFiles.isNotEmpty && updatedItem != null) {
      // New logic: If new files are present, start with an empty list for replacement
      final List<String> imageUrls = [];
      bool allUploadsSuccessful = true;

      for (final imageFile in imageFiles) {
        try {
          final uploadResponse = await _menuService.uploadMenuItemImage(
            uid: uid,
            filePath: imageFile.path,
          );
          
          // if (uploadResponse.success && uploadResponse.data != null) {
          //   // Service is expected to return List<String> of new image URLs
          //   final List<String> newUrls = uploadResponse.data as List<String>;
          //   for (final newUrl in newUrls) {
          //     // Add only unique new URLs
          //     if (!imageUrls.contains(newUrl)) {
          //       imageUrls.add(newUrl);
          //     }
          //   }
          // } else {
          //   allUploadsSuccessful = false;
          //   print('MenuViewModel: Warning: Image upload for ${imageFile.path} failed: ${uploadResponse.message}');
          //   Fluttertoast.showToast(
          //     msg: 'Warning: Image upload for ${imageFile.path} failed: ${uploadResponse.message ?? "Unknown error."}',
          //     backgroundColor: Colors.orange,
          //   );
          // }
        } catch (e) {
          // Catch unhandled exception from service layer (e.g., type cast error)
          allUploadsSuccessful = false;
          print('MenuViewModel: Severe Warning: Image upload for ${imageFile.path} crashed with error: $e');
          Fluttertoast.showToast(
            msg: 'Severe Warning: Image upload for ${imageFile.path} failed due to an error. Image will not be updated.',
            backgroundColor: Colors.orange,
          );
        }
      }
      
      // Only update the local object with new image URLs if all uploads were successful.
      // The image URLs returned by the service are the authoritative ones.
      if (allUploadsSuccessful) {
        updatedItem = updatedItem.copyWith(images: imageUrls);
      }
    }
    

    _isLoading = false;
    notifyListeners();
    
    Fluttertoast.showToast(
      msg: 'Dish updated successfully!',
      backgroundColor: Colors.green,
    );
    
    // Refresh the full list from the server to get the authoritative data
    // This is preferred over local list manipulation for complex updates,
    // which should resolve issues with Category/Cuisine display after an update.
    await loadFoodItems();
    
    return true;
  }

  Future<bool> deleteMenu(String id) async {
    _isLoading = true;
    notifyListeners();

    final response = await _menuService.deleteMenu(id);

    _isLoading = false;
    notifyListeners();

    if (response.success) {
      Fluttertoast.showToast(
        msg: 'Dish deleted successfully!',
        backgroundColor: Colors.green,
      );
      await loadFoodItems();
      return true;
    } else {
      Fluttertoast.showToast(
        msg: response.message ?? 'Failed to delete dish',
        backgroundColor: Colors.red,
      );
      return false;
    }
  }

  Future<bool> toggleFoodItemAvailability(FoodItem item) async {
    _isLoading = true;
    notifyListeners();

    final newAvailability = !item.isActive;
    // Assuming FoodItem has a copyWith method for immutability
    final updatedItem = item.copyWith(isActive: newAvailability);

    final response = await _menuService.toggleMenuItemStatus(
      id: item.id!,
      isActive: newAvailability,
    );
    
    // We update the local list on success and call loadFoodItems() in the next step.
    // The previous implementation used updateFoodItem which is likely the old PUT endpoint.
    // The new service call is toggleMenuItemStatus which is a PUT to /restaurant-menu/{id}/toggle

    _isLoading = false;
    notifyListeners();

    if (response.success) {
      Fluttertoast.showToast(
        msg: '${item.menuName} is now ${newAvailability ? 'available' : 'unavailable'}',
        backgroundColor: Colors.green,
      );
      // Update local list and notify listeners
      final index = _foodItems.indexWhere((element) => element.id == item.id);
      if (index != -1) {
        // The API response from toggle is generic, so we update the local object state directly
        _foodItems[index] = updatedItem;
      }
      notifyListeners();
      return true;
    } else {
      Fluttertoast.showToast(
        msg: response.message ?? 'Failed to update availability',
        backgroundColor: Colors.red,
      );
      return false;
    }
  }

  FoodItem? getFoodItemById(String id) {
    try {
      return _foodItems.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<Category?> getCategoryById(String id) async {
    final response = await _menuService.getCategoryById(id);
    if (response.success && response.data != null) {
      return response.data;
    } else {
      print('MenuViewModel: Failed to load category by ID: ${response.message}');
      return null;
    }
  }

  Future<Cuisine?> getCuisineById(String id) async {
    final response = await _menuService.getCuisineById(id);
    if (response.success && response.data != null) {
      return response.data;
    } else {
      print('MenuViewModel: Failed to load cuisine by ID: ${response.message}');
      return null;
    }
  }
  static List<String> getMenuUidsFromList(List<FoodItem> items) {
    return items.where((item) => item.menuUid != null).map((item) => item.menuUid!).toList();
  }

  Future<FoodItem?> loadFoodItemByUid(String menuUid) async {
    print('MenuViewModel: Loading food item by UID: $menuUid');
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _menuService.viewMenuByUid(menuUid);
      
      _isLoading = false;
      notifyListeners();

      if (response.success && response.data != null) {
        print('MenuViewModel: Loaded food item: ${response.data!.menuName}');
        return response.data;
      } else {
        print('MenuViewModel: Failed to load food item by UID: ${response.message}');
        Fluttertoast.showToast(
          msg: response.message ?? 'Failed to load menu item details',
          backgroundColor: Colors.red,
        );
        return null;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('MenuViewModel: Error loading food item by UID: $e');
      Fluttertoast.showToast(
        msg: 'An error occurred while loading menu item details',
        backgroundColor: Colors.red,
      );
      return null;
    }
  }
}
