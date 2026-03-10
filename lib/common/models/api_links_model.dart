/// HATEOAS links model for API V3 paginated responses
/// Provides navigation links for pagination
class ApiLinksModel {
  final String? self;
  final String? first;
  final String? last;
  final String? prev;
  final String? next;

  ApiLinksModel({
    this.self,
    this.first,
    this.last,
    this.prev,
    this.next,
  });

  factory ApiLinksModel.fromJson(Map<String, dynamic> json) {
    return ApiLinksModel(
      self: json['self'],
      first: json['first'],
      last: json['last'],
      prev: json['prev'],
      next: json['next'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'self': self,
      'first': first,
      'last': last,
      'prev': prev,
      'next': next,
    };
  }

  /// Check if there is a next page
  bool get hasNext => next != null;

  /// Check if there is a previous page
  bool get hasPrev => prev != null;
}
