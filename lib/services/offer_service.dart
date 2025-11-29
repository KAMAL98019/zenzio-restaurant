import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import '../models/api_response.dart';
import '../models/offer.dart';
import '../core/constant/api_constant.dart';
import 'api_service.dart';

class OfferService {
  final ApiService _apiService = ApiService();

  Future<ApiResponse<List<Offer>>> getAllOffers({
    required String restaurantId,
    String? statusFilter,
  }) async {
    try {
      print('OfferService: Getting all offers');
      final queryParameters = {'restaurantId': restaurantId};
      if (statusFilter != null) queryParameters['statusFilter'] = statusFilter;

      return await _apiService.get(
        ApiConstants.offers,
        queryParameters: queryParameters,
        fromJson: (responseData) {
          List<dynamic> dataList = [];
          if (responseData is Map && responseData.containsKey('data')) {
            dataList = responseData['data'] as List;
          } else if (responseData is List) {
            dataList = responseData;
          }

          return dataList
              .map((json) {
                try {
                  return Offer.fromJson(json);
                } catch (e) {
                  print('Error parsing offer: $e');
                  return null;
                }
              })
              .whereType<Offer>()
              .toList();
        },
      );
    } catch (e) {
      print('OfferService error in getAllOffers: $e');
      return ApiResponse.error(error: e, message: 'Failed to load offers');
    }
  }

  Future<ApiResponse<Offer>> updateOffer({
    required String id,
    required Offer offer,
    File? imageFile,
  }) async {
    try {
      print('OfferService: Updating offer $id');

      final dio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      FormData formData = FormData.fromMap({
        'rest_name': offer.restaurantId,
        'title': offer.title,
        'description': offer.description ?? '',
        'discountType': offer.discountType,
        'discountValue': offer.discountValue,
        if (offer.minOrderValue != null) 'minOrderValue': offer.minOrderValue,
        'startDate': offer.startDate.toIso8601String().split('T').first,
        'endDate': offer.endDate.toIso8601String().split('T').first,
        if (offer.startTime != null) 'startTime': offer.startTime,
        if (offer.endTime != null) 'endTime': offer.endTime,
        'termsConditions': offer.termsConditions ?? '',
      });

      if (imageFile != null) {
        formData.files.add(
          MapEntry('offerImage', await MultipartFile.fromFile(imageFile.path)),
        );
      }

      final response = await dio.put(ApiConstants.offer(id), data: formData);

      print('OfferService: Update response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data is Map && response.data.containsKey('data')
            ? response.data['data']
            : response.data;
        return ApiResponse.success(
          data: Offer.fromJson(data),
          message: 'Offer updated successfully!',
        );
      } else {
        return ApiResponse.error(
          error: 'HTTP ${response.statusCode}',
          message: 'Failed to update offer',
        );
      }
    } on TimeoutException {
      print('OfferService: Update timeout');
      return ApiResponse.error(error: 'Timeout', message: 'Request timeout');
    } catch (e) {
      print('OfferService error in updateOffer: $e');
      return ApiResponse.error(error: e, message: 'Failed to update offer: $e');
    }
  }

  Future<ApiResponse<dynamic>> deleteOffer({
    required String id,
    required String restaurantId,
  }) async {
    try {
      print('OfferService: Deleting offer $id');

      final dio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      final response = await dio.delete(
        ApiConstants.offer(id),
        data: {'restaurantId': restaurantId},
      );

      print('OfferService: Delete response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return ApiResponse.success(
          data: response.data,
          message: 'Offer deleted successfully',
        );
      } else {
        return ApiResponse.error(
          error: 'HTTP ${response.statusCode}',
          message: 'Failed to delete offer',
        );
      }
    } on TimeoutException {
      print('OfferService: Delete timeout');
      return ApiResponse.error(error: 'Timeout', message: 'Request timeout');
    } catch (e) {
      print('OfferService error in deleteOffer: $e');
      return ApiResponse.error(error: e, message: 'Failed to delete offer: $e');
    }
  }

  Future<ApiResponse<Offer>> createOffer({
    required Offer offer,
    File? imageFile,
  }) async {
    try {
      print('OfferService: Creating offer');

      final dio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      FormData formData = FormData.fromMap(offer.toJson());

      if (imageFile != null) {
        formData.files.add(
          MapEntry('offerImage', await MultipartFile.fromFile(imageFile.path)),
        );
      }

      final response = await dio.post(ApiConstants.offers, data: formData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data is Map && response.data.containsKey('data')
            ? response.data['data']
            : response.data;
        return ApiResponse.success(
          data: Offer.fromJson(data),
          message: 'Offer created successfully!',
        );
      } else {
        return ApiResponse.error(
          error: 'HTTP ${response.statusCode}',
          message: 'Failed to create offer',
        );
      }
    } catch (e) {
      print('OfferService error in createOffer: $e');
      return ApiResponse.error(error: e, message: 'Failed to create offer: $e');
    }
  }

  Future<ApiResponse<Offer>> getOffer({
    required String id,
    required String restaurantId,
  }) async {
    try {
      return await _apiService.get(
        ApiConstants.offer(id),
        queryParameters: {'restaurantId': restaurantId},
        fromJson: (data) {
          if (data is Map && data.containsKey('data')) {
            return Offer.fromJson(data['data']);
          }
          return Offer.fromJson(data);
        },
      );
    } catch (e) {
      print('OfferService error in getOffer: $e');
      return ApiResponse.error(error: e, message: 'Failed to load offer');
    }
  }
}
