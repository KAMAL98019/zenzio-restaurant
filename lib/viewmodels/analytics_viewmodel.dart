import 'package:flutter/material.dart';
import '../models/analytics.dart';

class AnalyticsViewModel extends ChangeNotifier {
  SalesAnalytics? _analytics;
  bool _isLoading = false;
  String _selectedPeriod = 'Last 7 Days';

  SalesAnalytics? get analytics => _analytics;
  bool get isLoading => _isLoading;
  String get selectedPeriod => _selectedPeriod;

  final List<String> periods = [
    'Last 7 Days',
    'Last 30 Days',
    'Last 3 Months',
    'Last Year',
  ];

  Future<void> loadAnalytics() async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));

    // Load dummy data
    _analytics = SalesAnalytics.dummy();

    _isLoading = false;
    notifyListeners();
  }

  void changePeriod(String period) {
    _selectedPeriod = period;
    loadAnalytics();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
