import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/text_styles.dart';
import '../../viewmodels/forgot_password_viewmodel.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../login/login_screen.dart';

class ResetPasswordScreen extends StatelessWidget {
  final ForgotPasswordViewModel viewModel;

  const ResetPasswordScreen({Key? key, required this.viewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Scaffold(
        appBar: const CustomAppBar(title: 'Zenzio'),
        body: Consumer<ForgotPasswordViewModel>(
          builder: (context, vm, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Set New Password', style: AppTextStyles.h2),
                  const SizedBox(height: 8),
                  
                  Text(
                    'Please enter your new password below.',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 32),

                  CustomTextField(
                    controller: vm.newPasswordController,
                    label: 'New Password',
                    hint: 'Enter new password',
                    obscureText: vm.obscureNewPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        vm.obscureNewPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: vm.toggleNewPasswordVisibility,
                    ),
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: vm.confirmPasswordController,
                    label: 'Confirm Password',
                    hint: 'Confirm new password',
                    obscureText: vm.obscureConfirmPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        vm.obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: vm.toggleConfirmPasswordVisibility,
                    ),
                  ),
                  const SizedBox(height: 32),

                  CustomButton(
                    text: 'Reset Password',
                    onPressed: () async {
                      final success = await vm.resetPassword();
                      if (success && context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                          (route) => false,
                        );
                      }
                    },
                    isLoading: vm.isLoading,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
