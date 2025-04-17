import 'package:flutter/material.dart';

class JobItem {
  final String title;
  final String location;
  final String timeAgo;
  final IconData icon;

  JobItem({
    required this.title,
    required this.location,
    required this.timeAgo,
    required this.icon,
  });
}
