
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart' as permission;
import 'map_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final Location _location = Location();
  StreamSubscription<LocationData>? _locationSubscription;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Tracker'),
      ),
      body: Column(
        children: [
          _buildActionButtons(),
          Expanded(child: _buildLocationList()),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: _isLoading ? null : _getLocation,
            child: const Text('Add My Location'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _isLoading ? null : _toggleLiveLocation,
            child: Text(_locationSubscription == null
                ? 'Enable Live Location'
                : 'Stop Live Location'
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('location').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            return _buildLocationTile(doc);
          },
        );
      },
    );
  }

  Widget _buildLocationTile(QueryDocumentSnapshot doc) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(doc['name'].toString()),
        subtitle: Row(
          children: [
            Text('Lat: ${doc['latitude'].toStringAsFixed(4)}'),
            const SizedBox(width: 16),
            Text('Long: ${doc['longitude'].toStringAsFixed(4)}'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.map),
          onPressed: () => _navigateToMap(doc.id),
        ),
      ),
    );
  }

  Future<void> _getLocation() async {
    try {
      setState(() => _isLoading = true);
      final locationData = await _location.getLocation();
      await _updateLocation(locationData);
    } catch (e) {
      _showError('Failed to get location: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleLiveLocation() async {
    if (_locationSubscription != null) {
      await _stopListening();
    } else {
      await _startListening();
    }
  }

  Future<void> _startListening() async {
    try {
      setState(() => _isLoading = true);
      _locationSubscription = _location.onLocationChanged.listen(
        _updateLocation,
        onError: (error) {
          _showError('Location listening error: $error');
          _stopListening();
        },
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _stopListening() async {
    await _locationSubscription?.cancel();
    setState(() => _locationSubscription = null);
  }

  Future<void> _updateLocation(LocationData locationData) async {
    try {
      await _firestore.collection('location').doc('user1').set({
        'latitude': locationData.latitude,
        'longitude': locationData.longitude,
        'name': 'Umesh',
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      _showError('Failed to update location: $e');
    }
  }

  Future<void> _requestPermission() async {
    final status = await permission.Permission.location.request();
    if (status.isDenied) {
      _showError('Location permission is required');
      await _requestPermission();
    } else if (status.isPermanentlyDenied) {
      _showError('Location permission is permanently denied. Please enable it in settings.');
      permission.openAppSettings();
    }
  }

  void _navigateToMap(String userId) {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => MapPage(userId: userId))
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message))
    );
  }
}