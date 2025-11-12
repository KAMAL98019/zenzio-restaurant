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
      Fluttertoast.showToast(msg: 'Please enter email or mobile number');
      return false;
    }

    _isLoading = true;
    notifyListeners();

    final response = await _authService.sendOtp(
      emailOrMobileController.text.trim(),
    );

    _isLoading = false;
    notifyListeners();

    if (response.success) {
      Fluttertoast.showToast(
        msg: 'OTP sent successfully!',
        backgroundColor: Colors.green,
      );
      return true;
    } else {
      Fluttertoast.showToast(
        msg: response.message ?? 'Failed to send OTP',
        backgroundColor: Colors.red,
      );
      return false;
    }
  }

  Future<bool> verifyOtp() async {
    if (otpController.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter OTP');
      return false;
    }

    if (otpController.text.trim().length != 6) {
      Fluttertoast.showToast(msg: 'Please enter valid 6-digit OTP');
      return false;
    }

    _isLoading = true;
    notifyListeners();

    final response = await _authService.verifyOtp(
      emailOrMobile: emailOrMobileController.text.trim(),
      otp: otpController.text.trim(),
    );

    _isLoading = false;
    notifyListeners();

    if (response.success) {
      Fluttertoast.showToast(
        msg: 'OTP verified successfully!',
        backgroundColor: Colors.green,
      );
      return true;
    } else {
      Fluttertoast.showToast(
        msg: response.message ?? 'Invalid OTP',
        backgroundColor: Colors.red,
      );
      return false;
    }
  }

  Future<bool> resetPassword() async {
    if (newPasswordController.text.isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter new password');
      return false;
    }

    if (newPasswordController.text.length < 6) {
      Fluttertoast.showToast(msg: 'Password must be at least 6 characters');
      return false;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      Fluttertoast.showToast(msg: 'Passwords do not match');
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
      Fluttertoast.showToast(
        msg: 'Password reset successfully!',
        backgroundColor: Colors.green,
      );
      return true;
    } else {
      Fluttertoast.showToast(
        msg: response.message ?? 'Failed to reset password',
        backgroundColor: Colors.red,
      );
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
}
