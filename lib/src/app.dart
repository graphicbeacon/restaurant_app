import 'package:flutter/material.dart';

import 'search_screen.dart';
import 'search_filters_screen.dart';

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
      initialRoute: 'home',
      routes: {
        'home': (context) => SearchPage(title: 'Restaurant App'),
        'filters': (context) => SearchFilters(),
      },
    );
  }
}
