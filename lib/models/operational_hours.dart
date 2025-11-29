import 'package:flutter/material.dart';

class OperationalHours {
  final int day;
  final bool enabled;
  final TimeOfDay from;
  final TimeOfDay to;

  OperationalHours({
    required this.day,
    required this.enabled,
    required this.from,
    required this.to,
  });

  factory OperationalHours.fromJson(Map<String, dynamic> json) {
    return OperationalHours(
      day: json['day'] ?? 0,
      enabled: json['enabled'] ?? false,
      from: _timeOfDayFromString(json['from']),
      to: _timeOfDayFromString(json['to']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': _stringFromDayIndex(day),
      'enabled': enabled,
      'from': _stringFromTimeOfDay(from),
      'to': _stringFromTimeOfDay(to),
    };
  }

  OperationalHours copyWith({
    int? day,
    bool? enabled,
    TimeOfDay? from,
    TimeOfDay? to,
  }) {
    return OperationalHours(
      day: day ?? this.day,
      enabled: enabled ?? this.enabled,
      from: from ?? this.from,
      to: to ?? this.to,
    );
  }

  static List<OperationalHours> getDefaultHours() {
    return List.generate(7, (index) {
      return OperationalHours(
        day: index,
        enabled: true,
        from: const TimeOfDay(hour: 9, minute: 0),
        to: const TimeOfDay(hour: 22, minute: 0),
      );
    });
  }

  static TimeOfDay _timeOfDayFromString(String? timeString) {
    if (timeString == null || timeString.isEmpty) {
      return const TimeOfDay(hour: 0, minute: 0);
    }
    final parts = timeString.split(':');
    if (parts.length == 2) {
      return TimeOfDay(
        hour: int.parse(parts[0]),  // Fixed: was int.parse(parts)
        minute: int.parse(parts[1]), // Fixed: was int.parse(parts)
      );
    }
    return const TimeOfDay(hour: 0, minute: 0);
  }

  static String _stringFromTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  static String _stringFromDayIndex(int dayIndex) {
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    if (dayIndex >= 0 && dayIndex < dayNames.length) {
      return dayNames[dayIndex];
    }
    return '';
  }
}
