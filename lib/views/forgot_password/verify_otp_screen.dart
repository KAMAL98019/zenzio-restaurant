import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zenzio_restaurant/core/constant/appcolors.dart';
import '../../core/theme/text_styles.dart';
import '../../viewmodels/forgot_password_viewmodel.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_button.dart';
import 'reset_password_screen.dart';

class VerifyOtpScreen extends StatelessWidget {
  final ForgotPasswordViewModel viewModel;

  const VerifyOtpScreen({Key? key, required this.viewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Scaffold(
        appBar: const CustomAppBar(title: 'Zenzio'),
        body: Consumer<ForgotPasswordViewModel>(
          builder: (context, vm, _) {
            final maskedContact = _maskContact(vm.emailOrMobileController.text);
            
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Verify Your Mobile Number', style: AppTextStyles.h2),
                  const SizedBox(height: 8),
                  
                  Text(
                    'Enter the 6-digit code sent to $maskedContact',
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // OTP Input Fields
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width: 50,
                        child: TextField(
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          style: AppTextStyles.h2,
                          decoration: InputDecoration(
                            counterText: '',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            if (value.length == 1 && index < 5) {
                              FocusScope.of(context).nextFocus();
                            }
                            
                            // Collect OTP
                            final otp = _collectOtp(context);
                            if (otp.length == 6) {
                              vm.otpController.text = otp;
                            }
                          },
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: () => vm.sendOtp(),
                    child: const Text('Resend code in 0:59'),
                  ),
                  const SizedBox(height: 32),

                  CustomButton(
                    text: 'Verify',
                    onPressed: () async {
                      final success = await vm.verifyOtp();
                      if (success && context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ResetPasswordScreen(viewModel: vm),
                          ),
                        );
                      }
                    },
                    isLoading: vm.isLoading,
                  ),
                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Having trouble? Contact Support',
                      style: AppTextStyles.link,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _maskContact(String contact) {
    if (contact.contains('@')) {
      final parts = contact.split('@');
      return '${parts[0].substring(0, 2)}***@${parts[1]}';
    } else {
      return '+91 ${contact.substring(0, 2)}XXX ${contact.substring(contact.length - 2)}';
    }
  }

  String _collectOtp(BuildContext context) {
    // Helper to collect OTP from text fields (simplified)
    return '';
  }
}
