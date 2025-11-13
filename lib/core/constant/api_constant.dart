class ApiConstants {
  // Base URL
  // static const String baseUrl = 'https://backend.zenzio.in';

  static const String baseUrl =
      'https://erica-transthoracic-envyingly.ngrok-free.dev';

  // API Endpoints
  static const String login = '/restaurants/auth/login/email';
  static const String register = '/restaurants/auth/signup/email';
  static const String sendPhoneOtp = '/otp/send';
  static const String verifyPhoneOtp = '/otp/verify';

  // ✅ Use your actual values from /clients/generate
  static const clientId = '0fb4e7a0-8ca8-46a3-8ffe-0f4a078bb811';
  static const clientSecret = ''; 

  // Restaurant Profile
  static String restaurantDetails(String id) => '/api/restaurants/$id';
  static String updateRestaurant(String id) => '/api/restaurants/$id';

  // Forgot Password
  static const String sendForgotPasswordOtp = '/api/restaurants/forgot-password/send-otp';
  static const String verifyForgotPasswordOtp = '/api/restaurants/forgot-password/verify-otp';
  static const String resetPassword =
      '/api/restaurants/forgot-password/reset-password';

  // Restaurant Status
  static String restaurantStatus() => '/api/restaurant-status';

  // Timeout
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static const String orders = '/api/all';
  static String acceptOrder(String id) => '/api/$id/accept';
  static String rejectOrder(String id) => '/api/$id/reject';
  static String updateOrderStatus(String id) => '/api/$id/status';
  static String trackOrder(String id) => '/api/$id/track';

  static const String foodItems = '/api/food-items';
  static String foodItem(String id) => '/api/food-items/$id';

  // Categories & Cuisines
  static const String categories = '/api/categories';
  static String categoryById(String id) => '/api/categories/$id';
  static const String cuisines = '/api/cuisines';
  static String cuisineById(String id) => '/api/cuisines/$id';

  static const String bookings = '/api/bookings';
  static String booking(String id) => '/api/bookings/$id';
  static String acceptBooking(String id) => '/api/bookings/$id/accept';
  static String rejectBooking(String id) => '/api/bookings/$id/reject';
  static String cancelBooking(String id) => '/api/bookings/$id/cancel';
  static String markAsSeated(String id) => '/api/bookings/$id/seated';

  // Dining Spaces
  static String diningSpaces(String restaurantId) =>
      '/api/dining-spaces/{restaurantId}?restaurantId=$restaurantId';
  static const String createDiningSpace = '/api/dining-spaces';
  static String updateDiningSpace(String id) => '/api/dining-spaces/$id';
  static String deleteDiningSpace(String id) => '/api/dining-spaces/$id';

  // Events
  static String getEvents(String restaurantId) => '/api/events/$restaurantId';
  static String createEvent(String restaurantId) => '/api/events/$restaurantId';
  static String updateEvent(String restaurantId, String id) =>
      '/api/events/$restaurantId/$id';
  static String deleteEvent(String restaurantId, String id) =>
      '/api/events/$restaurantId/$id';

  static const String offers = '/api/restaurant/offers';
  static String offer(String id) => '/api/restaurant/offers/$id';
  static String deleteOffer(String id) =>
      '/api/restaurant/offers/$id'; // Add this line
}
