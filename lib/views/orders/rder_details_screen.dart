import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:zenzio_restaurant/core/constant/appcolors.dart';
import '../../core/theme/text_styles.dart';
import '../../viewmodels/order_viewmodel.dart';
import '../../widgets/custom_appbar.dart';
import '../../models/order.dart';
import 'track_order_screen.dart';

class OrderDetailsScreen extends StatelessWidget {
  final String orderId;

  const OrderDetailsScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: CustomAppBar(title: 'Order #$orderId'),
      body: Consumer<OrderViewModel>(
        builder: (context, viewModel, _) {
          final order = viewModel.getOrderById(orderId);

          if (order == null) {
            return const Center(child: Text('Order not found'));
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Status Header
                if (order.status == 'Preparing' || order.status == 'Ready')
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: _getStatusColor(order.status),
                    child: Column(
                      children: [
                        Text(
                          order.status == 'Preparing'
                              ? 'ORDER ACCEPTED'
                              : 'ORDER READY',
                          style: AppTextStyles.h2.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        _buildOrderTimeline(order),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                // Customer Details
                _buildSection(
                  title: 'Customer Details',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            order.userName ?? 'Customer',
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.call, color: AppColors.primary),
                            label: const Text('Call Customer'),
                          ),
                        ],
                      ),
                      if (order.userPhone != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          order.userPhone!,
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                      if (order.userAddress != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          order.userAddress!,
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                      if (order.latitude != null && order.longitude != null) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 150,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: FlutterMap(
                              options: MapOptions(
                                initialCenter: LatLng(order.latitude!, order.longitude!),
                                initialZoom: 15,
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: LatLng(order.latitude!, order.longitude!),
                                      width: 40,
                                      height: 40,
                                      child: const Icon(
                                        Icons.location_pin,
                                        color: AppColors.primary,
                                        size: 40,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Items Ordered
                _buildSection(
                  title: 'Items Ordered',
                  child: Column(
                    children: order.items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${item.quantity}x',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (item.customizations != null &&
                                      item.customizations!.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    ...item.customizations!.map(
                                      (custom) => Text(
                                        '• $custom',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Text(
                              '₹${item.price.toStringAsFixed(2)}',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Estimated Preparation Time
                if (order.status == 'New' || order.status == 'Preparing')
                  _buildSection(
                    title: 'Estimated Preparation Time',
                    child: _EstimatedTimeSelector(order: order),
                  ),

                // Delivery Partner Details (if available)
                if (order.deliveryPartner != null)
                  _buildSection(
                    title: 'Delivery Partner Details',
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            order.deliveryPartner!.name[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.deliveryPartner!.name,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                order.deliveryPartner!.phone,
                                style: AppTextStyles.bodyMedium,
                              ),
                              if (order.deliveryPartner!.vehicleType != null)
                                Text(
                                  '🛵 ${order.deliveryPartner!.vehicleType}',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.call, color: Colors.white),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Bill Summary
                _buildSection(
                  title: 'Bill Summary',
                  child: Column(
                    children: [
                      _buildBillRow('Item Total', order.itemTotal),
                      _buildBillRow('Delivery Charge', order.deliveryCharge),
                      _buildBillRow('Taxes', order.taxes),
                      const Divider(height: 24),
                      _buildBillRow(
                        'Grand Total',
                        order.grandTotal,
                        isTotal: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Action Buttons
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildActionButtons(context, order, viewModel),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildOrderTimeline(Order order) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _TimelineItem(
          label: 'Order Time:',
          value: _formatDateTime(order.createdAt),
        ),
        const SizedBox(width: 24),
        _TimelineItem(
          label: 'Est. Delivery:',
          value: order.estimatedDelivery != null
              ? _formatDateTime(order.estimatedDelivery!)
              : 'N/A',
        ),
      ],
    );
  }

  Widget _buildBillRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)
                : AppTextStyles.bodyMedium,
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: isTotal
                ? AppTextStyles.h3.copyWith(color: AppColors.primary)
                : AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    Order order,
    OrderViewModel viewModel,
  ) {
    switch (order.status) {
      case 'New':
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showAcceptDialog(context, order.id),
                child: const Text('Accept Order'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _showRejectDialog(context, order.id),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error),
                ),
                child: Text(
                  'Reject Order',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ),
          ],
        );

      case 'Preparing':
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                ),
                child: const Text('Waiting for the Delivery Partner'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                child: const Text('Reject Order'),
              ),
            ),
          ],
        );

      case 'Ready':
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TrackOrderScreen(orderId: order.id),
                    ),
                  );
                },
                child: const Text('Track Delivery Partner'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.print, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('Print KOT'),
                  ],
                ),
              ),
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }

  void _showAcceptDialog(BuildContext context, String orderId) {
    int selectedTime = 30;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Estimated Preparation Time'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                value: selectedTime,
                decoration: const InputDecoration(
                  labelText: 'Select estimated timing',
                ),
                items: [10, 15, 30, 40, 45, 60].map((time) {
                  return DropdownMenuItem(
                    value: time,
                    child: Text('$time Min'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedTime = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: [10, 15, 30].map((time) {
                  return ChoiceChip(
                    label: Text('$time min'),
                    selected: selectedTime == time,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => selectedTime = time);
                      }
                    },
                    backgroundColor: AppColors.warning,
                    selectedColor: AppColors.warning,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              const Text(
                'Required to accept order',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                final success = await context
                    .read<OrderViewModel>()
                    .acceptOrder(orderId, selectedTime);
                if (success && context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Accept Order'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRejectDialog(BuildContext context, String orderId) {
    final reasons = [
      'Out of stock',
      'Restaurant too busy',
      'Unable to prepare',
      'Other',
    ];
    String selectedReason = reasons[0];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Reject Order'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please select a reason:'),
              const SizedBox(height: 16),
              ...reasons.map((reason) {
                return RadioListTile<String>(
                  title: Text(reason),
                  value: reason,
                  groupValue: selectedReason,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedReason = value);
                    }
                  },
                );
              }).toList(),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                final success = await context
                    .read<OrderViewModel>()
                    .rejectOrder(orderId, selectedReason);
                if (success && context.mounted) {
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              child: const Text('Reject Order'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} • ${_formatTime(dateTime)}';
  }

  String _formatDate(DateTime dateTime) {
    return 'May ${dateTime.day}, ${dateTime.year}';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} $period';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Preparing':
        return AppColors.primary;
      case 'Ready':
        return AppColors.success;
      default:
        return AppColors.primary;
    }
  }
}

class _TimelineItem extends StatelessWidget {
  final String label;
  final String value;

  const _TimelineItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _EstimatedTimeSelector extends StatefulWidget {
  final Order order;

  const _EstimatedTimeSelector({required this.order});

  @override
  State<_EstimatedTimeSelector> createState() => _EstimatedTimeSelectorState();
}

class _EstimatedTimeSelectorState extends State<_EstimatedTimeSelector> {
  int selectedTime = 40;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField<int>(
          value: selectedTime,
          decoration: const InputDecoration(
            labelText: 'Select estimated timing',
          ),
          items: [10, 15, 30, 40, 45, 60].map((time) {
            return DropdownMenuItem(
              value: time,
              child: Text('$time Min'),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => selectedTime = value);
            }
          },
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          children: [10, 15, 30].map((time) {
            return ChoiceChip(
              label: Text('$time min'),
              selected: selectedTime == time,
              onSelected: (selected) {
                if (selected) {
                  setState(() => selectedTime = time);
                }
              },
              backgroundColor: AppColors.warning,
              selectedColor: AppColors.warning,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        const Text(
          'Required to accept order',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
