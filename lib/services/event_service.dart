import 'package:zenzio_restaurant/core/constant/api_constant.dart';
import 'package:zenzio_restaurant/models/api_response.dart';
import 'package:zenzio_restaurant/models/event.dart';
import 'package:zenzio_restaurant/services/api_service.dart';

class EventService {
  final ApiService _apiService = ApiService();

  Future<EventListResponse> getEvents(String restaurantId) async {
    final response = await _apiService.get(
      ApiConstants.getEvents(restaurantId),
      fromJson: (json) =>
          (json as List).map((e) => Event.fromJson(e)).toList(),
    );
    return EventListResponse(
      success: response.success,
      message: response.message ?? 'Unknown error',
      events: response.data ?? [],
    );
  }

  Future<EventResponse> createEvent(Event event) async {
    final response = await _apiService.post(
      ApiConstants.createEvent(event.restaurantId),
      data: event.toJson(),
      fromJson: (json) => Event.fromJson(json),
    );
    return EventResponse(
      success: response.success,
      message: response.message ?? 'Unknown error',
      event: response.data ?? Event(
        id: '',
        restaurantId: '',
        eventName: '',
        eventDescription: '',
        eventType: '', // Default value
        frequency: '',
        eventTimes: [],
        associatedDiningArea: '',
        isActive: false,
      ),
    );
  }

  Future<EventResponse> updateEvent(String id, Event event) async {
    final response = await _apiService.put(
      ApiConstants.updateEvent(event.restaurantId, id),
      data: event.toJson(),
      fromJson: (json) => Event.fromJson(json),
    );
    return EventResponse(
      success: response.success,
      message: response.message ?? 'Unknown error',
      event: response.data ?? Event(
        id: '',
        restaurantId: '',
        eventName: '',
        eventDescription: '',
        eventType: '', // Default value
        frequency: '',
        eventTimes: [],
        associatedDiningArea: '',
        isActive: false,
      ),
    );
  }

  Future<ApiResponse> deleteEvent(String restaurantId, String id) async {
    final response = await _apiService.delete(
      ApiConstants.deleteEvent(restaurantId, id),
    );
    return ApiResponse(
      success: response.success,
      message: response.message,
    );
  }
}