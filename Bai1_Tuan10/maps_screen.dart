import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  LatLng? _currentPosition;
  LatLng _destination = LatLng(10.7769, 106.7009); // TP.HCM

  static final CameraPosition _initialPosition = CameraPosition(
    target: LatLng(10.7769, 106.7009),
    zoom: 14,
  );

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // Lấy vị trí hiện tại
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng bật dịch vụ vị trí!')),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _addMarker(_currentPosition!, "Vị trí của bạn");
      _moveCamera(_currentPosition!);
    });
  }

  // Thêm marker
  void _addMarker(LatLng position, String markerId) {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId(markerId),
          position: position,
          infoWindow: InfoWindow(title: markerId),
        ),
      );
    });
  }

  // Di chuyển camera
  Future<void> _moveCamera(LatLng position) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLng(position));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Map Navigator')),
      body: GoogleMap(
        initialCameraPosition: _initialPosition,
        markers: _markers,
        polylines: _polylines,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}