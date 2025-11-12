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
    
    if (_restaurantId != null) {
      await Future.wait([
        loadFoodItems(),
        loadCategories(),
        loadCuisines(),
      ]);
    } else {
      print('MenuViewModel: Restaurant ID is null, cannot load data');
    }
  }

  Future<void> loadFoodItems() async {
    if (_restaurantId == null) {
      print('MenuViewModel: Cannot load food items, restaurant ID is null');
      return;
    }

    print('MenuViewModel: Loading food items for restaurant: $_restaurantId');
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _menuService.getAllFoodItems(
        restaurantId: _restaurantId!,
        cuisineId: _selectedCuisine?.id,
        categoryId: _selectedCategory?.id,
      );

      _isLoading = false;

      print('MenuViewModel: Response success: ${response.success}');
      print('MenuViewModel: Response data is null: ${response.data == null}');
      print('MenuViewModel: Response data length: ${response.data?.length ?? 0}');

      if (response.success && response.data != null) {
        _foodItems = response.data!;
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

  Future<void> loadCategories() async {
    print('MenuViewModel: Loading categories...');
    final response = await _menuService.getCategories();
    if (response.success && response.data != null) {
      _categories = response.data!;
      print('MenuViewModel: Loaded ${_categories.length} categories.');
      notifyListeners();
    } else {
      print('MenuViewModel: Failed to load categories: ${response.message}');
    }
  }

  Future<void> loadCuisines() async {
    print('MenuViewModel: Loading cuisines...');
    final response = await _menuService.getCuisines();
    if (response.success && response.data != null) {
      _cuisines = response.data!;
      print('MenuViewModel: Loaded ${_cuisines.length} cuisines.');
      notifyListeners();
    } else {
      print('MenuViewModel: Failed to load cuisines: ${response.message}');
    }
  }

  Future<bool> addFoodItem(FoodItem foodItem, File? imageFile) async {
    _isLoading = true;
    notifyListeners();

    final response = await _menuService.createFoodItem(
      foodItem: foodItem,
      imageFile: imageFile,
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

  Future<bool> updateFoodItem(String id, FoodItem foodItem, File? imageFile) async {
    _isLoading = true;
    notifyListeners();

    final response = await _menuService.updateFoodItem(
      id: id,
      foodItem: foodItem,
      imageFile: imageFile,
    );

    _isLoading = false;
    notifyListeners();

    if (response.success) {
      Fluttertoast.showToast(
        msg: 'Dish updated successfully!',
        backgroundColor: Colors.green,
      );
      await loadFoodItems();
      return true;
    } else {
      Fluttertoast.showToast(
        msg: response.message ?? 'Failed to update dish',
        backgroundColor: Colors.red,
      );
      return false;
    }
  }

  Future<bool> deleteFoodItem(String id) async {
    _isLoading = true;
    notifyListeners();

    final response = await _menuService.deleteFoodItem(id);

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
}
