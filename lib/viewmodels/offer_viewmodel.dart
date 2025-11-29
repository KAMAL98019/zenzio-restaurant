import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:zenzio_restaurant/models/category.dart';
import 'package:zenzio_restaurant/models/cuisine.dart';
import '../models/offer.dart';
import '../models/food_item.dart';
import '../services/offer_service.dart';
import '../services/menu_service.dart';
import '../services/auth_service.dart';

class OfferViewModel extends ChangeNotifier {
  final OfferService _offerService = OfferService();
  final MenuService _menuService = MenuService();
  final AuthService _authService = AuthService();

  List<Offer> _offers = [];
  List<Category> _categories = [];
  List<Cuisine> _cuisines = [];
  List<FoodItem> _foodItems = [];
  bool _isLoading = false;
  String? _restaurantId;

  List<Offer> get offers => _offers;
  List<Category> get categories => _categories;
  List<Cuisine> get cuisines => _cuisines;
  List<FoodItem> get foodItems => _foodItems;
  bool get isLoading => _isLoading;

  // Get active offers
  List<Offer> get activeOffers =>
      _offers.where((offer) => offer.isActive()).toList();

  // Get pending offers
  List<Offer> get pendingOffers =>
      _offers.where((offer) => offer.isPending()).toList();

  // Get expired offers
  List<Offer> get expiredOffers =>
      _offers.where((offer) => offer.isExpired()).toList();

  Future<void> initialize() async {
    try {
      print('OfferViewModel: Initializing...');
      _restaurantId = await _authService.getRestaurantId();
      print('OfferViewModel: Restaurant ID: $_restaurantId');

      // Directly load offers and other data as per user request, without checking for null restaurantId
      await Future.wait([
        loadOffers(),
        loadCategories(),
        loadCuisines(),
        loadFoodItems(),
      ]);
    } catch (e) {
      print('OfferViewModel: Error initializing: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadOffers({String? statusFilter}) async {
    print('OfferViewModel: Loading offers for restaurant: $_restaurantId');
    _isLoading = true;
    notifyListeners();

    try {
      // Always use dummy data as per user request
      _offers = _createDummyOffers();
      print('OfferViewModel: Loaded ${_offers.length} dummy offers');
      for (var offer in _offers) {
        print(
          '  - ${offer.title} (Status: ${offer.status}, Approval: ${offer.approvalStatus})',
        );
      }
    } catch (e) {
      print('OfferViewModel: Error loading offers: $e. Using dummy data.');
      _offers = _createDummyOffers(); // Fallback to dummy data on exception
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCategories() async {
    try {
      print('OfferViewModel: Loading categories...');
      final response = await _menuService.getCategories();
      if (response.success && response.data != null) {
        _categories = response.data!;
        print('OfferViewModel: Loaded ${_categories.length} categories');
        notifyListeners();
      }
    } catch (e) {
      print('OfferViewModel: Error loading categories: $e');
    }
  }

  Future<void> loadCuisines() async {
    try {
      print('OfferViewModel: Loading cuisines...');
      final response = await _menuService.getCuisines();
      if (response.success && response.data != null) {
        _cuisines = response.data!;
        print('OfferViewModel: Loaded ${_cuisines.length} cuisines');
        notifyListeners();
      }
    } catch (e) {
      print('OfferViewModel: Error loading cuisines: $e');
    }
  }

  Future<void> loadFoodItems() async {
    // The new menu API doesn't require restaurantId. We remove the null check and parameter.
    try {
      print('OfferViewModel: Loading food items...');
      final response = await _menuService.getAllFoodItems();
      if (response.success && response.data != null) {
        _foodItems = response.data!;
        print('OfferViewModel: Loaded ${_foodItems.length} food items');
        notifyListeners();
      }
    } catch (e) {
      print('OfferViewModel: Error loading food items: $e');
    }
  }

  Future<bool> createOffer(Offer offer, File? imageFile) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _offerService.createOffer(
        offer: offer,
        imageFile: imageFile,
      );

      if (response.success) {
        Fluttertoast.showToast(
          msg: 'Offer created successfully!',
          backgroundColor: Colors.green,
        );
        await loadOffers();
        return true;
      } else {
        Fluttertoast.showToast(
          msg: response.message ?? 'Failed to create offer',
          backgroundColor: Colors.red,
        );
        return false;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error: $e', backgroundColor: Colors.red);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateOffer(String id, Offer offer, File? imageFile) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _offerService.updateOffer(
        id: id,
        offer: offer,
        imageFile: imageFile,
      );

      if (response.success) {
        Fluttertoast.showToast(
          msg: 'Offer updated successfully!',
          backgroundColor: Colors.green,
        );
        await loadOffers();
        return true;
      } else {
        Fluttertoast.showToast(
          msg: response.message ?? 'Failed to update offer',
          backgroundColor: Colors.red,
        );
        return false;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error: $e', backgroundColor: Colors.red);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleOfferStatus(String id, bool isActive) async {
    _isLoading = true; // Set loading state for status toggle
    notifyListeners();

    try {
      final offer = _offers.firstWhere((o) => o.id == id);
      final updatedOffer = offer.copyWith(
        status: isActive ? 'ACTIVE' : 'INACTIVE',
      );

      return await updateOffer(id, updatedOffer, null);
    } catch (e) {
      print('OfferViewModel: Error toggling offer status: $e');
      Fluttertoast.showToast(msg: 'Error: $e', backgroundColor: Colors.red);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteOffer(String id) async {
    if (_restaurantId == null) {
      print('OfferViewModel: Cannot delete - Restaurant ID is null');
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _offerService.deleteOffer(
        id: id,
        restaurantId: _restaurantId!,
      );

      if (response.success) {
        Fluttertoast.showToast(
          msg: 'Offer deleted successfully!',
          backgroundColor: Colors.green,
        );
        await loadOffers();
        return true;
      } else {
        Fluttertoast.showToast(
          msg: response.message ?? 'Failed to delete offer',
          backgroundColor: Colors.red,
        );
        return false;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error: $e', backgroundColor: Colors.red);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Offer? getOfferById(String id) {
    try {
      return _offers.firstWhere((offer) => offer.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Offer> _createDummyOffers() {
    final now = DateTime.now();
    const dummyRestaurantId = 'dummy_restaurant_id';

    return [
      // 1. Weekend Special (Active)
      Offer(
        id: '1',
        restaurantId: dummyRestaurantId,
        title: 'Weekend Special',
        description: '20% OFF all menu items',
        discountType: 'PERCENTAGE',
        discountValue: 20.0,
        startDate: now.subtract(const Duration(days: 7)),
        endDate: now.add(const Duration(days: 7)),
        status: 'ACTIVE',
        approvalStatus: 'APPROVED',
        offerImage: 'assets/images/weekend_special.png',
      ),
      // 2. Happy Hour Deal (Pending Approval)
      Offer(
        id: '2',
        restaurantId: dummyRestaurantId,
        title: 'Happy Hour Deal',
        description: 'Buy 1 Get 1 Free on beverages',
        discountType: 'PERCENTAGE',
        discountValue: 50.0, // Placeholder for BOGO
        startDate: now.subtract(const Duration(days: 7)),
        endDate: now.add(const Duration(days: 7)),
        status: 'INACTIVE', // Toggle is off in the image
        approvalStatus: 'PENDING',
        offerImage: 'assets/images/happy_hour.png',
      ),
      // 3. Lunch Special (Active)
      Offer(
        id: '3',
        restaurantId: dummyRestaurantId,
        title: 'Lunch Special',
        description: 'Flat ₹100 Discount on orders above ₹500',
        discountType: 'FLAT',
        discountValue: 100.0,
        minOrderValue: 500.0,
        startDate: now.subtract(const Duration(days: 7)),
        endDate: now.add(const Duration(days: 14)),
        status: 'ACTIVE',
        approvalStatus: 'APPROVED',
        offerImage: 'assets/images/lunch_special.png',
      ),
      // 4. Student Discount (Expired)
      Offer(
        id: '4',
        restaurantId: dummyRestaurantId,
        title: 'Student Discount',
        description: '15% OFF with valid student ID',
        discountType: 'PERCENTAGE',
        discountValue: 15.0,
        startDate: now.subtract(const Duration(days: 30)),
        endDate: now.subtract(const Duration(days: 15)), // Expired
        status: 'INACTIVE', // Toggle is off in the image
        approvalStatus: 'APPROVED',
        offerImage: 'assets/images/student_discount.png',
      ),
      // 5. Family Package (Active)
      Offer(
        id: '5',
        restaurantId: dummyRestaurantId,
        title: 'Family Package',
        description: '30% OFF on family meals',
        discountType: 'PERCENTAGE',
        discountValue: 30.0,
        startDate: now.subtract(const Duration(days: 7)),
        endDate: now.add(const Duration(days: 30)),
        status: 'ACTIVE',
        approvalStatus: 'APPROVED',
        offerImage: 'assets/images/family_package.png',
      ),
    ];
  }

  @override
  void dispose() {
    super.dispose();
  }
}
