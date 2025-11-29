import 'package:zenzio_restaurant/core/constant/api_constant.dart';
// screens/order_tracking_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'delivery_tracking_screen.dart';

class OrderTrackingScreen extends StatelessWidget {
  final String orderId;

  const OrderTrackingScreen({Key? key, required this.orderId}) : super(key: key);

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Tracking',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              orderId,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Timeline
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildTimelineItem('Order Placed', true, true),
                  _buildTimelineItem('Restaurant Confirmed', true, true),
                  _buildTimelineItem('Preparing', true, true),
                  _buildTimelineItem('Ready for Pickup', true, true),
                  _buildTimelineItem('Waiting for Delivery Partner', true, false),
                  _buildTimelineItem('Out for Delivery', false, false),
                  _buildTimelineItem('Delivered', false, false),
                ],
              ),
            ),
            // Message
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Waiting for a Delivery Partner to Accept Your Order...',
                      style: TextStyle(color: Colors.grey[700], fontSize: 15),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.more_horiz, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Map
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 200,
                  child: Stack(
                    children: [
                      FlutterMap(
                        options: MapOptions(
                          initialCenter: LatLng(40.7128, -74.0060),
                          initialZoom: 13,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: ApiConstants.mapTileUrl,
                            subdomains: ApiConstants.mapTileSubdomains,
                            userAgentPackageName: 'com.example.app',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: LatLng(40.7128, -74.0060),
                                width: 60,
                                height: 60,
                                child: const Icon(
                                  Icons.delivery_dining,
                                  color: Colors.red,
                                  size: 40,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Positioned(
                        bottom: 16,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.delivery_dining, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Locating a delivery partner near you...',
                                  style: TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Estimated Delivery
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Estimated Delivery:',
                    style: TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '6:45 - 7:00 PM',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.help_outline, color: Colors.red),
                      label: const Text(
                        'Need Help?',
                        style: TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(String title, bool isCompleted, bool isActive) {
    return Row(
      children: [
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isCompleted ? Colors.red : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted ? Colors.red : Colors.grey[300]!,
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : isActive
                      ? Container(
                          margin: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        )
                      : null,
            ),
            if (title != 'Delivered')
              Container(
                width: 2,
                height: 40,
                color: isCompleted ? Colors.red : Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              color: isCompleted || isActive ? Colors.red : Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}
