import 'dart:io';
import 'package:dio/dio.dart';
import '../models/api_response.dart';
import '../models/food_item.dart';
import '../models/category.dart';
import '../models/cuisine.dart';
import '../core/constant/api_constant.dart';
import 'api_service.dart';

class MenuService {
  final ApiService _apiService = ApiService();

  // Get all food items
  Future<ApiResponse<List<FoodItem>>> getAllFoodItems({
    required String restaurantId,
    String? cuisineId,
    String? categoryId,
  }) async {
    try {
      print('MenuService: Fetching food items for restaurant: $restaurantId');
      
      final queryParameters = {
        'restaurantId': restaurantId,
        if (cuisineId != null) 'cuisineId': cuisineId,
        if (categoryId != null) 'categoryId': categoryId,
      };

      final response = await _apiService.get(
        ApiConstants.foodItems,
        queryParameters: queryParameters,
        fromJson: (responseData) {
          print('MenuService: Processing response data');
          
          // Handle the response structure: {"success": true, "data": [...]}
          List<dynamic> dataList;
          
          if (responseData is Map && responseData.containsKey('data')) {
            dataList = responseData['data'] as List;
            print('MenuService: Found ${dataList.length} items in response.data');
          } else if (responseData is List) {
            dataList = responseData;
            print('MenuService: Response is directly a list with ${dataList.length} items');
          } else {
            print('MenuService: Unexpected response format: ${responseData.runtimeType}');
            return <FoodItem>[];
          }

          final items = dataList.map((json) {
            try {
              final item = FoodItem.fromJson(json);
              print('MenuService: Parsed item: ${item.dishname}');
              return item;
            } catch (e) {
              print('MenuService: Error parsing food item: $e');
              print('MenuService: Problem JSON: $json');
              return null;
            }
          }).whereType<FoodItem>().toList();

          print('MenuService: Successfully parsed ${items.length} food items');
          return items;
        },
      );

      return response;
    } catch (e) {
      print('MenuService: Error in getAllFoodItems: $e');
      return ApiResponse.error(
        error: e,
        message: 'Failed to load food items',
      );
    }
  }

  // Get categories
  Future<ApiResponse<List<Category>>> getCategories() async {
    try {
      print('MenuService: Fetching categories');
      
      return await _apiService.get(
        ApiConstants.categories,
        fromJson: (responseData) {
          List<dynamic> dataList;
          
          if (responseData is Map && responseData.containsKey('data')) {
            dataList = responseData['data'] as List;
          } else if (responseData is List) {
            dataList = responseData;
          } else {
            print('MenuService: Unexpected categories response format');
            return <Category>[];
          }

          return dataList.map((json) {
            try {
              return Category.fromJson(json);
            } catch (e) {
              print('MenuService: Error parsing category: $e');
              return null;
            }
          }).whereType<Category>().toList();
        },
      );
    } catch (e) {
      print('MenuService: Error in getCategories: $e');
      return ApiResponse.error(
        error: e,
        message: 'Failed to load categories',
      );
    }
  }

  // Get cuisines
  Future<ApiResponse<List<Cuisine>>> getCuisines() async {
    try {
      print('MenuService: Fetching cuisines');
      
      return await _apiService.get(
        ApiConstants.cuisines,
        fromJson: (responseData) {
          List<dynamic> dataList;
          
          if (responseData is Map && responseData.containsKey('data')) {
            dataList = responseData['data'] as List;
          } else if (responseData is List) {
            dataList = responseData;
          } else {
            print('MenuService: Unexpected cuisines response format');
            return <Cuisine>[];
          }

          return dataList.map((json) {
            try {
              return Cuisine.fromJson(json);
            } catch (e) {
              print('MenuService: Error parsing cuisine: $e');
              return null;
            }
          }).whereType<Cuisine>().toList();
        },
      );
    } catch (e) {
      print('MenuService: Error in getCuisines: $e');
      return ApiResponse.error(
        error: e,
        message: 'Failed to load cuisines',
      );
    }
  }

  // Get single food item
  Future<ApiResponse<FoodItem>> getFoodItem(String id) async {
    try {
      return await _apiService.get(
        ApiConstants.foodItem(id),
        fromJson: (data) {
          if (data is Map && data.containsKey('data')) {
            return FoodItem.fromJson(data['data']);
          }
          return FoodItem.fromJson(data);
        },
      );
    } catch (e) {
      print('MenuService: Error in getFoodItem: $e');
      return ApiResponse.error(
        error: e,
        message: 'Failed to load food item',
      );
    }
  }

  // Create food item
  Future<ApiResponse<FoodItem>> createFoodItem({
    required FoodItem foodItem,
    File? imageFile,
  }) async {
    try {
      print('MenuService: Creating food item: ${foodItem.dishname}');
      
      final dio = Dio(BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectionTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
      ));

      FormData formData = FormData.fromMap(foodItem.toJson());

      if (imageFile != null) {
        formData.files.add(
          MapEntry(
            'dishimage',
            await MultipartFile.fromFile(
              imageFile.path,
              filename: imageFile.path.split('/').last,
            ),
          ),
        );
      }

      final response = await dio.post(
        ApiConstants.foodItems,
        data: formData,
      );

      print('MenuService: Create response: ${response.data}');

      return ApiResponse.success(
        data: FoodItem.fromJson(response.data),
        message: 'Food item created successfully',
      );
    } catch (e) {
      print('MenuService: Error in createFoodItem: $e');
      return ApiResponse.error(
        error: e,
        message: 'Failed to create food item',
      );
    }
  }

  // Update food item
  Future<ApiResponse<FoodItem>> updateFoodItem({
    required String id,
    required FoodItem foodItem,
    File? imageFile,
  }) async {
    try {
      print('MenuService: Updating food item: $id');
      
      final dio = Dio(BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectionTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
      ));

      FormData formData = FormData.fromMap(foodItem.toJson());

      if (imageFile != null) {
        formData.files.add(
          MapEntry(
            'dishimage',
            await MultipartFile.fromFile(
              imageFile.path,
              filename: imageFile.path.split('/').last,
            ),
          ),
        );
      }

      final response = await dio.put(
        ApiConstants.foodItem(id),
        data: formData,
      );

      print('MenuService: Update response: ${response.data}');

      return ApiResponse.success(
        data: FoodItem.fromJson(response.data),
        message: 'Food item updated successfully',
      );
    } catch (e) {
      print('MenuService: Error in updateFoodItem: $e');
      return ApiResponse.error(
        error: e,
        message: 'Failed to update food item',
      );
    }
  }

  // Delete food item
  Future<ApiResponse<dynamic>> deleteFoodItem(String id) async {
    try {
      print('MenuService: Deleting food item: $id');
      
      return await _apiService.delete(
        ApiConstants.foodItem(id),
      );
    } catch (e) {
      print('MenuService: Error in deleteFoodItem: $e');
      return ApiResponse.error(
        error: e,
        message: 'Failed to delete food item',
      );
    }
  }

  // Get category by ID
  Future<ApiResponse<Category>> getCategoryById(String id) async {
    try {
      return await _apiService.get(
        ApiConstants.categoryById(id),
        fromJson: (data) {
          if (data is Map && data.containsKey('data')) {
            return Category.fromJson(data['data']);
          }
          return Category.fromJson(data);
        },
      );
    } catch (e) {
      print('MenuService: Error in getCategoryById: $e');
      return ApiResponse.error(
        error: e,
        message: 'Failed to load category',
      );
    }
  }

  // Get cuisine by ID
  Future<ApiResponse<Cuisine>> getCuisineById(String id) async {
    try {
      return await _apiService.get(
        ApiConstants.cuisineById(id),
        fromJson: (data) {
          if (data is Map && data.containsKey('data')) {
            return Cuisine.fromJson(data['data']);
          }
          return Cuisine.fromJson(data);
        },
      );
    } catch (e) {
      print('MenuService: Error in getCuisineById: $e');
      return ApiResponse.error(
        error: e,
        message: 'Failed to load cuisine',
      );
    }
  }
}
