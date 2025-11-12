import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zenzio_restaurant/core/constant/appcolors.dart';
import '../../core/theme/text_styles.dart';
import '../../viewmodels/booking_viewmodel.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';
import '../../models/booking.dart';
import '../../models/dining_space.dart';
import '../../services/auth_service.dart';

class AddDiningAreaScreen extends StatefulWidget {
  final DiningSpace? diningSpace;

  const AddDiningAreaScreen({Key? key, this.diningSpace}) : super(key: key);

  @override
  State<AddDiningAreaScreen> createState() => _AddDiningAreaScreenState();
}

class _AddDiningAreaScreenState extends State<AddDiningAreaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _areaNameController = TextEditingController();
  final _seatingCapacityController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<File> _selectedPhotos = [];
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.diningSpace != null) {
      _loadExistingData();
    }
  }

  void _loadExistingData() {
    final space = widget.diningSpace!;
    _areaNameController.text = space.areaName;
    _seatingCapacityController.text = space.seatingCapacity.toString();
    _descriptionController.text = space.description ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: CustomAppBar(
        title: widget.diningSpace == null ? 'Add Dining Area' : 'Edit Dining Area',
      ),
      body: Consumer<BookingViewModel>(
        builder: (context, viewModel, _) {
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Area Name
                  CustomTextField(
                    controller: _areaNameController,
                    label: 'Area Name',
                    hint: 'e.g., Main Dining Room, Patio',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter area name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Seating Capacity
                  CustomTextField(
                    controller: _seatingCapacityController,
                    label: 'Seating Capacity',
                    hint: 'Number of seats',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter seating capacity';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Description
                  CustomTextField(
                    controller: _descriptionController,
                    label: 'Description (Optional)',
                    hint: 'Describe the dining area',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),

                  // Photos
                  Text(
                    'Photos (Optional)',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Photo Grid
                  if (_selectedPhotos.isNotEmpty)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: _selectedPhotos.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _selectedPhotos[index],
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedPhotos.removeAt(index);
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                  if (_selectedPhotos.isNotEmpty) const SizedBox(height: 12),

                  // Add Photos Button
                  OutlinedButton.icon(
                    onPressed: _pickPhotos,
                    icon: const Icon(Icons.add_photo_alternate),
                    label: const Text('Add Photos'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Save Button
                  CustomButton(
                    text: widget.diningSpace == null ? 'Add Area' : 'Save Changes',
                    onPressed: () => _saveDiningArea(viewModel),
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

  Future<void> _pickPhotos() async {
    final List<XFile>? images = await _imagePicker.pickMultiImage(
      imageQuality: 80,
    );

    if (images == null) return;

    if (images.isNotEmpty) {
      setState(() {
        _selectedPhotos.addAll(images.map((img) => File(img.path)));
      });
    }
  }

  Future<void> _saveDiningArea(BookingViewModel viewModel) async {
    if (_formKey.currentState?.validate() == false) return;

    final restaurantId = await AuthService().getRestaurantId();
    print('AddDiningAreaScreen: Retrieved restaurantId: $restaurantId'); // Debug print
    if (restaurantId == null) {
      Fluttertoast.showToast(
        msg: 'Restaurant ID not found. Please log in again.',
        backgroundColor: Colors.red,
      );
      return;
    }

    final diningSpace = DiningSpace(
      id: widget.diningSpace?.id,
      restaurantId: restaurantId,
      areaName: _areaNameController.text.trim(),
      seatingCapacity: int.parse(_seatingCapacityController.text),
      description: _descriptionController.text.trim(),
    );

    bool success;
    if (widget.diningSpace == null) {
      success = await viewModel.addDiningSpace(
        diningSpace,
        _selectedPhotos.isNotEmpty ? _selectedPhotos : null,
      );
    } else {
      final diningSpaceId = widget.diningSpace?.id;
      if (diningSpaceId == null) {
        Fluttertoast.showToast(
          msg: 'Cannot update: Dining Space ID is missing.',
          backgroundColor: Colors.red,
        );
        return;
      }
      success = await viewModel.updateDiningSpace(
        diningSpaceId,
        diningSpace,
        _selectedPhotos.isNotEmpty ? _selectedPhotos : null,
      );
    }

    if (success && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _areaNameController.dispose();
    _seatingCapacityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
