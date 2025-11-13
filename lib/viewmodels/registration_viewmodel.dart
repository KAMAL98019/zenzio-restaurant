import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:convert';
import '../models/restaurant.dart';
import '../models/operational_hours.dart';
import '../models/documents.dart';
import '../models/bank_details.dart';
import '../models/address.dart'; // Added import for Address
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
  bool _isOtpSent = false;
  bool _isOtpVerified = false;
  bool _isSendingOtp = false;
  bool _isVerifyingOtp = false;

  static const int _maxImageSize = 1 * 1024 * 1024; // 1MB
  static const int _maxDocumentSize = 2 * 1024 * 1024; // 2MB

  // Step 1: Restaurant Details
  final TextEditingController restaurantNameController =
      TextEditingController();
  final TextEditingController restaurantAddressController =
      TextEditingController();
  final TextEditingController landmarkController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController avgCostController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String? restaurantLogoPath;
  String? bannerImagePath;
  LatLng? restaurantLocation;

  // Step 2: Contact Details
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController restContactNumberController = TextEditingController();
  final TextEditingController restEmailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  List<OperationalHours> operationalHours = OperationalHours.getDefaultHours();
  List<String> selectedCuisines = [];
  List<String> selectedCategories = [];

  // Step 3: Documents & Bank Details
  String? fssaiCertificatePath;
  String? gstCertificatePath;
  final TextEditingController bankAccountNameController =
      TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController ifscCodeController = TextEditingController();
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController accountTypeController = TextEditingController();
  final TextEditingController fssaiNumberController = TextEditingController();
  final TextEditingController gstNumberController = TextEditingController();
  final TextEditingController tradeLicenseNumberController = TextEditingController();
  final TextEditingController otherDocumentTypeController = TextEditingController();
  String? tradeLicensePath;
  String? otherDocumentPath;

  // Getters
  int get currentStep => _currentStep;
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  bool get agreeToTerms => _agreeToTerms;
  bool get isOtpSent => _isOtpSent;
  bool get isOtpVerified => _isOtpVerified;
  bool get isSendingOtp => _isSendingOtp;
  bool get isVerifyingOtp => _isVerifyingOtp;
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
    restaurantNameController.text = restaurant!.restaurantName;
    restaurantAddressController.text = restaurant!.address.address;
    landmarkController.text = restaurant!.address.landMark ?? '';
    cityController.text = restaurant!.address.city;
    stateController.text = restaurant!.address.state;
    pincodeController.text = restaurant!.address.pincode;
    avgCostController.text = restaurant!.avgCostTwo;
    firstNameController.text = restaurant!.firstName;
    lastNameController.text = restaurant!.lastName;
    emailController.text = restaurant!.email;
    phoneNumberController.text = restaurant!.phoneNumber;
    restContactNumberController.text = restaurant!.restContactNumber;
    restEmailController.text = restaurant!.restEmail;
    bankAccountNameController.text = restaurant!.bankDetails.bankAccountName;
    accountNumberController.text = restaurant!.bankDetails.accountNumber;
    ifscCodeController.text = restaurant!.bankDetails.ifscCode;
    operationalHours = restaurant!.operationalHours;
    selectedCuisines = restaurant!.cuisines.map((e) => e.id).toList();
    selectedCategories = restaurant!.categories.map((e) => e.id).toList();
    restaurantLocation = LatLng(restaurant!.address.lat, restaurant!.address.lng);
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
    if (restaurantNameController.text.trim().length < 3 ||
        restaurantNameController.text.trim().length > 100) {
      _showToast('Restaurant name must be between 3 and 100 characters');
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
    if (firstNameController.text.trim().isEmpty) {
      _showToast('Please enter contact person first name');
      return false;
    }
    if (lastNameController.text.trim().isEmpty) {
      _showToast('Please enter contact person last name');
      return false;
    }
    if (emailController.text.trim().isEmpty ||
        !RegExp(
          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
        ).hasMatch(emailController.text.trim())) {
      _showToast('Please enter a valid contact person email address');
      return false;
    }
    if (phoneNumberController.text.trim().length != 10) {
      _showToast('Please enter valid contact person mobile number (10 digits)');
      return false;
    }
    if (mode == 'registration' && !_isOtpVerified) {
      _showToast('Please verify your contact person mobile number with OTP');
      return false;
    }
    if (restContactNumberController.text.trim().length != 10) {
      _showToast('Please enter valid restaurant contact number (10 digits)');
      return false;
    }
    if (restEmailController.text.trim().isEmpty ||
        !RegExp(
          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
        ).hasMatch(restEmailController.text.trim())) {
      _showToast('Please enter a valid restaurant email address');
      return false;
    }
    if (mode == 'registration' &&
        (passwordController.text.length < 8 ||
            passwordController.text.length > 20)) {
      _showToast('Password must be between 8 and 20 characters');
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
        restaurantName: restaurantNameController.text.trim(),
        avgCostTwo: avgCostController.text.trim(),
        restLogo: restaurantLogoPath ?? restaurant!.restLogo,
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        email: emailController.text.trim(),
        phoneNumber: phoneNumberController.text.trim(),
        restContactNumber: restContactNumberController.text.trim(),
        restEmail: restEmailController.text.trim(),
        cuisines: restaurant!.cuisines,
        categories: restaurant!.categories,
        operationalHours: operationalHours,
        documents: restaurant!.documents,
        bankDetails: restaurant!.bankDetails.copyWith(
          bankAccountName: bankAccountNameController.text.trim(),
          accountNumber: accountNumberController.text.trim(),
          ifscCode: ifscCodeController.text.trim(),
        ),
        agreeToTerms: restaurant!.agreeToTerms,
        status: restaurant!.status,
        deliveryType: restaurant!.deliveryType,
        deliveryRadius: restaurant!.deliveryRadius,
        deliveryZones: restaurant!.deliveryZones,
        minOrderAmount: restaurant!.minOrderAmount,
        baseDeliveryFee: restaurant!.baseDeliveryFee,
        otp: restaurant!.otp,
        otpExpiry: restaurant!.otpExpiry,
        otpVerified: restaurant!.otpVerified,
        createdAt: restaurant!.createdAt,
        updatedAt: DateTime.now().toIso8601String(),
        address: restaurant!.address.copyWith(
          address: restaurantAddressController.text.trim(),
          landMark: landmarkController.text.trim(),
          city: cityController.text.trim(),
          state: stateController.text.trim(),
          pincode: pincodeController.text.trim(),
          lat: restaurantLocation?.latitude ?? 0.0,
          lng: restaurantLocation?.longitude ?? 0.0,
        ),
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
        restaurantName: restaurantNameController.text.trim(),
        avgCostTwo: avgCostController.text.trim(),
        restLogo: restaurantLogoPath ?? '',
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        email: emailController.text.trim(),
        phoneNumber: phoneNumberController.text.trim(),
        restContactNumber: restContactNumberController.text.trim(),
        restEmail: restEmailController.text.trim(),
        cuisines: [], // Will be populated later
        categories: [], // Will be populated later
        operationalHours: operationalHours,
        documents: Documents(
          fssaiNumber: fssaiNumberController.text.trim(),
          fssaiCertificateUrl: fssaiCertificatePath ?? '',
          gstNumber: gstNumberController.text.trim(),
          gstCertificateUrl: gstCertificatePath ?? '',
          tradeLicenseNumber: tradeLicenseNumberController.text.trim(),
          tradeLicenseUrl: tradeLicensePath ?? '',
          otherDocumentType: otherDocumentTypeController.text.trim(),
          otherDocumentUrl: otherDocumentPath ?? '',
        ),
        bankDetails: BankDetails(
          bankName: bankNameController.text.trim(),
          bankAccountName: bankAccountNameController.text.trim(),
          accountNumber: accountNumberController.text.trim(),
          ifscCode: ifscCodeController.text.trim(),
          accountType: accountTypeController.text.trim(),
        ),
        agreeToTerms: _agreeToTerms,
        status: 'pending',
        deliveryType: 'RADIUS',
        otpVerified: _isOtpVerified, // Use the new state
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        address: Address(
          address: restaurantAddressController.text.trim(),
          city: cityController.text.trim(),
          state: stateController.text.trim(),
          pincode: pincodeController.text.trim(),
          landMark: landmarkController.text.trim(),
          lat: restaurantLocation?.latitude ?? 0.0,
          lng: restaurantLocation?.longitude ?? 0.0,
        ),
      );

      final Map<String, String> additionalFields = {
        "password": passwordController.text.trim(),
      };

      print('Reaching registration with data: ${jsonEncode(restaurant.toJson())}');

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
        _setLoading(false); // Ensure loading is off before navigation
        Navigator.pushAndRemoveUntil(
          navigatorKey.currentContext!,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
        return true;
      } else {
        _setLoading(false); // Ensure loading is off on failure
        _showToast(
          response.message ?? 'Registration failed. Please check all fields.',
        );
        return false;
      }
    } catch (e) {
      _setLoading(false); // Ensure loading is off on error
      _showToast('Error: ${e.toString()}');
      return false;
    }
    // The finally block is no longer strictly necessary for _setLoading(false)
    // as it's handled in all exit paths.
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

  void setOtpVerified(bool value) {
    _isOtpVerified = value;
    notifyListeners();
  }
  void resetOtpState() {
    _isOtpSent = false;
    _isOtpVerified = false;
    otpController.clear();
    notifyListeners();
  }

  Future<void> sendOtp() async {
    if (phoneNumberController.text.trim().length != 10) {
      _showToast('Please enter valid 10-digit mobile number');
      return;
    }

    _isSendingOtp = true;
    notifyListeners();

    try {
      final response = await _authService.sendRegistrationOtp(
        phoneNumberController.text.trim(),
      );

      if (response.success) {
        _isOtpSent = true;
        _showToast('OTP sent successfully!', isError: false);
      } else {
        _showToast(response.message ?? 'Failed to send OTP');
      }
    } catch (e) {
      _showToast('Error sending OTP: ${e.toString()}');
    } finally {
      _isSendingOtp = false;
      notifyListeners();
    }
  }

  Future<bool> verifyOtp() async {
    if (otpController.text.trim().length != 6) {
      _showToast('Please enter valid 6-digit OTP');
      return false;
    }

    _isVerifyingOtp = true;
    notifyListeners();

    try {
      final response = await _authService.verifyRegistrationOtp(
        mobileNumber: phoneNumberController.text.trim(),
        otp: otpController.text.trim(),
      );

      if (response.success) {
        _isOtpVerified = true;
        _showToast('Mobile number verified successfully!', isError: false);
        return true;
      } else {
        _showToast(response.message ?? 'Invalid OTP');
        return false;
      }
    } catch (e) {
      _showToast('Error verifying OTP: ${e.toString()}');
      return false;
    } finally {
      _isVerifyingOtp = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    restaurantNameController.dispose();
    restaurantAddressController.dispose();
    landmarkController.dispose();
    cityController.dispose();
    stateController.dispose();
    pincodeController.dispose();
    avgCostController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    restContactNumberController.dispose();
    restEmailController.dispose();
    passwordController.dispose();
    otpController.dispose();
    bankAccountNameController.dispose();
    accountNumberController.dispose();
    ifscCodeController.dispose();
    bankNameController.dispose();
    accountTypeController.dispose();
    fssaiNumberController.dispose();
    gstNumberController.dispose();
    tradeLicenseNumberController.dispose();
    otherDocumentTypeController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
