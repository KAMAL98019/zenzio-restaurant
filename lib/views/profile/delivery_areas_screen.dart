import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:zenzio_restaurant/core/constant/appcolors.dart';
import 'package:zenzio_restaurant/viewmodels/dashboard_viewmodel.dart';
import 'package:zenzio_restaurant/models/restaurant.dart';
import 'package:zenzio_restaurant/services/restaurant_service.dart';

class DeliveryAreasScreen extends StatefulWidget {
  const DeliveryAreasScreen({Key? key}) : super(key: key);

  @override
  State<DeliveryAreasScreen> createState() => _DeliveryAreasScreenState();
}

class _DeliveryAreasScreenState extends State<DeliveryAreasScreen> {
  double _deliveryRadius = 5.0; // Default to 5 km
  final RestaurantService _restaurantService = RestaurantService();
  late DashboardViewModel _dashboardViewModel;
  String? _restaurantId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _dashboardViewModel = Provider.of<DashboardViewModel>(
      context,
      listen: false,
    );
    _restaurantId = _dashboardViewModel.restaurantId;
    _loadDeliverySettings();
  }

  Future<void> _loadDeliverySettings() async {
    if (_restaurantId == null) return;

    setState(() {
      _isLoading = true;
    });

    final response = await _restaurantService.getRestaurantById(_restaurantId!);
    if (response.success && response.data != null) {
      final restaurant = response.data!;
      setState(() {
        _deliveryRadius = restaurant.deliveryRadius ?? 5.0;
      });
    } else {
      debugPrint('Failed to load restaurant data: ${response.message}');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveDeliveryAreas() async {
    if (_restaurantId == null) return;

    setState(() {
      _isLoading = true;
    });

    final currentRestaurant = _dashboardViewModel.currentRestaurant;
    if (currentRestaurant == null) {
      debugPrint('Current restaurant data is null.');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final updatedRestaurant = Restaurant(
      id: _restaurantId!,
      restaurantName: currentRestaurant.restaurantName,
      contactPerson: currentRestaurant.contactPerson, // Added required field
      avgCostTwo: currentRestaurant.avgCostTwo,
      photo: currentRestaurant.photo, // Changed from restLogo
      firstName: currentRestaurant.firstName,
      lastName: currentRestaurant.lastName,
      email: currentRestaurant.email,
      phoneNumber: currentRestaurant.phoneNumber,
      restContactNumber: currentRestaurant.restContactNumber,
      password: currentRestaurant.password, // Added required field
      restEmail: currentRestaurant.restEmail,
      restWebsite: currentRestaurant.restWebsite,
      socialMedia: currentRestaurant.socialMedia,
      operationalHours: currentRestaurant.operationalHours,
      documents: currentRestaurant.documents,
      bankDetails: currentRestaurant.bankDetails,
      agreeToTerms: currentRestaurant.agreeToTerms,
      status: currentRestaurant.status,
      deliveryType: 'RADIUS', // Assuming RADIUS for this screen
      deliveryRadius: _deliveryRadius,
      deliveryZones: currentRestaurant.deliveryZones,
      minOrderAmount: currentRestaurant.minOrderAmount,
      baseDeliveryFee: currentRestaurant.baseDeliveryFee,
      otp: currentRestaurant.otp,
      otpExpiry: currentRestaurant.otpExpiry,
      otpVerified: currentRestaurant.otpVerified,
      createdAt: currentRestaurant.createdAt,
      updatedAt: DateTime.now().toIso8601String(),
      address: currentRestaurant.address,
    );

    final response = await _restaurantService.updateRestaurant(
      _restaurantId!,
      updatedRestaurant,
    );

    if (response.success) {
      await _dashboardViewModel.fetchRestaurantDetails();
      if (mounted) {
        Navigator.pop(context);
      }
    } else {
      debugPrint('Failed to update delivery areas: ${response.message}');
    }

    setState(() {
      _isLoading = false;
    });
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
          'Delivery Areas',
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
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        // 'Restaurant Location: ${_dashboardViewModel.currentRestaurant?.address?.address ?? 'N/A'}',
                        "",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: LatLng(
                          _dashboardViewModel.currentRestaurant?.address?.lat ??
                              28.6139,
                          _dashboardViewModel.currentRestaurant?.address?.lng ??
                              77.2090,
                        ),
                        initialZoom: 13.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.zenzio.restaurant',
                        ),
                        CircleLayer(
                          circles: [
                            CircleMarker(
                              point: LatLng(
                                _dashboardViewModel
                                        .currentRestaurant
                                        ?.address
                                        ?.lat ??
                                    28.6139,
                                _dashboardViewModel
                                        .currentRestaurant
                                        ?.address
                                        ?.lng ??
                                    77.2090,
                              ),
                              radius:
                                  _deliveryRadius *
                                  1000, // Convert km to meters
                              color: AppColors.primary.withOpacity(0.3),
                              borderColor: AppColors.primary,
                              borderStrokeWidth: 2,
                            ),
                          ],
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              width: 80.0,
                              height: 80.0,
                              point: LatLng(
                                _dashboardViewModel
                                        .currentRestaurant
                                        ?.address
                                        ?.lat ??
                                    28.6139,
                                _dashboardViewModel
                                        .currentRestaurant
                                        ?.address
                                        ?.lng ??
                                    77.2090,
                              ),
                              child: const Icon(
                                Icons.location_on,
                                color: AppColors.primary,
                                size: 40.0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Delivery Radius: ${_deliveryRadius.toStringAsFixed(0)} km',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Slider(
                    value: _deliveryRadius,
                    min: 1,
                    max: 20,
                    divisions: 19,
                    activeColor: AppColors.primary,
                    inactiveColor: Colors.grey.shade300,
                    onChanged: (newValue) {
                      setState(() {
                        // Round to nearest 0.5 km for smoother increments
                        _deliveryRadius = (newValue * 2).round() / 2;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildRadiusOption(1),
                      _buildRadiusOption(3),
                      _buildRadiusOption(5),
                      _buildRadiusOption(10),
                      _buildRadiusOption(15),
                      _buildRadiusOption(20),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Customers outside this radius cannot order delivery.',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveDeliveryAreas,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 20,
                        ),
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
                              'Save Delivery Areas',
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

  Widget _buildRadiusOption(int radius) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _deliveryRadius = radius.toDouble();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _deliveryRadius == radius
              ? AppColors.primary
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _deliveryRadius == radius
                ? AppColors.primary
                : Colors.grey.shade300,
          ),
        ),
        child: Text(
          '$radius km',
          style: TextStyle(
            color: _deliveryRadius == radius ? Colors.white : Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
