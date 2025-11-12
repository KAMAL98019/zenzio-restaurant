import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zenzio_restaurant/core/constant/appcolors.dart';
import 'package:zenzio_restaurant/views/orders/rder_details_screen.dart';
import '../../core/theme/text_styles.dart';
import '../../viewmodels/order_viewmodel.dart';
import '../../widgets/custom_appbar.dart';
import '../../models/order.dart';

class OrdersListScreen extends StatefulWidget {
  const OrdersListScreen({Key? key}) : super(key: key);

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<OrderViewModel>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: CustomAppBar(
        title: 'Orders',
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer<OrderViewModel>(
        builder: (context, viewModel, _) {
          return Column(
            children: [
              // Status Filter Tabs
              _buildStatusTabs(viewModel),
              
              // Orders List
              Expanded(
                child: viewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : viewModel.orders.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: () => viewModel.loadOrders(),
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: viewModel.orders.length,
                              itemBuilder: (context, index) {
                                final order = viewModel.orders[index];
                                return _OrderCard(
                                  order: order,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => OrderDetailsScreen(
                                          orderId: order.id,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusTabs(OrderViewModel viewModel) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: viewModel.orderStatuses.length,
        itemBuilder: (context, index) {
          final status = viewModel.orderStatuses[index];
          final isSelected = viewModel.selectedStatus == status;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(status),
              selected: isSelected,
              onSelected: (_) => viewModel.filterByStatus(status),
              backgroundColor: AppColors.background,
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 80,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 16),
          Text(
            'No orders found',
            style: AppTextStyles.h3.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Orders will appear here',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;

  const _OrderCard({
    required this.order,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '#${order.orderId}',
                    style: AppTextStyles.h3,
                  ),
                  Text(
                    '₹${order.grandTotal.toStringAsFixed(0)}',
                    style: AppTextStyles.h3.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Placed: ${_formatTime(order.createdAt)}',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 12),

              // Customer Info
              if (order.userName != null) ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${order.userName} - ${order.userPhone ?? ''}',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),
                    if (order.userPhone != null)
                      IconButton(
                        icon: const Icon(Icons.call, color: AppColors.primary),
                        onPressed: () {},
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
              ],

              // Order Items
              Text(
                _getItemsSummary(order.items),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Status Badge and Actions
              Row(
                children: [
                  _StatusBadge(status: order.status),
                  const Spacer(),
                  TextButton(
                    onPressed: onTap,
                    child: Row(
                      children: const [
                        Text('View Details'),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward, size: 16),
                      ],
                    ),
                  ),
                ],
              ),

              // Action Buttons based on status
              const SizedBox(height: 8),
              _buildActionButtons(context, order),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Order order) {
    final viewModel = context.read<OrderViewModel>();

    switch (order.status) {
      case 'New':
        return Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _showAcceptDialog(context, order.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text('Accept Order'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
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
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
            ),
            child: const Text('Waiting for the Delivery Partner'),
          ),
        );

      case 'Ready':
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              viewModel.updateOrderStatus(order.id, 'DISPATCHED');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Mark as Dispatched'),
          ),
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
              const Text(
                'Required to accept order',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
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
                await context.read<OrderViewModel>().acceptOrder(
                      orderId,
                      selectedTime,
                    );
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
                await context.read<OrderViewModel>().rejectOrder(
                      orderId,
                      selectedReason,
                    );
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

  String _getItemsSummary(List<OrderItem> items) {
    if (items.isEmpty) return 'No items';
    
    final summary = items.take(3).map((item) {
      return '${item.quantity}x ${item.name}';
    }).join(', ');

    if (items.length > 3) {
      return '$summary ...+${items.length - 3} more items';
    }
    return summary;
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} $period';
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case 'New':
        backgroundColor = AppColors.warning.withOpacity(0.2);
        textColor = AppColors.warning;
        break;
      case 'Preparing':
        backgroundColor = AppColors.info.withOpacity(0.2);
        textColor = AppColors.info;
        break;
      case 'Ready':
        backgroundColor = AppColors.success.withOpacity(0.2);
        textColor = AppColors.success;
        break;
      case 'Completed':
        backgroundColor = AppColors.success.withOpacity(0.2);
        textColor = AppColors.success;
        break;
      case 'Cancelled':
        backgroundColor = AppColors.error.withOpacity(0.2);
        textColor = AppColors.error;
        break;
      default:
        backgroundColor = AppColors.textHint.withOpacity(0.2);
        textColor = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: AppTextStyles.bodySmall.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
