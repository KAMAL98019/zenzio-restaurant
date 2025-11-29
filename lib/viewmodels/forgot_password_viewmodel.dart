import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/auth_service.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  final TextEditingController emailOrMobileController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  bool get isLoading => _isLoading;
  bool get obscureNewPassword => _obscureNewPassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;

  void toggleNewPasswordVisibility() {
    _obscureNewPassword = !_obscureNewPassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    notifyListeners();
  }

  Future<bool> sendOtp() async {
    if (emailOrMobileController.text.trim().isEmpty) {
      _showCustomToast('Please enter email or mobile number', isError: true);
      return false;
    }

    _isLoading = true;
    notifyListeners();

    final response = await _authService.sendForgotPasswordOtp(
      emailOrMobileController.text.trim(),
    );

    _isLoading = false;
    notifyListeners();

    if (response.success) {
      _showCustomToast('OTP sent successfully!', isError: false);
      return true;
    } else {
      _showCustomToast(response.message ?? 'Failed to send OTP', isError: true);
      return false;
    }
  }

  Future<bool> verifyOtp() async {
    if (otpController.text.trim().isEmpty) {
      _showCustomToast('Please enter OTP', isError: true);
      return false;
    }

    if (otpController.text.trim().length != 6) {
      _showCustomToast('Please enter valid 6-digit OTP', isError: true);
      return false;
    }

    _isLoading = true;
    notifyListeners();

    final response = await _authService.verifyForgotPasswordOtp(
      emailOrMobile: emailOrMobileController.text.trim(),
      otp: otpController.text.trim(),
    );

    _isLoading = false;
    notifyListeners();

    if (response.success) {
      _showCustomToast('OTP verified successfully!', isError: false);
      return true;
    } else {
      _showCustomToast(response.message ?? 'Invalid OTP', isError: true);
      return false;
    }
  }

  Future<bool> resetPassword() async {
    if (newPasswordController.text.isEmpty) {
      _showCustomToast('Please enter new password', isError: true);
      return false;
    }

    if (newPasswordController.text.length < 6) {
      _showCustomToast('Password must be at least 6 characters', isError: true);
      return false;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      _showCustomToast('Passwords do not match', isError: true);
      return false;
    }

    _isLoading = true;
    notifyListeners();

    final response = await _authService.resetPassword(
      emailOrMobile: emailOrMobileController.text.trim(),
      newPassword: newPasswordController.text,
    );

    _isLoading = false;
    notifyListeners();

    if (response.success) {
      _showCustomToast('Password reset successfully!', isError: false);
      return true;
    } else {
      _showCustomToast(response.message ?? 'Failed to reset password', isError: true);
      return false;
    }
  }

  @override
  void dispose() {
    emailOrMobileController.dispose();
    otpController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
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
