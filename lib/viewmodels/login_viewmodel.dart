import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:zenzio_restaurant/main.dart'; // for navigatorKey
import 'package:zenzio_restaurant/views/dashboard/dashboard_screen.dart';
import '../services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _showOtpField = false;

  bool get isLoading => _isLoading;
  bool get obscurePassword => _obscurePassword;
  bool get showOtpField => _showOtpField;

  void toggleOtpFieldVisibility(bool value) {
    _showOtpField = value;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  Future<bool> login() async {
    final emailOrMobile = emailController.text.trim();
    final password = passwordController.text;

    if (emailOrMobile.isEmpty) {
      _showCustomToast('Please enter email or mobile number', isError: true);
      return false;
    }

    if (password.isEmpty) {
      _showCustomToast('Please enter password', isError: true);
      return false;
    }

    _isLoading = true;
    notifyListeners();

    final response = await _authService.login(
      emailOrMobile: emailOrMobile,
      password: password,
    );

    _isLoading = false;
    notifyListeners();

    print("Login response: ${response.data?['data']}");

    if (response.success && response.data != null) {
      // ✅ Extract details
      final restaurantId = (response.data?['data'] as Map<String, dynamic>?)?['id']?.toString();
      final token = response.data?['token'];

      // print("✅ Restaurant ID: $restaurantId");

      if (restaurantId != null) {
        // ✅ Save Restaurant ID & Token in SharedPreferences
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('registrationID', restaurantId);
          await prefs.setString('authToken', token ?? '');

          // Debug log
          // debugPrint('🔐 Saved registrationID: $restaurantId');
          // debugPrint('🔐 Saved authToken: $token');
        } catch (e) {
          debugPrint('⚠️ Error saving preferences: $e');
        }
      }

      _showCustomToast('Login successful!', isError: false);

      // ✅ Navigate to Dashboard
      Navigator.pushAndRemoveUntil(
        navigatorKey.currentContext!,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
        (route) => false,
      );

      return true;
    } else {
      _showCustomToast(response.message ?? 'Login failed', isError: true);
      return false;
    }
  }

  Future<bool> sendOtpForLogin() async {
    final mobileNumber = emailController.text.trim(); // Assuming emailController can also hold mobile number

    if (mobileNumber.isEmpty) {
      _showCustomToast('Please enter your mobile number', isError: true);
      return false;
    }

    _isLoading = true;
    notifyListeners();

    final response = await _authService.sendOtpLogin(mobileNumber);

    _isLoading = false;
    notifyListeners();

    if (response.success) {
      _showCustomToast('OTP sent to your mobile number', isError: false);
      _showOtpField = true; // Show OTP field after sending
      notifyListeners();
      return true;
    } else {
      _showCustomToast(response.message ?? 'Failed to send OTP', isError: true);
      return false;
    }
  }

  Future<bool> verifyOtpAndLogin() async {
    final mobileNumber = emailController.text.trim();
    final otp = otpController.text.trim();

    if (mobileNumber.isEmpty || otp.isEmpty) {
      _showCustomToast('Please enter mobile number and OTP', isError: true);
      return false;
    }

    _isLoading = true;
    notifyListeners();

    final response = await _authService.verifyOtpLogin(
      mobileNumber: mobileNumber,
      otp: otp,
    );

    _isLoading = false;
    notifyListeners();

    if (response.success && response.data != null) {
      // Safely access data map
      final dataMap = response.data?['data'] as Map<String, dynamic>?;
      String? restaurantId;

      if (dataMap != null) {
        restaurantId = dataMap['id']?.toString();
        // If 'id' is not found directly, check for a nested 'user' object for the ID, common in OTP flows
        if (restaurantId == null) {
          final userMap = dataMap['user'] as Map<String, dynamic>?;
          restaurantId = userMap?['id']?.toString();
        }
      }
      final token = response.data?['token'];

      if (restaurantId != null) {
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('registrationID', restaurantId);
          await prefs.setString('authToken', token ?? '');
        } catch (e) {
          debugPrint('⚠️ Error saving preferences: $e');
        }
      }

      _showCustomToast('OTP login successful!', isError: false);

      Navigator.pushAndRemoveUntil(
        navigatorKey.currentContext!,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
        (route) => false,
      );
      return true;
    } else {
      _showCustomToast(response.message ?? 'OTP verification failed', isError: true);
      return false;
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    otpController.dispose();
    super.dispose();
  }

  void _showCustomToast(String message, {bool isError = true}) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: isError ? Colors.red : Colors.green,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
