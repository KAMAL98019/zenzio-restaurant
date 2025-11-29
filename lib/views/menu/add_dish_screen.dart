import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zenzio_restaurant/core/constant/appcolors.dart';
import '../../core/theme/text_styles.dart';
import '../../viewmodels/menu_viewmodel.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';
import '../../models/food_item.dart';
import '../../services/auth_service.dart';
import '../../widgets/category_cuisine_selector.dart'; // Import the new widget
import '../../models/category.dart';
import '../../models/cuisine.dart';
import 'package:collection/collection.dart'; // Import collection for firstWhereOrNull

class AddDishScreen extends StatefulWidget {
  final FoodItem? foodItem;

  const AddDishScreen({Key? key, this.foodItem}) : super(key: key);

  @override
  State<AddDishScreen> createState() => _AddDishScreenState();
}

class _AddDishScreenState extends State<AddDishScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dishNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _allergensController = TextEditingController();
  final _discountController = TextEditingController(); // New field

  File? _selectedImage;
  bool _isVegetarian = false;
  bool _containsAllergens = false;
  bool _isActive = true; // New field, defaults to true

  List<CustomizationOption> _customizedOptions = []; // New field
  List<CustomizationOption> _sizeOptions = [];
  List<CustomizationOption> _toppingOptions = [];

  @override
  void initState() {
    super.initState();
    if (widget.foodItem != null) {
      _loadExistingData();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MenuViewModel>(context, listen: false).initialize();
    });
  }

  Future<void> _loadExistingData() async {
    final item = widget.foodItem!;
    _dishNameController.text = item.dishname;
    _descriptionController.text = item.description ?? '';
    _priceController.text = item.price.toString();
    _isVegetarian = item.veg;
    _containsAllergens = item.containAllergens;
    _allergensController.text = item.specifyAllergens ?? '';
    _discountController.text = item.discount?.toString() ?? ''; // Load discount
    _isActive = item.isActive; // Load isActive

    // Set selected category and cuisine in ViewModel if available
    final viewModel = Provider.of<MenuViewModel>(context, listen: false);
    // Ensure categories and cuisines are loaded before setting selected values
    await viewModel.initialize(); // Await the initialization
    
    if (item.categoryId != null && viewModel.categories.isNotEmpty) {
      final selectedCategory = viewModel.categories.firstWhereOrNull(
        (cat) => cat.id.toString() == item.categoryId,
      );
      viewModel.setSelectedCategory(selectedCategory);
    } else {
      viewModel.setSelectedCategory(null); // Set to null if no category or categories are empty
    }
    if (item.cuisineId != null && viewModel.cuisines.isNotEmpty) {
      final selectedCuisine = viewModel.cuisines.firstWhereOrNull(
        (cuisine) => cuisine.id.toString() == item.cuisineId,
      );
      viewModel.setSelectedCuisine(selectedCuisine);
    } else {
      viewModel.setSelectedCuisine(null); // Set to null if no cuisine or cuisines are empty
    }

    if (item.customizedOption != null) {
      _customizedOptions = item.customizedOption!;
    }
    if (item.sizeOption != null) {
      _sizeOptions = item.sizeOption!;
    }
    if (item.topping != null) {
      _toppingOptions = item.topping!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: CustomAppBar(
        title: widget.foodItem == null ? 'Add New Dish' : 'Edit Dish',
      ),
      body: Consumer<MenuViewModel>(
        builder: (context, viewModel, _) {
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Upload
                  _buildImageUpload(),
                  const SizedBox(height: 24),

                  // Dish Name
                  CustomTextField(
                    controller: _dishNameController,
                    label: 'Dish Name',
                    hint: 'Enter dish name',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter dish name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Description
                  CustomTextField(
                    controller: _descriptionController,
                    label: 'Dish Description',
                    hint: 'Describe your dish',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  // Price
                  CustomTextField(
                    controller: _priceController,
                    label: 'Price',
                    hint: '0.00',
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
                    prefixIcon: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('₹', style: AppTextStyles.bodyMedium),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter price';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Discount Field
                  CustomTextField(
                    controller: _discountController,
                    label: 'Discount (%)',
                    hint: 'Enter discount percentage',
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(2),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Category and Cuisine Selector
                  CategoryCuisineSelector(
                    categories: viewModel.categories,
                    cuisines: viewModel.cuisines,
                    onCategorySelected: (category) {
                      viewModel.setSelectedCategory(category);
                    },
                    onCuisineSelected: (cuisine) {
                      viewModel.setSelectedCuisine(cuisine);
                    },
                    selectedCategory: viewModel.selectedCategory,
                    selectedCuisine: viewModel.selectedCuisine,
                  ),
                  const SizedBox(height: 24),

                  // Vegetarian Toggle
                  _buildSwitchTile(
                    label: 'Vegetarian',
                    value: _isVegetarian,
                    onChanged: (value) {
                      setState(() => _isVegetarian = value);
                    },
                  ),
                  const SizedBox(height: 8),

                  // Contains Allergens Toggle
                  _buildSwitchTile(
                    label: 'Contains Allergens',
                    value: _containsAllergens,
                    onChanged: (value) {
                      setState(() => _containsAllergens = value);
                    },
                  ),
                  const SizedBox(height: 8),

                  // Is Active Toggle
                  _buildSwitchTile(
                    label: 'Is Available (Active)',
                    value: _isActive,
                    onChanged: (value) {
                      setState(() => _isActive = value);
                    },
                  ),

                  // Allergen Specification
                  if (_containsAllergens) ...[
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _allergensController,
                      label: 'Specify Allergens',
                      hint: 'Specify allergens',
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Customization Options
                  Text(
                    'Customization Options (Optional)',
                    style: AppTextStyles.h3,
                  ),
                  const SizedBox(height: 16),

                  // Custom Options (Non-Size/Topping)
                  ..._customizedOptions.asMap().entries.map((entry) {
                    return _buildCustomizationOption(
                      label: 'Custom Option',
                      option: entry.value,
                      onDelete: () {
                        setState(() {
                          _customizedOptions.removeAt(entry.key);
                        });
                      },
                    );
                  }).toList(),

                  // Size Options
                  ..._sizeOptions.asMap().entries.map((entry) {
                    return _buildCustomizationOption(
                      label: 'Size Option',
                      option: entry.value,
                      onDelete: () {
                        setState(() {
                          _sizeOptions.removeAt(entry.key);
                        });
                      },
                    );
                  }).toList(),

                  // Topping Options
                  ..._toppingOptions.asMap().entries.map((entry) {
                    return _buildCustomizationOption(
                      label: 'Topping',
                      option: entry.value,
                      onDelete: () {
                        setState(() {
                          _toppingOptions.removeAt(entry.key);
                        });
                      },
                    );
                  }).toList(),

                  const SizedBox(height: 16),

                  // Add Options Buttons
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _showAddOptionDialog('Custom Option'),
                        icon: const Icon(Icons.add, color: AppColors.primary),
                        label: const Text('Add Custom Option'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primary),
                          foregroundColor: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),

                      OutlinedButton.icon(
                        onPressed: () => _showAddOptionDialog('Size Option'),
                        icon: const Icon(Icons.add, color: AppColors.primary),
                        label: const Text('Add Size Option'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primary),
                          foregroundColor: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),

                      OutlinedButton.icon(
                        onPressed: () => _showAddOptionDialog('Topping'),
                        icon: const Icon(Icons.add, color: AppColors.primary),
                        label: const Text('Add Topping'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primary),
                          foregroundColor: AppColors.primary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Save Button
                  CustomButton(
                    text: 'Save Dish',
                    onPressed: () => _saveDish(viewModel),
                    isLoading: viewModel.isLoading,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageUpload() {
    final existingImageUrl = widget.foodItem?.dishimage ??
        (widget.foodItem?.images?.isNotEmpty == true
            ? widget.foodItem!.images!.first
            : null);

    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(12),
          color: AppColors.background,
        ),
        child: _selectedImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(_selectedImage!, fit: BoxFit.cover),
              )
            : existingImageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      existingImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildPlaceholder(),
                    ),
                  )
                : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.camera_alt, size: 48, color: AppColors.textHint),
        const SizedBox(height: 8),
        Text(
          'Upload Dish Image',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textHint,
          ),
        ),
      ],
    );
  }


  Widget _buildSwitchTile({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildCustomizationOption({
    required String label,
    required CustomizationOption option,
    required VoidCallback onDelete,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(child: Text(option.name, style: AppTextStyles.bodyMedium)),
          const SizedBox(width: 8),
          Text(
            '₹${option.price.toStringAsFixed(2)}',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.delete, color: AppColors.error, size: 20),
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _showAddOptionDialog(String type) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add $type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Option Name',
                hintText: type == 'Custom Option'
                    ? 'Extra Egg'
                    : (type == 'Size Option' ? 'Large' : 'Extra Cheese'),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(
                labelText: 'Price',
                hintText: '0.00',
                prefixText: '₹ ',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  priceController.text.isNotEmpty) {
                final option = CustomizationOption(
                  name: nameController.text,
                  price: double.tryParse(priceController.text) ?? 0,
                );

                setState(() {
                  if (type == 'Custom Option') {
                    _customizedOptions.add(option);
                  } else if (type == 'Size Option') {
                    _sizeOptions.add(option);
                  } else {
                    _toppingOptions.add(option);
                  }
                });

                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveDish(MenuViewModel viewModel) async {
    if (!_formKey.currentState!.validate()) return;

    final restaurantId = await AuthService().getRestaurantId();
    if (restaurantId == null) return;

    final foodItem = FoodItem(
      id: widget.foodItem?.id,
      menuUid:
          widget.foodItem?.menuUid, // ADDED: Pass existing menuUid for update
      restId: restaurantId,
      cuisineId: viewModel.selectedCuisine?.id.toString(),
      categoryId: viewModel.selectedCategory?.id.toString(),
      menuName: _dishNameController.text.trim(),
      category: viewModel.selectedCategory?.name ?? 'Uncategorized',
      cuisineType: viewModel.selectedCuisine?.name,
      description: _descriptionController.text.trim(),
      price: double.parse(_priceController.text),
      foodType: _isVegetarian ? 'Veg' : 'Non-Veg', // Use new foodType field
      containAllergence: _containsAllergens, // Use new containAllergence field
      specifyAllergence: _containsAllergens
          ? _allergensController.text.trim()
          : null, // Use new specifyAllergence field
      customizedOption: _customizedOptions.isNotEmpty
          ? _customizedOptions
          : null, // Use new customizedOption field
      sizeOption: _sizeOptions.isNotEmpty
          ? _sizeOptions
          : null, // Use new sizeOption field
      topping: _toppingOptions.isNotEmpty
          ? _toppingOptions
          : null, // Use new topping field
      discount:
          int.tryParse(_discountController.text) ??
          null, // Use new discount field
      isActive: _isActive, // Use new isActive field
      // Old API fields for compatibility (must be null for new API)
      veg: _isVegetarian,
      containAllergens: _containsAllergens,
      specifyAllergens: _containsAllergens
          ? _allergensController.text.trim()
          : null,
      customisedOptions: null, // Set old field to null
    );

    FoodItem itemToSave = foodItem;

    // If a new image is selected during an update, clear old image URLs from the model
    if (widget.foodItem != null && _selectedImage != null) {
      itemToSave = itemToSave.copyWith(
        dishimage: null,
        images: null,
      );
    }
    
    // For editing, if no new image is selected, ensure the old image URL is retained in the 'images' list
    if (widget.foodItem != null && _selectedImage == null) {
      final oldImageUrls = widget.foodItem!.images ?? [];
      final oldDishImage = widget.foodItem!.dishimage;

      if (oldImageUrls.isNotEmpty) {
        // Use the existing 'images' list which is List<String>
        itemToSave = itemToSave.copyWith(images: oldImageUrls);
      } else if (oldDishImage != null) {
        // Fallback to old 'dishimage' field if 'images' is null/empty
        itemToSave = itemToSave.copyWith(images: [oldDishImage]);
      }
    }

    // FIXED: convert File? -> List<File>?
    List<File>? images = _selectedImage != null ? [_selectedImage!] : null;

    bool success;
    if (widget.foodItem == null) {
      success = await viewModel.addFoodItem(itemToSave, images);
    } else {
      success = await viewModel.updateFoodItem(
        widget.foodItem!.id!,
        itemToSave,
        images,
      );
    }

    if (success && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _dishNameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _allergensController.dispose();
    _discountController.dispose(); // Dispose new controller
    super.dispose();
  }
}
