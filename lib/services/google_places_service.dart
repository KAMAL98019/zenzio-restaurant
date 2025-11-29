import 'dart:convert';
import 'package:http/http.dart' as http;

class GooglePlacesService {
  static const String _baseUrl =
      'https://maps.googleapis.com/maps/api/place/autocomplete/json';

  final String apiKey;

  GooglePlacesService({required this.apiKey});

  Future<List<PlaceSuggestion>> getPlaceSuggestions(
    String input, {
    String types = '',
    String? components,
  }) async {
    if (input.isEmpty) return [];

    final queryParams = {
      'input': input,
      'key': apiKey,
      'language': 'en',
    };

    // Add components if provided
    if (components != null && components.isNotEmpty) {
      queryParams['components'] = components;
    }

    // Add types if provided
    if (types.isNotEmpty) {
      queryParams['types'] = types;
    }

    final url = Uri.parse(_baseUrl).replace(queryParameters: queryParams);

    print('🔍 API URL: $url'); // Debug print

    try {
      final response = await http.get(url);
      
      print('📡 Response Status: ${response.statusCode}'); // Debug print
      print('📡 Response Body: ${response.body}'); // Debug print

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK') {
          final predictions = data['predictions'] as List;
          print('✅ Found ${predictions.length} suggestions'); // Debug print
          return predictions
              .map((p) => PlaceSuggestion.fromJson(p))
              .toList();
        } else {
          print('❌ API Error: ${data['status']} - ${data['error_message'] ?? 'No error message'}');
          return [];
        }
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Exception: $e');
      return [];
    }
  }
}

class PlaceSuggestion {
  final String description;
  final String placeId;

  PlaceSuggestion({
    required this.description,
    required this.placeId,
  });

  factory PlaceSuggestion.fromJson(Map<String, dynamic> json) {
    return PlaceSuggestion(
      description: json['description'] ?? '',
      placeId: json['place_id'] ?? '',
    );
  }
}