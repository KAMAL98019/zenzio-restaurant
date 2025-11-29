import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zenzio_restaurant/core/constant/appcolors.dart';
import '../../core/theme/text_styles.dart';
import '../../viewmodels/menu_viewmodel.dart';
import '../../widgets/custom_appbar.dart';
import '../../models/food_item.dart';
import 'add_dish_screen.dart';

class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({Key? key}) : super(key: key);

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  Map<String, bool> _expandedCategories = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<MenuViewModel>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: const CustomAppBar(title: 'Menu Management'),
      body: Consumer<MenuViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading && viewModel.foodItems.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final groupedItems = viewModel.groupedByCategory;

          return Column(
            children: [
              // Add New Dish Button
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AddDishScreen()),
                      );
                      // Refresh the menu items after returning from AddDishScreen
                      context.read<MenuViewModel>().loadFoodItems();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Add New Dish'),
                  ),
                ),
              ),

              // Categories List
              Expanded(
                child: groupedItems.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () async {
                          await viewModel.loadFoodItems();
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: groupedItems.length,
                          itemBuilder: (context, index) {
                            final category = groupedItems.keys.elementAt(index);
                            final items = groupedItems[category]!;
                            final isExpanded =
                                _expandedCategories[category] ?? true;

                            return _CategorySection(
                              category: category,
                              items: items,
                              isExpanded: isExpanded,
                              onToggle: () {
                                setState(() {
                                  _expandedCategories[category] = !isExpanded;
                                });
                              },
                              onEdit: () {
                                // Edit category
                              },
                              onDelete: () {
                                // Delete category
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_menu, size: 80, color: AppColors.textHint),
          const SizedBox(height: 16),
          Text(
            'No dishes added yet',
            style: AppTextStyles.h3.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first dish to get started',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
          ),
        ],
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final String category;
  final List<FoodItem> items;
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategorySection({
    required this.category,
    required this.items,
    required this.isExpanded,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        children: [
          // Category Header
          InkWell(
            onTap: onToggle,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(child: Text(category, style: AppTextStyles.h3)),
                  const SizedBox(width: 8),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),

          // Items List
          if (isExpanded)
            ...items.map((item) => _DishItem(item: item)).toList(),
        ],
      ),
    );
  }
}

class _DishItem extends StatelessWidget {
  final FoodItem item;

  const _DishItem({required this.item});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<MenuViewModel>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dish Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: (item.images?.isNotEmpty ?? false)
                ? Image.network(
                    item.images!.first,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPlaceholderImage();
                    },
                  )
                : _buildPlaceholderImage(),
          ),
          const SizedBox(width: 12),

          // Dish Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.menuName,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                if (item.description != null && item.description!.isNotEmpty)
                  Text(
                    item.description!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 4),
                _buildPriceAndDiscount(item),
                _buildRatingAndOrderedCount(item),
                if (item.containAllergence && item.specifyAllergence != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      'Contains Allergens: ${item.specifyAllergence}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 4),

          // Action Buttons
          _buildAvailabilityToggle(item, viewModel),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.primary, size: 20),
            onPressed: () async {
              if (item.menuUid != null) {
                // Fetch the latest dish data using the new API
                final fetchedItem = await viewModel.loadFoodItemByUid(item.menuUid!);
                if (fetchedItem != null) {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddDishScreen(foodItem: fetchedItem),
                    ),
                  );
                }
              } else if (item.id != null) {
                // Fallback to old flow if menuUid is not present, using the passed item.
                // This is a temporary measure until all items have a menuUid.
                 await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddDishScreen(foodItem: item),
                    ),
                  );
              }
              // In both cases, refresh the list upon return
              viewModel.loadFoodItems();
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            style: const ButtonStyle(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.delete, color: AppColors.error, size: 20),
            onPressed: () {
              final idToDelete = item.menuUid ?? item.id;
              if (idToDelete != null) {
                _showDeleteDialog(context, idToDelete, viewModel);
              }
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            style: const ButtonStyle(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.restaurant, color: AppColors.textHint),
    );
  }

  Widget _buildPriceAndDiscount(FoodItem item) {
    if ((item.discount ?? 0) > 0) {
      final discountedPrice = item.price * (1 - (item.discount! / 100));

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '₹${discountedPrice.toStringAsFixed(2)}',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '${item.discount}% OFF',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Text(
            '₹${item.price.toStringAsFixed(2)}',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
      );
    }
    return Text(
      '₹${item.price.toStringAsFixed(2)}',
      style: AppTextStyles.bodyMedium.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildRatingAndOrderedCount(FoodItem item) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Row(
        children: [
          Icon(Icons.star, color: Colors.amber, size: 14),
          const SizedBox(width: 4),
          Text(
            item.rating?.toStringAsFixed(1) ?? 'N/A',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(width: 8),
          Text(
            '(${item.orderedCount ?? 0} orders)',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityToggle(FoodItem item, MenuViewModel viewModel) {
    return SizedBox(
      height: 24,
      child: FittedBox(
        fit: BoxFit.fill,
        child: Switch(
          value: item.isActive,
          onChanged: (newValue) {
            if (item.id != null) {
              viewModel.toggleFoodItemAvailability(item);
            }
          },
          activeColor: AppColors.primary,
          inactiveThumbColor: AppColors.textHint,
          inactiveTrackColor: AppColors.divider,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    String id,
    MenuViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Dish'),
        content: const Text('Are you sure you want to delete this dish?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await viewModel.deleteMenu(id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

