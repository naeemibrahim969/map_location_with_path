import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_map_polyline_new/google_map_polyline_new.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Map Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Center(child: MyHomePage(title: 'Google Map')),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late GoogleMapController _controller;
  static const LatLng sourceLocation = LatLng(31.5204, 74.3587);
  static const LatLng destination = LatLng(31.4697, 74.2728);

  GoogleMapPolyline googleMapPolyline = new GoogleMapPolyline(apiKey:"");
  final List<Polyline> polyline = [];
  List<LatLng> routeCoords = [];

  LocationData? currentLocation;

  void getCurrentLocation(){
    Location location = Location();
    location.getLocation().then((_location){
      // print("Location "+_location.latitude.toString());
      // print("Location "+_location.longitude.toString());
      currentLocation = _location;
      setState(() {});

    });

    location.onLocationChanged.listen((newLocation) {

      _controller.animateCamera(
          CameraUpdate.newCameraPosition(
              CameraPosition(target: LatLng(newLocation.latitude!,newLocation.longitude!),zoom:18.0)
          )
      );
      currentLocation = newLocation;
      setState(() {});
    });
  }

  @override
  void initState() {
    getCurrentLocation();
    computePath();
    super.initState();
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
  }

  computePath()async{
    LatLng origin = new LatLng(sourceLocation.latitude, sourceLocation.longitude);
    LatLng end = new LatLng(destination.latitude, destination.longitude);
    routeCoords.addAll((await googleMapPolyline.getCoordinatesWithLocation(origin: origin, destination: end, mode: RouteMode.driving)) as Iterable<LatLng>);

    setState(() {
      polyline.add(Polyline(
          polylineId: PolylineId('iter'),
          visible: true,
          points: routeCoords,
          width: 5,
          color: Colors.blueAccent,
          startCap: Cap.roundCap,
          endCap: Cap.buttCap
      ));
    });
  }


  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body:currentLocation!=null ? GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
            target:LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
            zoom: 14.0),
        // polylines: _polyline,
        polylines: Set.from(polyline),
        markers: {
          Marker(markerId: MarkerId("current"),position: LatLng(currentLocation!.latitude!, currentLocation!.longitude!)),
          Marker(markerId: MarkerId("source"),position: sourceLocation),
          Marker(markerId: MarkerId("destination"),position: destination),
        },
      ):const Center(child: Text("Loading"),)
    );
  }
}
