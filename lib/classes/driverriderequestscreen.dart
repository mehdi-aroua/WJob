// import 'package:flutter/material.dart';
// import '../services/socket_service.dart';

// class DriverRideRequestScreen extends StatefulWidget {
//   final Map<String, dynamic> rideRequest;
//   final DriverSocketService socketService;

//   const DriverRideRequestScreen({
//     Key? key,
//     required this.rideRequest,
//     required this.socketService,
//   }) : super(key: key);

//   @override
//   State<DriverRideRequestScreen> createState() => _DriverRideRequestScreenState();
// }

// class _DriverRideRequestScreenState extends State<DriverRideRequestScreen> {
//   bool _isLoading = false;

//   void _handleResponse(bool accepted) async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       // Get driver's current location and details
//       Map<String, dynamic> driverDetails = {
//         'driverName': 'John Doe', // Replace with actual driver name
//         'vehicleDetails': 'Toyota Camry - ABC123', // Replace with actual vehicle details
//         'estimatedTime': '5', // Calculate based on distance
//         'currentLocation': {
//           'latitude': 0.0, // Replace with actual location
//           'longitude': 0.0,
//         },
//       };

//       // Send response to server
//       widget.socketService.respondToRideRequest(
//         widget.rideRequest['rideId'],
//         accepted,
//         driverDetails: driverDetails,
//       );

//       // Close the screen
//       Navigator.of(context).pop(accepted);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e')),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('New Ride Request'),
//         automaticallyImplyLeading: false,
//       ),
//       body: _isLoading
//           ? Center(child: CircularProgressIndicator())
//           : Padding(
//               padding: EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   Card(
//                     child: Padding(
//                       padding: EdgeInsets.all(16.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Pickup Location',
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 18,
//                             ),
//                           ),
//                           SizedBox(height: 8),
//                           Text(widget.rideRequest['pickupAddress'] ?? 'Unknown location'),
//                           SizedBox(height: 16),
//                           Text(
//                             'Dropoff Location',
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 18,
//                             ),
//                           ),
//                           SizedBox(height: 8),
//                           Text(widget.rideRequest['dropoffAddress'] ?? 'Unknown location'),
//                           SizedBox(height: 16),
//                           Text(
//                             'Estimated Distance',
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 18,
//                             ),
//                           ),
//                           SizedBox(height: 8),
//                           Text('${widget.rideRequest['distance'] ?? '0'} km'),
//                           SizedBox(height: 16),
//                           Text(
//                             'Estimated Fare',
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 18,
//                             ),
//                           ),
//                           SizedBox(height: 8),
//                           Text('\$${widget.rideRequest['fare'] ?? '0'}'),
//                         ],
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 20),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: ElevatedButton(
//                           onPressed: () => _handleResponse(false),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.red,
//                             padding: EdgeInsets.symmetric(vertical: 16),
//                           ),
//                           child: Text(
//                             'Reject',
//                             style: TextStyle(fontSize: 18),
//                           ),
//                         ),
//                       ),
//                       SizedBox(width: 16),
//                       Expanded(
//                         child: ElevatedButton(
//                           onPressed: () => _handleResponse(true),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.green,
//                             padding: EdgeInsets.symmetric(vertical: 16),
//                           ),
//                           child: Text(
//                             'Accept',
//                             style: TextStyle(fontSize: 18),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }
// }