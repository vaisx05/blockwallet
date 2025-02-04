import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as map_tool;

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  late final MapController _mapController;
  LatLng? _currentLocation;
  List<LatLng> polygonPoints = [];
  List<Marker> markers = []; // List to store the markers
  bool isRectangleMode = true; // Toggle between rectangle or pin points

  final Color _geofenceColor =
      Colors.blue.withOpacity(0.2); // Semi-transparent blue

  final TextEditingController _point1Controller = TextEditingController();
  final TextEditingController _point2Controller = TextEditingController();
  final TextEditingController _point3Controller = TextEditingController();
  final TextEditingController _point4Controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _getCurrentLocation(); // Get the current location on init
  }

  // Function to get the current location and handle permissions
  Future<void> _getCurrentLocation() async {
    PermissionStatus permission = await Permission.location.status;

    if (permission == PermissionStatus.denied) {
      permission = await Permission.location.request();
      if (permission != PermissionStatus.granted) {
        print("Location permission denied.");
        return;
      }
    }

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("Location services are disabled.");
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });

    _mapController.move(_currentLocation!, 18); // Zoom level 18
  }

  // Handle map taps to add points or draw a rectangle
  void _onMapTap(TapPosition tapPosition, LatLng point) {
    setState(() {
      if (polygonPoints.length < 4) {
        polygonPoints.add(point);
        markers.add(
          Marker(
            point: point,
            width: 60,
            height: 60,
            child: const Icon(
              Icons.location_on,
              size: 30,
              color: Colors.red,
            ),
          ),
        );
        _updateTextFields();
      }
    });
  }

  // Update the text fields with the points clicked
  void _updateTextFields() {
    if (polygonPoints.length >= 1) {
      _point1Controller.text =
          '${polygonPoints[0].latitude}, ${polygonPoints[0].longitude}';
    }
    if (polygonPoints.length >= 2) {
      _point2Controller.text =
          '${polygonPoints[1].latitude}, ${polygonPoints[1].longitude}';
    }
    if (polygonPoints.length >= 3) {
      _point3Controller.text =
          '${polygonPoints[2].latitude}, ${polygonPoints[2].longitude}';
    }
    if (polygonPoints.length >= 4) {
      _point4Controller.text =
          '${polygonPoints[3].latitude}, ${polygonPoints[3].longitude}';
    }
  }

  // Button to toggle between rectangle mode and pin point mode
  void _toggleMode() {
    setState(() {
      isRectangleMode = !isRectangleMode;
      if (isRectangleMode) {
        polygonPoints.clear(); // Clear polygon points when switching mode
        markers.clear(); // Clear markers
        _point1Controller.clear();
        _point2Controller.clear();
        _point3Controller.clear();
        _point4Controller.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body: Column(
          children: [
            // Top half for the map
            Flexible(
              flex: 2,
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _currentLocation ?? const LatLng(0.0, 0.0),
                  initialZoom: 18,
                  onTap: _onMapTap, // Detect map taps
                ),
                children: [
                  openStreetMapTileLayer,
                  if (_currentLocation != null) ...[
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _currentLocation!,
                          width: 60,
                          height: 60,
                          child: const Icon(
                            Icons.circle_sharp,
                            size: 20,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    // Draw geofence (polygon) if points are defined
                    if (polygonPoints.length == 4) ...[
                      PolygonLayer(polygons: [
                        Polygon(
                          points: polygonPoints,
                          borderColor: Colors.blue,
                          color: _geofenceColor,
                          borderStrokeWidth: 2,
                        ),
                      ])
                    ],
                    // Show the added markers
                    MarkerLayer(
                      markers: markers,
                    ),
                  ],
                ],
              ),
            ),
            // Bottom section for input fields (fixed height)
            SizedBox(
              height: 300, // Set a fixed height for the bottom section
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _styledTextField(_point1Controller, "Point 1"),
                    _styledTextField(_point2Controller, "Point 2"),
                    _styledTextField(_point3Controller, "Point 3"),
                    _styledTextField(_point4Controller, "Point 4"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

TileLayer get openStreetMapTileLayer => TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'dev.fleaflet.flutter_ma.example',
    );

Widget _styledTextField(TextEditingController controller, String label) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.grey[200], // Light grey background
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade400), // Soft border
    ),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
    child: TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: InputBorder.none, // Removes the default border
      ),
      readOnly: true,
    ),
  );
}
