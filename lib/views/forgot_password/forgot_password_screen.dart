import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zenzio_restaurant/viewmodels/forgot_password_viewmodel.dart';
import '../../core/theme/text_styles.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import 'verify_otp_screen.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ForgotPasswordViewModel(),
      child: Scaffold(
        appBar: const CustomAppBar(title: 'Zenzio'),
        body: Consumer<ForgotPasswordViewModel>(
          builder: (context, viewModel, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Forgot Your Password?', style: AppTextStyles.h2),
                  const SizedBox(height: 8),
                  
                  Text(
                    'Enter your registered mobile number or email to receive a verification code.',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 32),

                  CustomTextField(
                    controller: viewModel!.emailOrMobileController,
                    label: 'Mobile Number or Email',
                    hint: 'Enter your mobile number or email',
                  ),
                  const SizedBox(height: 32),

                  CustomButton(
                    text: 'Send Verification Code',
                    onPressed: () async {
                      final success = await viewModel.sendOtp();
                      if (success && context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VerifyOtpScreen(viewModel: viewModel),
                          ),
                        );
                      }
                    },
                    isLoading: viewModel.isLoading,
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
