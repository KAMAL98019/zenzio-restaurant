import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:zenzio_restaurant/core/constant/appcolors.dart';
import 'package:zenzio_restaurant/utils/text_formatters.dart';
import 'package:zenzio_restaurant/viewmodels/dashboard_viewmodel.dart';
import 'package:zenzio_restaurant/models/restaurant.dart';
import 'package:zenzio_restaurant/services/restaurant_service.dart';
import 'package:zenzio_restaurant/models/bank_details.dart';
import 'package:zenzio_restaurant/widgets/custom_text_field.dart';
import 'package:flutter/services.dart';

class BankDetailsScreen extends StatefulWidget {
  const BankDetailsScreen({Key? key}) : super(key: key);

  @override
  State<BankDetailsScreen> createState() => _BankDetailsScreenState();
}

class _BankDetailsScreenState extends State<BankDetailsScreen> {
  // final TextEditingController _bankAccountNameController =
  //     TextEditingController(); // Removed as per BankDetails model update
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _ifscCodeController = TextEditingController();

  final RestaurantService _restaurantService = RestaurantService();
  late DashboardViewModel _dashboardViewModel;
  String? _restaurantId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _dashboardViewModel =
        Provider.of<DashboardViewModel>(context, listen: false);
    _restaurantId = _dashboardViewModel.restaurantId;
    _loadBankDetails();
  }

  Future<void> _loadBankDetails() async {
    if (_restaurantId == null) return;

    setState(() {
      _isLoading = true;
    });

    final response = await _restaurantService.getRestaurantById(_restaurantId!);
    if (response.success && response.data != null) {
      final restaurant = response.data!;
      setState(() {
        _bankNameController.text = restaurant.bankDetails?.bankName ?? '';
        _accountNumberController.text =
            restaurant.bankDetails?.accountNumber ?? '';
        _ifscCodeController.text = restaurant.bankDetails?.ifscCode ?? '';
      });
    } else {
      debugPrint('Failed to load bank details: ${response.message}');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveBankDetails() async {
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
      bankDetails: BankDetails(
        bankName: _bankNameController.text,
        accountNumber: _accountNumberController.text,
        ifscCode: _ifscCodeController.text,
        accountType: currentRestaurant.bankDetails.accountType,
      ),
      agreeToTerms: currentRestaurant.agreeToTerms,
      status: currentRestaurant.status,
      deliveryType: currentRestaurant.deliveryType,
      deliveryRadius: currentRestaurant.deliveryRadius,
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
        _restaurantId!, updatedRestaurant);

    if (response.success) {
      await _dashboardViewModel.fetchRestaurantDetails();
      if (mounted) {
        Navigator.pop(context);
      }
    } else {
      debugPrint('Failed to update bank details: ${response.message}');
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    // _bankAccountNameController.dispose(); // Removed
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _ifscCodeController.dispose();
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
          'Bank Details',
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
                  // Currently Saved Details Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Currently Saved Details',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            Icon(Icons.lock_outline, color: Colors.grey.shade600),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Account Number: XXXXXX${_accountNumberController.text.isNotEmpty ? _accountNumberController.text.substring(_accountNumberController.text.length - 4) : '1234'}',
                          style: const TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Bank Name: ${_dashboardViewModel.currentRestaurant?.bankDetails?.bankName ?? 'HDFC Bank'}',
                          style: const TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'IFSC: ${_ifscCodeController.text.isNotEmpty ? _ifscCodeController.text : 'HDFC0000123'}',
                          style: const TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Update Bank Details Section
                  const Text(
                    'Update Bank Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // CustomTextField(
                  //   controller: _bankAccountNameController,
                  //   labelText: 'Enter account holder name',
                  //   hintText: 'Enter account holder name',
                  // ),
                  // const SizedBox(height: 16),
                  TextFormField(
                    controller: _accountNumberController,
                    decoration: InputDecoration(
                      labelText: 'Enter account number',
                      hintText: 'Enter account number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(11),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _bankNameController,
                    decoration: InputDecoration(
                      labelText: 'Enter bank name',
                      hintText: 'Enter bank name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _ifscCodeController,
                    decoration: InputDecoration(
                      labelText: 'Enter IFSC code',
                      hintText: 'Enter IFSC code',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                      LengthLimitingTextInputFormatter(11),
                      UpperCaseTextFormatter(),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange.shade700, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'For your security, bank detail changes require re-verification by admin. Processing may take 1-2 business days.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveBankDetails,
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
                              'Save Bank Details',
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
