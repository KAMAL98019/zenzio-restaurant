import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:zenzio_restaurant/core/constant/appcolors.dart';
import '../../core/theme/text_styles.dart';
import '../../viewmodels/registration_viewmodel.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class Step2ContactHours extends StatelessWidget {
  const Step2ContactHours({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RegistrationViewModel>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('How can we reach you?', style: AppTextStyles.h3),
          const SizedBox(height: 24),

          CustomTextField(
            controller: viewModel.firstNameController,
            label: 'Contact Person First Name',
            hint: 'Enter first name',
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: viewModel.lastNameController,
            label: 'Contact Person Last Name',
            hint: 'Enter last name',
          ),
          const SizedBox(height: 16),

          CustomTextField(
            controller: viewModel.emailController,
            label: 'Contact Person Email',
            hint: 'Enter email address',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),

          CustomTextField(
            controller: viewModel.phoneNumberController,
            label: 'Contact Person Mobile Number',
            hint: 'Enter mobile number',
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
          ),
          const SizedBox(height: 8),
          if (viewModel.mode == 'registration')
            _buildOtpSection(context, viewModel),
          const SizedBox(height: 16),

          CustomTextField(
            controller: viewModel.restContactNumberController,
            label: 'Restaurant Contact Number',
            hint: 'Enter restaurant mobile number',
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
          ),
          const SizedBox(height: 16),

          CustomTextField(
            controller: viewModel.restEmailController,
            label: 'Restaurant Email',
            hint: 'Enter restaurant email address',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),

          CustomTextField(
            controller: viewModel.passwordController,
            label: 'Password',
            hint: 'Create a password (min 8-20 characters)',
            obscureText: true,
          ),
          const SizedBox(height: 24),

          Text('Operational Hours', style: AppTextStyles.h3),
          const SizedBox(height: 16),

          ...List.generate(viewModel.operationalHours.length, (index) {
            final hours = viewModel.operationalHours[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      _getDayName(hours.day), // Fixed: now accepts int
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                  Switch(
                    value: hours.enabled,
                    onChanged: (value) {
                      viewModel.updateOperationalHours(
                        index,
                        hours.copyWith(enabled: value),
                      );
                    },
                    activeColor: AppColors.primary,
                  ),
                  if (hours.enabled) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: _TimeField(
                              label: 'From',
                              initialValue:
                                  hours.from, // Fixed: now accepts TimeOfDay
                              onChanged: (value) {
                                viewModel.updateOperationalHours(
                                  index,
                                  hours.copyWith(from: value),
                                );
                              },
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text('to'),
                          ),
                          Expanded(
                            child: _TimeField(
                              label: 'To',
                              initialValue:
                                  hours.to, // Fixed: now accepts TimeOfDay
                              onChanged: (value) {
                                viewModel.updateOperationalHours(
                                  index,
                                  hours.copyWith(to: value),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
          const SizedBox(height: 32),

          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Back',
                  onPressed: viewModel.previousStep,
                  isOutlined: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomButton(
                  text: 'Continue',
                  onPressed: viewModel.nextStep,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOtpSection(
    BuildContext context,
    RegistrationViewModel viewModel,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (viewModel.isOtpSent && !viewModel.isOtpVerified) ...[
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.end, // ✅ Align button with textfield bottom
            children: [
              Expanded(
                child: CustomTextField(
                  controller: viewModel.otpController,
                  label: 'Verification Code (OTP)',
                  hint: 'Enter 6-digit OTP',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 56, // ✅ match text field height
                child: CustomButton(
                  text: viewModel.isVerifyingOtp ? 'Verifying...' : 'Verify',
                  onPressed: () {
                    viewModel.verifyOtp();
                  },
                  isLoading: viewModel.isVerifyingOtp,
                  isOutlined: true,
                  width: 120,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'OTP sent to ${viewModel.phoneNumberController.text.trim()}.',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 8),
        ] else if (viewModel.isOtpVerified)
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Text(
                'Mobile number verified!',
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.green),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  viewModel.resetOtpState();
                },
                child: const Text('Change Number'),
              ),
            ],
          )
        else
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: viewModel.isSendingOtp ? 'Sending OTP...' : 'Send OTP',
              onPressed: () {
                viewModel.sendOtp();
              },
              isLoading: viewModel.isSendingOtp,
              isOutlined: true,
            ),
          ),
      ],
    );
  }

  // Fixed: now accepts int (0-6) and converts to day name
  String _getDayName(int day) {
    const days = [
      'Monday', // 0
      'Tuesday', // 1
      'Wednesday', // 2
      'Thursday', // 3
      'Friday', // 4
      'Saturday', // 5
      'Sunday', // 6
    ];
    return days[day];
  }
}

class _TimeField extends StatelessWidget {
  final String label;
  final TimeOfDay initialValue; // Fixed: changed from String to TimeOfDay
  final Function(TimeOfDay)
  onChanged; // Fixed: changed from String to TimeOfDay

  const _TimeField({
    required this.label,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Convert TimeOfDay to String for display
    final timeString =
        '${initialValue.hour.toString().padLeft(2, '0')}:${initialValue.minute.toString().padLeft(2, '0')}';
    final controller = TextEditingController(text: timeString);

    return InkWell(
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: initialValue, // Use TimeOfDay directly
        );
        if (time != null) {
          final formatted =
              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
          controller.text = formatted;
          onChanged(time); // Pass TimeOfDay object, not String
        }
      },
      child: IgnorePointer(
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: label,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          style: AppTextStyles.bodySmall,
        ),
      ),
    );
  }
}
