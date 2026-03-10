/// Metadata model for API V3 responses
/// Contains pagination information and other metadata
class ApiMetaModel {
  final String? version;
  final String? timestamp;
  final String? requestId;
  final PaginationMetaModel? pagination;

  ApiMetaModel({
    this.version,
    this.timestamp,
    this.requestId,
    this.pagination,
  });

  factory ApiMetaModel.fromJson(Map<String, dynamic> json) {
    return ApiMetaModel(
      version: json['version'],
      timestamp: json['timestamp'],
      requestId: json['request_id'],
      pagination: json['pagination'] != null
          ? PaginationMetaModel.fromJson(json['pagination'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'timestamp': timestamp,
      'request_id': requestId,
      'pagination': pagination?.toJson(),
    };
  }
}

/// Pagination metadata for paginated API responses
class PaginationMetaModel {
  final int currentPage;
  final int perPage;
  final int total;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;

  PaginationMetaModel({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory PaginationMetaModel.fromJson(Map<String, dynamic> json) {
    return PaginationMetaModel(
      currentPage: json['current_page'] ?? 1,
      perPage: json['per_page'] ?? 20,
      total: json['total'] ?? 0,
      totalPages: json['total_pages'] ?? 0,
      hasNext: json['has_next'] ?? false,
      hasPrev: json['has_prev'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'per_page': perPage,
      'total': total,
      'total_pages': totalPages,
      'has_next': hasNext,
      'has_prev': hasPrev,
    };
  }

  /// Convert to V1-style pagination for backward compatibility in controllers
  /// Returns offset-based pagination that existing code expects
  int get offset => (currentPage - 1) * perPage;
  int get limit => perPage;
  int get totalSize => total;
}
