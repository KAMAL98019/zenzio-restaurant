import 'package:flutter/material.dart';
import 'package:zenzio_restaurant/core/constant/appcolors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNotificationSection('Today', [
              _buildNotificationItem(
                'Your order has been delivered!',
                'Your order from Burger Kingdom has been delivered. Enjoy your meal!',
                '10:30 AM',
                isNew: true,
              ),
              _buildNotificationItem(
                'Order confirmed',
                'Your order #ORD-28764 has been confirmed and is being prepared.',
                '09:15 AM',
                isNew: true,
              ),
              _buildNotificationItem(
                'Special offer for you!',
                'Get 20% OFF on your next order from Pizza Paradise. Valid today only!',
                '08:23 AM',
              ),
            ]),
            _buildNotificationSection('Yesterday', [
              _buildNotificationItem(
                'Your reservation is confirmed',
                'Your table for 2 at Urban Bistro has been confirmed for tomorrow at 7:30 PM.',
                '19:45 PM',
              ),
              _buildNotificationItem(
                'Rate your experience',
                'How was your food from Sushi Master? Rate your experience and help others.',
                '14:12 PM',
              ),
            ]),
            _buildNotificationSection('Earlier This Week', [
              _buildNotificationItem(
                'Delivery person assigned',
                'Michael S. will be delivering your order from Taco Fiesta.',
                'Mon, 10:30 AM',
              ),
              _buildNotificationItem(
                'Payment successful',
                'Your payment of \$35.71 for order #ORD-27654 was successful.',
                'Mon, 09:15 AM',
              ),
              _buildNotificationItem(
                'New restaurant in your area!',
                'Discover Noodle House, now available for delivery in your area.',
                'Sun, 18:23 PM',
              ),
              _buildNotificationItem(
                'Weekend special offers',
                'Check out these exclusive weekend deals from your favorite restaurants.',
                'Sun, 17:05 PM',
              ),
            ]),
            const SizedBox(height: 24),
            // Delete example
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  const Text(
                    '> delete example',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.white),
                      onPressed: () {
                        // Handle delete action
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSection(String title, List<Widget> notifications) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        ...notifications,
      ],
    );
  }

  Widget _buildNotificationItem(
      String title, String subtitle, String time, {bool isNew = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isNew)
            Container(
              margin: const EdgeInsets.only(right: 8.0, top: 4.0),
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}