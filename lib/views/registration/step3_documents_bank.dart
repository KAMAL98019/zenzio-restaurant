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

              CustomTextField(
                controller: viewModel.fssaiNumberController,
                label: 'FSSAI Number',
                hint: 'Enter FSSAI Number',
              ),
              const SizedBox(height: 16),
              UploadField(
                label: 'FSSAI Certificate',
                hint:
                    'Drop your file here, or browse\nUpload PDF, JPG, or PNG (Max 2MB)',
                onFileSelected: (path) => viewModel.setFssaiCertificate(path),
                currentFilePath: viewModel.fssaiCertificatePath,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: viewModel.gstNumberController,
                label: 'GST Number',
                hint: 'Enter GST Number',
              ),
              const SizedBox(height: 16),
              UploadField(
                label: 'GST Certificate',
                hint:
                    'Drop your file here, or browse\nUpload PDF, JPG, or PNG (Max 2MB)',
                onFileSelected: (path) => viewModel.setGstCertificate(path),
                currentFilePath: viewModel.gstCertificatePath,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: viewModel.tradeLicenseNumberController,
                label: 'Trade License Number',
                hint: 'Enter Trade License Number',
              ),
              const SizedBox(height: 16),
              UploadField(
                label: 'Trade License File',
                hint:
                    'Drop your file here, or browse\nUpload PDF, JPG, or PNG (Max 2MB)',
                onFileSelected: (path) => viewModel.setTradeLicenseFile(path),
                currentFilePath: viewModel.tradeLicensePath,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: viewModel.otherDocumentTypeController,
                label: 'Other Document Type (e.g., Shop Act)',
                hint: 'Enter Document Type',
              ),
              const SizedBox(height: 16),
              UploadField(
                label: 'Other Document File',
                hint:
                    'Drop your file here, or browse\nUpload PDF, JPG, or PNG (Max 2MB)',
                onFileSelected: (path) => viewModel.setOtherDocumentFile(path),
                currentFilePath: viewModel.otherDocumentPath,
              ),
              const SizedBox(height: 24),

              Text('Bank Details', style: AppTextStyles.h3),
              const SizedBox(height: 16),


              CustomTextField(
                controller: viewModel.bankNameController,
                label: 'Bank Name',
                hint: 'Enter bank name',
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: viewModel.accountNumberController,
                label: 'Account Number',
                hint: 'Enter account number',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
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
              const SizedBox(height: 16),

              CustomTextField(
                controller: viewModel.accountTypeController,
                label: 'Account Type',
                hint: 'Enter account type (e.g., Savings, Current)',
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
