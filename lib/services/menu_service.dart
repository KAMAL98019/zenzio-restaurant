import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../models/api_response.dart';
import '../models/food_item.dart';
import '../models/category.dart';
import '../models/cuisine.dart';
import '../core/constant/api_constant.dart';
import 'api_service.dart';

class MenuService {
  final ApiService _apiService = ApiService();

  // Helper to construct full S3 URL from image key
  List<String> _processMenuImageKeys(List<dynamic>? imageKeys) {
    if (imageKeys == null) return [];
    return imageKeys.whereType<String>().map((key) {
      if (key.startsWith('http')) return key;
      return '${ApiConstants.s3MenuImageBaseUrl}$key';
    }).toList();
  }

  // Helper to ensure FoodItem JSON has full URLs before deserialization
  Map<String, dynamic> _preprocessFoodItemJson(Map<String, dynamic> json) {
    if (json.containsKey('images') && json['images'] is List) {
      json['images'] = _processMenuImageKeys(json['images'] as List?);
    }
    return json;
  }

  // Get all food items
  Future<ApiResponse<List<FoodItem>>> getAllFoodItems({
    String? cuisineId,
    String? categoryId,
  }) async {
    try {
      print('MenuService: Fetching all restaurant menus');

      final queryParameters = {
        if (cuisineId != null) 'cuisineId': cuisineId,
        if (categoryId != null) 'categoryId': categoryId,
      };

      final response = await _apiService.get<RestaurantMenusData>(
        ApiConstants.restaurantMenu, // New API endpoint: GET /restaurant-menu
        queryParameters: queryParameters,
        fromJson: (responseData) {
          print('MenuService: Processing response data for /restaurant-menu');
          // The data field in ApiResponse will contain a Map that represents RestaurantMenusData
          if (responseData is Map<String, dynamic>) {
            // Preprocess each menu item in the list
            if (responseData.containsKey('restaurant_menus') && responseData['restaurant_menus'] is List) {
              responseData['restaurant_menus'] = (responseData['restaurant_menus'] as List)
                  .map((item) => item is Map<String, dynamic> ? _preprocessFoodItemJson(item) : item)
                  .toList();
            }
            return RestaurantMenusData.fromJson(responseData);
          }
          throw Exception('Invalid data format for RestaurantMenusData');
        },
      );

      // The new endpoint returns the list nested under "data": {"restaurant_menus": [...]}.
      // The overall ApiResponse is now ApiResponse<RestaurantMenusData>, so we extract the list here.
      return ApiResponse.success(
        data: response.data?.restaurantMenus ?? [],
        message: response.message,
      );
    } catch (e) {
      print('MenuService: Error in getAllFoodItems: $e');
      return ApiResponse.error(error: e, message: 'Failed to load food items');
    }
  }

  // Get categories
  Future<ApiResponse<List<Category>>> getCategories() async {
    try {
      print('MenuService: Fetching categories');

      return await _apiService.get<List<Category>>(
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

          return dataList
              .map((json) {
                try {
                  return Category.fromJson(json);
                } catch (e) {
                  print('MenuService: Error parsing category: $e');
                  return null;
                }
              })
              .whereType<Category>()
              .toList();
        },
      );
    } catch (e) {
      print('MenuService: Error in getCategories: $e');
      return ApiResponse.error(error: e, message: 'Failed to load categories');
    }
  }

  // Get cuisines
  Future<ApiResponse<List<Cuisine>>> getCuisines() async {
    try {
      print('MenuService: Fetching cuisines');

      return await _apiService.get<List<Cuisine>>(
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

          return dataList
              .map((json) {
                try {
                  return Cuisine.fromJson(json);
                } catch (e) {
                  print('MenuService: Error parsing cuisine: $e');
                  return null;
                }
              })
              .whereType<Cuisine>()
              .toList();
        },
      );
    } catch (e) {
      print('MenuService: Error in getCuisines: $e');
      return ApiResponse.error(error: e, message: 'Failed to load cuisines');
    }
  }

  // Get single food item by UID (New API)
  // GET /restaurant-menu/{uid}
  Future<ApiResponse<FoodItem>> viewMenuByUid(String uid) async {
    try {
      print('MenuService: Fetching menu item by UID: $uid');

      final response = await _apiService.get<FoodItem>(
        '${ApiConstants.restaurantMenu}/$uid',
        fromJson: (data) {
          if (data is Map<String, dynamic> &&
              data.containsKey('restaurant_menu')) {
            return FoodItem.fromJson(_preprocessFoodItemJson(data['restaurant_menu']));
          }
          return FoodItem.fromJson(_preprocessFoodItemJson(data));
        },
      );
      return response;
    } catch (e) {
      print('MenuService: Error in viewMenuByUid: $e');
      return ApiResponse.error(error: e, message: 'Failed to load food item');
    }
  }

  // DEPRECATED: Old Get single food item by ID
  Future<ApiResponse<FoodItem>> getFoodItem(String id) async {
    try {
      return await _apiService.get<FoodItem>(
        ApiConstants.foodItem(id),
        fromJson: (data) {
          if (data is Map && data.containsKey('data')) {
            return FoodItem.fromJson(_preprocessFoodItemJson(data['data']));
          }
          return FoodItem.fromJson(_preprocessFoodItemJson(data));
        },
      );
    } catch (e) {
      print('MenuService: Error in getFoodItem: $e');
      return ApiResponse.error(error: e, message: 'Failed to load food item');
    }
  }

  // ----------------------------------------------------------------
  // DEPRECATED: Old method for creating food item with direct Dio for multipart
  // Use createMenuItem for JSON post, and uploadMenuItemImage for file upload
  // ----------------------------------------------------------------
  // Create food item
  Future<ApiResponse<FoodItem>> createFoodItem({
    required FoodItem foodItem,
    File? imageFile,
  }) async {
    // ... Existing implementation ... (Kept for compatibility, but marked as deprecated)
    try {
      print('MenuService: Creating food item: ${foodItem.dishname}');

      final dio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: ApiConstants.connectionTimeout,
          receiveTimeout: ApiConstants.receiveTimeout,
        ),
      );

      FormData formData = FormData.fromMap(
        foodItem.toJson(includeOldFields: true),
      );

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

      final response = await dio.post(ApiConstants.foodItems, data: formData);

      print('MenuService: Create response: ${response.data}');

      return ApiResponse.success(
        data: FoodItem.fromJson(response.data),
        message: 'Food item created successfully',
      );
    } catch (e) {
      print('MenuService: Error in createFoodItem: $e');
      return ApiResponse.error(error: e, message: 'Failed to create food item');
    }
  }

  // Add Dish (New API)
  // POST /restaurant-menu
  Future<ApiResponse<FoodItem>> addDish({
    required FoodItem foodItem,
    List<File>? imageFiles, // Updated to accept a list of files
  }) async {
    try {
      print('MenuService: Creating new dish: ${foodItem.menuName}');

      final Map<String, dynamic> itemData = foodItem.toJson(
        includeOldFields: false,
      );

      final response = await _apiService.post(
        ApiConstants.restaurantMenu,
        data: itemData,
        fromJson: (data) {
          // data is the extracted 'data' from the API response: { "restaurant_menu": { ... } }
          if (data is Map<String, dynamic> &&
              data.containsKey('restaurant_menu')) {
            return FoodItem.fromJson(data['restaurant_menu']);
          }
          return FoodItem.fromJson(data);
        },
      );

      // Handle image upload if files are provided
      if (imageFiles != null &&
          imageFiles.isNotEmpty &&
          response.success &&
          response.data?.menuUid != null) {
        final List<String> imageUrls = [];
        for (final imageFile in imageFiles) {
          final uploadResponse = await uploadMenuItemImage(
            uid: response.data!.menuUid!,
            filePath: imageFile.path,
          );
          debugPrint('✅ Upload Response: ${jsonEncode(uploadResponse.data)}');
          
          if (uploadResponse.success &&
              uploadResponse.data != null &&
              uploadResponse.data!.isNotEmpty) {
            // uploadMenuItemImage now returns List<String> (the URLs)
            imageUrls.addAll(uploadResponse.data!);
          }

          if (!uploadResponse.success) {
            // Log or handle the image upload failure without failing the dish creation
            print(
              'MenuService: Warning: Dish created, but image upload for ${imageFile.path} failed: ${uploadResponse.message}',
            );
            // Continue to next file, or break if one failure is enough
          }
        }

        // Recreate the ApiResponse with the updated FoodItem (including image URLs)
        if (imageUrls.isNotEmpty) {
          final updatedFoodItem = response.data!.copyWith(images: imageUrls);
          return ApiResponse.success(
            data: updatedFoodItem,
            message: response.message,
          );
        }
      }

      return response;
    } catch (e) {
      print('MenuService: Error in addDish: $e');
      return ApiResponse.error(error: e, message: 'Failed to create dish.');
    }
  }

  // Upload Menu Item Image (New API)
  // POST /restaurant-menu/upload-image/{uid}
  Future<ApiResponse<List<String>>> uploadMenuItemImage({
    required String uid,
    required String filePath,
  }) async {
    try {
      final originalFile = File(filePath);
      final originalFileSize = await originalFile.length();
      print('MenuService: Uploading image for menu item $uid. Original size: ${originalFileSize / 1024} KB');

      // 1. Define a temporary path for the compressed file
      final dir = await getTemporaryDirectory();
      final targetPath =
          '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

      // 2. Compress the image to a temporary file
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        originalFile.absolute.path,
        targetPath,
        minWidth: 1000,
        minHeight: 1000,
        quality: 88, // Compression quality to reduce file size (aim for < 1MB)
        format: CompressFormat.jpeg,
      );

      if (compressedFile == null) {
        throw Exception('Image compression failed for $filePath');
      }

      final compressedFileSize = await compressedFile.length();
      print(
          'MenuService: Compressed size: ${compressedFileSize / 1024} KB. Target path: ${compressedFile.path}');

      // The backend API expects 'files' as the field name for the image
      final response = await _apiService.uploadFile<List<String>>(
        ApiConstants.restaurantMenuUploadImage(uid),
        filePath: compressedFile.path, // Use the compressed file's path
        fieldName: 'files',
        fromJson: (responseData) {
          // The API returns a List of objects like [{status: success, message: ..., key: ..., url: ...}]
          List<dynamic> dataList;

          if (responseData is List) {
            dataList = responseData;
          } else if (responseData is Map && responseData.containsKey('data')) {
            dataList = responseData['data'] as List;
          } else {
            return [];
          }

          // We map the list of maps to a list of 'url' strings
          return dataList
              .map((e) => e is Map<String, dynamic> && e.containsKey('url') ? e['url'] as String : null)
              .whereType<String>()
              .toList();
        },
      );

      // Clean up the compressed temporary file
      await File(compressedFile.path).delete();

      return response;
    } catch (e) {
      print('MenuService: Error in uploadMenuItemImage: $e');
      return ApiResponse.error(
        error: e,
        message: 'Failed to upload menu item image.',
      );
    }
  }

  // Toggle Menu Item Active Status (New API)
  // PATCH /restaurant-menu/{id}/toggle
  Future<ApiResponse<dynamic>> toggleMenuItemStatus({
    required String id,
    required bool isActive,
  }) async {
    try {
      print(
        'MenuService: Toggling active status for menu item $id to $isActive',
      );

      final response = await _apiService.patch(
        ApiConstants.restaurantMenuToggle(id),
        data: {'isActive': isActive},
      );

      return response;
    } catch (e) {
      print('MenuService: Error in toggleMenuItemStatus: $e');
      return ApiResponse.error(
        error: e,
        message: 'Failed to toggle menu item status',
      );
    }
  }

  // Deactivate Menu Item (New API)
  // PATCH /restaurant-menu/{id}/deactivate
  Future<ApiResponse<dynamic>> deactivateMenuItem({required String id}) async {
    try {
      print('MenuService: Deactivating menu item $id');

      final response = await _apiService.patch(
        ApiConstants.restaurantMenuDeactivate(id),
      );

      return response;
    } catch (e) {
      print('MenuService: Error in deactivateMenuItem: $e');
      return ApiResponse.error(
        error: e,
        message: 'Failed to deactivate menu item',
      );
    }
  }

  // Activate Menu Item (New API)
  // PATCH /restaurant-menu/{id}/activate
  Future<ApiResponse<dynamic>> activateMenuItem({required String id}) async {
    try {
      print('MenuService: Activating menu item $id');

      final response = await _apiService.patch(
        ApiConstants.restaurantMenuActivate(id),
      );

      return response;
    } catch (e) {
      print('MenuService: Error in activateMenuItem: $e');
      return ApiResponse.error(
        error: e,
        message: 'Failed to activate menu item',
      );
    }
  }

  // Patch Menu (New API)
  // PATCH /restaurant-menu/{uid}
 Future<ApiResponse<FoodItem>> patchMenu({
  required String uid,
  required FoodItem foodItem,
}) async {
  try {
    print('MenuService: Patching menu item: $uid');

    final Map<String, dynamic> itemData = foodItem.toJson(
      includeOldFields: false,
    );

    final response = await _apiService.patch(
      '${ApiConstants.restaurantMenu}/$uid',
      data: itemData,
      fromJson: (data) {
        if (data is Map<String, dynamic> &&
            data.containsKey('restaurant_menu')) {
          final json = _preprocessFoodItemJson(data['restaurant_menu']);
          return FoodItem.fromJson(json);
        }

        final json = _preprocessFoodItemJson(data);
        return FoodItem.fromJson(json);
      },
    );

    return response;
  } catch (e) {
    print('MenuService: Error in patchMenu: $e');
    return ApiResponse.error(error: e, message: 'Failed to patch menu item');
  }
}

Future<ApiResponse<FoodItem>> updateMenu({
  required String uid,
  required FoodItem foodItem,
}) async {
  try {
    print('MenuService: Updating menu item: $uid');

    final Map<String, dynamic> itemData = foodItem.toJson(
      includeOldFields: false,
    );

    final response = await _apiService.put(
      '${ApiConstants.restaurantMenu}/$uid',
      data: itemData,
      fromJson: (data) {
        if (data is Map<String, dynamic> &&
            data.containsKey('restaurant_menu')) {
          final json = _preprocessFoodItemJson(data['restaurant_menu']);
          return FoodItem.fromJson(json);
        }

        final json = _preprocessFoodItemJson(data);
        return FoodItem.fromJson(json);
      },
    );

    return response;
  } catch (e) {
    print('MenuService: Error in updateMenu: $e');
    return ApiResponse.error(error: e, message: 'Failed to update menu item');
  }
}

  // DEPRECATED: Old Update food item (REMOVED - Use patchMenu or updateMenu instead)
  /*
  Future<ApiResponse<FoodItem>> updateFoodItem({
    required String id,
    required FoodItem foodItem,
    File? imageFile,
  }) async {
    // This method is deprecated and was causing 401 errors.
    // The code that relies on this method in the MenuViewModel has been updated
    // to use patchMenu. This method is commented out to prevent accidental usage.
    return ApiResponse.error(
      error: 'Deprecated API',
      message: 'This update method is deprecated. Use patchMenu or updateMenu.',
    );
  }
  */

  // Delete Menu (New API)
  // DELETE /restaurant-menu/{menuId}
  Future<ApiResponse<dynamic>> deleteMenu(String menuId) async {
    try {
      print('MenuService: Deleting menu item by ID: $menuId');

      return await _apiService.delete('${ApiConstants.restaurantMenu}/$menuId');
    } catch (e) {
      print('MenuService: Error in deleteMenu: $e');
      return ApiResponse.error(error: e, message: 'Failed to delete menu item');
    }
  }

  // Get category by ID
  Future<ApiResponse<Category>> getCategoryById(String id) async {
    try {
      return await _apiService.get<Category>(
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
      return ApiResponse.error(error: e, message: 'Failed to load category');
    }
  }

  // Get cuisine by ID
  Future<ApiResponse<Cuisine>> getCuisineById(String id) async {
    try {
      return await _apiService.get<Cuisine>(
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
      return ApiResponse.error(error: e, message: 'Failed to load cuisine');
    }
  }

  // Get Menu Enums (New API)
  // GET /restaurant_enum
  Future<ApiResponse<List<Category>>> getMenuEnums() async {
    try {
      print('MenuService: Fetching menu enums');

      return await _apiService.get<List<Category>>(
        ApiConstants.restaurantEnums, // New API endpoint
        fromJson: (responseData) {
          List<dynamic> dataList;

          if (responseData is Map && responseData.containsKey('data')) {
            dataList = responseData['data'] as List;
          } else if (responseData is List) {
            dataList = responseData;
          } else {
            print('MenuService: Unexpected menu enums response format');
            return <Category>[];
          }

          return dataList
              .map((json) {
                try {
                  return Category.fromJson(json);
                } catch (e) {
                  print('MenuService: Error parsing enum category: $e');
                  return null;
                }
              })
              .whereType<Category>()
              .toList();
        },
      );
    } catch (e) {
      print('MenuService: Error in getMenuEnums: $e');
      return ApiResponse.error(error: e, message: 'Failed to load menu enums');
    }
  }
}
