import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'package:smart_timer/smart_timer.dart';



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double currentZoom = 13.0;
  MapController mapController = MapController();
  latLng.LatLng currentCenter = latLng.LatLng(0.0, 0.0);
  Position? position;
  double Deplacement = 0.0;
  double pos_latitutde = 0.0;
  double pos_longitude = 0.0;

  update_map() {
    print("Update position map");
    currentCenter = latLng.LatLng(get_latitude(), get_longitude());
  }

  get_latitude() {
    return pos_latitutde;
  }

  get_longitude() {
    return pos_longitude;
  }

  void initState() {


    SmartTimer(
      duration: Duration(seconds: 3),
      onTick: () => {
        _getCurrentLocation(),
        update_map(),
        _zoom(),

        print("Update position"),
      },
    );
    // TODO: implement initState
  }


  @override
  void _getCurrentLocation() async {
    Future<Position> _determinePosition() async {
      LocationPermission permission;
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Future.error('Location Permissions are denied');
        }
      }
      return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    }
    Position position = await _determinePosition();

    setState(() {
      pos_latitutde = position.latitude;
      pos_longitude = position.longitude;
      update_map();
      Deplacement += 0.01;
      print("Position $position");
      print('Bonhome latitude: ${get_latitude()}');
      print('Bonhome Longitude: ${get_longitude()}');
    });
  }


  void _zoom_init() {
    currentZoom = 13.0;
    mapController.move(currentCenter, currentZoom);
  }

  void _zoom() {
    print(currentZoom);
    print(currentCenter);
    currentZoom = currentZoom + 0.2;
    mapController.move(currentCenter, currentZoom);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Ou es - tu ?"),
        ),
        body: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.purple, width: 2.0),
          ),
          child: Center(
            child: Column(
              children: [
                _location(),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        border: Border.all(color: Colors.black54, width: 2.0)),
                    child: SizedBox(
                      width: 350,
                      height: 400,
                      child: Stack(
                        children: <Widget>[
                          Container(
                            child: _mapView(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: Container(
          child: Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.bottomRight,
                child: FloatingActionButton(
                  backgroundColor: Colors.green,
                  onPressed: _getCurrentLocation,
                  tooltip: 'Move  Man',
                  child: const Icon(
                    Icons.man,
                    color: Colors.amber,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: FloatingActionButton(
                  backgroundColor: Colors.green,
                  onPressed: _zoom,
                  tooltip: 'Zoom In',
                  child: const Icon(
                    Icons.add,
                    color: Colors.amber,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: FloatingActionButton(
                  backgroundColor: Colors.green,
                  onPressed: _zoom_init,
                  tooltip: 'Zoom Update',
                  child: const Icon(
                    Icons.update,
                    color: Colors.amber,
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Widget _location() {
    return Container(
        padding: EdgeInsets.all(5.0),
        alignment: Alignment.topLeft,
        child: Text(
          'Location: Lat: $pos_latitutde Long: $pos_longitude',
          // ignore: prefer_const_constructors
          style: TextStyle(
            color: Colors.black54,
          ),
        ));
  }

  Widget _mapView() {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        center: currentCenter,
        maxZoom: 18.0,
        zoom: currentZoom,
        keepAlive: true,
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
        Align(
          alignment: Alignment.center,
          child: MarkerLayer(markers: [
            Marker(
              point: latLng.LatLng(get_latitude(), get_longitude()),
              builder: (context) => Container(
                  child: Icon(
                    Icons.man,
                    color: Colors.redAccent,
                    size: 50.0,
                  )),
            ),
          ]),
        )
      ],
    );
  }
}
