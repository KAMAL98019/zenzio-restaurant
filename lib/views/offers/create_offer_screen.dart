import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:zenzio_restaurant/core/constant/api_constant.dart';
import 'package:zenzio_restaurant/core/constant/appcolors.dart';
import '../../core/theme/text_styles.dart';
import '../../viewmodels/offer_viewmodel.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';
import '../../models/offer.dart';
import '../../services/auth_service.dart';
import 'applicable_items_selector_screen.dart';

class CreateOfferScreen extends StatefulWidget {
  final Offer? offer;

  const CreateOfferScreen({Key? key, this.offer}) : super(key: key);

  @override
  State<CreateOfferScreen> createState() => _CreateOfferScreenState();
}

class _CreateOfferScreenState extends State<CreateOfferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _discountValueController = TextEditingController();
  final _minOrderValueController = TextEditingController();
  final _termsController = TextEditingController();

  File? _selectedImage;
  String _discountType = 'PERCENTAGE';
  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  List<String> _selectedItems = [];
  bool _allMenuItems = true;
  bool _isInitialized = false;
  bool _isLoadingData = false;

  @override
  void initState() {
    super.initState();
    if (widget.offer != null) {
      _loadExistingData();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize ViewModel data only once
    if (!_isInitialized) {
      _isInitialized = true;
      _ensureDataLoaded();
    }
  }

  Future<void> _ensureDataLoaded() async {
    final viewModel = context.read<OfferViewModel>();

    setState(() {
      _isLoadingData = true;
    });

    try {
      // Load all required data
      if (viewModel.foodItems.isEmpty) {
        print('CreateOfferScreen: Loading food items...');
        await viewModel.loadFoodItems();
      }
      if (viewModel.categories.isEmpty) {
        print('CreateOfferScreen: Loading categories...');
        await viewModel.loadCategories();
      }
      if (viewModel.cuisines.isEmpty) {
        print('CreateOfferScreen: Loading cuisines...');
        await viewModel.loadCuisines();
      }

      print(
        'CreateOfferScreen: Data loaded - FoodItems: ${viewModel.foodItems.length}, Categories: ${viewModel.categories.length}, Cuisines: ${viewModel.cuisines.length}',
      );
    } catch (e) {
      print('CreateOfferScreen: Error loading data: $e');
    } finally {
      setState(() {
        _isLoadingData = false;
      });
    }
  }

  void _loadExistingData() {
    try {
      final offer = widget.offer!;
      _titleController.text = offer.title;
      _descriptionController.text = offer.description ?? '';
      _discountType = offer.discountType;
      _discountValueController.text = offer.discountValue.toString();
      _minOrderValueController.text = offer.minOrderValue?.toString() ?? '';
      _termsController.text = offer.termsConditions ?? '';
      _startDate = offer.startDate;
      _endDate = offer.endDate;

      if (offer.startTime != null && offer.startTime!.isNotEmpty) {
        final parts = offer.startTime!.split(':');
        if (parts.length >= 2) {
          _startTime = TimeOfDay(
            hour: int.tryParse(parts[0]) ?? 0,
            minute: int.tryParse(parts[1]) ?? 0,
          );
        }
      }

      if (offer.endTime != null && offer.endTime!.isNotEmpty) {
        final parts = offer.endTime!.split(':');
        if (parts.length >= 2) {
          _endTime = TimeOfDay(
            hour: int.tryParse(parts[0]) ?? 0,
            minute: int.tryParse(parts[1]) ?? 0,
          );
        }
      }

      if (offer.applicableItems != null && offer.applicableItems!.isNotEmpty) {
        _selectedItems = List.from(offer.applicableItems!);
        _allMenuItems = false;
      }

      print('CreateOfferScreen: Loaded existing offer data - ${offer.title}');
    } catch (e) {
      print('CreateOfferScreen: Error loading existing offer data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: CustomAppBar(
        title: widget.offer == null ? 'Create New Offer' : 'Edit Offer',
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : Consumer<OfferViewModel>(
              builder: (context, viewModel, _) {
                return Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Offer Post Image
                        Text(
                          'Offer Post Image',
                          style: AppTextStyles.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        _buildImageUpload(),
                        const SizedBox(height: 4),
                        Text(
                          'Upload a visually appealing image for the customer app home screen',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Offer Title
                        CustomTextField(
                          controller: _titleController,
                          label: 'Offer Title',
                          hint: 'e.g., Weekend Feast!',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter offer title';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Offer Description
                        CustomTextField(
                          controller: _descriptionController,
                          label: 'Offer Description/Details',
                          hint: 'e.g., Get 20% off on all main courses',
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),

                        // Discount Type
                        Text('Discount Type', style: AppTextStyles.bodyMedium),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _discountType,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.cardBackground,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'PERCENTAGE',
                              child: Text('Percentage'),
                            ),
                            DropdownMenuItem(
                              value: 'FLAT',
                              child: Text('Flat Amount'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _discountType = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        // Discount Value
                        CustomTextField(
                          controller: _discountValueController,
                          label: 'Discount Value',
                          hint: _discountType == 'PERCENTAGE'
                              ? 'e.g., 20'
                              : 'e.g., 100',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,2}'),
                            ),
                          ],
                          suffixIcon: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              _discountType == 'PERCENTAGE' ? '%' : '₹',
                              style: AppTextStyles.bodyMedium,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter discount value';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Minimum Order Value
                        CustomTextField(
                          controller: _minOrderValueController,
                          label: 'Minimum Order Value (Optional)',
                          hint: 'e.g., 500',
                          keyboardType: const TextInputType.numberWithOptions(
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
                        ),
                        const SizedBox(height: 24),

                        // Start Date and Time
                        Text(
                          'Start Date and Time',
                          style: AppTextStyles.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDateSelector(
                                context,
                                label: _startDate == null
                                    ? 'Select Date'
                                    : DateFormat(
                                        'dd/MM/yyyy',
                                      ).format(_startDate!),
                                onTap: () => _selectStartDate(context),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildTimeSelector(
                                context,
                                label: _startTime == null
                                    ? 'Select Time'
                                    : _startTime!.format(context),
                                onTap: () => _selectStartTime(context),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // End Date and Time
                        Text(
                          'End Date and Time',
                          style: AppTextStyles.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDateSelector(
                                context,
                                label: _endDate == null
                                    ? 'Select Date'
                                    : DateFormat(
                                        'dd/MM/yyyy',
                                      ).format(_endDate!),
                                onTap: () => _selectEndDate(context),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildTimeSelector(
                                context,
                                label: _endTime == null
                                    ? 'Select Time'
                                    : _endTime!.format(context),
                                onTap: () => _selectEndTime(context),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Applicable Items/Categories
                        Text(
                          'Applicable Items/Categories',
                          style: AppTextStyles.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () =>
                              _showApplicableItemsSelector(context, viewModel),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.cardBackground,
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _allMenuItems
                                      ? Icons.check_circle
                                      : Icons.circle_outlined,
                                  color: _allMenuItems
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _allMenuItems
                                        ? 'All Menu Items'
                                        : '${_selectedItems.length} items selected',
                                    style: AppTextStyles.bodyMedium,
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_drop_down,
                                  color: AppColors.textSecondary,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Terms & Conditions
                        CustomTextField(
                          controller: _termsController,
                          label: 'Terms & Conditions',
                          hint: 'Any special conditions for this offer?',
                          maxLines: 4,
                        ),
                        const SizedBox(height: 32),

                        // Submit Button
                        CustomButton(
                          text: widget.offer == null
                              ? 'Create Offer'
                              : 'Update Offer',
                          onPressed: () => _submitOffer(viewModel),
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
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
          color: AppColors.cardBackground,
        ),
        child: _selectedImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(_selectedImage!, fit: BoxFit.cover),
              )
            : widget.offer?.offerImage != null && _selectedImage == null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  '${ApiConstants.baseUrl}/${widget.offer!.offerImage!}',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildPlaceholder();
                  },
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
          'Upload Offer Image',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
        ),
      ],
    );
  }

  Widget _buildDateSelector(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: label.contains('Select')
                      ? AppColors.textHint
                      : AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time, color: AppColors.textSecondary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: label.contains('Select')
                      ? AppColors.textHint
                      : AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
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
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  void _showApplicableItemsSelector(
    BuildContext context,
    OfferViewModel viewModel,
  ) async {
    // Check if data is loaded
    if (viewModel.foodItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Loading menu items, please wait...')),
      );
      await viewModel.loadFoodItems();

      if (viewModel.foodItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No menu items available')),
        );
        return;
      }
    }

    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ApplicableItemsSelectorScreen(
            categories: viewModel.categories,
            cuisines: viewModel.cuisines,
            foodItems: viewModel.foodItems,
            selectedItems: _selectedItems,
            allMenuItems: _allMenuItems,
          ),
        ),
      );

      if (result != null && mounted) {
        setState(() {
          _allMenuItems = result['allMenuItems'] ?? true;
          _selectedItems = result['selectedItems'] ?? [];
        });
      }
    } catch (e) {
      print('Error showing item selector: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _submitOffer(OfferViewModel viewModel) async {
    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start and end dates')),
      );
      return;
    }

    try {
      final restaurantId = await AuthService().getRestaurantId();
      if (restaurantId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Restaurant ID not found')),
        );
        return;
      }

      final offer = Offer(
        id: widget.offer?.id,
        restaurantId: restaurantId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        discountType: _discountType,
        discountValue: double.parse(_discountValueController.text),
        minOrderValue: _minOrderValueController.text.isNotEmpty
            ? double.parse(_minOrderValueController.text)
            : null,
        startDate: _startDate!,
        endDate: _endDate!,
        startTime: _startTime != null
            ? '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}'
            : null,
        endTime: _endTime != null
            ? '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}'
            : null,
        applicableItems: _allMenuItems ? null : _selectedItems,
        termsConditions: _termsController.text.trim(),
      );

      bool success;
      if (widget.offer == null) {
        print('CreateOfferScreen: Creating new offer...');
        success = await viewModel.createOffer(offer, _selectedImage);
      } else {
        print('CreateOfferScreen: Updating offer ${widget.offer!.id}...');
        success = await viewModel.updateOffer(
          widget.offer!.id!,
          offer,
          _selectedImage,
        );
      }

      if (success && mounted) {
        print('CreateOfferScreen: Operation successful, navigating back');
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('CreateOfferScreen: Error submitting offer: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _discountValueController.dispose();
    _minOrderValueController.dispose();
    _termsController.dispose();
    super.dispose();
  }
}
