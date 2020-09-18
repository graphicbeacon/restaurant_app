class SearchOptions {
  String location;
  String order;
  String sort;
  double count;
  List<int> categories = [];

  SearchOptions({
    this.location,
    this.order,
    this.sort,
    this.count,
  });

  Map<String, dynamic> toJson() => {
        'entity_type': location,
        'sort': sort,
        'order': order,
        'count': count,
        'category': categories.join(',')
      };
}
