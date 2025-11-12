import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../models/restaurant.dart';
import '../models/operational_hours.dart';
import '../services/auth_service.dart';
import '../services/restaurant_service.dart';
import '../main.dart';
import '../views/login/login_screen.dart';

class RegistrationViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final RestaurantService _restaurantService = RestaurantService();

  // Mode: 'registration' or 'edit'
  String mode = 'registration';

  late Restaurant? restaurant;
  int _currentStep = 0;
  bool _isLoading = false;
  bool _isUpdating = false;
  bool _agreeToTerms = false;

  static const int _maxImageSize = 1 * 1024 * 1024; // 1MB
  static const int _maxDocumentSize = 2 * 1024 * 1024; // 2MB

  // Step 1: Restaurant Details
  final TextEditingController restaurantNameController =
      TextEditingController();
  final TextEditingController restaurantAddressController =
      TextEditingController();
  final TextEditingController avgCostController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String? restaurantLogoPath;
  String? bannerImagePath;
  LatLng? restaurantLocation;

  // Step 2: Contact Details
  final TextEditingController contactPersonController = TextEditingController();
  final TextEditingController contactEmailController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  List<OperationalHours> operationalHours = OperationalHours.getDefaultHours();
  List<String> selectedCuisines = [];

  // Step 3: Documents & Bank Details
  String? fssaiCertificatePath;
  String? gstCertificatePath;
  final TextEditingController bankAccountNameController =
      TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController ifscCodeController = TextEditingController();

  // Getters
  int get currentStep => _currentStep;
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  bool get agreeToTerms => _agreeToTerms;
  int get totalSteps => 3;

  /// Initialize for editing existing restaurant
  Future<void> initializeForEdit(String restaurantId) async {
    mode = 'edit';
    _setLoading(true);
    try {
      final response = await _restaurantService.getRestaurantById(restaurantId);
      if (response.success && response.data != null) {
        restaurant = response.data;
        _populateControllers();
        notifyListeners();
      } else {
        _showToast(response.message ?? 'Failed to load restaurant data');
      }
    } catch (e) {
      _showToast('Error loading restaurant: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  void _populateControllers() {
    if (restaurant == null) return;
    restaurantNameController.text = restaurant!.restName;
    restaurantAddressController.text = restaurant!.restAddress;
    avgCostController.text = restaurant!.avgCostTwo;
    contactPersonController.text = restaurant!.contactPersonName;
    contactEmailController.text = restaurant!.contactEmail;
    contactNumberController.text = restaurant!.contactNumber;
    bankAccountNameController.text = restaurant!.bankAccountName;
    accountNumberController.text = restaurant!.accountNumber;
    ifscCodeController.text = restaurant!.ifscCode;
    operationalHours = restaurant!.operationalHours;
  }

  void setRestaurantLogo(String path) {
    if (!_validateFileSize(path, 'Restaurant Logo', _maxImageSize)) {
      return;
    }
    restaurantLogoPath = path;
    print('Restaurant Logo set: $restaurantLogoPath');
    notifyListeners();
  }

  void setBannerImage(String path) {
    if (!_validateFileSize(path, 'Banner Image', _maxImageSize)) {
      return;
    }
    bannerImagePath = path;
    print('Banner Image set: $bannerImagePath');
    notifyListeners();
  }

  void setFssaiCertificate(String path) {
    if (!_validateFileSize(path, 'FSSAI Certificate', _maxDocumentSize)) {
      return;
    }
    fssaiCertificatePath = path;
    print('FSSAI Certificate set: $fssaiCertificatePath');
    notifyListeners();
  }

  void setGstCertificate(String path) {
    if (!_validateFileSize(path, 'GST Certificate', _maxDocumentSize)) {
      return;
    }
    gstCertificatePath = path;
    print('GST Certificate set: $gstCertificatePath');
    notifyListeners();
  }

  void setRestaurantLocation(LatLng location) {
    restaurantLocation = location;
    notifyListeners();
  }

  void addCuisine(String cuisine) {
    if (!selectedCuisines.contains(cuisine)) {
      selectedCuisines.add(cuisine);
      notifyListeners();
    }
  }

  void removeCuisine(String cuisine) {
    selectedCuisines.remove(cuisine);
    notifyListeners();
  }

  void updateOperationalHours(int index, OperationalHours hours) {
    if (index >= 0 && index < operationalHours.length) {
      operationalHours[index] = hours;
      notifyListeners();
    }
  }

  void toggleOperationalHoursEnabled(int index, bool enabled) {
    if (index >= 0 && index < operationalHours.length) {
      final hours = operationalHours[index];
      operationalHours[index] = OperationalHours(
        day: hours.day,
        enabled: enabled,
        from: hours.from,
        to: hours.to,
      );
      notifyListeners();
    }
  }

  bool _validateFileSize(String filePath, String fileName, int maxSize) {
    try {
      File file = File(filePath);
      if (file.existsSync()) {
        int fileSize = file.lengthSync();
        double fileSizeMB = fileSize / 1024 / 1024;
        double maxSizeMB = maxSize / 1024 / 1024;

        if (fileSize > maxSize) {
          _showToast(
            '$fileName is too large (${fileSizeMB.toStringAsFixed(2)}MB). Maximum: ${maxSizeMB.toStringAsFixed(1)}MB.',
          );
          return false;
        }
        return true;
      }
    } catch (e) {
      print('Error validating file size: $e');
    }
    return true;
  }

  bool validateStep1() {
    if (restaurantNameController.text.trim().isEmpty) {
      _showToast('Please enter restaurant name');
      return false;
    }
    if (restaurantAddressController.text.trim().isEmpty) {
      _showToast('Please enter restaurant address');
      return false;
    }
    if (avgCostController.text.trim().isEmpty) {
      _showToast('Please enter average cost for two');
      return false;
    }
    if (int.tryParse(avgCostController.text.trim()) == null) {
      _showToast('Please enter a valid number for average cost');
      return false;
    }
    return true;
  }

  bool validateStep2() {
    if (contactPersonController.text.trim().isEmpty) {
      _showToast('Please enter contact person name');
      return false;
    }
    if (contactEmailController.text.trim().isEmpty ||
        !RegExp(
          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
        ).hasMatch(contactEmailController.text.trim())) {
      _showToast('Please enter a valid email address');
      return false;
    }
    if (contactNumberController.text.trim().length < 10) {
      _showToast('Please enter valid contact number (10 digits)');
      return false;
    }
    if (mode == 'registration' && passwordController.text.length < 6) {
      _showToast('Password must be at least 6 characters');
      return false;
    }
    return true;
  }

  bool validateStep3() {
    if (bankAccountNameController.text.trim().isEmpty) {
      _showToast('Please enter bank account name');
      return false;
    }
    if (accountNumberController.text.trim().isEmpty) {
      _showToast('Please enter account number');
      return false;
    }
    if (ifscCodeController.text.trim().isEmpty) {
      _showToast('Please enter IFSC code');
      return false;
    }
    if (mode == 'registration') {
      if (fssaiCertificatePath == null || fssaiCertificatePath!.isEmpty) {
        _showToast('Please upload FSSAI Certificate');
        return false;
      }
      if (gstCertificatePath == null || gstCertificatePath!.isEmpty) {
        _showToast('Please upload GST Certificate');
        return false;
      }
      if (!_agreeToTerms) {
        _showToast('Please agree to terms and conditions');
        return false;
      }
    }
    return true;
  }

  void nextStep() {
    bool isValid = false;

    switch (_currentStep) {
      case 0:
        isValid = validateStep1();
        break;
      case 1:
        isValid = validateStep2();
        break;
      case 2:
        isValid = validateStep3();
        break;
    }

    if (isValid && _currentStep < totalSteps - 1) {
      _currentStep++;
      notifyListeners();
    } else if (isValid && _currentStep == totalSteps - 1) {
      mode == 'registration' ? submitRegistration() : updateRestaurantProfile();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  Future<void> updateRestaurantProfile() async {
    if (!validateStep3()) return;

    _setUpdating(true);
    try {
      final updatedRestaurant = Restaurant(
        id: restaurant!.id,
        restName: restaurantNameController.text.trim(),
        restAddress: restaurantAddressController.text.trim(),
        avgCostTwo: avgCostController.text.trim(),
        restLogo: restaurantLogoPath ?? restaurant!.restLogo,
        contactPersonName: contactPersonController.text.trim(),
        contactEmail: contactEmailController.text.trim(),
        contactNumber: contactNumberController.text.trim(),
        operationalHours: operationalHours,
        fssaiCertificate: restaurant!.fssaiCertificate,
        gstCertificate: restaurant!.gstCertificate,
        bankAccountName: bankAccountNameController.text.trim(),
        accountNumber: accountNumberController.text.trim(),
        ifscCode: ifscCodeController.text.trim(),
        agreeToTerms: restaurant!.agreeToTerms,
        status: restaurant!.status,
        deliveryType: restaurant!.deliveryType,
        deliveryRadius: restaurant!.deliveryRadius,
        deliveryZones: restaurant!.deliveryZones,
        restaurantLatitude: restaurant!.restaurantLatitude,
        restaurantLongitude: restaurant!.restaurantLongitude,
        minOrderAmount: restaurant!.minOrderAmount,
        baseDeliveryFee: restaurant!.baseDeliveryFee,
        otp: restaurant!.otp,
        otpExpiry: restaurant!.otpExpiry,
        otpVerified: restaurant!.otpVerified,
        createdAt: restaurant!.createdAt,
        updatedAt: DateTime.now().toIso8601String(),
      );

      final response = await _restaurantService.updateRestaurant(
        restaurant!.id,
        updatedRestaurant,
      );

      if (response.success) {
        restaurant = updatedRestaurant;
        _showToast('Profile updated successfully!', isError: false);
        notifyListeners();
      } else {
        _showToast(response.message ?? 'Failed to update profile');
      }
    } catch (e) {
      _showToast('Error updating profile: ${e.toString()}');
    } finally {
      _setUpdating(false);
    }
  }

  Future<bool> submitRegistration() async {
    if (!validateStep3()) return false;

    if (!await _validateAllFiles()) {
      return false;
    }

    _setLoading(true);

    try {
      final restaurant = Restaurant(
        id: '',
        restName: restaurantNameController.text.trim(),
        restAddress: restaurantAddressController.text.trim(),
        avgCostTwo: avgCostController.text.trim(),
        restLogo: restaurantLogoPath ?? '',
        contactPersonName: contactPersonController.text.trim(),
        contactEmail: contactEmailController.text.trim(),
        contactNumber: contactNumberController.text.trim(),
        operationalHours: operationalHours,
        fssaiCertificate: fssaiCertificatePath ?? '',
        gstCertificate: gstCertificatePath ?? '',
        bankAccountName: bankAccountNameController.text.trim(),
        accountNumber: accountNumberController.text.trim(),
        ifscCode: ifscCodeController.text.trim(),
        agreeToTerms: _agreeToTerms,
        status: 'pending',
        deliveryType: 'RADIUS',
        otpVerified: false,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      final Map<String, String> additionalFields = {
        'password': passwordController.text.trim(),
      };
      if (restaurantLocation != null) {
        additionalFields['latitude'] = restaurantLocation!.latitude.toString();
        additionalFields['longitude'] = restaurantLocation!.longitude
            .toString();
      }

      final response = await _authService.register(
        restaurant,
        additionalFields: additionalFields,
      );
      
      if (response.success) {
        _showToast('Registration successful!', isError: false);
        if (response.data != null && response.data!['id'] != null) {
          final restaurantId = response.data!['id'] as String;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('restaurant_id', restaurantId);
          print('Restaurant ID stored: $restaurantId');
        }
        Navigator.pushAndRemoveUntil(
          navigatorKey.currentContext!,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
        return true;
      } else {
        _showToast(
          response.message ?? 'Registration failed. Please check all fields.',
        );
        return false;
      }
    } catch (e) {
      _showToast('Error: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> _validateAllFiles() async {
    bool allFilesValid = true;

    if (fssaiCertificatePath == null || fssaiCertificatePath!.isEmpty) {
      _showToast('Please upload FSSAI Certificate');
      allFilesValid = false;
    } else {
      File fssaiFile = File(fssaiCertificatePath!);
      if (!await fssaiFile.exists()) {
        _showToast('FSSAI Certificate file not found. Please upload again.');
        allFilesValid = false;
      } else if (await fssaiFile.length() > _maxDocumentSize) {
        _showToast(
          'FSSAI Certificate is too large. Please choose a file smaller than 2MB.',
        );
        allFilesValid = false;
      }
    }

    if (gstCertificatePath == null || gstCertificatePath!.isEmpty) {
      _showToast('Please upload GST Certificate');
      allFilesValid = false;
    } else {
      File gstFile = File(gstCertificatePath!);
      if (!await gstFile.exists()) {
        _showToast('GST Certificate file not found. Please upload again.');
        allFilesValid = false;
      } else if (await gstFile.length() > _maxDocumentSize) {
        _showToast(
          'GST Certificate is too large. Please choose a file smaller than 2MB.',
        );
        allFilesValid = false;
      }
    }

    if (restaurantLogoPath != null && restaurantLogoPath!.isNotEmpty) {
      File logoFile = File(restaurantLogoPath!);
      if (!await logoFile.exists()) {
        _showToast('Restaurant logo file not found. Please upload again.');
        allFilesValid = false;
      } else if (await logoFile.length() > _maxImageSize) {
        _showToast(
          'Restaurant logo is too large. Please choose a file smaller than 1MB.',
        );
        allFilesValid = false;
      }
    }

    return allFilesValid;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setUpdating(bool value) {
    _isUpdating = value;
    notifyListeners();
  }

  void _showToast(String message, {bool isError = true}) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: isError ? Colors.red : Colors.green,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void toggleTermsAgreement(bool value) {
    _agreeToTerms = value;
    notifyListeners();
  }

  @override
  void dispose() {
    restaurantNameController.dispose();
    restaurantAddressController.dispose();
    avgCostController.dispose();
    contactPersonController.dispose();
    contactEmailController.dispose();
    contactNumberController.dispose();
    passwordController.dispose();
    bankAccountNameController.dispose();
    accountNumberController.dispose();
    ifscCodeController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
