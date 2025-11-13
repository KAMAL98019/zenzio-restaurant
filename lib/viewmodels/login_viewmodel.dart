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
      Fluttertoast.showToast(msg: 'Please enter email or mobile number');
      return false;
    }

    if (password.isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter password');
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
      final restaurantId = response.data?['data']['id']?.toString();
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

      Fluttertoast.showToast(
        msg: 'Login successful!',
        backgroundColor: Colors.green,
      );

      // ✅ Navigate to Dashboard
      Navigator.pushAndRemoveUntil(
        navigatorKey.currentContext!,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
        (route) => false,
      );

      return true;
    } else {
      Fluttertoast.showToast(
        msg: response.message ?? 'Login failed',
        backgroundColor: Colors.red,
      );
      return false;
    }
  }

  Future<bool> sendOtpForLogin() async {
    final mobileNumber = emailController.text.trim(); // Assuming emailController can also hold mobile number

    if (mobileNumber.isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter your mobile number');
      return false;
    }

    _isLoading = true;
    notifyListeners();

    final response = await _authService.sendOtpLogin(mobileNumber);

    _isLoading = false;
    notifyListeners();

    if (response.success) {
      Fluttertoast.showToast(msg: 'OTP sent to your mobile number');
      _showOtpField = true; // Show OTP field after sending
      notifyListeners();
      return true;
    } else {
      Fluttertoast.showToast(msg: response.message ?? 'Failed to send OTP');
      return false;
    }
  }

  Future<bool> verifyOtpAndLogin() async {
    final mobileNumber = emailController.text.trim();
    final otp = otpController.text.trim();

    if (mobileNumber.isEmpty || otp.isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter mobile number and OTP');
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
      final restaurantId = response.data?['data']['id']?.toString();
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

      Fluttertoast.showToast(
        msg: 'OTP login successful!',
        backgroundColor: Colors.green,
      );

      Navigator.pushAndRemoveUntil(
        navigatorKey.currentContext!,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
        (route) => false,
      );
      return true;
    } else {
      Fluttertoast.showToast(
        msg: response.message ?? 'OTP verification failed',
        backgroundColor: Colors.red,
      );
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
}
