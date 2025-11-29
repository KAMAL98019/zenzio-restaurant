import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zenzio_restaurant/core/constant/appcolors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/constant/api_constant.dart';
import '../../viewmodels/offer_viewmodel.dart';
import '../../widgets/custom_appbar.dart';
import '../../models/offer.dart';
import 'create_offer_screen.dart';

class OfferManagementScreen extends StatefulWidget {
  const OfferManagementScreen({Key? key}) : super(key: key);

  @override
  State<OfferManagementScreen> createState() => _OfferManagementScreenState();
}

class _OfferManagementScreenState extends State<OfferManagementScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<OfferViewModel>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: const CustomAppBar(title: 'Offer Management'),
      body: Consumer<OfferViewModel>(
        builder: (context, viewModel, _) {
          return Column(
            children: [
              // Create New Offer Button
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChangeNotifierProvider.value(
                            value: viewModel,
                            child: const CreateOfferScreen(),
                          ),
                        ),
                      );
                      // Refresh offers after returning
                      viewModel.loadOffers();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Create New Offer',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Offers List
              Expanded(
                child: viewModel.isLoading && viewModel.offers.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : viewModel.offers.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: () => viewModel.loadOffers(),
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: viewModel.offers.length,
                              itemBuilder: (context, index) {
                                final offer = viewModel.offers[index];
                                return _OfferCard(
                                  offer: offer,
                                  viewModel: viewModel,
                                  onDelete: () => _deleteOffer(context, offer.id!, viewModel),
                                  onEdit: () => _editOffer(context, offer, viewModel),
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

  Future<void> _editOffer(BuildContext context, Offer offer, OfferViewModel viewModel) async {
    print('Editing offer: ${offer.id}');
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: viewModel,
          child: CreateOfferScreen(offer: offer),
        ),
      ),
    );
  }

  void _deleteOffer(BuildContext context, String id, OfferViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Offer'),
        content: const Text('Are you sure you want to delete this offer?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Delete without waiting for response
              viewModel.deleteOffer(id);
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_offer,
            size: 80,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 16),
          Text(
            'No offers created yet',
            style: AppTextStyles.h3.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first offer to attract customers',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
          ),
        ],
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  final Offer offer;
  final OfferViewModel viewModel;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _OfferCard({
    required this.offer,
    required this.viewModel,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Offer Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: (offer.offerImage != null && offer.offerImage!.isNotEmpty)
                  ? Image.network(
                      '${ApiConstants.baseUrl}/${offer.offerImage!}',
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholderImage();
                      },
                    )
                  : _buildPlaceholderImage(),
            ),
            const SizedBox(width: 12),

            // Offer Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          offer.title,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      _StatusBadge(offer: offer),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    offer.getDiscountDisplay(),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (offer.description != null && offer.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      offer.description!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    offer.getValidityDisplay(),
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Actions Column
            Column(
              children: [
                // Edit Button
                IconButton(
                  icon: const Icon(Icons.edit, color: AppColors.primary, size: 20),
                  onPressed: onEdit,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),

                const SizedBox(height: 8),

                // Delete Button
                IconButton(
                  icon: const Icon(Icons.delete, color: AppColors.error, size: 20),
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.local_offer,
        color: AppColors.textHint,
        size: 40,
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final Offer offer;

  const _StatusBadge({required this.offer});

  @override
  Widget build(BuildContext context) {
    String status;
    Color backgroundColor;
    Color textColor;

    if (offer.isActive()) {
      status = 'Active';
      backgroundColor = AppColors.success.withOpacity(0.2);
      textColor = AppColors.success;
    } else if (offer.isPending()) {
      status = 'Pending';
      backgroundColor = AppColors.warning.withOpacity(0.2);
      textColor = AppColors.warning;
    } else if (offer.isUpcoming()) {
      status = 'Upcoming';
      backgroundColor = AppColors.info.withOpacity(0.2); // Assuming AppColors.info exists or define a new color
      textColor = AppColors.info; // Assuming AppColors.info exists or define a new color
    }
    else {
      status = 'Expired';
      backgroundColor = AppColors.textSecondary.withOpacity(0.2);
      textColor = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: AppTextStyles.caption.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
