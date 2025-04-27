// import 'package:catchTn/view/Home/demande.dart';
// import 'package:catchTn/view/Home/offre.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;
// // import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter/material.dart';

// typedef RideRequestCallback = void Function(Map<String, dynamic> rideDetails);
// typedef ErrorCallback = void Function(String message);

// class DriverSocketService {
//   IO.Socket? _socket;
//   static final DriverSocketService _instance = DriverSocketService._internal();
//   factory DriverSocketService() => _instance;
//   DriverSocketService._internal();
//   bool _isConnected = false;
//   String? _currentRideId;
//   // static final DriverSocketService _instance = DriverSocketService._internal();
//   RideRequestCallback? onRideRequest;
//   ErrorCallback? onError;
//   // final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
//   RideRequestCallback? onRideCanceled;

//   // factory DriverSocketService() {
//   //   return _instance;
//   // }

//   // DriverSocketService._internal() {
//   //   _initializeNotifications();
//   // }

//   IO.Socket get socket {
//     if (_socket == null) {
//       throw Exception('Socket not initialized. Call connect() first.');
//     }
//     return _socket!;
//   }

//   bool get isConnected => _isConnected;

//   // void _initializeNotifications() {
//   //   const AndroidInitializationSettings initializationSettingsAndroid =
//   //       AndroidInitializationSettings('@mipmap/ic_launcher');
//   //   final InitializationSettings initializationSettings = InitializationSettings(
//   //     android: initializationSettingsAndroid,
//   //   );
//   //   _notificationsPlugin.initialize(initializationSettings);
//   // }

//   // void _showNotification(String title, String body) async {
//   //   const AndroidNotificationDetails androidPlatformChannelSpecifics =
//   //       AndroidNotificationDetails(
//   //     'ride_request_channel',
//   //     'Ride Requests',
//   //     importance: Importance.high,
//   //     priority: Priority.high,
//   //     ticker: 'ticker',
//   //   );
//   //   const NotificationDetails platformChannelSpecifics =
//   //       NotificationDetails(android: androidPlatformChannelSpecifics);
//   //   await _notificationsPlugin.show(0, title, body, platformChannelSpecifics);
//   // }

//   Future<void> connect(String token,String roleId) async {
//     if (_socket != null) {
//       print("🟡 DEBUG: Socket already exists, disconnecting first...");
//       await disconnect();
//     }

//     print("🟡 DEBUG: Driver connecting to WebSocket...");

//     _socket = IO.io(
//       'http://10.0.2.2:3000',
//       IO.OptionBuilder()
//           .setTransports(['websocket'])
//           .setAuth({'token': token, 'roleId': roleId})
//           .enableForceNewConnection()
//           .enableReconnection()
//           .setReconnectionAttempts(5)
//           .setReconnectionDelay(2000)
//           .build(),
//     );
      
//     print("🟡 DEBUG: Token being sent: $token");
//     print("🟡 DEBUG: Role ID being sent: $roleId");
//     _socket!.onConnect((_) {
//       print("✅ DEBUG: Driver successfully connected to WebSocket");

//       _isConnected = true;
//       getDriverStatus(true);
//     });

//     // _socket!.on('rideRequest', (data) {
//     //   print("salomou alikom $data");
//     // });

//     _socket!.onConnectError((error) {
//       print("❌ ERROR: Driver WebSocket Connection Failed: $error");
//       _isConnected = false;
//     });

//     socket.on('disconnect', (reason) {
//       print("❌ ERROR: WebSocket Disconnected: $reason");
//       Future.delayed(Duration(seconds: 3), () {
//         print("🟡 DEBUG: Reconnecting...");
//         socket.connect();
//       });
//     });

//     _socket!.onError((error) {
//       print("❌ ERROR: WebSocket error: $error");
//       _isConnected = false;
//     });

//    _socket!.on('rideRequest', (data) {
//       print(
//           "🔵 [DEBUG] Événement rideRequest reçu: ${data.runtimeType} -> $data");
//       try {
//         print("🚕 Nouvelle demande de course reçue: $data");

//         bool isMap = data is Map<String, dynamic>;
//         bool hasId = isMap && data.containsKey('id');

//         if (isMap && hasId) {
//           _currentRideId = data['id'];
//           print("🚗 Ride ID reçu : $_currentRideId");

//           if (onRideRequest != null) {
//             onRideRequest!(data);
//           } else {
//             print("❌ ERRORssssss: Failed to process rideRequest");
//           }
//         }
//       } catch (e) {
//         print("❌ ERROR: Failed to process rideRequest: $e");
//       }
//     });
//     _socket!.on('rideCanceled', (data) {
//       print("🔵 [DEBUG] Événement cancel ride reçu: ${data.runtimeType} -> $data");
//       try {
//         print("🚕 cancel  de course reçue: $data");

//         bool isMap = data is Map<String, dynamic>;
//         bool hasId = isMap && data.containsKey('id');

//         if (isMap && hasId) {
//           _currentRideId = data['id'];
//           print("🚗 Ride ID reçu : $_currentRideId");

//           if (onRideCanceled != null) {
//             onRideCanceled!(data);
//           } else {
//             print("❌ ERRORssssss: Failed to process rideRequest");
//           }
//         }
//       } catch (e) {
//         print("❌ ERROR: Failed to process rideRequest: $e");
//       }
//     });
//     // socket.on('rideCanceled', (data) {
//     //   try {
//     //     print("❌ DEBUG: Ride Canceled - Raw Data: $data");

//     //     if (data == null) {
//     //       print("⚠️ WARNING: Received null data for 'rideCanceled' event.");
//     //       return;
//     //     }

//     //     // Ensure data is in the expected format
//     //     if (data is! Map<String, dynamic>) {
//     //       print("⚠️ WARNING: Unexpected data format: $data");
//     //       return;
//     //     }

//     //     print("✅ Processed Ride Canceled Event: ${data.toString()}");

//     //     // Invoke callback if available
//     //     if (onRideCanceled != null) {
//     //       onRideCanceled!(data);
//     //     } else {
//     //       print("ℹ️ INFO: No onRideCanceled callback set.");
//     //     }
//     //   } catch (e, stackTrace) {
//     //     print("❌ ERROR: Exception in 'rideCanceled' handler - $e");
//     //     print("🔍 Stack Trace: $stackTrace");
//     //   }
//     // });

//     _socket!.onError((error) {
//       print("❌ ERREUR WebSocket: $error");
//     });


//     _socket!.connect();
//   }

//   Future<void> disconnect() async {
//     if (_socket != null) {
//       print("🔴 DEBUG: Driver disconnecting from WebSocket");
//       getDriverStatus(false);
//       _socket!.disconnect();
//       _socket!.dispose();
//       _socket = null;
//       _isConnected = false;
//     }
//   }

//   void updateDriverStatus(bool isOnline, LatLng location, String vehicleType) {
//     if (_socket != null && _isConnected) {
//       print("🟡 DEBUG: Updating driver status: ${isOnline ? 'Offline' : 'Online'}");

//       _socket!.emit('updateDriverStatus', {
//         'isOnline': isOnline ? 'OFFLINE' : 'ONLINE',
//         'location': {
//           'latitude': location.latitude,
//           'longitude': location.longitude,
//           'vehicleType': vehicleType,
//         },
//       });
//     }
//   }
//   bool getDriverStatus(bool isOnline) {
//     // Return true for Online and false for Offline
//     return isOnline;
//   }


//   void updateLocation(Map<String, dynamic> location) {
//     // if (_socket != null && _isConnected) {
//     //   print("📍 DEBUG: Updating driver location: $location");
//     //   _socket!.emit('updateDriverLocation', location);
//     // }
//   }


//   void updateRideStatus(String rideId, String status, {Map<String, dynamic>? details}) {
//     if (_socket != null && _isConnected) {
//       print("🔄 DEBUG: Updating ride status: $rideId to $status");
//       _socket!.emit('updateRideStatus', {
//         'rideId': rideId,
//         'status': status,
//         if (details != null) ...details,
//       });
//     }
//   }

//   String? get currentRideId => _currentRideId;

//   void cancelRideRequest(String rideId) {
//     print("🔴 DEBUG: Cancelling ride request: $rideId");
//     socket.emit('cancelRideRequest', {'rideId': rideId});
//   }

// void setCallbacks({
//     RideRequestCallback? onRideRequest,
//     ErrorCallback? onError,
//     RideRequestCallback? onRideCanceled,
//   }) {
//     print("🟢 Setting driver socket callbacks...");
//     this.onRideRequest = onRideRequest ??
//         (data) {
//           print("⚠️ Default onRideRequest callback triggered");
//         };

//     this.onError = onError ??
//         (message) {
//           print("⚠️ Default error callback: $message");
//         };

//     this.onRideCanceled = (data) {
//     print("🔴 [CANCEL_CALLBACK] Entered onRideCanceled callback");
//     print("🔴 [CANCEL_CALLBACK] Received data: ${data.toString()}");
    
//     try {
//       if (!data.containsKey('id') || data['id'] == null) {
//         print("❌ [CANCEL_CALLBACK] Missing required rideId field ${data['id']}");
//         return;
//       }

//       print("🆔 [CANCEL_CALLBACK] Processing cancellation for ride: ${data['id']}");
//       print("📝 [CANCEL_CALLBACK] Reason: ${data['reason'] ?? 'No reason provided'}");

//       if (onRideCanceled != null) {
//         print("✅ [CANCEL_CALLBACK] Forwarding to provided callback");
//         onRideCanceled(data);
//       } else {
//         print("⚠️ [CANCEL_CALLBACK] No callback provided - using default");
//         print("ℹ️ Default cancellation handling for ride: ${data['id']}");
//       }
//     } catch (e, stack) {
//       print("❌ [CANCEL_CALLBACK] Exception in callback: $e");
//       print("📜 Stack trace: $stack");
//       if (onError != null) {
//         onError("Cancellation callback error: $e");
//       }
//     }
//   };


//     print("🟢 Driver callbacks set successfully");
//   }
// }
