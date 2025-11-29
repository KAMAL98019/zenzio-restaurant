import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../core/constant/appcolors.dart';
import '../core/theme/text_styles.dart';
import '../services/google_places_service.dart';

class PlacesAutocompleteField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String googleAPIKey;
  final String types;
  final String? components;

  const PlacesAutocompleteField({
    Key? key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.googleAPIKey,
    this.types = '',
    this.components,
  }) : super(key: key);

  @override
  State<PlacesAutocompleteField> createState() => _PlacesAutocompleteFieldState();
}

class _PlacesAutocompleteFieldState extends State<PlacesAutocompleteField> {
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final placesService = GooglePlacesService(apiKey: widget.googleAPIKey);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TypeAheadField<PlaceSuggestion>(
          controller: widget.controller,
          builder: (context, controller, focusNode) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: widget.hint,
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
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                suffixIcon: controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          controller.clear();
                          setState(() => _errorMessage = null);
                        },
                      )
                    : null,
              ),
              style: AppTextStyles.bodyMedium,
            );
          },
          suggestionsCallback: (search) async {
            print('🔎 Searching for: "$search"'); // Debug
            if (search.isEmpty) return [];
            
            try {
              final results = await placesService.getPlaceSuggestions(
                search,
                types: widget.types,
                components: widget.components,
              );
              
              if (results.isEmpty) {
                setState(() => _errorMessage = 'No results found for "$search"');
              } else {
                setState(() => _errorMessage = null);
              }
              
              return results;
            } catch (e) {
              print('❌ Error in suggestionsCallback: $e');
              setState(() => _errorMessage = 'Error: $e');
              return [];
            }
          },
          itemBuilder: (context, suggestion) {
            return ListTile(
              leading: const Icon(
                Icons.location_on,
                color: AppColors.primary,
                size: 20,
              ),
              title: Text(
                suggestion.description,
                style: AppTextStyles.bodyMedium,
              ),
            );
          },
          onSelected: (suggestion) {
            widget.controller.text = suggestion.description;
            setState(() => _errorMessage = null);
          },
          emptyBuilder: (context) => Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _errorMessage ?? 'No results found',
                  style: AppTextStyles.bodySmall.copyWith(color: Colors.red),
                ),
                const SizedBox(height: 8),
                Text(
                  'Check console logs for details',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          errorBuilder: (context, error) => Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Error: $error',
              style: AppTextStyles.bodySmall.copyWith(color: Colors.red),
            ),
          ),
          loadingBuilder: (context) => const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('Loading...', style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          debounceDuration: const Duration(milliseconds: 500),
        ),
      ],
    );
  }
}
