import 'package:flutter/material.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';

class LocationPage extends StatefulWidget {
  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  loc.Location location = loc.Location(); // Use loc prefix for the Location class
  loc.LocationData? _currentPosition;
  String _currentAddress = "Fetching address...";
  bool _isFetchingLocation = false;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    setState(() {
      _isFetchingLocation = true;
    });

    bool _serviceEnabled;
    loc.PermissionStatus _permissionGranted;

    // Check if the location service is enabled
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        setState(() {
          _isFetchingLocation = false;
        });
        return;
      }
    }

    // Check for location permission
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == loc.PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != loc.PermissionStatus.granted) {
        setState(() {
          _isFetchingLocation = false;
        });
        return;
      }
    }

    // Listen to location changes
    location.onLocationChanged.listen((loc.LocationData currentLocation) {
      setState(() {
        _currentPosition = currentLocation;
        _getAddressFromLatLng(_currentPosition!.latitude, _currentPosition!.longitude);
        _isFetchingLocation = false;
      });
    });
  }

  Future<void> _getAddressFromLatLng(double? lat, double? lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat!, lng!);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _currentAddress = "${place.locality}, ${place.postalCode}, ${place.country}";
        });
      }
    } catch (e) {
      setState(() {
        _currentAddress = "Could not fetch address";
      });
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Location Example"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_currentPosition != null)
              Text(
                "Latitude: ${_currentPosition!.latitude}, Longitude: ${_currentPosition!.longitude}",
                style: TextStyle(fontSize: 16),
              )
            else
              Text(
                "Fetching location...",
                style: TextStyle(fontSize: 16),
              ),
            SizedBox(height: 10),
            Text(
              "Address: $_currentAddress",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isFetchingLocation ? null : _getLocation,
              child: Text("Refresh Location"),
            ),
          ],
        ),
      ),
    );
  }
}
