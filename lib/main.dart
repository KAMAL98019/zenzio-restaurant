import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zenzio_restaurant/services/offer_service.dart';
import 'package:zenzio_restaurant/viewmodels/booking_viewmodel.dart';
import 'package:zenzio_restaurant/viewmodels/menu_viewmodel.dart';
import 'package:zenzio_restaurant/viewmodels/offer_viewmodel.dart';
import 'package:zenzio_restaurant/viewmodels/registration_viewmodel.dart';
import 'package:zenzio_restaurant/viewmodels/analytics_viewmodel.dart';

import 'core/theme/app_theme.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'viewmodels/dashboard_viewmodel.dart';
import 'viewmodels/order_viewmodel.dart';
import 'views/login/login_screen.dart';
import 'views/dashboard/dashboard_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize API service
  ApiService().initialize();

  // Lock orientation to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Get restaurant ID from SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final restaurantId = prefs.getString('restaurant_id');

  // Run app with MultiProvider for multiple ViewModels
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => DashboardViewModel()..initialize(),
        ),
        ChangeNotifierProvider(create: (_) => OrderViewModel()..initialize()),
        ChangeNotifierProvider(create: (_) => MenuViewModel()..initialize()),
        ChangeNotifierProvider(create: (_) => BookingViewModel()..initialize()),
        ChangeNotifierProvider(
          create: (_) => AnalyticsViewModel()..loadAnalytics(),
        ),
        ChangeNotifierProvider(create: (_) => OfferViewModel()..initialize()),
        ChangeNotifierProvider(
          create: (_) {
            final viewModel = RegistrationViewModel();
            // Initialize for edit mode if restaurant ID exists
            if (restaurantId != null && restaurantId.isNotEmpty) {
              viewModel.initializeForEdit(restaurantId);
            }
            return viewModel;
          },
        ),
      ],
      child: const ZenzioPartnerApp(),
    ),
  );
}

class ZenzioPartnerApp extends StatelessWidget {
  const ZenzioPartnerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Zenzio Partner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 600), _handleStartup);
  }

  /// ✅ Step 1: Handle permissions and auth check
  Future<void> _handleStartup() async {
    try {
      await _requestPermissions();
      await _navigateAfterAuth();
    } catch (e) {
      debugPrint("❌ Startup error: $e");
      _navigateTo(const LoginScreen());
    }
  }

  /// ✅ Step 2: Request location, camera, and photo permissions once
  Future<void> _requestPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    final requested = prefs.getBool('permissionsRequested') ?? false;

    if (!requested) {
      final statuses = await [
        Permission.location,
        Permission.camera,
        Permission.photos, // iOS / Android 13+
        Permission.storage, // Android <13
        Permission.mediaLibrary, // macOS
        Permission.photosAddOnly, // iOS add-only
      ].request();

      // If permanently denied, open app settings
      if (statuses.values.any((s) => s.isPermanentlyDenied)) {
        await openAppSettings();
      }

      await prefs.setBool('permissionsRequested', true);
    }
  }

  /// ✅ Step 3: Navigate based on login status
  Future<void> _navigateAfterAuth() async {
    bool isLoggedIn = false;

    try {
      isLoggedIn = await _authService.isLoggedIn().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          debugPrint("⚠️ Auth check timed out — redirecting to login...");
          return false;
        },
      );
    } catch (e) {
      debugPrint("AuthService error: $e");
    }

    if (!mounted) return;

    await Future.delayed(const Duration(milliseconds: 400));

    _navigateTo(isLoggedIn ? const DashboardScreen() : const LoginScreen());
  }

  /// Navigate safely
  void _navigateTo(Widget screen) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/zenzioicon.png',
              height: 120,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),
            const Text(
              "Zenzio Restaurant Partner",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(color: Color(0xFFE53935)),
          ],
        ),
      ),
    );
  }
}
