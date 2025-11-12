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

  File? _selectedImage;
  bool _isVegetarian = false;
  bool _containsAllergens = false;

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

  void _loadExistingData() {
    final item = widget.foodItem!;
    _dishNameController.text = item.dishname;
    _descriptionController.text = item.description ?? '';
    _priceController.text = item.price.toString();
    _isVegetarian = item.veg;
    _containsAllergens = item.containAllergens;
    _allergensController.text = item.specifyAllergence ?? '';

    // Set selected category and cuisine in ViewModel if available
    final viewModel = Provider.of<MenuViewModel>(context, listen: false);
    // Ensure categories and cuisines are loaded before setting selected values
    viewModel.initialize().then((_) {
      if (item.categoryId != null && viewModel.categories.isNotEmpty) {
        viewModel.setSelectedCategory(viewModel.categories.firstWhere(
          (cat) => cat.id == item.categoryId,
          orElse: () => viewModel.categories.first, // Provide a non-null default
        ));
      } else {
        viewModel.setSelectedCategory(null); // Set to null if no category or categories are empty
      }
      if (item.cuisineId != null && viewModel.cuisines.isNotEmpty) {
        viewModel.setSelectedCuisine(viewModel.cuisines.firstWhere(
          (cuisine) => cuisine.id == item.cuisineId,
          orElse: () => viewModel.cuisines.first, // Provide a non-null default
        ));
      } else {
        viewModel.setSelectedCuisine(null); // Set to null if no cuisine or cuisines are empty
      }
    });

    if (item.customisedOptions != null) {
      _sizeOptions = item.customisedOptions!
          .where((opt) => opt.name.toLowerCase().contains('size'))
          .toList();
      _toppingOptions = item.customisedOptions!
          .where((opt) => !opt.name.toLowerCase().contains('size'))
          .toList();
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
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
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

                  // Category Dropdown
                  _buildDropdown(
                    label: 'Category',
                    value: viewModel.selectedCategory?.id,
                    items: viewModel.categories
                        .map((cat) => DropdownMenuItem(
                                value: cat.id,
                                child: Text(cat.name),
                            ))
                        .toList(),
                    onChanged: (value) {
                      viewModel.setSelectedCategory(viewModel.categories.firstWhere((element) => element.id == value));
                    },
                  ),
                  const SizedBox(height: 16),

                  // Cuisine Type Dropdown
                  _buildDropdown(
                    label: 'Cuisine Type',
                    value: viewModel.selectedCuisine?.id,
                    items: viewModel.cuisines
                        .map((cuisine) => DropdownMenuItem(
                                value: cuisine.id,
                                child: Text(cuisine.name),
                            ))
                        .toList(),
                    onChanged: (value) {
                      viewModel.setSelectedCuisine(viewModel.cuisines.firstWhere((element) => element.id == value));
                    },
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

                  // Size Options
                  ..._sizeOptions.asMap().entries.map((entry) {
                    return _buildCustomizationOption(
                      label: 'Size',
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
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showAddOptionDialog('Size'),
                          icon: const Icon(Icons.add),
                          label: const Text('Add Size Option'),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showAddOptionDialog('Topping'),
                          icon: const Icon(Icons.add),
                          label: const Text('Add Topping'),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primary),
                          ),
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
            : widget.foodItem?.dishimage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.foodItem!.dishimage!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt,
                        size: 48,
                        color: AppColors.textHint,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Upload Dish Image',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            hintText: 'Select $label',
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
          items: items,
          onChanged: onChanged,
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
          Expanded(
            child: Text(
              option.name,
              style: AppTextStyles.bodyMedium,
            ),
          ),
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
        title: Text('Add $type Option'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: type,
                hintText: type == 'Size' ? 'Small' : 'Extra Cheese',
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
                  if (type == 'Size') {
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

    final allOptions = [..._sizeOptions, ..._toppingOptions];

    final foodItem = FoodItem(
      id: widget.foodItem?.id,
      restId: restaurantId,
      cuisineId: viewModel.selectedCuisine?.id,
      categoryId: viewModel.selectedCategory?.id,
      dishname: _dishNameController.text.trim(),
      description: _descriptionController.text.trim(),
      price: double.parse(_priceController.text),
      veg: _isVegetarian,
      containAllergens: _containsAllergens,
      specifyAllergence: _containsAllergens ? _allergensController.text.trim() : null,
      customisedOptions: allOptions.isNotEmpty ? allOptions : null,
    );

    bool success;
    if (widget.foodItem == null) {
      success = await viewModel.addFoodItem(foodItem, _selectedImage);
    } else {
      success = await viewModel.updateFoodItem(
        widget.foodItem!.id!,
        foodItem,
        _selectedImage,
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
    // No need to dispose _selectedCategory and _selectedCuisine as they are removed.
    super.dispose();
  }
}
