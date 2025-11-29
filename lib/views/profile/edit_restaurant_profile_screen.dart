import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zenzio_restaurant/core/constant/appcolors.dart';
import 'package:zenzio_restaurant/models/restaurant.dart';
import 'package:zenzio_restaurant/services/restaurant_service.dart';
import 'package:zenzio_restaurant/viewmodels/dashboard_viewmodel.dart';
import 'package:zenzio_restaurant/widgets/custom_text_field.dart';
import 'package:zenzio_restaurant/models/address.dart';

class EditRestaurantProfileScreen extends StatefulWidget {
  const EditRestaurantProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditRestaurantProfileScreen> createState() =>
      _EditRestaurantProfileScreenState();
}

class _EditRestaurantProfileScreenState
    extends State<EditRestaurantProfileScreen> {
  final RestaurantService _restaurantService = RestaurantService();
  late DashboardViewModel _dashboardViewModel;

  final TextEditingController _restaurantNameController =
      TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _restaurantDescriptionController =
      TextEditingController();
  final TextEditingController _averageCostForTwoController =
      TextEditingController();
  final TextEditingController _fullAddressController =
      TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _restContactNumberController =
      TextEditingController();
  final TextEditingController _restEmailController = TextEditingController();
  final TextEditingController _restWebsiteController = TextEditingController();
  final TextEditingController _socialMediaController = TextEditingController();

  String? _restaurantId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _dashboardViewModel =
        Provider.of<DashboardViewModel>(context, listen: false);
    _restaurantId = _dashboardViewModel.restaurantId;
    _loadRestaurantData();
  }

  Future<void> _loadRestaurantData() async {
    if (_restaurantId == null) return;

    setState(() {
      _isLoading = true;
    });

    final response = await _restaurantService.getRestaurantById(_restaurantId!);
    if (response.success && response.data != null) {
      final restaurant = response.data!;
      _restaurantNameController.text = restaurant.restaurantName;
      _firstNameController.text = restaurant.firstName ?? '';
      _lastNameController.text = restaurant.lastName ?? '';
      _emailController.text = restaurant.email;
      _phoneNumberController.text = restaurant.phoneNumber;
      _restContactNumberController.text = restaurant.restContactNumber;
      _restEmailController.text = restaurant.restEmail ?? '';
      _restWebsiteController.text = restaurant.restWebsite ?? '';
      _socialMediaController.text = restaurant.socialMedia ?? '';
      _averageCostForTwoController.text = restaurant.avgCostTwo ?? '';
      _fullAddressController.text = restaurant.address.address;
      _landmarkController.text = restaurant.address.landMark ?? '';
      _cityController.text = restaurant.address.city;
      _stateController.text = restaurant.address.state;
      _pincodeController.text = restaurant.address.pincode;
    } else {
      debugPrint('Failed to load restaurant data: ${response.message}');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _updateRestaurantProfile() async {
    if (_restaurantId == null) return;

    setState(() {
      _isLoading = true;
    });

    final updatedRestaurant = Restaurant(
      id: _restaurantId!,
      restaurantName: _restaurantNameController.text,
      contactPerson: _firstNameController.text.trim() + ' ' + _lastNameController.text.trim(), // Added required field
      avgCostTwo: _averageCostForTwoController.text,
      photo: _dashboardViewModel.currentRestaurant?.photo ?? [], // Replaced restLogo with photo
      firstName: _firstNameController.text.isEmpty ? null : _firstNameController.text,
      lastName: _lastNameController.text.isEmpty ? null : _lastNameController.text,
      email: _emailController.text,
      phoneNumber: _phoneNumberController.text,
      restContactNumber: _restContactNumberController.text,
      password: _dashboardViewModel.currentRestaurant?.password ?? '', // Added required field
      restEmail: _restEmailController.text.isEmpty ? null : _restEmailController.text,
      restWebsite: _restWebsiteController.text.isEmpty ? null : _restWebsiteController.text,
      socialMedia: _socialMediaController.text.isEmpty ? null : _socialMediaController.text,

      operationalHours:
          _dashboardViewModel.currentRestaurant?.operationalHours ?? [],
      documents: _dashboardViewModel.currentRestaurant!.documents,
      bankDetails: _dashboardViewModel.currentRestaurant!.bankDetails,
      agreeToTerms:
          _dashboardViewModel.currentRestaurant?.agreeToTerms,
      status: _dashboardViewModel.currentRestaurant?.status,
      deliveryType:
          _dashboardViewModel.currentRestaurant?.deliveryType,
      deliveryRadius:
          _dashboardViewModel.currentRestaurant?.deliveryRadius,
      deliveryZones: _dashboardViewModel.currentRestaurant?.deliveryZones,
      minOrderAmount:
          _dashboardViewModel.currentRestaurant?.minOrderAmount,
      baseDeliveryFee:
          _dashboardViewModel.currentRestaurant?.baseDeliveryFee,
      otp: _dashboardViewModel.currentRestaurant?.otp,
      otpExpiry: _dashboardViewModel.currentRestaurant?.otpExpiry,
      otpVerified:
          _dashboardViewModel.currentRestaurant?.otpVerified ?? false,
      createdAt: _dashboardViewModel.currentRestaurant?.createdAt,
      updatedAt: DateTime.now().toIso8601String(),
      address: Address(
        address: _fullAddressController.text,
        city: _cityController.text,
        state: _stateController.text,
        pincode: _pincodeController.text,
        landMark: _landmarkController.text,
        lat: _dashboardViewModel.currentRestaurant?.address.lat ?? 0.0,
        lng: _dashboardViewModel.currentRestaurant?.address.lng ?? 0.0,
      ),
    );

    final response = await _restaurantService.updateRestaurant(
        _restaurantId!, updatedRestaurant);

    if (response.success) {
      await _dashboardViewModel.fetchRestaurantDetails(); // Await the fetch
      if (mounted) {
        // Use read to avoid listening if not needed for this specific widget
        // but ensure the DashboardScreen (which listens) will rebuild.
        // Alternatively, if this screen needs to react to the change,
        // consider making it listen to the DashboardViewModel.
        Navigator.pop(context);
      }
    } else {
      debugPrint('Failed to update profile: ${response.message}');
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _restaurantNameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _restaurantDescriptionController.dispose();
    _averageCostForTwoController.dispose();
    _fullAddressController.dispose();
    _landmarkController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _restContactNumberController.dispose();
    _restEmailController.dispose();
    _restWebsiteController.dispose();
    _socialMediaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Restaurant Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: const DecorationImage(
                                  image:
                                      AssetImage('assets/images/zenzioicon.png'),
                                  fit: BoxFit.cover,
                                ),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white, width: 2),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(4.0),
                                  child: Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () {
                            // Handle logo upload
                          },
                          child: const Text(
                            'Change Logo',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    controller: _restaurantNameController,
                    labelText: 'Restaurant Name',
                    hintText: 'Golden Spoon Restaurant',
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _firstNameController,
                    labelText: 'Contact Person First Name',
                    hintText: 'John',
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _lastNameController,
                    labelText: 'Contact Person Last Name',
                    hintText: 'Smith',
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _emailController,
                    labelText: 'Contact Email',
                    hintText: 'contact@goldenspoon.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _phoneNumberController,
                    labelText: 'Contact Mobile Number',
                    hintText: '+91 98765 43210',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _restContactNumberController,
                    labelText: 'Restaurant Contact Number',
                    hintText: '+91 98765 43210',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _restEmailController,
                    labelText: 'Restaurant Email',
                    hintText: 'restaurant@goldenspoon.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _restWebsiteController,
                    labelText: 'Restaurant Website (Optional)',
                    hintText: 'www.goldenspoon.com',
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _socialMediaController,
                    labelText: 'Social Media Link (Optional)',
                    hintText: 'facebook.com/goldenspoon',
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _restaurantDescriptionController,
                    labelText: 'Restaurant Description / Tagline',
                    hintText:
                        'Serving authentic cuisine with locally sourced ingredients since 1995.',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _averageCostForTwoController,
                    labelText: 'Average Cost for Two',
                    hintText: '600',
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.currency_rupee, size: 18),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _fullAddressController,
                    labelText: 'Full Address',
                    hintText:
                        '123, ABC Complex, MG Road, Bangalore - 560001, Karnataka, India',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      // Handle map location
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.location_on,
                            color: AppColors.primary, size: 18),
                        SizedBox(width: 4),
                        Text(
                          'Locate on Map',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ✅ Direct ElevatedButton instead of CustomButton
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          _isLoading ? null : () => _updateRestaurantProfile(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Update Profile',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
