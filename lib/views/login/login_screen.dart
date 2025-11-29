import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zenzio_restaurant/core/constant/appcolors.dart';
import '../../core/theme/text_styles.dart';
import '../../viewmodels/login_viewmodel.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../registration/registration_screen.dart';
import '../forgot_password/forgot_password_screen.dart';
import '../dashboard/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Consumer<LoginViewModel>(
            builder: (context, viewModel, _) {
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Logo Section
                      Column(
                        children: [
                          Image.asset(
                            'assets/images/zenzioicon.png',
                            height: 90,
                            errorBuilder: (context, error, stackTrace) =>
                                const Text(
                                  'Zenzio',
                                  style: TextStyle(
                                    fontSize: 42,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Welcome Back!",
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Login to continue managing your restaurant",
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 36),

                      // Login Card
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            // TabBar
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.border,
                                ),
                              ),
                              child: TabBar(
                                controller: _tabController,
                                indicator: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                labelColor: Colors.white,
                                unselectedLabelColor: AppColors.textSecondary,
                                labelStyle: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                tabs: const [
                                  Tab(text: 'Email Login'),
                                  Tab(text: 'OTP Login'),
                                ],
                                onTap: (index) {
                                  viewModel.emailController.clear();
                                  viewModel.passwordController.clear();
                                  viewModel.otpController.clear();
                                  viewModel.toggleOtpFieldVisibility(
                                    index == 1,
                                  );
                                },
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Tab Views
                            SizedBox(
                              height: 400, // Increased height to prevent overflow
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  _buildEmailPasswordLogin(context, viewModel),
                                  _buildOtpLogin(context, viewModel),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Register Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'New to Zenzio? ',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RegistrationScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Register Your Restaurant',
                              style: AppTextStyles.link.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // EMAIL LOGIN
  Widget _buildEmailPasswordLogin(
    BuildContext context,
    LoginViewModel viewModel,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: viewModel.emailController,
          label: 'Email Address',
          hint: 'Enter your registered email',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: viewModel.passwordController,
          label: 'Password',
          hint: 'Enter your password',
          obscureText: viewModel.obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              viewModel.obscurePassword
                  ? Icons.visibility_off
                  : Icons.visibility,
              color: AppColors.textSecondary,
            ),
            onPressed: viewModel.togglePasswordVisibility,
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
              );
            },
            child: Text('Forgot Password?', style: AppTextStyles.link),
          ),
        ),
        const SizedBox(height: 24),
        CustomButton(
          text: 'Login',
          onPressed: () async {
            final success = await viewModel.login();
            if (success && context.mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const DashboardScreen()),
              );
            }
          },
          isLoading: viewModel.isLoading,
        ),
      ],
    );
  }

  // OTP LOGIN
  Widget _buildOtpLogin(BuildContext context, LoginViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: viewModel.emailController, // Reused for mobile number
          label: 'Mobile Number',
          hint: 'Enter your registered mobile number',
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        CustomButton(
          text: 'Send OTP',
          onPressed: () => viewModel.sendOtpForLogin(),
          isLoading: viewModel.isLoading,
        ),
        if (viewModel.showOtpField) ...[
          const SizedBox(height: 16),
          CustomTextField(
            controller: viewModel.otpController,
            label: 'OTP',
            hint: 'Enter the OTP sent to your number',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => viewModel.sendOtpForLogin(),
              child: Text('Resend OTP', style: AppTextStyles.link),
            ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Verify OTP & Login',
            onPressed: () async {
              final success = await viewModel.verifyOtpAndLogin();
              if (success && context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const DashboardScreen()),
                );
              }
            },
            isLoading: viewModel.isLoading,
          ),
        ],
      ],
    );
  }
}
