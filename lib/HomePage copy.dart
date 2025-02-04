// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:geolocator/geolocator.dart'; // Add geolocator package
// import 'package:permission_handler/permission_handler.dart'; // Add permission_handler package
// import 'package:maps_toolkit/maps_toolkit.dart' as map_tool;

// class MapView extends StatefulWidget {
//   const MapView({super.key});

//   @override
//   State<MapView> createState() => _MapViewState();
// }

// class _MapViewState extends State<MapView> {
//   late final MapController _mapController;

//   LatLng? _currentLocation;

//   Timer? _timer;
//   int _elapsedSeconds = 0; // To track elapsed time when inside the polygon
//   bool isInSelectedArea = false;

//   // college lat n long
//   // List<LatLng> polygonPoints = [
//   //   LatLng(11.060602, 77.033631), //left top
//   //   LatLng(11.061460, 77.033545), //right top
//   //   LatLng(11.061497, 77.033975), //right bottom
//   //   LatLng(11.060634, 77.034034), //left bottom
//   // ];

//   List<LatLng> polygonPoints = [
//     LatLng(11.021503, 77.062476), //left top
//     LatLng(11.022267, 77.062331), //right top
//     LatLng(11.022425, 77.062819), //right bottom
//     LatLng(11.021693, 77.062964), //left bottom
//   ];

//   final Color _geofenceColor =
//       Colors.blue.withOpacity(0.2); // Semi-transparent blue

//   @override
//   void initState() {
//     super.initState();
//     _mapController = MapController();
//     _getCurrentLocation(); // Get the current location on init
//   }

//   // Function to get the current location and handle permissions
//   Future<void> _getCurrentLocation() async {
//     // Check if the location permission is granted
//     PermissionStatus permission = await Permission.location.status;

//     if (permission == PermissionStatus.denied) {
//       // If permission is denied, request it
//       permission = await Permission.location.request();
//       if (permission != PermissionStatus.granted) {
//         // Handle permission denial (e.g., show a message)
//         print("Location permission denied.");
//         return;
//       }
//     }

//     // Check if location services are enabled
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       // Handle the error, e.g., by showing a dialog
//       print("Location services are disabled.");
//       return;
//     }

//     // Get the current location
//     Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);

//     setState(() {
//       _currentLocation = LatLng(position.latitude, position.longitude);
//     });

//     // Move the map to the current location once available
//     _mapController.move(_currentLocation!, 18); // Zoom level 18
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: Scaffold(
//         extendBodyBehindAppBar: true,
//         appBar: AppBar(
//           backgroundColor: Colors.transparent, // Transparent background
//           elevation: 0, // No shadow

//           iconTheme:
//               IconThemeData(color: Colors.black), // Icon color for visibility
//         ),
//         body: Stack(
//           children: [
//             FlutterMap(
//               mapController: _mapController,
//               options: MapOptions(
//                 initialCenter: _currentLocation ?? const LatLng(0.0, 0.0),
//                 initialZoom: 18, // Set initial zoom level to 18
//                 interactionOptions: const InteractionOptions(
//                   flags: ~InteractiveFlag
//                       .doubleTapDragZoom, // Disable double-tap zooming
//                 ),
//               ),
//               children: [
//                 openStreetMapTileLayer,
//                 if (_currentLocation != null) ...[
//                   MarkerLayer(
//                     markers: [
//                       Marker(
//                         point: _currentLocation!,
//                         width: 60,
//                         height: 60,
//                         child: const Icon(
//                           Icons.circle_sharp,
//                           size: 20,
//                           color: Colors.blue,
//                         ),
//                       ),
//                     ],
//                   ),
//                   PolygonLayer(polygons: [
//                     Polygon(
//                       points: polygonPoints,
//                       borderColor: Colors.blue,
//                       color: _geofenceColor,
//                       borderStrokeWidth: 2,
//                     ),
//                   ])
//                 ],
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// TileLayer get openStreetMapTileLayer => TileLayer(
//       urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
//       userAgentPackageName: 'dev.fleaflet.flutter_ma.example',
//     );
