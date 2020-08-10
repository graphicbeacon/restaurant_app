import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';

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
  List _restaurants;

  void searchRestaurants(String query) async {
    final response = await widget.dio.get('', queryParameters: {
      'q': query,
    });
    setState(() {
      _restaurants = response.data['restaurants'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SearchForm(
              onSearch: searchRestaurants,
            ),
            _restaurants == null
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
                : Expanded(
                    child: ListView(
                      children: _restaurants.map((restaurant) {
                        return ListTile(
                          title: Text(restaurant['restaurant']['name']),
                          subtitle: Text(
                              restaurant['restaurant']['location']['address']),
                          trailing: Text(
                              '${restaurant['restaurant']['user_rating']['aggregate_rating']} stars, '
                              '${restaurant['restaurant']['all_reviews_count']} reviews'),
                        );
                      }).toList(),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
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
