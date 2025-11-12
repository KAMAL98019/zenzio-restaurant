import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zenzio_restaurant/core/constant/appcolors.dart';
import '../../core/theme/text_styles.dart';
import '../../viewmodels/booking_viewmodel.dart';
import '../../widgets/custom_appbar.dart';

class BookingDetailsScreen extends StatelessWidget {
  final String bookingId;

  const BookingDetailsScreen({Key? key, required this.bookingId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: CustomAppBar(title: 'Booking #$bookingId'),
      body: Consumer<BookingViewModel>(
        builder: (context, viewModel, _) {
          final booking = viewModel.getBookingById(bookingId);

          if (booking == null) {
            return const Center(child: Text('Booking not found'));
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Header
                if (booking.status == 'Confirmed' || booking.status == 'Seated')
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    color: booking.status == 'Confirmed'
                        ? AppColors.success
                        : AppColors.info,
                    child: Text(
                      'BOOKING ${booking.status.toUpperCase()}',
                      style: AppTextStyles.h2.copyWith(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),

                const SizedBox(height: 16),

                // Customer Details
                _buildSection(
                  context,
                  title: '',
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.border,
                        child: Text(
                          booking.customerName[0].toUpperCase(),
                          style: AppTextStyles.h2,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking.customerName,
                              style: AppTextStyles.h3,
                            ),
                            Text(
                              booking.customerPhone,
                              style: AppTextStyles.bodyMedium.copyWith(
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

                // Booking Details
                _buildSection(
                  context,
                  title: 'Booking Details',
                  child: Column(
                    children: [
                      _buildDetailRow(
                        Icons.calendar_today,
                        booking.getFormattedDate(),
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        Icons.access_time,
                        booking.bookingTime,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        Icons.people,
                        '${booking.guests} people',
                      ),
                      if (booking.specialRequests != null &&
                          booking.specialRequests!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Special Requests:',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.scaffoldBackground,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            booking.specialRequests!,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Table Allocation
                if (booking.tableNumber != null || booking.status == 'Confirmed')
                  _buildSection(
                    context,
                    title: 'Table Allocation',
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              booking.tableNumber ?? 'Not assigned',
                              style: AppTextStyles.bodyLarge,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.grid_view, color: AppColors.primary),
                          onPressed: () {},
                          style: IconButton.styleFrom(
                            side: const BorderSide(color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                // Action Buttons
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildActionButtons(context, booking, viewModel),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(BuildContext context,
      {required String title, required Widget child}) {
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
          if (title.isNotEmpty) ...[
            Text(title, style: AppTextStyles.h3),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Text(text, style: AppTextStyles.bodyMedium),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    booking,
    BookingViewModel viewModel,
  ) {
    switch (booking.status) {
      case 'Confirmed':
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final success = await viewModel.markAsSeated(booking.id);
                  if (success && context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: const Text('Mark as Seated'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  final success = await viewModel.cancelBooking(booking.id);
                  if (success && context.mounted) {
                    Navigator.pop(context);
                  }
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
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                ),
                child: const Text('Send Reminder SMS'),
              ),
            ),
          ],
        );

      case 'Seated':
        return Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Customer is currently dining',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.info,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
