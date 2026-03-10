import 'api_meta_model.dart';
import 'api_links_model.dart';

/// Base wrapper for all API V3 responses
/// Provides standardized structure with success, data, meta, and links
class ApiResponseModel<T> {
  final bool success;
  final T? data;
  final ApiMetaModel? meta;
  final ApiLinksModel? links;
  final String? message;

  ApiResponseModel({
    required this.success,
    this.data,
    this.meta,
    this.links,
    this.message,
  });

  /// Factory constructor to parse JSON response and convert data
  ///
  /// [json] - The raw JSON response from API
  /// [dataFromJson] - Function to convert the data property to type T
  ///
  /// Example usage:
  /// ```dart
  /// ApiResponseModel<RestaurantModel>.fromJson(
  ///   response.body,
  ///   (data) => RestaurantModel.fromJson(data),
  /// )
  /// ```
  factory ApiResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? dataFromJson,
  ) {
    return ApiResponseModel<T>(
      success: json['success'] ?? false,
      data: json['data'] != null && dataFromJson != null
          ? dataFromJson(json['data'])
          : json['data'] as T?,
      meta: json['meta'] != null
          ? ApiMetaModel.fromJson(json['meta'])
          : null,
      links: json['links'] != null
          ? ApiLinksModel.fromJson(json['links'])
          : null,
      message: json['message'],
    );
  }

  /// Check if the response is successful
  bool get isSuccess => success;

  /// Check if the response has data
  bool get hasData => data != null;

  /// Check if the response has pagination metadata
  bool get hasPagination => meta?.pagination != null;
}
