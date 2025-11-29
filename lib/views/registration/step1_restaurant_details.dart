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
                'Drop your file here, or browse\nUpload JPG, or PNG (Max 1MB)',
            isOptional: true,
            onFileSelected: (path) => viewModel.setRestaurantLogo(path),
            currentFilePath: viewModel.restaurantLogoPath,
          ),
          const SizedBox(height: 32),

          // Continue Button
          CustomButton(text: 'Continue', onPressed: viewModel.nextStep),
        ],
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'package:zenzio_restaurant/core/constant/appcolors.dart';
// import '../../core/theme/text_styles.dart';
// import '../../viewmodels/registration_viewmodel.dart';
// import '../../widgets/custom_button.dart';
// import '../../widgets/custom_textfield.dart';
// import '../../widgets/places_autocomplete_field.dart'; // ✅ New import
// import '../../widgets/upload_field.dart';
// import '../../services/location_service.dart';
// import 'package:latlong2/latlong.dart';

// class Step1RestaurantDetails extends StatefulWidget {
//   const Step1RestaurantDetails({Key? key}) : super(key: key);

//   @override
//   State<Step1RestaurantDetails> createState() => _Step1RestaurantDetailsState();
// }

// class _Step1RestaurantDetailsState extends State<Step1RestaurantDetails> {
//   bool _isLoadingLocation = false;
  
//   // ✅ Replace with your actual Google API Key
//   static const String _googleAPIKey = 'YOUR_GOOGLE_PLACES_API_KEY';

//   @override
//   void initState() {
//     super.initState();
//     _autoSetCurrentLocation();
//   }

//   Future<void> _autoSetCurrentLocation() async {
//     final viewModel = context.read<RegistrationViewModel>();
//     if (!mounted) return;
//     setState(() => _isLoadingLocation = true);

//     try {
//       final locationService = LocationService();
//       LatLng? currentLocation = await locationService.getCurrentLocation();

//       if (!mounted) return;

//       if (currentLocation != null) {
//         viewModel.setRestaurantLocation(currentLocation);

//         final String address = await locationService.getAddressFromCoordinates(
//           currentLocation,
//         );

//         if (!mounted) return;
//         viewModel.restaurantAddressController.text = address;
//       } else {
//         if (!mounted) return;
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text(
//               'Unable to fetch location. Tap address field to retry.',
//             ),
//           ),
//         );
//       }
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error getting location: $e')),
//       );
//     } finally {
//       if (!mounted) return;
//       setState(() => _isLoadingLocation = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final viewModel = context.watch<RegistrationViewModel>();

//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text('Tell us about your Restaurant', style: AppTextStyles.h3),
//           const SizedBox(height: 24),

//           CustomTextField(
//             controller: viewModel.restaurantNameController,
//             label: 'Restaurant Name',
//             hint: 'Enter restaurant name',
//           ),
//           const SizedBox(height: 16),

//           // ✅ City Autocomplete - type pannumothu dropdown varum
//           PlacesAutocompleteField(
//             controller: viewModel.cityController,
//             label: 'City',
//             hint: 'Type to search city...',
//             googleAPIKey: _googleAPIKey,
//             types: '(cities)', // Only cities
//             components: 'country:in', // India only
//           ),
//           const SizedBox(height: 16),

//           // ✅ State Autocomplete
//           PlacesAutocompleteField(
//             controller: viewModel.stateController,
//             label: 'State',
//             hint: 'Type to search state...',
//             googleAPIKey: _googleAPIKey,
//             types: 'administrative_area_level_1', 
//             components: 'country:in',
//           ),
//           const SizedBox(height: 16),

//           CustomTextField(
//             controller: viewModel.pincodeController,
//             label: 'Pincode',
//             hint: 'Enter pincode',
//             keyboardType: TextInputType.number,
//             inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//           ),
//           const SizedBox(height: 16),

//           CustomTextField(
//             controller: viewModel.landmarkController,
//             label: 'Landmark (Optional)',
//             hint: 'Enter nearby landmark',
//           ),
//           const SizedBox(height: 16),

//           Stack(
//             alignment: Alignment.centerRight,
//             children: [
//               CustomTextField(
//                 controller: viewModel.restaurantAddressController,
//                 label: 'Restaurant Address',
//                 hint: 'Enter or auto-detect address',
//                 maxLines: 3,
//                 readOnly: false,
//                 suffixIcon: IconButton(
//                   icon: const Icon(Icons.my_location, color: AppColors.primary),
//                   tooltip: 'Detect current location',
//                   onPressed: _isLoadingLocation ? null : _autoSetCurrentLocation,
//                 ),
//               ),
//               if (_isLoadingLocation)
//                 const Positioned(
//                   right: 16,
//                   child: SizedBox(
//                     height: 20,
//                     width: 20,
//                     child: CircularProgressIndicator(strokeWidth: 2),
//                   ),
//                 ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             'You can edit the address or tap the location icon to auto-detect it.',
//             style: AppTextStyles.bodySmall,
//           ),
//           const SizedBox(height: 16),

//           CustomTextField(
//             controller: viewModel.avgCostController,
//             label: 'Average Cost for Two',
//             hint: 'Enter amount in ₹',
//             keyboardType: TextInputType.number,
//             inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//             prefixIcon: const Padding(
//               padding: EdgeInsets.all(16),
//               child: Text('₹', style: AppTextStyles.bodyMedium),
//             ),
//           ),
//           const SizedBox(height: 16),

//           UploadField(
//             label: 'Restaurant Logo',
//             hint: 'Drop your file here, or browse\nUpload PDF, JPG, or PNG (Max 5MB)',
//             isOptional: true,
//             onFileSelected: (path) => viewModel.setRestaurantLogo(path),
//           ),
//           const SizedBox(height: 32),

//           CustomButton(text: 'Continue', onPressed: viewModel.nextStep),
//         ],
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'package:zenzio_restaurant/core/constant/appcolors.dart';
// import '../../core/theme/text_styles.dart';
// import '../../core/constant/dropdown_data.dart';
// import '../../viewmodels/registration_viewmodel.dart';
// import '../../widgets/custom_button.dart';
// import '../../widgets/custom_textfield.dart';
// import '../../widgets/custom_dropdown_field.dart';
// import '../../widgets/upload_field.dart';
// import '../../services/location_service.dart';
// import 'package:latlong2/latlong.dart';

// class Step1RestaurantDetails extends StatefulWidget {
//   const Step1RestaurantDetails({Key? key}) : super(key: key);

//   @override
//   State<Step1RestaurantDetails> createState() => _Step1RestaurantDetailsState();
// }

// class _Step1RestaurantDetailsState extends State<Step1RestaurantDetails> {
//   bool _isLoadingLocation = false;

//   @override
//   void initState() {
//     super.initState();
//     _autoSetCurrentLocation();
//   }

//   Future<void> _autoSetCurrentLocation() async {
//     final viewModel = context.read<RegistrationViewModel>();
//     if (!mounted) return;
//     setState(() => _isLoadingLocation = true);

//     try {
//       final locationService = LocationService();
//       LatLng? currentLocation = await locationService.getCurrentLocation();

//       if (!mounted) return;

//       if (currentLocation != null) {
//         viewModel.setRestaurantLocation(currentLocation);

//         final String address = await locationService.getAddressFromCoordinates(
//           currentLocation,
//         );

//         if (!mounted) return;
//         viewModel.restaurantAddressController.text = address;
//       } else {
//         if (!mounted) return;
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text(
//               'Unable to fetch location. Tap address field to retry.',
//             ),
//           ),
//         );
//       }
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Error getting location: $e')));
//     } finally {
//       if (!mounted) return;
//       setState(() => _isLoadingLocation = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final viewModel = context.watch<RegistrationViewModel>();

//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text('Tell us about your Restaurant', style: AppTextStyles.h3),
//           const SizedBox(height: 24),

//           // Restaurant Name
//           CustomTextField(
//             controller: viewModel.restaurantNameController,
//             label: 'Restaurant Name',
//             hint: 'Enter restaurant name',
//           ),
//           const SizedBox(height: 16),

//           // State Dropdown
//           CustomDropdownField(
//             label: 'State',
//             hint: 'Select state',
//             items: DropdownData.indianStates,
//             value: viewModel.selectedState,
//             onChanged: (value) {
//               viewModel.setSelectedState(value);
//             },
//           ),
//           const SizedBox(height: 16),

//           // City Dropdown (dependent on state)
//           CustomDropdownField(
//             label: 'City',
//             hint: viewModel.selectedState == null
//                 ? 'Select state first'
//                 : 'Select city',
//             items: viewModel.selectedState != null
//                 ? DropdownData.getCitiesForState(viewModel.selectedState!)
//                 : [],
//             value: viewModel.selectedCity,
//             onChanged: viewModel.selectedState != null
//                 ? (value) {
//                     viewModel.setSelectedCity(value);
//                   }
//                 : null,
//           ),
//           const SizedBox(height: 16),

//           CustomTextField(
//             controller: viewModel.pincodeController,
//             label: 'Pincode',
//             hint: 'Enter pincode',
//             keyboardType: TextInputType.number,
//             inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//           ),
//           const SizedBox(height: 16),

//           CustomTextField(
//             controller: viewModel.landmarkController,
//             label: 'Landmark (Optional)',
//             hint: 'Enter nearby landmark',
//           ),
//           const SizedBox(height: 16),

//           // Restaurant Address (auto-filled + editable)
//           Stack(
//             alignment: Alignment.centerRight,
//             children: [
//               CustomTextField(
//                 controller: viewModel.restaurantAddressController,
//                 label: 'Restaurant Address',
//                 hint: 'Enter or auto-detect address',
//                 maxLines: 3,
//                 readOnly: false,
//                 suffixIcon: IconButton(
//                   icon: const Icon(Icons.my_location, color: AppColors.primary),
//                   tooltip: 'Detect current location',
//                   onPressed: _isLoadingLocation
//                       ? null
//                       : _autoSetCurrentLocation,
//                 ),
//               ),
//               if (_isLoadingLocation)
//                 const Positioned(
//                   right: 16,
//                   child: SizedBox(
//                     height: 20,
//                     width: 20,
//                     child: CircularProgressIndicator(strokeWidth: 2),
//                   ),
//                 ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             'You can edit the address or tap the location icon to auto-detect it.',
//             style: AppTextStyles.bodySmall,
//           ),
//           const SizedBox(height: 16),

//           // Average Cost
//           CustomTextField(
//             controller: viewModel.avgCostController,
//             label: 'Average Cost for Two',
//             hint: 'Enter amount in ₹',
//             keyboardType: TextInputType.number,
//             inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//             prefixIcon: const Padding(
//               padding: EdgeInsets.all(16),
//               child: Text('₹', style: AppTextStyles.bodyMedium),
//             ),
//           ),
//           const SizedBox(height: 16),

//           // Upload logo
//           UploadField(
//             label: 'Restaurant Logo',
//             hint:
//                 'Drop your file here, or browse\nUpload PDF, JPG, or PNG (Max 5MB)',
//             isOptional: true,
//             onFileSelected: (path) => viewModel.setRestaurantLogo(path),
//           ),
//           const SizedBox(height: 32),

//           // Continue Button
//           CustomButton(text: 'Continue', onPressed: viewModel.nextStep),
//         ],
//       ),
//     );
//   }
// }
