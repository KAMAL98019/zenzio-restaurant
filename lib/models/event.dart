import 'package:zenzio_restaurant/models/api_response.dart';

class Event {
  final String id;
  final String restaurantId;
  final String eventName;
  final String eventDescription;
  final String eventType; // 'EVENT' or 'CLOSURE'
  final String frequency;
  final String? eventDay;
  final String? eventDate;
  final List<String> eventTimes;
  final String associatedDiningArea;
  final bool isActive;

  Event({
    required this.id,
    required this.restaurantId,
    required this.eventName,
    required this.eventDescription,
    required this.eventType,
    required this.frequency,
    this.eventDay,
    this.eventDate,
    required this.eventTimes,
    required this.associatedDiningArea,
    required this.isActive,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      restaurantId: json['restaurantId'],
      eventName: json['eventName'],
      eventDescription: json['eventDescription'],
      eventType: json['eventType'],
      frequency: json['frequency'],
      eventDay: json['eventDay'],
      eventDate: json['eventDate'],
      eventTimes: List<String>.from(json['eventTimes']),
      associatedDiningArea: json['associatedDiningArea'],
      isActive: json['isActive'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurantId': restaurantId,
      'eventName': eventName,
      'eventDescription': eventDescription,
      'eventType': eventType,
      'frequency': frequency,
      'eventDay': eventDay,
      'eventDate': eventDate,
      'eventTimes': eventTimes,
      'associatedDiningArea': associatedDiningArea,
      'isActive': isActive,
    };
  }
}

class EventListResponse extends ApiResponse {
  final List<Event> events;

  EventListResponse({
    required bool success,
    required String message,
    required this.events,
  }) : super(success: success, message: message);

  factory EventListResponse.fromJson(Map<String, dynamic> json) {
    return EventListResponse(
      success: json['success'],
      message: json['message'],
      events: (json['data'] as List)
          .map((eventJson) => Event.fromJson(eventJson))
          .toList(),
    );
  }
}

class EventResponse extends ApiResponse {
  final Event event;

  EventResponse({
    required bool success,
    required String message,
    required this.event,
  }) : super(success: success, message: message);

  factory EventResponse.fromJson(Map<String, dynamic> json) {
    return EventResponse(
      success: json['success'],
      message: json['message'],
      event: Event.fromJson(json['data']),
    );
  }
}