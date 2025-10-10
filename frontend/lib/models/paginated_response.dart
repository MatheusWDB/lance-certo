class PaginatedResponse<T> {
  PaginatedResponse({
    required this.content,
    required this.number,
    required this.size,
    required this.totalElements,
    required this.totalPages,
  });

  final List<dynamic> content;
  final int number;
  final int size;
  final int totalElements;
  final int totalPages;

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedResponse(
      content: (json['content'] as List<dynamic>)
          .map((itemJson) => fromJsonT(itemJson as Map<String, dynamic>))
          .toList(),
      number: json['page']['number'] as int,
      size: json['page']['size'] as int,
      totalElements: json['page']['totalElements'] as int,
      totalPages: json['page']['totalPages'] as int,
    );
  }
}
