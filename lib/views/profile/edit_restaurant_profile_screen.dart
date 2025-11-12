import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zenzio_restaurant/core/constant/appcolors.dart';
import 'package:zenzio_restaurant/models/restaurant.dart';
import 'package:zenzio_restaurant/services/restaurant_service.dart';
import 'package:zenzio_restaurant/viewmodels/dashboard_viewmodel.dart';
import 'package:zenzio_restaurant/widgets/custom_text_field.dart';

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
  final TextEditingController _contactPersonNameController =
      TextEditingController();
  final TextEditingController _contactEmailController =
      TextEditingController();
  final TextEditingController _contactMobileNumberController =
      TextEditingController();
  final TextEditingController _restaurantDescriptionController =
      TextEditingController();
  final TextEditingController _averageCostForTwoController =
      TextEditingController();
  final TextEditingController _fullAddressController =
      TextEditingController();

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
      _restaurantNameController.text = restaurant.restName;
      _contactPersonNameController.text = restaurant.contactPersonName;
      _contactEmailController.text = restaurant.contactEmail;
      _contactMobileNumberController.text = restaurant.contactNumber;
      _averageCostForTwoController.text = restaurant.avgCostTwo;
      _fullAddressController.text = restaurant.restAddress;
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
      restName: _restaurantNameController.text,
      restAddress: _fullAddressController.text,
      avgCostTwo: _averageCostForTwoController.text,
      restLogo: _dashboardViewModel.currentRestaurant?.restLogo ?? '',
      contactPersonName: _contactPersonNameController.text,
      contactEmail: _contactEmailController.text,
      contactNumber: _contactMobileNumberController.text,
      operationalHours:
          _dashboardViewModel.currentRestaurant?.operationalHours ?? [],
      fssaiCertificate:
          _dashboardViewModel.currentRestaurant?.fssaiCertificate ?? '',
      gstCertificate:
          _dashboardViewModel.currentRestaurant?.gstCertificate ?? '',
      bankAccountName:
          _dashboardViewModel.currentRestaurant?.bankAccountName ?? '',
      accountNumber:
          _dashboardViewModel.currentRestaurant?.accountNumber ?? '',
      ifscCode: _dashboardViewModel.currentRestaurant?.ifscCode ?? '',
      agreeToTerms:
          _dashboardViewModel.currentRestaurant?.agreeToTerms ?? false,
      status: _dashboardViewModel.currentRestaurant?.status ?? 'inactive',
      deliveryType:
          _dashboardViewModel.currentRestaurant?.deliveryType ?? 'RADIUS',
      deliveryRadius:
          _dashboardViewModel.currentRestaurant?.deliveryRadius,
      deliveryZones: _dashboardViewModel.currentRestaurant?.deliveryZones,
      restaurantLatitude:
          _dashboardViewModel.currentRestaurant?.restaurantLatitude,
      restaurantLongitude:
          _dashboardViewModel.currentRestaurant?.restaurantLongitude,
      minOrderAmount:
          _dashboardViewModel.currentRestaurant?.minOrderAmount,
      baseDeliveryFee:
          _dashboardViewModel.currentRestaurant?.baseDeliveryFee,
      otp: _dashboardViewModel.currentRestaurant?.otp,
      otpExpiry: _dashboardViewModel.currentRestaurant?.otpExpiry,
      otpVerified:
          _dashboardViewModel.currentRestaurant?.otpVerified ?? false,
      createdAt: _dashboardViewModel.currentRestaurant?.createdAt ??
          DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
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
    _contactPersonNameController.dispose();
    _contactEmailController.dispose();
    _contactMobileNumberController.dispose();
    _restaurantDescriptionController.dispose();
    _averageCostForTwoController.dispose();
    _fullAddressController.dispose();
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
                    controller: _contactPersonNameController,
                    labelText: 'Contact Person Name',
                    hintText: 'John Smith',
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _contactEmailController,
                    labelText: 'Contact Email',
                    hintText: 'contact@goldenspoon.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _contactMobileNumberController,
                    labelText: 'Contact Mobile Number',
                    hintText: '+91 98765 43210',
                    keyboardType: TextInputType.phone,
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
