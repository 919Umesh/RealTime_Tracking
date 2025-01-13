
// map_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  final String userId;

  const MapPage({Key? key, required this.userId}) : super(key: key);

  @override
  MapPageState createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  GoogleMapController? _mapController;
  bool _isMapCreated = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Location Map')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('location').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          try {
            final userDoc = snapshot.data!.docs.firstWhere(
                    (doc) => doc.id == widget.userId
            );

            final latitude = userDoc['latitude'] as double;
            final longitude = userDoc['longitude'] as double;
            final location = LatLng(latitude, longitude);

            return GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                target: location,
                zoom: 15,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('user_location'),
                  position: location,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueMagenta
                  ),
                ),
              },
              onMapCreated: (controller) {
                setState(() {
                  _mapController = controller;
                  _isMapCreated = true;
                });
                _animateToLocation(location);
              },
            );
          } catch (e) {
            return Center(
              child: Text('Error loading map: $e'),
            );
          }
        },
      ),
    );
  }

  Future<void> _animateToLocation(LatLng location) async {
    if (_mapController != null) {
      await _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: location,
            zoom: 15,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}