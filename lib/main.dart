// https://www.digitalocean.com/community/tutorials/flutter-geolocator-plugin
// https://github.com/Kavit900/flutter_geodata_app
// https://medium.com/unitechie/flutter-tutorial-geolocation-1d07808f1bb9
import 'package:flutter/material.dart';
import 'home_page.dart';

void main() {
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
