class PageResponse<T> {
  final List<T> content;
  final int totalElements;
  final int totalPages;
  final int pageNumber;
  final int pageSize;
  final bool first;
  final bool last;

  const PageResponse({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.pageNumber,
    required this.pageSize,
    required this.first,
    required this.last,
  });

  factory PageResponse.fromJson(
      Map<String, dynamic> json,
      T Function(Map<String, dynamic>) fromJsonT,
      ) {
    return PageResponse<T>(
      content: (json['content'] as List? ?? [])
          .map((e) => fromJsonT(e as Map<String, dynamic>))
          .toList(),
      totalElements: json['totalElements'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      pageNumber: json['number'] ?? 0,
      pageSize: json['size'] ?? 0,
      first: json['first'] ?? true,
      last: json['last'] ?? true,
    );
  }
}