import 'package:flutter/material.dart';

class JobItem {
  final String? title;
  final String? company;
  final String? location;
  final String? description;
  final String? salary;
  final String? experience;
  final String? datePosted;
  final String? link;
  final String? timeAgo;
  final IconData? icon;

  JobItem({
    this.title,
    this.company,
    this.location,
    this.description,
    this.salary,
    this.experience,
    this.datePosted,
    this.link,
    this.timeAgo,
    this.icon,
  });
}