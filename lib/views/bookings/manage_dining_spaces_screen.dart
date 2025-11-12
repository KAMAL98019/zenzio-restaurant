import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:zenzio_restaurant/core/constant/appcolors.dart';
import 'package:zenzio_restaurant/models/booking.dart';
import 'package:zenzio_restaurant/models/dining_space.dart';
import 'package:zenzio_restaurant/views/bookings/add_dining_area_screen.dart';
import '../../core/theme/text_styles.dart';
import '../../viewmodels/booking_viewmodel.dart';
import '../../widgets/custom_appbar.dart';

class ManageDiningSpacesScreen extends StatefulWidget {
  const ManageDiningSpacesScreen({Key? key}) : super(key: key);

  @override
  State<ManageDiningSpacesScreen> createState() => _ManageDiningSpacesScreenState();
}

class _ManageDiningSpacesScreenState extends State<ManageDiningSpacesScreen> {
  final _capacityController = TextEditingController();
  bool _acceptBookings = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final viewModel = context.read<BookingViewModel>();
      viewModel.loadDiningSpaces();
      _capacityController.text = viewModel.getTotalSeatingCapacity().toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: const CustomAppBar(title: 'Manage Dining Spaces'),
      body: Consumer<BookingViewModel>(
        builder: (context, viewModel, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Total Seating Capacity Section
                _buildSection(
                  title: 'Total Seating Capacity',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Restaurant Capacity (Seats)',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _capacityController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          hintText: 'e.g., 150',
                          filled: true,
                          fillColor: AppColors.background,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Accept Dining Bookings',
                            style: AppTextStyles.bodyMedium,
                          ),
                          Switch(
                            value: _acceptBookings,
                            onChanged: (value) {
                              setState(() => _acceptBookings = value);
                            },
                            activeColor: AppColors.primary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Dining Areas Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Dining Areas', style: AppTextStyles.h2),
                  ],
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddDiningAreaScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Add New Area'),
                  ),
                ),

                const SizedBox(height: 16),

                // Dining Areas List
                if (viewModel.diningSpaces.isEmpty)
                  _buildEmptyAreas()
                else
                  ...viewModel.diningSpaces.map(
                    (space) => _DiningAreaCard(
                      diningSpace: space,
                      onEdit: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddDiningAreaScreen(
                              diningSpace: space,
                            ),
                          ),
                        );
                      },
                      onDelete: () {
                        if (space.id != null) {
                          _showDeleteDialog(context, space.id!, viewModel);
                        }
                      },
                    ),
                  ),

                const SizedBox(height: 24),

                // Recurring Events/Closures Section (Placeholder)
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     Text('Recurring Events/Closures', style: AppTextStyles.h2),
                //   ],
                // ),
                const SizedBox(height: 16),

                // SizedBox(
                //   width: double.infinity,
                //   child: ElevatedButton(
                //     onPressed: () {
                //       // Navigate to add event screen
                //     },
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: AppColors.primary,
                //       padding: const EdgeInsets.symmetric(vertical: 16),
                //     ),
                //     child: const Text('Add New Event/Closure'),
                //   ),
                // ),

                const SizedBox(height: 16),

                // Example Events (Mock Data)
                // _EventCard(
                //   title: 'Live Music Night',
                //   subtitle: 'Every Friday 7-9 PM',
                //   description: 'All Areas',
                //   onEdit: () {},
                //   onDelete: () {},
                // ),

                // const SizedBox(height: 12),

                // _EventCard(
                //   title: 'Private Party',
                //   subtitle: 'Dec 24 Full Day',
                //   description: 'Patio Only',
                //   onEdit: () {},
                //   onDelete: () {},
                // ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Text(title, style: AppTextStyles.h2),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildEmptyAreas() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.event_seat,
              size: 48,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 8),
            Text(
              'No dining areas added yet',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    String id,
    BookingViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Dining Area'),
        content: const Text('Are you sure you want to delete this dining area?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await viewModel.deleteDiningSpace(id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _capacityController.dispose();
    super.dispose();
  }
}

class _DiningAreaCard extends StatelessWidget {
  final DiningSpace diningSpace;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _DiningAreaCard({
    required this.diningSpace,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  diningSpace.areaName,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${diningSpace.seatingCapacity} seats',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.primary),
            onPressed: onEdit,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.delete, color: AppColors.error),
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _EventCard({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: AppColors.primary),
                    onPressed: onEdit,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.delete, color: AppColors.error),
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
