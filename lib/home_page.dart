import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latLng;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Position? _position;
  void _getCurrentLocation() async {
    Position position = await _determinePosition();
    setState(() {
      _position = position;
      print("Position $_position");
      print(position.latitude) ;
      print(position.longitude);
    });
  }

  Future<Position> _determinePosition() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location Permissions are denied');
      }
    }
    return await Geolocator.getCurrentPosition();
  }

  double currentZoom = 13.0;
  MapController mapController = MapController();
  latLng.LatLng currentCenter = latLng.LatLng(51.509364, -0.128928);

  void _zoom() {
    currentZoom = currentZoom - 1;
    mapController.move(currentCenter, currentZoom);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ou es - tu ?"),
      ),
      body: Center(
        child: Column(
          children: [
            _location(),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0)  ,
                  border: Border.all(
                    color: Colors.black54,
                    width : 2.0
                  )
                ),
                child: SizedBox(
                  width: 350,
                  height: 400,

                  child: Stack(
                    children : <Widget>[
                      Container(
                          child: _mapView(),
                      ),
                      Container(

                      ),
                    ],
                  ),

                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _location() {
    return Container(
      padding: EdgeInsets.all(5.0),
      alignment: Alignment.topLeft,
      child: _position != null
        ? Text('Current Location: ' + _position.toString(),style: TextStyle(
          color: Colors.black54,
        ),)
        : Text('No Location Data'),
    );
  }

  Widget _mapView() {
    return FlutterMap(
      options: MapOptions(
        center: currentCenter,
        maxZoom: 19,
        zoom: currentZoom,
      ),
      nonRotatedChildren: [
        AttributionWidget.defaultWidget(
          source: 'OpenStreetMap contributors',
          onSourceTapped: null,
        ),
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
          userAgentPackageName: 'com.example.app',
        ),
        MarkerLayer(markers: [
          Marker(
            width: 45.0,
            height: 45.0,
            point: latLng.LatLng(51.509364, -0.128928),
            builder: (context) => Container(
              child: IconButton(
                icon: const Icon(Icons.man_2),
                color: Colors.red,
                iconSize: 50.0,
                onPressed: () {},
              ),
            ),
          ),
        ])
      ],
    );
  }
}
