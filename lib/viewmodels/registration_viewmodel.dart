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
  final TextEditingController contactPersonController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController restContactNumberController =
      TextEditingController();
  final TextEditingController restEmailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  List<OperationalHours> operationalHours = OperationalHours.getDefaultHours();
  List<String> selectedCuisines = [];
  List<String> selectedCategories = [];

  // Step 3: Documents & Bank Details
  String? fssaiCertificatePath;
  String? gstCertificatePath;
  // final TextEditingController bankAccountNameController =
  //     TextEditingController(); // Removed as per BankDetails model update
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController ifscCodeController = TextEditingController();
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController accountTypeController = TextEditingController();
  final TextEditingController fssaiNumberController = TextEditingController();
  final TextEditingController gstNumberController = TextEditingController();
  final TextEditingController tradeLicenseNumberController =
      TextEditingController();
  final TextEditingController otherDocumentTypeController =
      TextEditingController();
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
        _showToast('Failed to load restaurant data', isError: true);
      }
    } catch (e) {
      _showToast('Error loading restaurant: ${e.toString()}', isError: true);
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
    avgCostController.text = restaurant!.avgCostTwo ?? '';
    contactPersonController.text = restaurant!.contactPerson;
    emailController.text = restaurant!.email;
    phoneNumberController.text = restaurant!.phoneNumber;
    restContactNumberController.text = restaurant!.restContactNumber;
    restEmailController.text = restaurant!.restEmail ?? '';
    // bankAccountNameController.text = restaurant!.bankDetails.bankAccountName; // Removed
    accountNumberController.text = restaurant!.bankDetails.accountNumber;
    ifscCodeController.text = restaurant!.bankDetails.ifscCode;
    operationalHours = restaurant!.operationalHours;
    restaurantLocation = LatLng(
      restaurant!.address.lat,
      restaurant!.address.lng,
    );
  }

  /// Populates the text controllers and state variables from a JSON map.
  /// This is typically used for pre-filling the registration form.
  void populateRegistrationFieldsFromJson(Map<String, dynamic> json) {
    restaurantNameController.text = json['restaurant_name'] ?? '';
    contactPersonController.text = json['contact_person'] ?? '';
    restContactNumberController.text = json['contact_number'] ?? '';
    emailController.text = json['email'] ?? '';
    phoneNumberController.text = json['phoneNumber'] ?? '';
    passwordController.text = json['password'] ?? '';

    // Address
    final addressJson = json['address'] as Map<String, dynamic>?;
    if (addressJson != null) {
      cityController.text = addressJson['city'] ?? '';
      stateController.text = addressJson['state'] ?? '';
      pincodeController.text = addressJson['pincode'] ?? '';
      restaurantAddressController.text = addressJson['address'] ?? '';
      landmarkController.text = addressJson['land_mark'] ?? '';
      final lat = addressJson['lat'] as double?;
      final lng = addressJson['lng'] as double?;
      if (lat != null && lng != null) {
        restaurantLocation = LatLng(lat, lng);
      }
    }

    // Documents
    final documentsJson = json['documents'] as Map<String, dynamic>?;
    if (documentsJson != null) {
      fssaiNumberController.text = documentsJson['fssai_number'] ?? '';
      gstNumberController.text =
          documentsJson['gsg_number'] ??
          ''; // Note: payload uses 'gsg_number', model uses 'gstNumber'
      tradeLicenseNumberController.text =
          documentsJson['trade_license_number'] ?? '';
      otherDocumentTypeController.text =
          documentsJson['otherDocumentType'] ?? '';

      // Set photo and document paths (assuming these are URLs for pre-fill)
      final fssaiFiles = documentsJson['file_fssai'] as List<dynamic>?;
      if (fssaiFiles != null && fssaiFiles.isNotEmpty) {
        fssaiCertificatePath = fssaiFiles.first.toString();
      }

      final gstFiles = documentsJson['file_gst'] as List<dynamic>?;
      if (gstFiles != null && gstFiles.isNotEmpty) {
        gstCertificatePath = gstFiles.first.toString();
      }

      final tradeLicenseFiles =
          documentsJson['file_trade_license'] as List<dynamic>?;
      if (tradeLicenseFiles != null && tradeLicenseFiles.isNotEmpty) {
        tradeLicensePath = tradeLicenseFiles.first.toString();
      }

      final otherDocFiles = documentsJson['file_other_doc'] as List<dynamic>?;
      if (otherDocFiles != null && otherDocFiles.isNotEmpty) {
        otherDocumentPath = otherDocFiles.first.toString();
      }
    }

    // Bank Details
    final bankDetailsJson = json['bank_details'] as Map<String, dynamic>?;
    if (bankDetailsJson != null) {
      bankNameController.text = bankDetailsJson['bank_name'] ?? '';
      accountNumberController.text = bankDetailsJson['account_number'] ?? '';
      ifscCodeController.text = bankDetailsJson['ifsc_code'] ?? '';
      accountTypeController.text = bankDetailsJson['account_type'] ?? '';
    }

    // Operational Hours
    final hoursList = json['operational_hours'] as List<dynamic>?;
    if (hoursList != null) {
      try {
        operationalHours = hoursList
            .map((e) => OperationalHours.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (e) {
        print('Error parsing operational hours: $e');
        operationalHours = OperationalHours.getDefaultHours();
      }
    } else {
      operationalHours = OperationalHours.getDefaultHours();
    }

    // Photos
    final photoList = json['photo'] as List<dynamic>?;
    if (photoList != null && photoList.isNotEmpty) {
      // Assuming the first photo is the main logo
      restaurantLogoPath = photoList.first.toString();
    }

    // Set other relevant flags
    _isOtpVerified = false; // Mobile number needs re-verification
    _currentStep = 0; // Start at the first step
    _agreeToTerms = false; // Terms need to be re-agreed

    notifyListeners();
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

  void setTradeLicenseFile(String path) {
    if (!_validateFileSize(path, 'Trade License File', _maxDocumentSize)) {
      return;
    }
    tradeLicensePath = path;
    print('Trade License File set: $tradeLicensePath');
    notifyListeners();
  }

  void setOtherDocumentFile(String path) {
    if (!_validateFileSize(path, 'Other Document File', _maxDocumentSize)) {
      return;
    }
    otherDocumentPath = path;
    print('Other Document File set: $otherDocumentPath');
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
            isError: true,
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
      _showToast('Please enter restaurant name', isError: true);
      return false;
    }
    if (restaurantNameController.text.trim().length < 3 ||
        restaurantNameController.text.trim().length > 100) {
      _showToast('Restaurant name must be between 3 and 100 characters', isError: true);
      return false;
    }
    if (restaurantAddressController.text.trim().isEmpty) {
      _showToast('Please enter restaurant address', isError: true);
      return false;
    }
    return true;
  }

  bool validateStep2() {
    if (contactPersonController.text.trim().length < 3) {
      _showToast('Please enter contact person\'s full name', isError: true);
      return false;
    }
    if (emailController.text.trim().isEmpty ||
        !RegExp(
          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
        ).hasMatch(emailController.text.trim())) {
      _showToast('Please enter a valid contact person email address', isError: true);
      return false;
    }
    if (phoneNumberController.text.trim().length != 10) {
      _showToast('Please enter valid contact person mobile number (10 digits)', isError: true);
      return false;
    }
    if (mode == 'registration' && !_isOtpVerified) {
      _showToast('Please verify your contact person mobile number with OTP', isError: true);
      return false;
    }
    if (restContactNumberController.text.trim().length != 10) {
      _showToast('Please enter valid restaurant contact number (10 digits)', isError: true);
      return false;
    }
    if (restEmailController.text.trim().isEmpty ||
        !RegExp(
          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
        ).hasMatch(restEmailController.text.trim())) {
      _showToast('Please enter a valid restaurant email address', isError: true);
      return false;
    }
    if (mode == 'registration' &&
        (passwordController.text.length < 8 ||
            passwordController.text.length > 20)) {
      _showToast('Password must be between 8 and 20 characters', isError: true);
      return false;
    }
    return true;
  }

  bool validateStep3() {
    if (bankNameController.text.trim().isEmpty) {
      _showToast('Please enter bank name', isError: true);
      return false;
    }
    if (accountNumberController.text.trim().isEmpty) {
      _showToast('Please enter account number', isError: true);
      return false;
    }
    if (ifscCodeController.text.trim().isEmpty) {
      _showToast('Please enter IFSC code', isError: true);
      return false;
    }
    if (accountTypeController.text.trim().isEmpty) {
      _showToast('Please enter account type', isError: true);
      return false;
    }
    if (mode == 'registration') {
      // if (fssaiCertificatePath == null || fssaiCertificatePath!.isEmpty) {
      //   _showToast('Please upload FSSAI Certificate', isError: true);
      //   return false;
      // }
      // if (gstCertificatePath == null || gstCertificatePath!.isEmpty) {
      //   _showToast('Please upload GST Certificate', isError: true);
      //   return false;
      // }
      // if (!_agreeToTerms) {
      //   _showToast('Please agree to terms and conditions', isError: true);
      //   return false;
      // }
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
        contactPerson: contactPersonController.text
            .trim(), // Updated to use contactPersonController
        avgCostTwo: avgCostController.text.trim(),
        photo: restaurantLogoPath != null
            ? [restaurantLogoPath!]
            : restaurant!.photo, // Renamed from restLogo
        firstName: null, // Removed field, set to null
        lastName: null, // Removed field, set to null
        email: emailController.text.trim(),
        phoneNumber: phoneNumberController.text.trim(),
        restContactNumber: restContactNumberController.text.trim(),
        password: '', // Required for constructor, not sent in update
        restEmail: restEmailController.text.trim(),

        operationalHours: operationalHours,
        documents: restaurant!.documents,
        bankDetails: restaurant!.bankDetails.copyWith(
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
        restaurant!.id!,
        updatedRestaurant,
      );

      if (response.success) {
        restaurant = updatedRestaurant;
        _showToast('Profile updated successfully!', isError: false);
        notifyListeners();
      } else {
        _showToast( 'Failed to update profile', isError: true);
      }
    } catch (e) {
      _showToast('Error updating profile: ${e.toString()}', isError: true);
    } finally {
      _setUpdating(false);
    }
  }

  Future<bool> submitRegistration() async {
    if (!validateStep3()) return false;
    if (!await _validateAllFiles()) return false;

    _setLoading(true);

    try {
      final restaurant = Restaurant(
        id: '',
        restaurantName: restaurantNameController.text.trim(),
        contactPerson: contactPersonController.text.trim(),
        avgCostTwo: avgCostController.text.trim(),
        email: emailController.text.trim(),
        phoneNumber: phoneNumberController.text.trim(),
        restContactNumber: restContactNumberController.text.trim(),
        password: passwordController.text.trim(),
        restEmail: restEmailController.text.trim(),

        agreeToTerms: true,
        status: "INACTIVE",
        deliveryType: "RADIUS",
        otpVerified: true,
        createdAt: '',
        updatedAt: '',

        photo: restaurantLogoPath != null ? [restaurantLogoPath!] : [],

        operationalHours: operationalHours,

        address: Address(
          city: cityController.text.trim(),
          state: stateController.text.trim(),
          pincode: pincodeController.text.trim(),
          address: restaurantAddressController.text.trim(),
          landMark: landmarkController.text.trim(),
          lat: restaurantLocation?.latitude ?? 0.0,
          lng: restaurantLocation?.longitude ?? 0.0,
        ),

        bankDetails: BankDetails(
          bankName: bankNameController.text.trim(),
          accountNumber: accountNumberController.text.trim(),
          ifscCode: ifscCodeController.text.trim(),
          accountType: accountTypeController.text.trim(),
        ),

        documents: Documents(
          fssaiNumber: fssaiNumberController.text.trim(),
          fileFssai: fssaiCertificatePath != null
              ? [fssaiCertificatePath!]
              : [],
          gstNumber: gstNumberController.text.trim(),
          fileGst: gstCertificatePath != null ? [gstCertificatePath!] : [],
          tradeLicenseNumber: tradeLicenseNumberController.text.trim(),
          fileTradeLicense: tradeLicensePath != null
              ? [tradeLicensePath!]
              : null,
          otherDocumentType: otherDocumentTypeController.text.trim(),
          fileOtherDoc: otherDocumentPath != null ? [otherDocumentPath!] : null,
        ),
      );

      final response = await _authService.register(restaurant);

      if (response.success) {
        _showToast('Registration successful!', isError: false);
        Navigator.pushAndRemoveUntil(
          navigatorKey.currentContext!,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
        return true;
      } else {
        _showToast(response.message ?? 'Registration failed', isError: true);
        return false;
      }
    } catch (e) {
      _showToast("Error: $e", isError: true);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> _validateAllFiles() async {
    bool allFilesValid = true;

    // if (fssaiCertificatePath == null || fssaiCertificatePath!.isEmpty) {
    //   _showToast('Please upload FSSAI Certificate');
    //   allFilesValid = false;
    // } else {
    //   File fssaiFile = File(fssaiCertificatePath!);
    //   if (!await fssaiFile.exists()) {
    //     _showToast('FSSAI Certificate file not found. Please upload again.');
    //     allFilesValid = false;
    //   } else if (await fssaiFile.length() > _maxDocumentSize) {
    //     _showToast(
    //       'FSSAI Certificate is too large. Please choose a file smaller than 2MB.',
    //     );
    //     allFilesValid = false;
    //   }
    // }

    // if (gstCertificatePath == null || gstCertificatePath!.isEmpty) {
    //   _showToast('Please upload GST Certificate');
    //   allFilesValid = false;
    // } else {
    //   File gstFile = File(gstCertificatePath!);
    //   if (!await gstFile.exists()) {
    //     _showToast('GST Certificate file not found. Please upload again.');
    //     allFilesValid = false;
    //   } else if (await gstFile.length() > _maxDocumentSize) {
    //     _showToast(
    //       'GST Certificate is too large. Please choose a file smaller than 2MB.',
    //     );
    //     allFilesValid = false;
    //   }
    // }

    if (restaurantLogoPath != null && restaurantLogoPath!.isNotEmpty) {
      File logoFile = File(restaurantLogoPath!);
      if (!await logoFile.exists()) {
        _showToast('Restaurant logo file not found. Please upload again.', isError: true);
        allFilesValid = false;
      } else if (await logoFile.length() > _maxImageSize) {
        _showToast(
          'Restaurant logo is too large. Please choose a file smaller than 1MB.',
          isError: true,
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
      _showToast('Please enter valid 10-digit mobile number', isError: true);
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
        _showToast(response.message ?? 'Failed to send OTP', isError: true);
      }
    } catch (e) {
      _showToast('Error sending OTP: ${e.toString()}', isError: true);
    } finally {
      _isSendingOtp = false;
      notifyListeners();
    }
  }

  Future<bool> verifyOtp() async {
    if (otpController.text.trim().length != 6) {
      _showToast('Please enter valid 6-digit OTP', isError: true);
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
        _showToast(response.message ?? 'Invalid OTP', isError: true);
        return false;
      }
    } catch (e) {
      _showToast('Error verifying OTP: ${e.toString()}', isError: true);
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
    contactPersonController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    restContactNumberController.dispose();
    restEmailController.dispose();
    passwordController.dispose();
    otpController.dispose();
    // bankAccountNameController.dispose(); // Removed
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
