import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPage createState() => _MapPage();
}

class _MapPage extends State<MapPage> {
  GoogleMapController? _mapController;
  CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(37.7700913, -122.4704359), //Setting Default Location to SF Japanese Tea Garden if can't fetch user location
    zoom: 10.0,
  );

  Position? _currPos;
  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    //Checking if there's locational service perms
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    //Check perms for geolocator & location
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    //grab user pos
    Position user_pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    //set up pos and set camera to user's pos
    setState(() {
      _currPos = user_pos;
      _initialCameraPosition = CameraPosition(
        target: LatLng(user_pos.latitude, user_pos.longitude),
        zoom: 10.0,
      );
    });
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(_initialCameraPosition),
      );
    }
  }

  //update camera to current location. TESTING NEEDED
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_currPos != null) {
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              _currPos!.latitude,
              _currPos!.longitude,
            ),
            zoom: 10.0,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currPos == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Map'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Map'),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: _initialCameraPosition,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MapPage(),
  ));
}