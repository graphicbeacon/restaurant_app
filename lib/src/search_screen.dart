import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'api.dart';
import 'app_state.dart';
import 'search_form.dart';
import 'restaurant_item.dart';

class SearchScreen extends StatefulWidget {
  SearchScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String query;

  @override
  Widget build(BuildContext context) {
    final api = Provider.of<ZomatoApi>(context);
    final state = Provider.of<AppState>(context);

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
              Navigator.pushNamed(context, 'filters');
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
                    future: api.searchRestaurants(query, state.searchOptions),
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
