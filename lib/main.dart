// https://www.digitalocean.com/community/tutorials/flutter-geolocator-plugin
// https://github.com/Kavit900/flutter_geodata_app
// https://medium.com/unitechie/flutter-tutorial-geolocation-1d07808f1bb9
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// to store apiKey in Environment.apiKey
abstract class Environment {
  static String get apiKey => dotenv.env['apiKey'] ?? '';
}


Future<void> main() async {
  await dotenv.load(fileName: "assets/.env"); // My API key in .env file
  //print('apiKey = ' + Environment.apiKey);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}
