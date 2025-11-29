import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
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
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _restaurantIdKey = 'restaurant_id';

  // Maximum file sizes (in bytes)
  static const int _maxImageSize = 1 * 1024 * 1024; // 1MB for images
  static const int _maxDocumentSize = 2 * 1024 * 1024; // 2MB for documents

  // Register Restaurant with File Upload and Compression
  Future<ApiResponse<Map<String, dynamic>>> register(
    Restaurant restaurant,
  ) async {
    try {
      var uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.register}');

      final body = restaurant.toRegistrationJson();

      print("Sending Body: $body");

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'platform': 'Android',
          'User-Agent': 'Android',
          'mode': 'development',
          'clientId': ApiConstants.clientId,
        },
        body: jsonEncode(body),
      );

      print("Response Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse(
          success: true,
          message: "Registration successful",
          data: jsonDecode(response.body),
        );
      }else{
        return ApiResponse(
          success: false,
          message: 'Registration failed. Please try again.',
        );
      }

      // Parse the error response body
      // final Map<String, dynamic> errorData = json.decode(response.body);
      // String errorMessage = 'Registration failed. Please try again.';

      // return ApiResponse(success: false, message: errorMessage);
    } catch (e) {
      return ApiResponse(success: false, message: "Error: $e");
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
          print(
            'Original $fieldName file size: ${(originalSize / 1024 / 1024).toStringAsFixed(2)}MB',
          );

          File fileToUpload;

          if (isImage) {
            fileToUpload = await _compressImage(originalFile, fieldName);
          } else {
            fileToUpload = await _compressDocument(originalFile, fieldName);
          }

          final compressedSize = fileToUpload.lengthSync();
          print(
            'Compressed $fieldName file size: ${(compressedSize / 1024 / 1024).toStringAsFixed(2)}MB',
          );

          // Get file extension
          String extension = path.extension(filePath).toLowerCase();
          if (isImage &&
              !extension.contains('jpg') &&
              !extension.contains('jpeg')) {
            extension = '.jpg'; // Convert to jpg for compressed images
          }

          var multipartFile = await http.MultipartFile.fromPath(
            fieldName,
            fileToUpload.path,
            filename:
                '${fieldName}_${DateTime.now().millisecondsSinceEpoch}$extension',
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
        final moreCompressedBytes = img.encodeJpg(
          resizedImage,
          quality: quality,
        );

        // Create temporary file
        final tempFile = File(
          '${originalFile.parent.path}/compressed_${fieldName}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        await tempFile.writeAsBytes(moreCompressedBytes);

        print(
          'Image heavily compressed: ${(originalSize / 1024 / 1024).toStringAsFixed(2)}MB -> ${(tempFile.lengthSync() / 1024 / 1024).toStringAsFixed(2)}MB (quality: $quality%)',
        );
        return tempFile;
      }

      // Create temporary file
      final tempFile = File(
        '${originalFile.parent.path}/compressed_${fieldName}_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await tempFile.writeAsBytes(compressedBytes);

      print(
        'Image compressed: ${(originalSize / 1024 / 1024).toStringAsFixed(2)}MB -> ${(tempFile.lengthSync() / 1024 / 1024).toStringAsFixed(2)}MB (quality: $quality%)',
      );

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

      print(
        'Document $fieldName is too large: ${(originalSize / 1024 / 1024).toStringAsFixed(2)}MB',
      );

      // For documents, we return the original but the server might reject it
      // In a real app, you might want to implement PDF compression or other strategies
      throw Exception(
        'Document too large: ${(originalSize / 1024 / 1024).toStringAsFixed(2)}MB. Maximum allowed: ${_maxDocumentSize / 1024 / 1024}MB',
      );
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
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        ApiConstants.login,
        data: {'email': emailOrMobile.trim(), 'password': password},
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final data = response.data!;

        final accessToken = data['accessToken'];
        final refreshToken = data['refreshToken'];

        if (accessToken != null && refreshToken != null) {
          await saveTokens(accessToken, refreshToken);
        }

        final userId = data['user']?['id']?.toString();
        if (userId != null) {
          await saveRestaurantId(userId);
        }

        return ApiResponse<Map<String, dynamic>>(
          success: true,
          message: data['message'] ?? "Login successful",
          data: data,
        );
      } else {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: response.data?['message'] ?? "Invalid login credentials",
        );
      }
    } on DioException catch (e) {
      // Get error message from response or use default
      String message = 'Login failed. Please try again.';

      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: message,
      );
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'An unexpected error occurred.',
      );
    }
  }

  // OTP Login - Send OTP
  Future<ApiResponse<dynamic>> sendOtpLogin(String mobileNumber) async {
    return await _apiService.post(
      ApiConstants.sendPhoneOtp,
      data: {'phone': mobileNumber.trim()},
    );
  }

  // OTP Login - Verify OTP
  Future<ApiResponse<Map<String, dynamic>>> verifyOtpLogin({
    required String mobileNumber,
    required String otp,
  }) async {
    final response = await _apiService.post<Map<String, dynamic>>(
      ApiConstants.loginOtpVerify,
      data: {'phone': mobileNumber.trim(), 'otp': otp.trim()},
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.success && response.data != null) {
      final token = response.data!['token'];
      final restaurantId = response.data!['data']?['id'];

      if (token != null && token.isNotEmpty) {
        await saveAccessToken(token);
      }
      if (restaurantId != null && restaurantId.isNotEmpty) {
        await saveRestaurantId(restaurantId);
      }
    }
    return response;
  }

  // Restaurant Login - Verify OTP (New API for Access/Refresh Tokens)
  Future<ApiResponse<Map<String, dynamic>>> verifyOtp({
    required String mobileNumber,
    required String otp,
  }) async {
    final response = await _apiService.post<Map<String, dynamic>>(
      ApiConstants.loginOtpVerify,
      data: {'phone': mobileNumber.trim(), 'otp': otp.trim()},
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.success && response.data != null) {
      final data = response.data!;
      final accessToken = data['accessToken'];
      final refreshToken = data['refreshToken'];

      if (accessToken != null &&
          accessToken.isNotEmpty &&
          refreshToken != null &&
          refreshToken.isNotEmpty) {
        print('DEBUG - Verify OTP Access Token: $accessToken');
        print('DEBUG - Verify OTP Refresh Token: $refreshToken');
        await saveTokens(accessToken, refreshToken);
      }

      // Find restaurant ID in user object
      final restaurantId = data['user']?['id'];
      if (restaurantId != null && restaurantId.isNotEmpty) {
        await saveRestaurantId(restaurantId);
      }
    }
    return response;
  }

  // Registration - Send OTP
  Future<ApiResponse<dynamic>> sendRegistrationOtp(String mobileNumber) async {
    return await _apiService.post(
      ApiConstants.sendPhoneOtp,
      data: {'phone': mobileNumber.trim()},
    );
  }

  // Registration - Verify OTP
  Future<ApiResponse<dynamic>> verifyRegistrationOtp({
    required String mobileNumber,
    required String otp,
  }) async {
    return await _apiService.post(
      ApiConstants.verifyPhoneOtp,
      data: {'phone': mobileNumber.trim(), 'otp': otp.trim()},
    );
  }

  // Forgot Password - Send OTP
  Future<ApiResponse<dynamic>> sendForgotPasswordOtp(
    String emailOrMobile,
  ) async {
    return await _apiService.post(
      ApiConstants.sendForgotPasswordOtp,
      data: {'phone': emailOrMobile.trim()},
    );
  }

  // Verify OTP
  Future<ApiResponse<dynamic>> verifyForgotPasswordOtp({
    required String emailOrMobile,
    required String otp,
  }) async {
    return await _apiService.post(
      ApiConstants.verifyForgotPasswordOtp,
      data: {'phone': emailOrMobile.trim(), 'otp': otp.trim()},
    );
  }

  // Reset Password
  Future<ApiResponse<dynamic>> resetPassword({
    required String emailOrMobile,
    required String newPassword,
  }) async {
    return await _apiService.post(
      ApiConstants.resetPassword,
      data: {'emailOrMobile': emailOrMobile.trim(), 'newPassword': newPassword},
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
      data: {"rest_id": restaurantId, 'status': status},
    );
  }

  // Save access token
  Future<void> saveAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, token);
    _apiService.setAuthToken(token);
  }

  // Save both access and refresh tokens
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
    _apiService.setAuthToken(accessToken);
  }

  // Save restaurant ID
  Future<void> saveRestaurantId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_restaurantIdKey, id);
    print('AuthService: Saved restaurantId: $id'); // Debug print
  }

  // Get saved access token
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_accessTokenKey);
    if (token != null && token.isNotEmpty) {
      _apiService.setAuthToken(token);
    }
    return token;
  }

  // Get saved refresh token
  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
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
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_restaurantIdKey);
    _apiService.removeAuthToken();
  }
}
