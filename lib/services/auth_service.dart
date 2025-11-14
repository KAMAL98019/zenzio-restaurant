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

      // ❌ DO NOT SEND application/json for multipart
      request.headers.addAll({
        'Accept': 'application/json',
        'platform': 'Android',
        'User-Agent': 'Android',
        'mode': 'development',
        'clientId': ApiConstants.clientId,
      });

      // ---------------------------
      //  BASIC TEXT FIELDS
      // ---------------------------
      request.fields['restaurant_name'] = restaurant.restaurantName;
      request.fields['avg_cost_two'] = restaurant.avgCostTwo.toString();
      request.fields['firstName'] = restaurant.firstName;
      request.fields['lastName'] = restaurant.lastName;
      request.fields['email'] = restaurant.email;
      request.fields['phoneNumber'] = restaurant.phoneNumber;
      request.fields['rest_contact_number'] = restaurant.restContactNumber;
      request.fields['rest_email'] = restaurant.restEmail;
      request.fields['agree_to_terms'] = restaurant.agreeToTerms.toString();
      request.fields['status'] = restaurant.status;

      // OPTIONAL FIELDS
      if (restaurant.restWebsite != null) {
        request.fields['rest_website'] = restaurant.restWebsite!;
      }
      if (restaurant.socialMedia != null) {
        request.fields['social_media'] = restaurant.socialMedia!;
      }

      // ---------------------------
      //   ADDRESS NESTED FIELDS
      // ---------------------------
      request.fields['address[address]'] = restaurant.address.address;
      request.fields['address[city]'] = restaurant.address.city;
      request.fields['address[state]'] = restaurant.address.state;
      request.fields['address[pincode]'] = restaurant.address.pincode;
      request.fields['address[land_mark]'] = restaurant.address.landMark ?? '';
      request.fields['address[lat]'] = restaurant.address.lat.toString();
      request.fields['address[lng]'] = restaurant.address.lng.toString();

      // ---------------------------
      //   ARRAY TYPE FIELDS
      // ---------------------------
      request.fields['cuisines'] = jsonEncode(
        restaurant.cuisines.map((e) => e.toJson()).toList(),
      );

      request.fields['categories'] = jsonEncode(
        restaurant.categories.map((e) => e.toJson()).toList(),
      );

      request.fields['operational_hours'] = jsonEncode(
        restaurant.operationalHours.map((e) => e.toJson()).toList(),
      );

      // ---------------------------
      //   DOCUMENTS (JSON STRING)
      // ---------------------------
      request.fields['documents'] = jsonEncode(restaurant.documents.toJson());

      // ---------------------------
      //   BANK DETAILS
      // ---------------------------
      request.fields['bankDetails'] = jsonEncode(
        restaurant.bankDetails.toJson(),
      );

      // ADDITIONAL FIELDS FROM VIEWMODEL
      additionalFields?.forEach((key, value) {
        request.fields[key] = value;
      });

      // ---------------------------
      //   FILE UPLOADS
      // ---------------------------
      print("Processing files for upload...");

      bool allFilesOk = true;

      // Restaurant Logo (Image)
      if (restaurant.restLogo.isNotEmpty) {
        try {
          await _addCompressedFileToRequest(
            request,
            'rest_logo',
            restaurant.restLogo,
            isImage: true,
          );
        } catch (e) {
          print('Logo upload failed: $e');
          allFilesOk = false;
        }
      }

      // FSSAI Certificate
      if (restaurant.documents.fssaiCertificateUrl.isNotEmpty) {
        try {
          await _addCompressedFileToRequest(
            request,
            'fssai_certificate',
            restaurant.documents.fssaiCertificateUrl,
            isImage: false,
          );
        } catch (e) {
          print('FSSAI upload failed: $e');
          allFilesOk = false;
        }
      }

      // GST Certificate
      if (restaurant.documents.gstCertificateUrl.isNotEmpty) {
        try {
          await _addCompressedFileToRequest(
            request,
            'gst_certificate',
            restaurant.documents.gstCertificateUrl,
            isImage: false,
          );
        } catch (e) {
          print('GST upload failed: $e');
          allFilesOk = false;
        }
      }

      if (!allFilesOk) {
        return ApiResponse(
          success: false,
          message:
              "Some files could not be processed. Please check file size (max 2MB).",
        );
      }

      // ---------------------------
      //   SEND REQUEST
      // ---------------------------
      print("Sending registration request...");
      var response = await request.send();
      var responseString = await response.stream.bytesToString();

      print("Register Status: ${response.statusCode}");
      print("Register Body: $responseString");

      if (response.statusCode == 200 || response.statusCode == 201) {
        var jsonResponse = jsonDecode(responseString);
        return ApiResponse(
          success: true,
          message: "Registration successful",
          data: jsonResponse["data"] ?? jsonResponse,
        );
      }

      // HANDLE ERROR RESPONSE
      try {
        var errorJson = jsonDecode(responseString);
        return ApiResponse(
          success: false,
          message: errorJson['message'] ?? "Registration failed",
        );
      } catch (_) {
        return ApiResponse(
          success: false,
          message: "HTTP ${response.statusCode}: $responseString",
        );
      }
    } catch (e) {
      print("Registration crash: $e");
      return ApiResponse(
        success: false,
        message: "Something went wrong. Check network and try again.",
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
    final response = await _apiService.post<Map<String, dynamic>>(
      ApiConstants.login,
      data: {'email': emailOrMobile.trim(), 'password': password},
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
      ApiConstants.verifyPhoneOtp,
      data: {'phone': mobileNumber.trim(), 'otp': otp.trim()},
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
