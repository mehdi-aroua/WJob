// import 'package:catchTn/classes/token.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:location/location.dart';

// class MapboxMapWidget extends StatefulWidget {
//   final VoidCallback onLocationRequested;
//   final List<Widget>? additionalLayers;
//   LatLng? currentCenter ;

//   MapboxMapWidget({required this.onLocationRequested,this.additionalLayers, this.currentCenter});

//   @override
//   _MapboxMapWidgetState createState() => _MapboxMapWidgetState();
// }

// class _MapboxMapWidgetState extends State<MapboxMapWidget> {
//   late MapController _mapController;
//   LocationData? currentLocation;
//   Marker? currentLocationMarker;
//   late LatLng _currentCenter;
//   // LatLng _currentCenter = widget.currentCenter ?? LatLng(36.8065, 10.1815);
//   double _currentZoom = 12.0;

//   @override
//   void initState() {
//     super.initState();
//     _mapController = MapController();
//     _currentCenter = widget.currentCenter ?? LatLng(36.8065, 10.1815);
//     _getCurrentLocation();
//     getCurrentLocations();
//   }

//   Future<void> _getCurrentLocation() async {
//     Location location = Location();
//     try {
//       final userLocation = await location.getLocation();
//       if (!mounted) return;
//       setState(() {
//         currentLocation = userLocation;
//         _currentCenter = LatLng(userLocation.latitude!, userLocation.longitude!);
//         _currentZoom = 15.0;
//         _mapController.move(_currentCenter, _currentZoom);
//         currentLocationMarker = Marker(
//           width: 80,
//           height: 80,
//           point: _currentCenter,
//           child: Image.asset("assets/Icone/Fichier46.png", width: 30, height: 30, fit: BoxFit.contain),
//         );
//       });
//     } catch (e) {
//       print('Error getting location: $e');
//     }
//   }
//   Future<LatLng?> getCurrentLocations() async {
//   Location location = Location();
//   try {
//     final userLocation = await location.getLocation();
//     if (userLocation.latitude != null && userLocation.longitude != null) {
//       return LatLng(userLocation.latitude!, userLocation.longitude!);
//     }
//   } catch (e) {
//     print('Error getting location: $e');
//   }
//   return null; 
// }

//   @override
//   Widget build(BuildContext context) {
//     return Positioned.fill(
//       child: FlutterMap(
//         mapController: _mapController,
//         options: MapOptions(
//           initialCenter: _currentCenter,
//           initialZoom: _currentZoom,
//         ),
//         children: [
//           TileLayer(
//             urlTemplate: "https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}",
//             additionalOptions: {
//               'accessToken': Token.mapboxToken,
//               'id': 'mapbox/streets-v11',
//             },
//           ),
//           MarkerLayer(
//             markers: [
//               if (currentLocationMarker != null) currentLocationMarker!,
//             ],
//           ),
//           if (widget.additionalLayers != null) ...widget.additionalLayers!,
//         ],
//       ),
//     );
//   }
// }
