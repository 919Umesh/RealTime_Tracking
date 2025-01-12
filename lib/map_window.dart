import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomInfoWindows extends StatefulWidget {
  final double initialLatitude;
  final double initialLongitude;

  const CustomInfoWindows({
    super.key,
    required this.initialLatitude,
    required this.initialLongitude,
  });

  @override
  State<CustomInfoWindows> createState() => _CustomInfoWindowsState();
}

class _CustomInfoWindowsState extends State<CustomInfoWindows> {
  final CustomInfoWindowController _customInfoWindowController =
  CustomInfoWindowController();
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    addCurrentLocationMarker();
  }

  void addCurrentLocationMarker() {
    markers.add(
      Marker(
        markerId: const MarkerId('current_location'),
        icon: BitmapDescriptor.defaultMarker,
        position: LatLng(widget.initialLatitude, widget.initialLongitude),
        onTap: () {
          _customInfoWindowController.addInfoWindow!(
            Container(
              color: Colors.white,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Location',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'This is your current location.',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            LatLng(widget.initialLatitude, widget.initialLongitude),
          );
        },
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('---------------------Location--------------');
    debugPrint('Latitude: ${widget.initialLatitude}');
    debugPrint('Longitude: ${widget.initialLongitude}');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Address'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(widget.initialLatitude, widget.initialLongitude),
              zoom: 15,
            ),
            markers: markers,
            onTap: (argument) {
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
        ],
      ),
    );
  }
}
