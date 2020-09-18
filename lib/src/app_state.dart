import 'api.dart';
import 'search_options.dart';

class AppState {
  final SearchOptions searchOptions = SearchOptions(
    location: zLocations.first,
    order: zOrder.first,
    sort: zSort.first,
    count: zMaxCount,
  );
}
