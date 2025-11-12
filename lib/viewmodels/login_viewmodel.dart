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

  bool _isLoading = false;
  bool _obscurePassword = true;

  bool get isLoading => _isLoading;
  bool get obscurePassword => _obscurePassword;

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

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
