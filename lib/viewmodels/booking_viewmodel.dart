import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/booking.dart';
import '../models/dining_space.dart';
import '../services/booking_service.dart';
import '../services/auth_service.dart';

class BookingViewModel extends ChangeNotifier {
  final BookingService _bookingService = BookingService();
  final AuthService _authService = AuthService();

  List<Booking> _bookings = [];
  List<DiningSpace> _diningSpaces = [];
  bool _isLoading = false;
  String _selectedStatus = 'All';
  DateTime _selectedDate = DateTime.now();
  String? _restaurantId;

  List<Booking> get bookings => _bookings;
  List<DiningSpace> get diningSpaces => _diningSpaces;
  bool get isLoading => _isLoading;
  String get selectedStatus => _selectedStatus;
  DateTime get selectedDate => _selectedDate;

  final List<String> bookingStatuses = [
    'All',
    'Pending',
    'Confirmed',
    'Seated',
    'Completed',
    'Cancelled',
  ];

  Future<void> initialize() async {
    try {
      print('BookingViewModel: Initializing...');
      _restaurantId = await _authService.getRestaurantId();
      print('BookingViewModel: Restaurant ID: $_restaurantId');

      if (_restaurantId != null) {
        await Future.wait([loadBookings(), loadDiningSpaces()]);
      } else {
        print('BookingViewModel: Restaurant ID not found');
      }
    } catch (e) {
      print('BookingViewModel: Error initializing: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    loadBookings();
  }

  Future<void> loadBookings({String? status}) async {
    if (_restaurantId == null) {
      print('BookingViewModel: Cannot load bookings - Restaurant ID is null');
      return;
    }

    print('BookingViewModel: Loading bookings for: $_restaurantId');
    _isLoading = true;
    notifyListeners();
    debugPrint("$status");
    try {
      final response = await _bookingService.getAllBookings(
        restaurantId: _restaurantId!,
        status: status != 'All' ? status : null,
        date: _selectedDate,
      );
      print("1 ${response.data}");
       _isLoading = false;

      print('BookingViewModel: Response success: ${response.success}');
      print(
        'BookingViewModel: Response data type: ${response.data.runtimeType}',
      );
      print(
        'BookingViewModel: Response data length: ${(response.data is List) ? (response.data as List).length : 'N/A'}',
      );

      if (response.success && response.data != null) {
        // Handle both direct list and nested response
        if (response.data is List) {
          _bookings = (response.data as List)
              .map((json) => Booking.fromJson(json as Map<String, dynamic>))
              .toList();
        } else if (response.data is Map &&
            (response.data as Map)['bookings'] != null) {
          _bookings = ((response.data as Map)['bookings'] as List)
              .map((json) => Booking.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          _bookings = [];
        }

        print('BookingViewModel: Loaded ${_bookings.length} bookings');
        for (var booking in _bookings) {
          print('  - Booking ${booking.id}: ${booking.status}');
        }
      } else {
        _bookings = [];
        print('BookingViewModel: Failed to load bookings: ${response.message}');
      }
    } catch (e) {
      _isLoading = false;
      _bookings = [];
      print('BookingViewModel: Error loading bookings: $e');
    }

    notifyListeners();
  }

  void filterByStatus(String status) {
    _selectedStatus = status;
    loadBookings(status: status);
  }

  Future<bool> acceptBooking(String bookingId, {String? tableNumber}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _bookingService.acceptBooking(
        bookingId: bookingId,
        tableNumber: tableNumber,
      );

      _isLoading = false;
      notifyListeners();

      if (response.success) {
        Fluttertoast.showToast(
          msg: 'Booking accepted successfully!',
          backgroundColor: Colors.green,
        );
        await loadBookings();
        return true;
      } else {
        Fluttertoast.showToast(
          msg: response.message ?? 'Failed to accept booking',
          backgroundColor: Colors.red,
        );
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      Fluttertoast.showToast(msg: 'Error: $e', backgroundColor: Colors.red);
      return false;
    }
  }

  Future<bool> rejectBooking(String bookingId, String reason) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _bookingService.rejectBooking(
        bookingId: bookingId,
        reason: reason,
      );

      _isLoading = false;
      notifyListeners();

      if (response.success) {
        Fluttertoast.showToast(
          msg: 'Booking rejected',
          backgroundColor: Colors.orange,
        );
        await loadBookings();
        return true;
      } else {
        Fluttertoast.showToast(
          msg: response.message ?? 'Failed to reject booking',
          backgroundColor: Colors.red,
        );
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      Fluttertoast.showToast(msg: 'Error: $e', backgroundColor: Colors.red);
      return false;
    }
  }

  Future<bool> cancelBooking(String bookingId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _bookingService.cancelBooking(bookingId);

      _isLoading = false;
      notifyListeners();

      if (response.success) {
        Fluttertoast.showToast(
          msg: 'Booking cancelled',
          backgroundColor: Colors.orange,
        );
        await loadBookings();
        return true;
      } else {
        Fluttertoast.showToast(
          msg: response.message ?? 'Failed to cancel booking',
          backgroundColor: Colors.red,
        );
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      Fluttertoast.showToast(msg: 'Error: $e', backgroundColor: Colors.red);
      return false;
    }
  }

  Future<bool> markAsSeated(String bookingId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _bookingService.markAsSeated(bookingId);

      _isLoading = false;
      notifyListeners();

      if (response.success) {
        Fluttertoast.showToast(
          msg: 'Marked as seated!',
          backgroundColor: Colors.green,
        );
        await loadBookings();
        return true;
      } else {
        Fluttertoast.showToast(
          msg: response.message ?? 'Failed to update booking',
          backgroundColor: Colors.red,
        );
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      Fluttertoast.showToast(msg: 'Error: $e', backgroundColor: Colors.red);
      return false;
    }
  }

  Booking? getBookingById(String id) {
    try {
      return _bookings.firstWhere((booking) => booking.id == id);
    } catch (e) {
      print('BookingViewModel: Booking not found: $id');
      return null;
    }
  }

  // Dining Spaces Management
  Future<void> loadDiningSpaces() async {
    if (_restaurantId == null) {
      print(
        'BookingViewModel: Cannot load dining spaces - Restaurant ID is null',
      );
      return;
    }

    print('BookingViewModel: Loading dining spaces for: $_restaurantId');

    try {
      final response = await _bookingService.getDiningSpaces(_restaurantId!);

      print(
        'BookingViewModel: Dining spaces response success: ${response.success}',
      );
      print(
        'BookingViewModel: Dining spaces response data type: ${response.data.runtimeType}',
      );

      if (response.success && response.data != null) {
        // Handle different response formats
        _diningSpaces = (response.data as List)
            .map((json) => DiningSpace.fromJson(json as Map<String, dynamic>))
            .toList();

        print('BookingViewModel: Loaded ${_diningSpaces.length} dining spaces');
        for (var space in _diningSpaces) {
          print('  - ${space.areaName}: ${space.seatingCapacity} seats');
        }
      } else {
        _diningSpaces = [];
        print(
          'BookingViewModel: Failed to load dining spaces: ${response.message}',
        );
      }

      notifyListeners();
    } catch (e) {
      _diningSpaces = [];
      print('BookingViewModel: Error loading dining spaces: $e');
      notifyListeners();
    }
  }

  Future<bool> addDiningSpace(
    DiningSpace diningSpace,
    List<File>? photos,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _bookingService.createDiningSpace(
        diningSpace: diningSpace,
        photos: photos,
      );

      _isLoading = false;
      notifyListeners();

      if (response.success) {
        Fluttertoast.showToast(
          msg: 'Dining space added successfully!',
          backgroundColor: Colors.green,
        );
        await loadDiningSpaces();
        await loadBookings();
        return true;
      } else {
        Fluttertoast.showToast(
          msg: response.message ?? 'Failed to add dining space',
          backgroundColor: Colors.red,
        );
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      Fluttertoast.showToast(msg: 'Error: $e', backgroundColor: Colors.red);
      return false;
    }
  }

  Future<bool> updateDiningSpace(
    String id,
    DiningSpace diningSpace,
    List<File>? photos,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _bookingService.updateDiningSpace(
        id: id,
        diningSpace: diningSpace,
        photos: photos,
      );

      _isLoading = false;
      notifyListeners();

      if (response.success) {
        Fluttertoast.showToast(
          msg: 'Dining space updated successfully!',
          backgroundColor: Colors.green,
        );
        await loadDiningSpaces();
        await loadBookings();
        return true;
      } else {
        Fluttertoast.showToast(
          msg: response.message ?? 'Failed to update dining space',
          backgroundColor: Colors.red,
        );
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      Fluttertoast.showToast(msg: 'Error: $e', backgroundColor: Colors.red);
      return false;
    }
  }

  Future<bool> deleteDiningSpace(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _bookingService.deleteDiningSpace(id);

      _isLoading = false;
      notifyListeners();

      if (response.success) {
        Fluttertoast.showToast(
          msg: 'Dining space deleted successfully!',
          backgroundColor: Colors.green,
        );
        await loadDiningSpaces();
        await loadBookings();
        return true;
      } else {
        Fluttertoast.showToast(
          msg: response.message ?? 'Failed to delete dining space',
          backgroundColor: Colors.red,
        );
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      Fluttertoast.showToast(msg: 'Error: $e', backgroundColor: Colors.red);
      return false;
    }
  }

  int getTotalSeatingCapacity() {
    return _diningSpaces.fold(0, (sum, space) => sum + space.seatingCapacity);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
