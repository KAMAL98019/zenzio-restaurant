import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;
import 'package:zenzio_restaurant/core/constant/api_constant.dart';
import '../models/api_response.dart';
import '../models/restaurant.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  static const String _tokenKey = 'auth_token';
  static const String _restaurantIdKey = 'restaurant_id';

  // Maximum file sizes (in bytes)
  static const int _maxImageSize = 1 * 1024 * 1024; // 1MB for images
  static const int _maxDocumentSize = 2 * 1024 * 1024; // 2MB for documents

  // Register Restaurant with File Upload and Compression
  Future<ApiResponse<Map<String, dynamic>>> register(
    Restaurant restaurant, {
    Map<String, String>? additionalFields,
  }) async {
    try {
      var uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.register}');
      var request = http.MultipartRequest('POST', uri);

      // Add text fields
      request.fields['id'] = restaurant.id;
      request.fields['rest_name'] = restaurant.restName;
      request.fields['rest_address'] = restaurant.restAddress;
      request.fields['avg_cost_two'] = restaurant.avgCostTwo.toString();
      request.fields['rest_logo'] = restaurant.restLogo;
      request.fields['contact_person_name'] = restaurant.contactPersonName;
      request.fields['contact_email'] = restaurant.contactEmail;
      request.fields['contact_number'] = restaurant.contactNumber;
      request.fields['operational_hours'] = jsonEncode(restaurant.operationalHours.map((e) => e.toJson()).toList());
      request.fields['fssai_certificate'] = restaurant.fssaiCertificate;
      request.fields['gst_certificate'] = restaurant.gstCertificate;
      request.fields['bank_account_name'] = restaurant.bankAccountName;
      request.fields['account_number'] = restaurant.accountNumber;
      request.fields['ifsc_code'] = restaurant.ifscCode;
      request.fields['agree_to_terms'] = restaurant.agreeToTerms.toString();
      request.fields['status'] = restaurant.status;
      request.fields['deliveryType'] = restaurant.deliveryType;
      request.fields['otpVerified'] = restaurant.otpVerified.toString();
      request.fields['createdAt'] = restaurant.createdAt;
      request.fields['updatedAt'] = restaurant.updatedAt;

      if (restaurant.deliveryRadius != null) {
        request.fields['deliveryRadius'] = restaurant.deliveryRadius.toString();
      }
      if (restaurant.deliveryZones != null) {
        request.fields['deliveryZones'] = restaurant.deliveryZones!;
      }
      if (restaurant.restaurantLatitude != null) {
        request.fields['restaurantLatitude'] = restaurant.restaurantLatitude.toString();
      }
      if (restaurant.restaurantLongitude != null) {
        request.fields['restaurantLongitude'] = restaurant.restaurantLongitude.toString();
      }
      if (restaurant.minOrderAmount != null) {
        request.fields['minOrderAmount'] = restaurant.minOrderAmount!;
      }
      if (restaurant.baseDeliveryFee != null) {
        request.fields['baseDeliveryFee'] = restaurant.baseDeliveryFee!;
      }
      if (restaurant.otp != null) {
        request.fields['otp'] = restaurant.otp!;
      }
      if (restaurant.otpExpiry != null) {
        request.fields['otpExpiry'] = restaurant.otpExpiry!;
      }

      // Add additional fields if provided
      if (additionalFields != null) {
        request.fields.addAll(additionalFields);
      }

      print('Starting file compression and upload...');

      // Add compressed files with error handling
      bool filesAdded = true;
      
      try {
        await _addCompressedFileToRequest(request, 'rest_logo', restaurant.restLogo, isImage: true);
      } catch (e) {
        print('Error adding restaurant logo: $e');
        filesAdded = false;
      }
      
      try {
        await _addCompressedFileToRequest(request, 'fssai_certificate', restaurant.fssaiCertificate, isImage: false);
      } catch (e) {
        print('Error adding FSSAI certificate: $e');
        filesAdded = false;
      }
      
      try {
        await _addCompressedFileToRequest(request, 'gst_certificate', restaurant.gstCertificate, isImage: false);
      } catch (e) {
        print('Error adding GST certificate: $e');
        filesAdded = false;
      }

      if (!filesAdded) {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: 'Error processing some files. Please check file sizes and formats.',
        );
      }

      print('Sending multipart request with compressed files...');
      print('Total fields: ${request.fields.length}');
      print('Total files: ${request.files.length}');
      
      var response = await request.send();
      var responseString = await response.stream.bytesToString();
      
      print('Response status: ${response.statusCode}');
      print('Response body: $responseString');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          var jsonResponse = jsonDecode(responseString);
          return ApiResponse<Map<String, dynamic>>(
            success: true,
            message: 'Registration successful',
            data: jsonResponse['data'] ?? jsonResponse,
          );
        } catch (e) {
          return ApiResponse<Map<String, dynamic>>(
            success: true,
            message: 'Registration successful',
            data: {}, // Return an empty map if data parsing fails but registration is successful
          );
        }
      } else if (response.statusCode == 413) {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: 'File sizes are too large. Please use smaller files (max 2MB for documents, 1MB for images).',
        );
      } else {
        var errorMessage = 'Registration failed';
        try {
          var errorJson = jsonDecode(responseString);
          errorMessage = errorJson['error'] ?? errorJson['message'] ?? errorMessage;
        } catch (e) {
          errorMessage = 'HTTP ${response.statusCode}: $responseString';
        }
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: errorMessage,
        );
      }
    } catch (e) {
      print('Registration error: $e');
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Network error: Please check your internet connection and try again.',
      );
    }
  }

  Future<void> _addCompressedFileToRequest(
    http.MultipartRequest request, 
    String fieldName, 
    String? filePath, {
    required bool isImage,
  }) async {
    if (filePath != null && filePath.isNotEmpty) {
      try {
        File originalFile = File(filePath);
        if (await originalFile.exists()) {
          final originalSize = originalFile.lengthSync();
          print('Original $fieldName file size: ${(originalSize / 1024 / 1024).toStringAsFixed(2)}MB');
          
          File fileToUpload;
          
          if (isImage) {
            fileToUpload = await _compressImage(originalFile, fieldName);
          } else {
            fileToUpload = await _compressDocument(originalFile, fieldName);
          }

          final compressedSize = fileToUpload.lengthSync();
          print('Compressed $fieldName file size: ${(compressedSize / 1024 / 1024).toStringAsFixed(2)}MB');

          // Get file extension
          String extension = path.extension(filePath).toLowerCase();
          if (isImage && !extension.contains('jpg') && !extension.contains('jpeg')) {
            extension = '.jpg'; // Convert to jpg for compressed images
          }

          var multipartFile = await http.MultipartFile.fromPath(
            fieldName,
            fileToUpload.path,
            filename: '${fieldName}_${DateTime.now().millisecondsSinceEpoch}$extension',
          );
          
          request.files.add(multipartFile);
          print('Successfully added compressed file: $fieldName');

        } else {
          print('File does not exist: $filePath');
          throw Exception('File not found: $filePath');
        }
      } catch (e) {
        print('Error processing file $fieldName: $e');
        rethrow;
      }
    } else {
      print('No file path provided for $fieldName');
      throw Exception('No file provided for $fieldName');
    }
  }

  Future<File> _compressImage(File originalFile, String fieldName) async {
    try {
      final originalSize = originalFile.lengthSync();
      
      // If image is already small enough, return original
      if (originalSize <= _maxImageSize) {
        print('$fieldName image is already within size limit');
        return originalFile;
      }

      print('Compressing $fieldName image...');
      
      // Read and decode image
      final imageBytes = await originalFile.readAsBytes();
      final image = img.decodeImage(imageBytes);
      
      if (image == null) {
        print('Failed to decode image: $fieldName');
        return originalFile;
      }

      // Calculate target dimensions to reduce file size
      double scaleFactor = 1.0;
      if (originalSize > _maxImageSize) {
        scaleFactor = sqrt(_maxImageSize / originalSize).clamp(0.3, 0.8);
      }

      int newWidth = (image.width * scaleFactor).toInt().clamp(800, 1200);
      int newHeight = (image.height * scaleFactor).toInt().clamp(600, 800);

      // Resize image
      img.Image resizedImage = img.copyResize(
        image, 
        width: newWidth, 
        height: newHeight,
        interpolation: img.Interpolation.linear,
      );

      // Calculate quality (70% to 30% based on compression needed)
      int quality = (70 * scaleFactor).toInt().clamp(30, 70);

      // Compress image
      final compressedBytes = img.encodeJpg(resizedImage, quality: quality);
      
      if (compressedBytes.length > _maxImageSize * 1.2) {
        // If still too large, reduce quality further
        quality = (quality * 0.7).toInt().clamp(20, 50);
        final moreCompressedBytes = img.encodeJpg(resizedImage, quality: quality);
        
        // Create temporary file
        final tempFile = File('${originalFile.parent.path}/compressed_${fieldName}_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await tempFile.writeAsBytes(moreCompressedBytes);
        
        print('Image heavily compressed: ${(originalSize / 1024 / 1024).toStringAsFixed(2)}MB -> ${(tempFile.lengthSync() / 1024 / 1024).toStringAsFixed(2)}MB (quality: $quality%)');
        return tempFile;
      }
      
      // Create temporary file
      final tempFile = File('${originalFile.parent.path}/compressed_${fieldName}_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tempFile.writeAsBytes(compressedBytes);

      print('Image compressed: ${(originalSize / 1024 / 1024).toStringAsFixed(2)}MB -> ${(tempFile.lengthSync() / 1024 / 1024).toStringAsFixed(2)}MB (quality: $quality%)');
      
      return tempFile;
    } catch (e) {
      print('Image compression failed for $fieldName: $e');
      return originalFile;
    }
  }

  Future<File> _compressDocument(File originalFile, String fieldName) async {
    try {
      final originalSize = originalFile.lengthSync();
      
      // If document is already small enough, return original
      if (originalSize <= _maxDocumentSize) {
        print('$fieldName document is already within size limit');
        return originalFile;
      }

      print('Document $fieldName is too large: ${(originalSize / 1024 / 1024).toStringAsFixed(2)}MB');
      
      // For documents, we return the original but the server might reject it
      // In a real app, you might want to implement PDF compression or other strategies
      throw Exception('Document too large: ${(originalSize / 1024 / 1024).toStringAsFixed(2)}MB. Maximum allowed: ${_maxDocumentSize / 1024 / 1024}MB');
      
    } catch (e) {
      print('Document handling failed for $fieldName: $e');
      rethrow;
    }
  }

  // Login
  Future<ApiResponse<Map<String, dynamic>>> login({
    required String emailOrMobile,
    required String password,
  }) async {
    final response = await _apiService.post<Map<String, dynamic>>(
      ApiConstants.login,
      data: {
        'emailOrMobile': emailOrMobile.trim(),
        'password': password,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.success && response.data != null) {
      final token = response.data!['token'];
      final restaurantId = response.data!['data']?['id'];

      if (token != null && token.isNotEmpty) {
        await saveAuthToken(token);
      }
      if (restaurantId != null && restaurantId.isNotEmpty) {
        await saveRestaurantId(restaurantId);
      }
    }
    return response;
  }

  // Forgot Password - Send OTP
  Future<ApiResponse<dynamic>> sendOtp(String emailOrMobile) async {
    return await _apiService.post(
      ApiConstants.sendOtp,
      data: {'emailOrMobile': emailOrMobile.trim()},
    );
  }

  // Verify OTP
  Future<ApiResponse<dynamic>> verifyOtp({
    required String emailOrMobile,
    required String otp,
  }) async {
    return await _apiService.post(
      ApiConstants.verifyOtp,
      data: {
        'emailOrMobile': emailOrMobile.trim(),
        'otp': otp.trim(),
      },
    );
  }

  // Reset Password
  Future<ApiResponse<dynamic>> resetPassword({
    required String emailOrMobile,
    required String newPassword,
  }) async {
    return await _apiService.post(
      ApiConstants.resetPassword,
      data: {
        'emailOrMobile': emailOrMobile.trim(),
        'newPassword': newPassword,
      },
    );
  }

  // Update restaurant online/offline status
  Future<ApiResponse<dynamic>> updateRestaurantStatus({
    required String restaurantId,
    required bool isOnline,
  }) async {
    final status = isOnline ? "ONLINE" : "OFFLINE";
    return await _apiService.post(
      ApiConstants.restaurantStatus(),
      data: {  "rest_id": restaurantId, 'status': status},
    );
  }

  // Save token
  Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    _apiService.setAuthToken(token);
  }

  // Save restaurant ID
  Future<void> saveRestaurantId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_restaurantIdKey, id);
    print('AuthService: Saved restaurantId: $id'); // Debug print
  }

  // Get saved token
  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token != null && token.isNotEmpty) {
      _apiService.setAuthToken(token);
    }
    return token;
  }

  // Get restaurant ID
  Future<String?> getRestaurantId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_restaurantIdKey);
    print('AuthService: Retrieved restaurantId: $id'); // Debug print
    return id;
  }

  // Check login state
  Future<bool> isLoggedIn() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_restaurantIdKey);
    _apiService.removeAuthToken();
  }
}