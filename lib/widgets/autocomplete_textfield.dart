import 'package:flutter/material.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import '../core/constant/appcolors.dart';
import '../core/theme/text_styles.dart';

class AutocompleteTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String googleAPIKey;
  final String? placeType;

  const AutocompleteTextField({
    Key? key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.googleAPIKey,
    this.placeType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ Changed to bodyMedium (or use any text style that exists in your AppTextStyles)
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        GooglePlaceAutoCompleteTextField(
          textEditingController: controller,
          googleAPIKey: googleAPIKey,
          inputDecoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: Colors.grey,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          debounceTime: 800,
          countries: const ['in'],
          isLatLngRequired: false,
          getPlaceDetailWithLatLng: (Prediction prediction) {
            controller.text = prediction.description ?? '';
          },
          itemClick: (Prediction prediction) {
            controller.text = prediction.description ?? '';
          },
          seperatedBuilder: const Divider(height: 1, thickness: 1),
          itemBuilder: (context, index, Prediction prediction) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_city,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      prediction.description ?? "",
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                ],
              ),
            );
          },
          isCrossBtnShown: true,
        ),
      ],
    );
  }
}