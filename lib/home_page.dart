import 'package:flutter/material.dart';
import 'package:geo/main.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'package:smart_timer/smart_timer.dart'; // to refresh position by timer
import 'package:deta/deta.dart'; // database https://deta.space/collections
import 'package:dio_client_deta_api/dio_client_deta_api.dart';
import 'package:dio/dio.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool selected = false;
  double currentZoom = 13.0;
  MapController mapController = MapController();
  latLng.LatLng currentCenter = latLng.LatLng(0.0, 0.0);
  Position? position;
  double zoomIn_step = 0.20;
  double pos_latitutde = 0.0;
  double pos_longitude = 0.0;

  update_map() {
    // print("Update position map");
    currentCenter = latLng.LatLng(get_latitude(), get_longitude());
  }

  get_position() {
    return currentCenter;
    // LatLng(latitude:37.421998, longitude:-122.084)
  }

  get_latitude() {
    return pos_latitutde; // plus precis 37.421998333333335
  }

  get_longitude() {
    return pos_longitude; // plus precis -122.084
  }

// gestion database https://deta.space/collections
  detaBase(String position) async {
    // print('apikey => ' + Environment.apiKey);
    // My API Key in Environment.apiKey , TOP SECRET...
    String baseName =
        "data_position"; // Name of the base (Base: data_position )
    final deta = Deta(
        projectKey: Environment.apiKey, client: DioClientDetaApi(dio: Dio()));
    final detabase = deta.base(baseName);
    // final all = await detabase.fetch(); // get all
    final pos = await detabase.get('john'); // get datas  by Key ='john'
    // update position in database
    await detabase.update(
      key: 'john',
      item: <String, dynamic>{
        'key': 'john',
        // pos_latitude , pos_longitude update
        'position': pos_latitutde.toString() + ' ' + pos_longitude.toString(),
      },
    );
    // print(all);
    print(pos['position']);
  }

  void initState() {
    // update by timer
    SmartTimer(
      duration: Duration(seconds: 5),
      onTick: () => {
        _getCurrentLocation(),
        update_map(),
        _zoom(),
        // print('update position : '),
        // print(get_position()),
        detaBase(get_position().toString()), // use only update detabase
      },
    );
  }

  @override
  void _getCurrentLocation() async {
    // position GPS
    Future<Position> _determinePosition() async {
      LocationPermission permission;
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Future.error('Location Permissions are denied');
        }
      }
      return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    }

    Position position = await _determinePosition();

    setState(() {
      selected = !selected;
      pos_latitutde = position.latitude;
      pos_longitude = position.longitude;
      update_map();
      // Deplacement += 0.01;
      // print("Position $position");
      // print('Bonhome latitude: ${get_latitude()}');
      // print('Bonhome Longitude: ${get_longitude()}');
    });
  }

  void _zoom_init() {
    currentZoom = 13.0;
    mapController.move(currentCenter, currentZoom);
  }

  void _zoom() {
    print('current  Zoom :  $currentZoom');
    (currentZoom > 18) ? currentZoom = 18 : currentZoom = currentZoom + zoomIn_step;

    mapController.move(currentCenter, currentZoom);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Ou es - tu ?",
            style: TextStyle(fontSize: 25.0),
          ),
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
          style: TextStyle(
            color: selected ? Colors.black54 : Colors.blue,
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
