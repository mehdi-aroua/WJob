import 'package:catchTn/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:catchTn/localization/demo_localization.dart';
import 'package:catchTn/localization/language_constants.dart';
import 'package:catchTn/view/on_boarding/startup_view.dart';
import 'dart:io';

/// ✅ Tester une notification manuelle
void showTestNotification() async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'channel_id',
    'channel_name',
    channelDescription: 'Test Channel',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
  );

  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    0,
    'Test Notification',
    'This is a test message!',
    platformChannelSpecifics,
    payload: 'test_payload',
  );
}