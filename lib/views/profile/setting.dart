import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zenzio_restaurant/core/constant/appcolors.dart';
import 'package:zenzio_restaurant/models/restaurant.dart';
import 'package:zenzio_restaurant/services/restaurant_service.dart';
import 'package:zenzio_restaurant/views/login/login_screen.dart';
import 'dart:convert'; // 👈 for Base64 decoding
import 'package:zenzio_restaurant/views/profile/edit_restaurant_profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final RestaurantService _restaurantService = RestaurantService();
  Restaurant? _restaurant;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRestaurantData();
  }

  Future<void> _loadRestaurantData() async {
    final prefs = await SharedPreferences.getInstance();
    final restaurantId = prefs.getString('restaurant_id');
    if (restaurantId != null) {
      final response = await _restaurantService.getRestaurantById(restaurantId);
      debugPrint(
        "Restaurant fetch response: ${response.success}, ${response.message}",
      );
      if (response.success && response.data != null) {
        setState(() {
          _restaurant = response.data;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  /// ✅ Helper: choose correct ImageProvider based on logo type
  ImageProvider _getLogoImage(String? logo) {
    if (logo == null || logo.isEmpty) {
      return const AssetImage('assets/images/restaurant_logo.png');
    }




    // Full URL
    return NetworkImage(logo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ Restaurant Profile Section
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: _getLogoImage(_restaurant?.restLogo),
                              fit: BoxFit.cover,
                            ),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _restaurant?.restaurantName ?? 'Restaurant Name',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const EditRestaurantProfileScreen(),
                                    ),
                                  );
                                },
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.edit,
                                      size: 14,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Edit Profile',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Operational Settings Section
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Text(
                      'OPERATIONAL SETTINGS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  _SettingsMenuItem(
                    icon: Icons.access_time,
                    iconColor: AppColors.primary,
                    title: 'Manage Operational Hours',
                    onTap: () {},
                  ),
                  _SettingsMenuItem(
                    icon: Icons.location_on_outlined,
                    iconColor: AppColors.primary,
                    title: 'Delivery Radius/Areas',
                    onTap: () {},
                  ),
                  _SettingsMenuItem(
                    icon: Icons.reviews_outlined,
                    iconColor: AppColors.primary,
                    title: 'Customer Review',
                    onTap: () {},
                  ),
                  _SettingsMenuItem(
                    icon: Icons.notifications_none,
                    iconColor: AppColors.primary,
                    title: 'Notifications & Alerts',
                    onTap: () {},
                  ),
                  _SettingsMenuItem(
                    icon: Icons.account_balance_wallet_outlined,
                    iconColor: AppColors.primary,
                    title: 'Bank Details',
                    onTap: () {},
                  ),
                  _SettingsMenuItem(
                    icon: Icons.card_membership_outlined,
                    iconColor: AppColors.primary,
                    title: 'My Subscription',
                    onTap: () {},
                  ),
                  _SettingsMenuItem(
                    icon: Icons.lock_outline,
                    iconColor: AppColors.primary,
                    title: 'Password & Security',
                    onTap: () {},
                  ),
                  _SettingsMenuItem(
                    icon: Icons.help_outline,
                    iconColor: AppColors.primary,
                    title: 'Help & Support',
                    onTap: () {},
                  ),
                  _SettingsMenuItem(
                    icon: Icons.logout,
                    iconColor: AppColors.primary,
                    title: 'Logout',
                    showArrow: false,
                    onTap: () => _showLogoutDialog(context),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: Text('Logout', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}

class _SettingsMenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final bool showArrow;
  final VoidCallback onTap;

  const _SettingsMenuItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.showArrow = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        trailing: showArrow
            ? Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 24)
            : null,
      ),
    );
  }
}
