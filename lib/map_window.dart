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
//
// import 'package:custom_info_window/custom_info_window.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:location/location.dart' as loc;
//
// class CustomInfoWindows extends StatefulWidget {
//   final double initialLatitude;
//   final double initialLongitude;
//
//   const CustomInfoWindows({
//     super.key,
//     required this.initialLatitude,
//     required this.initialLongitude,
//   });
//
//   @override
//   State<CustomInfoWindows> createState() => _CustomInfoWindowsState();
// }
//
// class _CustomInfoWindowsState extends State<CustomInfoWindows> {
//   final CustomInfoWindowController _customInfoWindowController =
//       CustomInfoWindowController();
//   final loc.Location _location = loc.Location();
//   late GoogleMapController _googleMapController;
//   Set<Marker> markers = {};
//
//   @override
//   void initState() {
//     super.initState();
//     _startLocationUpdates();
//   }
//
//   void _startLocationUpdates() async {
//     bool _serviceEnabled;
//     loc.PermissionStatus _permissionGranted;
//
//     _serviceEnabled = await _location.serviceEnabled();
//     if (!_serviceEnabled) {
//       _serviceEnabled = await _location.requestService();
//       if (!_serviceEnabled) return;
//     }
//
//     _permissionGranted = await _location.hasPermission();
//     if (_permissionGranted == loc.PermissionStatus.denied) {
//       _permissionGranted = await _location.requestPermission();
//       if (_permissionGranted != loc.PermissionStatus.granted) return;
//     }
//
//     // Listen for location changes
//     _location.onLocationChanged.listen((loc.LocationData currentLocation) {
//       debugPrint('---------------------Changes--------------------');
//       debugPrint(currentLocation.latitude.toString());
//       debugPrint(currentLocation.longitude.toString());
//       debugPrint('---------------------Changes--------------------');
//       if (currentLocation.latitude != null &&
//           currentLocation.longitude != null) {
//         LatLng newPosition =
//             LatLng(currentLocation.latitude!, currentLocation.longitude!);
//         setState(() {
//           markers = {
//             Marker(
//               markerId: const MarkerId('current_location'),
//               icon: BitmapDescriptor.defaultMarker,
//               position: newPosition,
//               onTap: () {
//                 _customInfoWindowController.addInfoWindow!(
//                   Container(
//                     color: Colors.white,
//                     child: const Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Current Location',
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 18,
//                           ),
//                         ),
//                         SizedBox(height: 4),
//                         Text(
//                           'This is your current location.',
//                           style: TextStyle(fontSize: 16),
//                         ),
//                       ],
//                     ),
//                   ),
//                   newPosition,
//                 );
//               },
//             )
//           };
//           _googleMapController.animateCamera(
//             CameraUpdate.newLatLng(newPosition),
//           );
//         });
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Address'),
//       ),
//       body: Stack(
//         children: [
//           GoogleMap(
//             initialCameraPosition: CameraPosition(
//               target: LatLng(widget.initialLatitude, widget.initialLongitude),
//               zoom: 15,
//             ),
//             markers: markers,
//             onTap: (argument) {
//               _customInfoWindowController.hideInfoWindow!();
//             },
//             onCameraMove: (position) {
//               _customInfoWindowController.onCameraMove!();
//             },
//             onMapCreated: (GoogleMapController controller) {
//               _googleMapController = controller;
//               _customInfoWindowController.googleMapController = controller;
//             },
//           ),
//           CustomInfoWindow(
//             controller: _customInfoWindowController,
//             height: 100,
//             width: 250,
//             offset: 35,
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _customInfoWindowController.dispose();
//     super.dispose();
//   }
// }
//
// import 'dart:async';
// import 'package:custom_info_window/custom_info_window.dart';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:location/location.dart' as loc;
//
// class CustomInfoWindows extends StatefulWidget {
//   final double initialLatitude;
//   final double initialLongitude;
//
//   const CustomInfoWindows({
//     super.key,
//     required this.initialLatitude,
//     required this.initialLongitude,
//   });
//
//   @override
//   State<CustomInfoWindows> createState() => _CustomInfoWindowsState();
// }
//
// class _CustomInfoWindowsState extends State<CustomInfoWindows> with WidgetsBindingObserver {
//   final CustomInfoWindowController _customInfoWindowController = CustomInfoWindowController();
//   final loc.Location _location = loc.Location();
//   final Set<Marker> _markers = {};
//
//   GoogleMapController? _googleMapController;
//   StreamSubscription<loc.LocationData>? _locationSubscription;
//   bool _isDisposed = false;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     _initializeLocation();
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.paused) {
//       _locationSubscription?.pause();
//     } else if (state == AppLifecycleState.resumed) {
//       _locationSubscription?.resume();
//     }
//   }
//
//   Future<void> _initializeLocation() async {
//     try {
//       final serviceEnabled = await _requestLocationService();
//       if (!serviceEnabled) return;
//
//       final permissionGranted = await _requestLocationPermission();
//       if (!permissionGranted) return;
//
//       await _startLocationUpdates();
//     } catch (e) {
//       debugPrint('Location initialization error: $e');
//     }
//   }
//
//   Future<bool> _requestLocationService() async {
//     bool serviceEnabled = await _location.serviceEnabled();
//     if (!serviceEnabled) {
//       serviceEnabled = await _location.requestService();
//     }
//     return serviceEnabled;
//   }
//
//   Future<bool> _requestLocationPermission() async {
//     final permissionStatus = await _location.hasPermission();
//     if (permissionStatus == loc.PermissionStatus.denied) {
//       final newPermissionStatus = await _location.requestPermission();
//       return newPermissionStatus == loc.PermissionStatus.granted;
//     }
//     return permissionStatus == loc.PermissionStatus.granted;
//   }
//
//   Future<void> _startLocationUpdates() async {
//     await _location.changeSettings(
//       interval: 5000, // Update interval in milliseconds
//       distanceFilter: 10, // Minimum distance (meters) before updates
//     );
//
//     _locationSubscription = _location.onLocationChanged.listen(
//       _handleLocationUpdate,
//       onError: (error) {
//         debugPrint('Location update error: $error');
//       },
//     );
//   }
//
//   void _handleLocationUpdate(loc.LocationData currentLocation) {
//     if (_isDisposed || !mounted) return;
//
//     if (currentLocation.latitude != null && currentLocation.longitude != null) {
//       final newPosition = LatLng(
//         currentLocation.latitude!,
//         currentLocation.longitude!,
//       );
//
//       setState(() {
//         _markers.clear();
//         _markers.add(_createMarker(newPosition));
//       });
//
//       _googleMapController?.animateCamera(
//         CameraUpdate.newLatLng(newPosition),
//       );
//     }
//   }
//
//   Marker _createMarker(LatLng position) {
//     return Marker(
//       markerId: const MarkerId('current_location'),
//       icon: BitmapDescriptor.defaultMarker,
//       position: position,
//       onTap: () => _showInfoWindow(position),
//     );
//   }
//
//   void _showInfoWindow(LatLng position) {
//     _customInfoWindowController.addInfoWindow!(
//       Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(8),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: const Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Current Location',
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16,
//               ),
//             ),
//             SizedBox(height: 4),
//             Text(
//               'This is your current location.',
//               style: TextStyle(fontSize: 14),
//             ),
//           ],
//         ),
//       ),
//       position,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Address'),
//         elevation: 0,
//       ),
//       body: Stack(
//         children: [
//           GoogleMap(
//             initialCameraPosition: CameraPosition(
//               target: LatLng(widget.initialLatitude, widget.initialLongitude),
//               zoom: 15,
//             ),
//             markers: _markers,
//             myLocationEnabled: true,
//             myLocationButtonEnabled: true,
//             mapToolbarEnabled: false,
//             onTap: (_) => _customInfoWindowController.hideInfoWindow!(),
//             onCameraMove: (_) => _customInfoWindowController.onCameraMove!(),
//             onMapCreated: (GoogleMapController controller) {
//               _googleMapController = controller;
//               _customInfoWindowController.googleMapController = controller;
//             },
//           ),
//           CustomInfoWindow(
//             controller: _customInfoWindowController,
//             height: 100,
//             width: 250,
//             offset: 35,
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _isDisposed = true;
//     WidgetsBinding.instance.removeObserver(this);
//     _locationSubscription?.cancel();
//     _customInfoWindowController.dispose();
//     _googleMapController?.dispose();
//     super.dispose();
//   }
// }
