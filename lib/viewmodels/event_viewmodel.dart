import 'package:flutter/material.dart';
import 'package:zenzio_restaurant/models/api_response.dart';
import 'package:zenzio_restaurant/models/event.dart';
import 'package:zenzio_restaurant/models/dining_space.dart';
import 'package:zenzio_restaurant/services/event_service.dart';
import 'package:zenzio_restaurant/services/booking_service.dart';

class EventViewModel extends ChangeNotifier {
  final EventService _eventService = EventService();
  final BookingService _bookingService = BookingService();

  List<Event> _events = [];
  List<Event> get events => _events;

  List<DiningSpace> _diningAreas = [];
  List<DiningSpace> get diningAreas => _diningAreas;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchEvents(String restaurantId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _eventService.getEvents(restaurantId);
    if (response.success) {
      _events = response.events;
    } else {
      _errorMessage = response.message;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchDiningAreas(String restaurantId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _bookingService.getDiningSpaces(restaurantId);
    if (response.success && response.data != null && response.data is Map<String, dynamic>) {
      final Map<String, dynamic> responseData = response.data!;
      if (responseData['spaces'] is List) {
        _diningAreas = (responseData['spaces'] as List)
            .map((json) => DiningSpace.fromJson(json))
            .toList();
      } else {
        _diningAreas = [];
        _errorMessage = 'Failed to load dining spaces: "spaces" key not found or not a list.';
      }
    } else {
      _diningAreas = [];
      _errorMessage = response.message ?? 'Failed to load dining spaces';
    }
    _isLoading = false;
    notifyListeners();
  }


  Future<bool> createEvent(Event event) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _eventService.createEvent(event);
    if (response.success) {
      _events.add(response.event);
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateEvent(String id, Event event) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _eventService.updateEvent(event.restaurantId, id as Event);
    if (response.success) {
      final index = _events.indexWhere((e) => e.id == id);
      if (index != -1) {
        _events[index] = response.event;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteEvent(String restaurantId, String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _eventService.deleteEvent(restaurantId, id);
    if (response.success) {
      _events.removeWhere((event) => event.id == id);
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}