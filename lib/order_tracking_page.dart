import 'dart:async';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({Key? key}) : super(key: key);

  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  final loc.Location location = loc.Location();
  loc.LocationData? _currentPosition;
  String _currentAddress = "Fetching address...";
  bool _isFetchingLocation = false;
  bool _isMapReady = false;
  final Set<Marker> _markers = {};
  final CustomInfoWindowController _customInfoWindowController =
  CustomInfoWindowController();
  StreamSubscription<loc.LocationData>? _locationSubscription;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  @override
  void dispose() {
    _customInfoWindowController.dispose();

    _locationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    try {
      await _locationSubscription?.cancel();

      setState(() {
        _isFetchingLocation = true;
      });

      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          throw Exception('Location services are disabled');
        }
      }

      var permission = await location.hasPermission();
      if (permission == loc.PermissionStatus.denied) {
        permission = await location.requestPermission();
        if (permission != loc.PermissionStatus.granted) {
          throw Exception('Location permission denied');
        }
      }


      final locationData = await location.getLocation();
      if (mounted) {
        setState(() {
          _currentPosition = locationData;
          _isMapReady = true;
        });


        _addCurrentLocationMarker(locationData.latitude, locationData.longitude);

        await _getAddressFromLatLng(locationData.latitude!, locationData.longitude!);
      }

      // Setup location change subscription
      _locationSubscription = location.onLocationChanged.listen(
            (loc.LocationData currentLocation) {
          if (mounted) {
            setState(() {
              _currentPosition = currentLocation;
              _addCurrentLocationMarker(
                currentLocation.latitude,
                currentLocation.longitude,
              );
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingLocation = false;
        });
      }
    }
  }

  Future<void> _getAddressFromLatLng(double lat, double lng) async {
    if (!mounted) return;

    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty && mounted) {
        final place = placemarks[0];
        setState(() {
          _currentAddress = '${place.street}, ${place.locality}, '
              '${place.administrativeArea} ${place.postalCode}';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentAddress = 'Unable to fetch address';
        });
      }
    }
  }

  void _addCurrentLocationMarker(double? lat, double? lng) {
    if (lat == null || lng == null || !mounted) return;

    _markers.clear();
    _markers.add(
      Marker(
        markerId: const MarkerId('current_location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        position: LatLng(lat, lng),
        onTap: () {
          if (!mounted) return;
          _customInfoWindowController.addInfoWindow!(
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Location',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currentAddress,
                    style: const TextStyle(fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            LatLng(lat, lng),
          );
        },
      ),
    );
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isMapReady || _currentPosition == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Location"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initializeLocation,
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(
                _currentPosition!.latitude!,
                _currentPosition!.longitude!,
              ),
              zoom: 15,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
            onTap: (position) {
              _customInfoWindowController.hideInfoWindow!();
            },
            onCameraMove: (position) {
              _customInfoWindowController.onCameraMove!();
            },
            onMapCreated: (GoogleMapController controller) {
              _customInfoWindowController.googleMapController = controller;
            },
          ),
          CustomInfoWindow(
            controller: _customInfoWindowController,
            height: 100,
            width: 250,
            offset: 35,
          ),
          if (_isFetchingLocation)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
