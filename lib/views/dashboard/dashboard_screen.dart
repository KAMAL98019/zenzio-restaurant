import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zenzio_restaurant/core/constant/appcolors.dart';
import 'package:zenzio_restaurant/models/order.dart';
import 'package:zenzio_restaurant/models/booking.dart';
import 'package:zenzio_restaurant/viewmodels/booking_viewmodel.dart';
import 'package:zenzio_restaurant/viewmodels/menu_viewmodel.dart';
import 'package:zenzio_restaurant/viewmodels/offer_viewmodel.dart';
import 'package:zenzio_restaurant/viewmodels/order_viewmodel.dart';
import 'package:zenzio_restaurant/views/analytics/sales_analytics_screen.dart';
import 'package:zenzio_restaurant/views/bookings/dining_bookings_screen.dart';
import 'package:zenzio_restaurant/views/menu/menu_management_screen.dart';
import 'package:zenzio_restaurant/views/offers/create_offer_screen.dart';
import 'package:zenzio_restaurant/views/offers/offer_management_screen.dart';
import 'package:zenzio_restaurant/views/orders/orders_list_screen.dart';
import 'package:zenzio_restaurant/views/orders/orders_screen.dart';
import 'package:zenzio_restaurant/views/profile/setting.dart';
import '../../core/theme/text_styles.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
import '../login/login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isOnline = true; // Local state for toggle

  @override
  void initState() {
    super.initState();
    context.read<DashboardViewModel>().initialize();
    _checkTokens();
  }

  void _checkTokens() async {
    const String accessTokenKey = 'access_token';
    const String refreshTokenKey = 'refresh_token';
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString(accessTokenKey);
    final refreshToken = prefs.getString(refreshTokenKey);

    print('SharedPreferences check - Access Token: $accessToken');
    print('SharedPreferences check - Refresh Token: $refreshToken');
  }

  String _timeAgo(DateTime date) {
    final Duration diff = DateTime.now().difference(date);
    if (diff.inDays > 0) {
      return '${diff.inDays} days ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} hours ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  void _toggleOnlineStatus() {
    setState(() {
      _isOnline = !_isOnline;
    });

    // Show snackbar feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isOnline ? 'Restaurant is now ONLINE' : 'Restaurant is now OFFLINE',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: _isOnline ? AppColors.online : AppColors.offline,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: AppColors.background,
      ),
      drawer: _buildDrawer(context),
      body: Consumer<DashboardViewModel>(
        builder: (context, viewModel, _) {
          return SingleChildScrollView(
            child: Column(
              children: [
                // Online/Offline Toggle
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowColor,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isOnline ? 'Online' : 'Offline',
                            style: AppTextStyles.h3.copyWith(
                              color: _isOnline
                                  ? AppColors.online
                                  : AppColors.offline,
                            ),
                          ),
                          Text(
                            _isOnline
                                ? 'Accepting orders'
                                : 'Not accepting orders',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                      Switch(
                        value: _isOnline,
                        onChanged: (_) => _toggleOnlineStatus(),
                        activeColor: AppColors.online,
                      ),
                    ],
                  ),
                ),

                // Stats Cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'New Orders',
                          value: '12',
                          subtitle: '↑ 3% from last hour',
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _StatCard(
                          title: "Today's Sales",
                          value: '₹1,284',
                          subtitle: '↑ 15% from last',
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Pending Bookings',
                          value: '8',
                          subtitle: 'Need in 30 min',
                          color: AppColors.warning,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _StatCard(
                          title: 'Live Offers',
                          value: '3',
                          subtitle: '10 redemptions',
                          color: AppColors.info,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Current Orders
                _SectionHeader(title: 'Current Orders'),
                if (viewModel.currentOrders.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('No current orders.'),
                  )
                else
                  ...viewModel.currentOrders.map(
                    (order) => _OrderCard(
                      orderId: order.id,
                      amount: '₹${order.totalAmount.toStringAsFixed(2)}',
                      time: order.createdAt != null
                          ? _timeAgo(order.createdAt!)
                          : 'N/A',
                    ),
                  ),
                const SizedBox(height: 16),

                // Recent Activity
                _SectionHeader(title: 'Recent Activity'),
                if (viewModel.recentActivity.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('No recent activity.'),
                  )
                else
                  ...viewModel.recentActivity.map(
                    (order) => _ActivityCard(
                      orderId: order.id,
                      amount: '₹${order.totalAmount.toStringAsFixed(2)}',
                      time: order.createdAt != null
                          ? _timeAgo(order.createdAt!)
                          : 'N/A',
                    ),
                  ),
                const SizedBox(height: 24),

                // Quick Actions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _QuickActionButton(
                        icon: Icons.restaurant_menu,
                        label: 'Manage\nMenu',
                        color: AppColors.primary,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MenuManagementScreen(),
                            ),
                          );
                        },
                      ),
                      _QuickActionButton(
                        icon: Icons.local_offer,
                        label: 'Create\nOffer',
                        color: AppColors.primary,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CreateOfferScreen(),
                            ),
                          );
                        },
                      ),
                      _QuickActionButton(
                        icon: Icons.analytics,
                        label: 'View\nAnalytics',
                        color: AppColors.primary,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SalesAnalyticsScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/zenzioicon.png',
                  height: 60,
                  errorBuilder: (context, error, stackTrace) {
                    return const Text(
                      'Zenzio',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.receipt),
            title: const Text('Orders'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider(
                    create: (_) => OrderViewModel(),
                    child: const OrdersScreen(),
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.restaurant_menu),
            title: const Text('Menu Management'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider(
                    create: (_) => MenuViewModel(),
                    child: const MenuManagementScreen(),
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Dining Bookings'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider(
                    create: (_) => BookingViewModel(),
                    child: const DiningBookingsScreen(),
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.local_offer),
            title: const Text('Offer Management'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider(
                    create: (_) => OfferViewModel(),
                    child: const OfferManagementScreen(),
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('Sales & Analytics'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SalesAnalyticsScreen()),
              );
            },
          ),
          // ListTile(
          //   leading: const Icon(Icons.history),
          //   title: const Text('Order History'),
          //   onTap: () {},
          // ),
          // ListTile(
          //   leading: const Icon(Icons.star),
          //   title: const Text('Customer Reviews'),
          //   onTap: () {},
          // ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Profile & Settings'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text(
              'Logout',
              style: TextStyle(color: AppColors.error),
            ),
            onTap: () async {
              await context.read<DashboardViewModel>().logout(context);
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.bodySmall),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.h2.copyWith(color: color)),
          const SizedBox(height: 4),
          Text(subtitle, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(title, style: AppTextStyles.h3)],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final String orderId;
  final String amount;
  final String time;

  const _OrderCard({
    required this.orderId,
    required this.amount,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.shopping_bag, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'New order $orderId - $amount',
                  style: AppTextStyles.bodyMedium,
                ),
                Text(time, style: AppTextStyles.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final String orderId;
  final String amount;
  final String time;

  const _ActivityCard({
    required this.orderId,
    required this.amount,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.fastfood, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'New order $orderId - $amount',
                  style: AppTextStyles.bodyMedium,
                ),
                Text(time, style: AppTextStyles.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _QuickActionButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
