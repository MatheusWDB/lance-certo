class Pageable {
  Pageable({required this.page, required this.size, this.sort});

  int page;
  int size;
  List<String>? sort;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {};
    map['page'] = page;
    map['size'] = size;
    if (sort != null || sort!.isNotEmpty) map['sort'] = sort;
    return map;
  }

  @override
  String toString() {
    return 'Pageable{page: $page, size: $size, sort: $sort}';
  }
}
