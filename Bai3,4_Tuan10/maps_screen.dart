import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

const String _kApiKey = 'AIzaSyCBXXfM9i7EWbjQkKF4ZmT8A4khSDLYIJY';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _mapController = Completer();
  final TextEditingController _startCtrl = TextEditingController();
  final TextEditingController _endCtrl = TextEditingController();

  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  LatLng? _startLatLng;
  LatLng? _endLatLng;

  // [Bài 4] kết quả khoảng cách & thời gian
  String? _distance;
  String? _duration;
  bool _isLoading = false;

  static const _defaultCamera = CameraPosition(
    target: LatLng(10.7769, 106.7009), // TP.HCM
    zoom: 12,
  );

  @override
  void initState() {
    super.initState();
    _setGpsAs(isOrigin: true); // tự lấy GPS làm điểm xuất phát
  }

  @override
  void dispose() {
    _startCtrl.dispose();
    _endCtrl.dispose();
    super.dispose();
  }

  // Xin quyền + lấy vị trí GPS
  Future<Position?> _getPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      _snack('Vui lòng bật GPS trên thiết bị!');
      return null;
    }
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) return null;
    }
    if (perm == LocationPermission.deniedForever) {
      _snack('Quyền vị trí bị từ chối. Vào Settings để bật.');
      return null;
    }
    return Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  // Dùng GPS làm điểm xuất phát (isOrigin=true) hoặc đích (false)
  Future<void> _setGpsAs({required bool isOrigin}) async {
    final pos = await _getPosition();
    if (pos == null) return;

    final latLng = LatLng(pos.latitude, pos.longitude);
    final text =
        '${pos.latitude.toStringAsFixed(6)}, ${pos.longitude.toStringAsFixed(6)}';

    setState(() {
      if (isOrigin) {
        _startLatLng = latLng;
        _startCtrl.text = text;
        _updateMarker(latLng, 'start', 'Điểm xuất phát');
      } else {
        _endLatLng = latLng;
        _endCtrl.text = text;
        _updateMarker(latLng, 'end', 'Điểm đích (vị trí hiện tại)');
        _clearRoute();
      }
    });
    _moveCamera(latLng);
  }

  // [Bài 4] Tap trên bản đồ → đặt điểm đích
  void _onMapTap(LatLng pos) {
    setState(() {
      _endLatLng = pos;
      _endCtrl.text =
      '${pos.latitude.toStringAsFixed(6)}, ${pos.longitude.toStringAsFixed(6)}';
      _updateMarker(pos, 'end', 'Điểm đích');
      _clearRoute();
    });
  }

  void _clearRoute() {
    _distance = null;
    _duration = null;
    _polylines.clear();
  }

  void _updateMarker(LatLng pos, String id, String title) {
    _markers.removeWhere((m) => m.markerId.value == id);
    _markers.add(Marker(
      markerId: MarkerId(id),
      position: pos,
      infoWindow: InfoWindow(title: title),
    ));
  }

  Future<void> _moveCamera(LatLng pos, {double zoom = 14}) async {
    final ctrl = await _mapController.future;
    ctrl.animateCamera(
        CameraUpdate.newCameraPosition(CameraPosition(target: pos, zoom: zoom)));
  }

  // Tìm đường + [Bài 4] lấy khoảng cách & thời gian
  Future<void> _findRoute() async {
    _startLatLng = _parse(_startCtrl.text) ?? _startLatLng;
    _endLatLng = _parse(_endCtrl.text) ?? _endLatLng;

    if (_startLatLng == null || _endLatLng == null) {
      _snack('Vui lòng nhập đủ điểm xuất phát và đích!');
      return;
    }

    setState(() => _isLoading = true);

    final url = 'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=${_startLatLng!.latitude},${_startLatLng!.longitude}'
        '&destination=${_endLatLng!.latitude},${_endLatLng!.longitude}'
        '&key=$_kApiKey';

    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final routes = data['routes'] as List?;

        if (routes != null && routes.isNotEmpty) {
          final leg = routes[0]['legs'][0];
          final points =
          _decodePolyline(routes[0]['overview_polyline']['points']);

          setState(() {
            _distance = leg['distance']['text'];   // [Bài 4]
            _duration = leg['duration']['text'];   // [Bài 4]
            _markers.clear();
            _updateMarker(_startLatLng!, 'start', 'Điểm xuất phát');
            _updateMarker(_endLatLng!, 'end', 'Điểm đích');
            _polylines
              ..clear()
              ..add(Polyline(
                polylineId: const PolylineId('route'),
                points: points,
                color: Colors.blue,
                width: 5,
              ));
          });
          _moveCamera(_startLatLng!, zoom: 12);
        } else {
          _snack('Không tìm thấy tuyến đường!');
        }
      } else {
        _snack('Lỗi API: ${res.statusCode}');
      }
    } catch (e) {
      _snack('Lỗi kết nối: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Helpers
  LatLng? _parse(String text) {
    final p = text.split(',');
    if (p.length != 2) return null;
    final lat = double.tryParse(p[0].trim());
    final lng = double.tryParse(p[1].trim());
    return (lat != null && lng != null) ? LatLng(lat, lng) : null;
  }

  List<LatLng> _decodePolyline(String encoded) {
    final pts = <LatLng>[];
    int i = 0, lat = 0, lng = 0;
    while (i < encoded.length) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(i++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lat += (result & 1) != 0 ? ~(result >> 1) : result >> 1;
      shift = 0; result = 0;
      do {
        b = encoded.codeUnitAt(i++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lng += (result & 1) != 0 ? ~(result >> 1) : result >> 1;
      pts.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return pts;
  }

  void _snack(String msg) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg)));

  // UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Maps - Bài 3 & 4'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Panel nhập điểm
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
            child: Column(
              children: [
                _locationRow(
                  ctrl: _startCtrl,
                  label: 'Điểm xuất phát (lat, lng)',
                  color: Colors.green,
                  icon: Icons.radio_button_checked,
                  gpsIcon: Icons.my_location,
                  gpsTip: 'Lấy vị trí hiện tại làm điểm xuất phát',
                  onGps: () => _setGpsAs(isOrigin: true),
                ),
                const SizedBox(height: 6),
                _locationRow(
                  ctrl: _endCtrl,
                  label: 'Điểm đích (lat, lng) — hoặc nhấn trên bản đồ',
                  color: Colors.red,
                  icon: Icons.location_on,
                  gpsIcon: Icons.gps_fixed,
                  gpsTip: 'Lấy vị trí hiện tại làm điểm đích',
                  onGps: () => _setGpsAs(isOrigin: false),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _findRoute,
                    icon: _isLoading
                        ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.directions),
                    label: Text(_isLoading ? 'Đang tìm...' : 'Tìm đường đi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                // [Bài 4] Banner khoảng cách & thời gian
                if (_distance != null && _duration != null)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade300),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _infoChip(Icons.straighten, 'Khoảng cách', _distance!),
                        VerticalDivider(color: Colors.blue.shade300, width: 24),
                        _infoChip(Icons.access_time, 'Thời gian', _duration!),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          // Bản đồ
          Expanded(
            child: GoogleMap(
              initialCameraPosition: _defaultCamera,
              markers: _markers,
              polylines: _polylines,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              onMapCreated: (c) => _mapController.complete(c),
              onTap: _onMapTap, // [Bài 4]
            ),
          ),
        ],
      ),
    );
  }

  Widget _locationRow({
    required TextEditingController ctrl,
    required String label,
    required Color color,
    required IconData icon,
    required IconData gpsIcon,
    required String gpsTip,
    required VoidCallback onGps,
  }) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: Icon(icon, color: color, size: 20),
              border: const OutlineInputBorder(),
              contentPadding:
              const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              isDense: true,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Tooltip(
          message: gpsTip,
          child: IconButton(
            onPressed: onGps,
            icon: Icon(gpsIcon, color: color),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ),
      ],
    );
  }

  Widget _infoChip(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.blue.shade700),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: TextStyle(fontSize: 11, color: Colors.blue.shade700)),
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ],
    );
  }
}