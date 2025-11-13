import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:zenzio_restaurant/core/constant/appcolors.dart';
import '../../core/theme/text_styles.dart';
import '../../viewmodels/registration_viewmodel.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/upload_field.dart';
import '../../services/location_service.dart';
import 'package:latlong2/latlong.dart';

class Step1RestaurantDetails extends StatefulWidget {
  const Step1RestaurantDetails({Key? key}) : super(key: key);

  @override
  State<Step1RestaurantDetails> createState() => _Step1RestaurantDetailsState();
}

class _Step1RestaurantDetailsState extends State<Step1RestaurantDetails> {
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _autoSetCurrentLocation();
  }

  Future<void> _autoSetCurrentLocation() async {
    final viewModel = context.read<RegistrationViewModel>();
    if (!mounted) return; // extra safety
    setState(() => _isLoadingLocation = true);

    try {
      final locationService = LocationService();
      LatLng? currentLocation = await locationService.getCurrentLocation();

      if (!mounted) return; // widget might have been disposed while waiting

      if (currentLocation != null) {
        viewModel.setRestaurantLocation(currentLocation);

        // ✅ Get readable text address
        final String address = await locationService.getAddressFromCoordinates(
          currentLocation,
        );

        if (!mounted) return; // ensure still mounted before updating UI
        viewModel.restaurantAddressController.text = address;
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to fetch location. Tap address field to retry.',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error getting location: $e')));
    } finally {
      if (!mounted) return;
      setState(() => _isLoadingLocation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RegistrationViewModel>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tell us about your Restaurant', style: AppTextStyles.h3),
          const SizedBox(height: 24),

          // Restaurant Name
          CustomTextField(
            controller: viewModel.restaurantNameController,
            label: 'Restaurant Name',
            hint: 'Enter restaurant name',
          ),
          const SizedBox(height: 16),

          CustomTextField(
            controller: viewModel.cityController,
            label: 'City',
            hint: 'Enter city',
          ),
          const SizedBox(height: 16),

          CustomTextField(
            controller: viewModel.stateController,
            label: 'State',
            hint: 'Enter state',
          ),
          const SizedBox(height: 16),

          CustomTextField(
            controller: viewModel.pincodeController,
            label: 'Pincode',
            hint: 'Enter pincode',
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 16),

          CustomTextField(
            controller: viewModel.landmarkController,
            label: 'Landmark (Optional)',
            hint: 'Enter nearby landmark',
          ),
          const SizedBox(height: 16),

          // Restaurant Address (auto-filled + editable)
          Stack(
            alignment: Alignment.centerRight,
            children: [
              CustomTextField(
                controller: viewModel.restaurantAddressController,
                label: 'Restaurant Address',
                hint: 'Enter or auto-detect address',
                maxLines: 3,
                readOnly: false, // ✅ Now editable
                suffixIcon: IconButton(
                  icon: const Icon(Icons.my_location, color: AppColors.primary),
                  tooltip: 'Detect current location',
                  onPressed: _isLoadingLocation
                      ? null
                      : _autoSetCurrentLocation,
                ),
              ),
              if (_isLoadingLocation)
                const Positioned(
                  right: 16,
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'You can edit the address or tap the location icon to auto-detect it.',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 16),

          // Average Cost
          CustomTextField(
            controller: viewModel.avgCostController,
            label: 'Average Cost for Two',
            hint: 'Enter amount in ₹',
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            prefixIcon: const Padding(
              padding: EdgeInsets.all(16),
              child: Text('₹', style: AppTextStyles.bodyMedium),
            ),
          ),
          const SizedBox(height: 16),

          // Upload logo
          UploadField(
            label: 'Restaurant Logo',
            hint:
                'Drop your file here, or browse\nUpload PDF, JPG, or PNG (Max 5MB)',
            isOptional: true,
            onFileSelected: (path) => viewModel.setRestaurantLogo(path),
          ),
          const SizedBox(height: 32),

          // Continue Button
          CustomButton(text: 'Continue', onPressed: viewModel.nextStep),
        ],
      ),
    );
  }
}
