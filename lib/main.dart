import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

void main() async {
  await DotEnv().load('.env');
  runApp(RestaurantSearchApp());
}

class RestaurantSearchApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SearchPage(title: 'Restaurant App'),
    );
  }
}

class SearchPage extends StatefulWidget {
  SearchPage({Key key, this.title}) : super(key: key);

  final String title;

  final dio = Dio(BaseOptions(
    baseUrl: 'https://developers.zomato.com/api/v2.1/search',
    headers: {
      'user-key': DotEnv().env['ZOMATO_API_KEY'],
      'Accept': 'application/json',
    },
  ));

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String query;

  Future<List> searchRestaurants(String query) async {
    final response = await widget.dio.get('', queryParameters: {
      'q': query,
    });
    return response.data['restaurants'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
        actions: [
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => SearchFilters()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Icon(
                Icons.tune,
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SearchForm(
              onSearch: (q) {
                setState(() {
                  query = q;
                });
              },
            ),
            query == null
                ? Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search,
                          color: Colors.black12,
                          size: 110,
                        ),
                        Text(
                          'No results to display',
                          style: TextStyle(
                            color: Colors.black12,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  )
                : FutureBuilder(
                    future: searchRestaurants(query),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (snapshot.hasData) {
                        return Expanded(
                          child: ListView(
                            children: snapshot.data
                                .map<Widget>(
                                    (json) => RestaurantItem(Restaurant(json)))
                                .toList(),
                          ),
                        );
                      }

                      return Text(
                          'Error retrieving results: ${snapshot.error}');
                    },
                  )
          ],
        ),
      ),
    );
  }
}

class RestaurantItem extends StatelessWidget {
  final Restaurant restaurant;

  RestaurantItem(this.restaurant);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          children: [
            restaurant.thumbnail != null && restaurant.thumbnail.isNotEmpty
                ? Ink(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.blueGrey,
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(restaurant.thumbnail),
                      ),
                    ),
                  )
                : Container(
                    height: 100,
                    width: 100,
                    color: Colors.blueGrey,
                    child: Icon(
                      Icons.restaurant,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant.name,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 7),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.redAccent,
                          size: 15,
                        ),
                        SizedBox(width: 5),
                        Text(restaurant.locality),
                      ],
                    ),
                    SizedBox(height: 5),
                    RatingBarIndicator(
                      rating: double.parse(restaurant.rating),
                      itemBuilder: (_, __) {
                        return Icon(
                          Icons.star,
                          color: Colors.amber,
                        );
                      },
                      itemSize: 20,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class Restaurant {
  final String id;
  final String name;
  final String address;
  final String locality;
  final String rating;
  final int reviews;
  final String thumbnail;

  Restaurant._({
    this.id,
    this.name,
    this.address,
    this.locality,
    this.rating,
    this.reviews,
    this.thumbnail,
  });
  factory Restaurant(Map json) => Restaurant._(
      id: json['restaurant']['id'],
      name: json['restaurant']['name'],
      address: json['restaurant']['location']['address'],
      locality: json['restaurant']['location']['locality'],
      rating: json['restaurant']['user_rating']['aggregate_rating']?.toString(),
      reviews: json['restaurant']['all_reviews_count'],
      thumbnail:
          json['restaurant']['featured_image'] ?? json['restaurant']['thumb']);
}

class SearchForm extends StatefulWidget {
  SearchForm({this.onSearch});

  final void Function(String search) onSearch;

  @override
  _SearchFormState createState() => _SearchFormState();
}

class _SearchFormState extends State<SearchForm> {
  final _formKey = GlobalKey<FormState>();

  var _autoValidate = false;
  var _search;

  @override
  Widget build(context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Form(
        key: _formKey,
        autovalidate: _autoValidate,
        child: Column(
          children: [
            TextFormField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Enter search',
                border: OutlineInputBorder(),
                filled: true,
                errorStyle: TextStyle(fontSize: 15),
              ),
              onChanged: (value) {
                _search = value;
              },
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter a search term';
                }
                return null;
              },
            ),
            SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: RawMaterialButton(
                onPressed: () {
                  final isValid = _formKey.currentState.validate();
                  if (isValid) {
                    widget.onSearch(_search);
                    // Collapses keypad
                    FocusManager.instance.primaryFocus.unfocus();
                  } else {
                    setState(() {
                      _autoValidate = true;
                    });
                  }
                },
                fillColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Text(
                    'Search',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchFilters extends StatefulWidget {
  @override
  _SearchFiltersState createState() => _SearchFiltersState();
}

class _SearchFiltersState extends State<SearchFilters> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Filter your search'),
        backgroundColor: Colors.red,
      ),
      backgroundColor: Colors.red,
      body: Text('Filter your search'),
    );
  }
}
