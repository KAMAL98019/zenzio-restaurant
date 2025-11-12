import 'package:flutter/material.dart';
import 'package:zenzio_restaurant/core/constant/appcolors.dart';
import 'package:zenzio_restaurant/models/category.dart';
import 'package:zenzio_restaurant/models/cuisine.dart';
import '../../core/theme/text_styles.dart';
import '../../widgets/custom_appbar.dart';
import '../../models/food_item.dart';

class ApplicableItemsSelectorScreen extends StatefulWidget {
  final List<Category> categories;
  final List<Cuisine> cuisines;
  final List<FoodItem> foodItems;
  final List<String> selectedItems;
  final bool allMenuItems;

  const ApplicableItemsSelectorScreen({
    Key? key,
    required this.categories,
    required this.cuisines,
    required this.foodItems,
    required this.selectedItems,
    required this.allMenuItems,
  }) : super(key: key);

  @override
  State<ApplicableItemsSelectorScreen> createState() =>
      _ApplicableItemsSelectorScreenState();
}

class _ApplicableItemsSelectorScreenState
    extends State<ApplicableItemsSelectorScreen> {
  late bool _allMenuItems;
  late List<String> _selectedItems;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _allMenuItems = widget.allMenuItems;
    _selectedItems = List.from(widget.selectedItems);
  }

  @override
  Widget build(BuildContext context) {
    // Group food items by category
    Map<String, List<FoodItem>> groupedItems = {};
    for (var item in widget.foodItems) {
      if (_searchQuery.isNotEmpty &&
          !item.dishname.toLowerCase().contains(_searchQuery.toLowerCase())) {
        continue;
      }
      
      final category = item.getCategoryDisplay();
      if (!groupedItems.containsKey(category)) {
        groupedItems[category] = [];
      }
      groupedItems[category]!.add(item);
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: const CustomAppBar(title: 'Applicable Items/Categories'),
      body: Column(
        children: [
          // All Menu Items Option
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              border: Border.all(
                color: _allMenuItems ? AppColors.primary : AppColors.border,
                width: _allMenuItems ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: InkWell(
              onTap: () {
                setState(() {
                  _allMenuItems = !_allMenuItems;
                  if (_allMenuItems) {
                    _selectedItems.clear();
                  }
                });
              },
              child: Row(
                children: [
                  Icon(
                    _allMenuItems ? Icons.check_circle : Icons.circle_outlined,
                    color: _allMenuItems ? AppColors.primary : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'All Menu Items',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _allMenuItems ? AppColors.primary : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                ],
              ),
            ),
          ),

          // Search Bar
          if (!_allMenuItems)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search Food',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: AppColors.cardBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),

          const SizedBox(height: 16),

          // Food Items List
          if (!_allMenuItems)
            Expanded(
              child: groupedItems.isEmpty
                  ? Center(
                      child: Text(
                        'No items found',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: groupedItems.length,
                      itemBuilder: (context, index) {
                        final category = groupedItems.keys.elementAt(index);
                        final items = groupedItems[category]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Category Header
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                category,
                                style: AppTextStyles.h3,
                              ),
                            ),

                            // Items in Category
                            ...items.map((item) {
                              final isSelected = _selectedItems.contains(item.id);
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.cardBackground,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected ? AppColors.primary : AppColors.border,
                                  ),
                                ),
                                child: CheckboxListTile(
                                  value: isSelected,
                                  onChanged: (value) {
                                    setState(() {
                                      if (value == true) {
                                        _selectedItems.add(item.id!);
                                      } else {
                                        _selectedItems.remove(item.id);
                                      }
                                    });
                                  },
                                  title: Text(item.dishname),
                                  subtitle: item.description != null && item.description!.isNotEmpty
                                      ? Text(
                                          item.description!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        )
                                      : null,
                                  activeColor: AppColors.primary,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                ),
                              );
                            }).toList(),

                            const SizedBox(height: 16),
                          ],
                        );
                      },
                    ),
            ),

          // Apply Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowColor,
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, {
                      'allMenuItems': _allMenuItems,
                      'selectedItems': _selectedItems,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    _allMenuItems
                        ? 'Apply (All Items)'
                        : 'Apply (${_selectedItems.length} items)',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
