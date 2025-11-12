import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:zenzio_restaurant/core/constant/appcolors.dart';
import 'package:zenzio_restaurant/utils/text_formatters.dart';
import '../../core/theme/text_styles.dart';
import '../../viewmodels/registration_viewmodel.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/upload_field.dart';
import '../dashboard/dashboard_screen.dart';

class Step3DocumentsBank extends StatelessWidget {
  const Step3DocumentsBank({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RegistrationViewModel>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Almost there! Just a few documents',
                style: AppTextStyles.h3,
              ),
              const SizedBox(height: 24),

              Text(
                'FSSAI License / Food Business License',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),

              UploadField(
                label: 'FSSAI Certificate',
                hint:
                    'Drop your file here, or browse\nUpload PDF, JPG, or PNG (Max 5MB)',
                onFileSelected: (path) => viewModel.setFssaiCertificate(path),
              ),
              const SizedBox(height: 16),

              UploadField(
                label: 'GST Certificate',
                hint:
                    'Drop your file here, or browse\nUpload PDF, JPG, or PNG (Max 5MB)',
                isOptional: true,
                onFileSelected: (path) => viewModel.setGstCertificate(path),
              ),
              const SizedBox(height: 24),

              Text('Bank Details', style: AppTextStyles.h3),
              const SizedBox(height: 16),

              CustomTextField(
                controller: viewModel.bankAccountNameController,
                label: 'Bank Account Name',
                hint: 'Enter account holder name',
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: viewModel.accountNumberController,
                label: 'Account Number',
                hint: 'Enter account number',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: viewModel.ifscCodeController,
                label: 'IFSC Code',
                hint: 'Uppercase letters and numbers only (e.g., SBIN0000123)',
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                  LengthLimitingTextInputFormatter(11),
                  UpperCaseTextFormatter(),
                ],
              ),

              const SizedBox(height: 24),

              // Fixed Terms & Conditions Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: viewModel.agreeToTerms,
                    onChanged: (value) =>
                        viewModel.toggleTermsAgreement(value ?? false),
                    activeColor: AppColors.primary,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4, top: 12),
                      child: GestureDetector(
                        onTap: () => viewModel.toggleTermsAgreement(
                          !viewModel.agreeToTerms,
                        ),
                        child: RichText(
                          text: TextSpan(
                            text: 'I agree to the ',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                            ),
                            children: [
                              TextSpan(
                                text: 'Terms & Conditions',
                                style: AppTextStyles.link,
                              ),
                              const TextSpan(text: ' and '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: AppTextStyles.link,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Buttons Row
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Back',
                      onPressed: viewModel.previousStep,
                      isOutlined: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'Submit',
                      onPressed: () async {
                        final success = await viewModel.submitRegistration();
                        if (success && context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DashboardScreen(),
                            ),
                            (route) => false,
                          );
                        }
                      },
                      isLoading: viewModel.isLoading,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
