
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  MapPageState createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  final Location _location = Location();
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  StreamSubscription<LocationData>? _locationSubscription;
  LatLng? _currentLocation;
  LatLng? _sourceLocation;
  LatLng? _destinationLocation;
  bool _isSelectingSource = false;
  bool _isSelectingDestination = false;

  //Google map API key
  final String _googleApiKey = 'AIzaSyDQ2c_pOSOFYSjxGMwkFvCVWKjYOM9siow';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final locationData = await _location.getLocation();
      setState(() {
        _currentLocation = LatLng(
          locationData.latitude!,
          locationData.longitude!,
        );
        _updateCurrentLocationMarker();
      });

      _locationSubscription = _location.onLocationChanged.listen((LocationData locationData) {
        setState(() {
          _currentLocation = LatLng(locationData.latitude!, locationData.longitude!);
          _updateCurrentLocationMarker();
          if (_sourceLocation != null && _destinationLocation != null) {
            _getPolylinePoints();
          }
        });
      });
    } catch (e) {
      debugPrint('Error in getting location: $e');
    }
  }

  void _updateCurrentLocationMarker() {
    if (_currentLocation != null) {
      _markers.removeWhere((marker) => marker.markerId.value == 'current');
      _markers.add(
        Marker(
          markerId: const MarkerId('current'),
          position: _currentLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'Current Location'),
        ),
      );
    }
  }

  Future<void> _getPolylinePoints() async {
    PolylinePoints polylinePoints = PolylinePoints();
    try {
      if (_sourceLocation != null && _destinationLocation != null) {
        PolylineResult resultToSource = await polylinePoints.getRouteBetweenCoordinates(
          googleApiKey: _googleApiKey,
          request: PolylineRequest(
            origin: PointLatLng(_sourceLocation!.latitude, _sourceLocation!.longitude),
            destination: PointLatLng(_destinationLocation!.latitude, _destinationLocation!.longitude),
            mode: TravelMode.walking,
          ),
        );

        if (resultToSource.points.isNotEmpty) {
          debugPrint('--------------polyline-------------');
          debugPrint( _sourceLocation.toString());
          debugPrint( _sourceLocation.toString());
          _updatePolyline('source_to_current', resultToSource.points, Colors.blue);
        } else {
          print("No route found from source to current location");
        }
      }

      if (_currentLocation != null && _destinationLocation != null) {
        PolylineResult resultToDestination = await polylinePoints.getRouteBetweenCoordinates(
          googleApiKey: _googleApiKey,
          request: PolylineRequest(
            origin: PointLatLng(_currentLocation!.latitude, _currentLocation!.longitude),
            destination: PointLatLng(_destinationLocation!.latitude, _destinationLocation!.longitude),
            mode: TravelMode.driving,
          ),
        );

        if (resultToDestination.points.isNotEmpty) {
          _updatePolyline('current_to_destination', resultToDestination.points, Colors.red);
        } else {
          print("No route found from current location to destination");
        }
      }
    } catch (e) {
      print("Error occurred: $e");
      debugPrint('Failed to get polyline points: $e');
    }
  }

  void _updatePolyline(String id, List<PointLatLng> points, Color color) {
    List<LatLng> polylineCoordinates = points
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();

    setState(() {
      _polylines.removeWhere((polyline) => polyline.polylineId.value == id);
      _polylines.add(
        Polyline(
          polylineId: PolylineId(id),
          color: color,
          points: polylineCoordinates,
          width: 3,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _getCurrentLocation,
          ),
        ],
      ),
      body: Stack(
        children: [
          _currentLocation == null
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
              target: _currentLocation!,
              zoom: 15,
            ),
            markers: _markers,
            polylines: _polylines,
            onMapCreated: (controller) => _mapController = controller,
            onTap: _handleMapTap,
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isSelectingSource = true;
                      _isSelectingDestination = false;
                    });
                  },
                  child: Text(_sourceLocation == null
                      ? 'Select Source'
                      : 'Change Source'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isSelectingSource = false;
                      _isSelectingDestination = true;
                    });
                  },
                  child: Text(_destinationLocation == null
                      ? 'Select Destination'
                      : 'Change Destination'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleMapTap(LatLng position) {
    if (_isSelectingSource) {
      setState(() {
        _sourceLocation = position;
        _markers.removeWhere((marker) => marker.markerId.value == 'source');
        _markers.add(
          Marker(
            markerId: const MarkerId('source'),
            position: position,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            infoWindow: const InfoWindow(title: 'Source'),
          ),
        );
        _isSelectingSource = false;
      });
    } else if (_isSelectingDestination) {
      setState(() {
        _destinationLocation = position;
        _markers.removeWhere((marker) => marker.markerId.value == 'destination');
        _markers.add(
          Marker(
            markerId: const MarkerId('destination'),
            position: position,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow: const InfoWindow(title: 'Destination'),
          ),
        );
        _isSelectingDestination = false;
      });
    }

    if (_sourceLocation != null && _destinationLocation != null) {
      _getPolylinePoints();
    }
  }
}