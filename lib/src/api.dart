import 'package:dio/dio.dart';

import 'category.dart';
import 'search_options.dart';

const zLocations = ['city', 'subzone', 'zone', 'landmark', 'metro', 'group'];
const zSort = ['cost', 'rating'];
const zOrder = ['asc', 'desc'];
const double zMaxCount = 20;

class ZomatoApi {
  final List<String> locations = zLocations;
  final List<String> sort = zSort;
  final List<String> order = zOrder;
  final double count = zMaxCount;

  final Dio _dio;
  final List<Category> categories = [];

  ZomatoApi(String key)
      : _dio = Dio(BaseOptions(
          baseUrl: 'https://developers.zomato.com/api/v2.1/',
          headers: {
            'user-key': key,
            'Accept': 'application/json',
          },
        ));

  Future loadCategories() async {
    final response = await _dio.get('categories');
    final data = response.data['categories'];
    categories.addAll(data.map<Category>((json) => Category(
          json['categories']['id'],
          json['categories']['name'],
        )));
  }

  Future<List> searchRestaurants(String query, SearchOptions options) async {
    final response = await _dio.get('search', queryParameters: {
      'q': query,
      ...(options != null ? options.toJson() : {}),
    });
    return response.data['restaurants'];
  }
}
