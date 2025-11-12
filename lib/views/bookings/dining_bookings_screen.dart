import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:zenzio_restaurant/core/constant/appcolors.dart';
import '../../core/theme/text_styles.dart';
import '../../viewmodels/booking_viewmodel.dart';
import '../../widgets/custom_appbar.dart';
import '../../models/booking.dart';
import 'booking_details_screen.dart';
import 'manage_dining_spaces_screen.dart';

class DiningBookingsScreen extends StatefulWidget {
  const DiningBookingsScreen({Key? key}) : super(key: key);

  @override
  State<DiningBookingsScreen> createState() => _DiningBookingsScreenState();
}

class _DiningBookingsScreenState extends State<DiningBookingsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<BookingViewModel>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: CustomAppBar(
        title: 'Dining Bookings',
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer<BookingViewModel>(
        builder: (context, viewModel, _) {
          return Column(
            children: [
              // Date Selector
              _buildDateSelector(viewModel),

              // Manage Dining Spaces Button
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ManageDiningSpacesScreen(),
                        ),
                      );
                      // Reload dining spaces when returning from ManageDiningSpacesScreen
                      context.read<BookingViewModel>().loadDiningSpaces();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Manage Dining Spaces'),
                  ),
                ),
              ),

              // Status Filter Tabs
              _buildStatusTabs(viewModel),

              // Bookings List
              Expanded(
                child: viewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : viewModel.bookings.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: () => viewModel.loadBookings(),
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: viewModel.bookings.length,
                              itemBuilder: (context, index) {
                                final booking = viewModel.bookings[index];
                                return _BookingCard(
                                  booking: booking,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => BookingDetailsScreen(
                                          bookingId: booking.id,
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

  Widget _buildDateSelector(BookingViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              DateFormat('MMMM dd, yyyy').format(viewModel.selectedDate),
              style: AppTextStyles.bodyMedium,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today, color: AppColors.primary),
            onPressed: () => _selectDate(viewModel),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BookingViewModel viewModel) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: viewModel.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      viewModel.setSelectedDate(picked);
    }
  }

  Widget _buildStatusTabs(BookingViewModel viewModel) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: viewModel.bookingStatuses.length,
        itemBuilder: (context, index) {
          final status = viewModel.bookingStatuses[index];
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
            Icons.event_seat,
            size: 80,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 16),
          Text(
            'No bookings found',
            style: AppTextStyles.h3.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Bookings will appear here',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
          ),
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback onTap;

  const _BookingCard({
    required this.booking,
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
              // Booking Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '#${booking.bookingId}',
                    style: AppTextStyles.h3,
                  ),
                  _StatusBadge(status: booking.status),
                ],
              ),
              const SizedBox(height: 12),

              // Customer Info
              Text(
                booking.customerName,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                booking.customerPhone,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),

              // Booking Details
              Text(
                'Date: ${booking.getFormattedDate()}, ${booking.bookingTime}',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Guests: ${booking.guests}',
                style: AppTextStyles.bodyMedium,
              ),

              // Action Buttons
              if (booking.status == 'Pending') ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showAcceptDialog(context, booking.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        child: const Text('Accept Booking'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showRejectDialog(context, booking.id),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.error),
                        ),
                        child: Text(
                          'Reject Booking',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else if (booking.status == 'Confirmed') ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<BookingViewModel>().markAsSeated(booking.id);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        child: const Text('Mark as Seated'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _showCancelDialog(context, booking.id);
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.error),
                        ),
                        child: Text(
                          'Cancel Booking',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else if (booking.status == 'Seated') ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: onTap,
                  child: const Text('View Details'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showAcceptDialog(BuildContext context, String bookingId) {
    final tableController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accept Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: tableController,
              decoration: const InputDecoration(
                labelText: 'Table Number (Optional)',
                hintText: 'e.g., Table 12',
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
              await context.read<BookingViewModel>().acceptBooking(
                    bookingId,
                    tableNumber: tableController.text.isNotEmpty
                        ? tableController.text
                        : null,
                  );
            },
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, String bookingId) {
    final reasons = [
      'Fully booked',
      'Restaurant closed',
      'Special event',
      'Other',
    ];
    String selectedReason = reasons[0];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Reject Booking'),
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
                await context.read<BookingViewModel>().rejectBooking(
                      bookingId,
                      selectedReason,
                    );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              child: const Text('Reject'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context, String bookingId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<BookingViewModel>().cancelBooking(bookingId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
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
      case 'Pending':
        backgroundColor = AppColors.warning.withOpacity(0.2);
        textColor = AppColors.warning;
        break;
      case 'Confirmed':
        backgroundColor = AppColors.success.withOpacity(0.2);
        textColor = AppColors.success;
        break;
      case 'Seated':
        backgroundColor = AppColors.info.withOpacity(0.2);
        textColor = AppColors.info;
        break;
      case 'Completed':
        backgroundColor = AppColors.textSecondary.withOpacity(0.2);
        textColor = AppColors.textSecondary;
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
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
