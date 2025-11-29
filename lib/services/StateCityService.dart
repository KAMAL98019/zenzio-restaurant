import 'dart:convert';
import 'package:flutter/services.dart';

class StateCityService {
  static Map<String, List<String>>? _stateCityData;

  static Future<void> loadData() async {
    final jsonString = await rootBundle.loadString('assets/data/india_cities.json');
    _stateCityData = Map<String, List<String>>.from(json.decode(jsonString));
  }

  static List<String> getStates() {
    return _stateCityData?.keys.toList() ?? [];
  }

  static List<String> getCities(String state) {
    return _stateCityData?[state] ?? [];
  }
}
