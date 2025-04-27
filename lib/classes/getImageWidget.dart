import 'dart:convert';
import 'package:flutter/material.dart';

ImageProvider getImageWidget(String? imageUrl) {
  if (imageUrl == null || imageUrl.isEmpty) {
    return AssetImage('assets/img/barber.png'); 
  } else if (imageUrl.startsWith('/9j/') || imageUrl.startsWith('iVBORw0KGgo')) {
    return MemoryImage(base64Decode(imageUrl));
  } else {
    // Network image
    return NetworkImage(imageUrl);
  }
}
