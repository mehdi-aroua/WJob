// // import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// // class NotificationService {
// //   static final FlutterLocalNotificationsPlugin _notificationsPlugin =
// //       FlutterLocalNotificationsPlugin();

// //   static void initialize() {
// //     const AndroidInitializationSettings initializationSettingsAndroid =
// //         AndroidInitializationSettings('@mipmap/ic_launcher');

// //     const InitializationSettings initializationSettings = InitializationSettings(
// //       android: initializationSettingsAndroid,
// //     );

// //     _notificationsPlugin.initialize(
// //       initializationSettings,
// //       onDidReceiveNotificationResponse: (NotificationResponse response) {
// //         // Ici, on détecte si une notification a été cliquée
// //         onNotificationClick?.call();
// //       },
// //     );
// //   }

// //   static void showNotification() async {
// //     const AndroidNotificationDetails androidPlatformChannelSpecifics =
// //         AndroidNotificationDetails(
// //       'channel_id', 'channel_name',
// //       importance: Importance.high,
// //       priority: Priority.high,
// //     );

// //     const NotificationDetails platformChannelSpecifics = NotificationDetails(
// //       android: androidPlatformChannelSpecifics,
// //     );

// //     await _notificationsPlugin.show(
// //       0, // ID de la notification
// //       "Nouvelle offre disponible !",
// //       "Cliquez ici pour voir l'offre",
// //       platformChannelSpecifics,
// //     );
// //   }

// //   static Function()? onNotificationClick;
// // }
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// class NotificationHelper {
//   static final FlutterLocalNotificationsPlugin _notificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   static Future<void> showRideRequestNotification(String rideId) async {
//     const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
//       'ride_request_channel', // Unique channel ID
//       'Ride Requests', // Name
//       channelDescription: 'Notifications for new ride requests',
//       importance: Importance.max,
//       priority: Priority.high,
//       ticker: 'New Ride Request',
//     );

//     const NotificationDetails notificationDetails =
//         NotificationDetails(android: androidDetails);

//     await _notificationsPlugin.show(
//       0, 
//       '🚖 New Ride Request', 
//       'Tap to accept the ride', 
//       notificationDetails,
//       payload: rideId, 
//     );
//   }
//   static Future<void> showRideCanceledNotification(String rideId) async {
//     const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
//       'ride_canceled_channel', 
//       'Ride Cancellations', 
//       channelDescription: 'Notifications for canceled rides',
//       importance: Importance.max,
//       priority: Priority.high,
//       ticker: 'Ride Canceled',
//     );

//     const NotificationDetails notificationDetails =
//         NotificationDetails(android: androidDetails);

//     await _notificationsPlugin.show(
//       1, 
//       '🚫 Ride Canceled', 
//       'The ride with ID $rideId has been canceled', 
//       notificationDetails,
//       payload: rideId, 
//     );
//   }
// }
