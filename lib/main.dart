import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import './src/restaurant_search_app.dart';

void main() async {
  await DotEnv().load('.env');
  runApp(RestaurantSearchApp());
}
