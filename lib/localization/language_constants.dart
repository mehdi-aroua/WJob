// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// const String LAGUAGE_CODE = 'languageCode';
// const String ENGLISH = 'en';
// const String FRANCAIS = 'fr';
// const String ARABIC = 'ar';
// const String  TOUNSI = 'tn';

// Future<Locale> setLocale(String languageCode) async {
//   SharedPreferences _prefs = await SharedPreferences.getInstance();
//   await _prefs.setString(LAGUAGE_CODE, languageCode);
//   return _locale(languageCode);
// }

// Future<Locale> getLocale() async {
//   SharedPreferences _prefs = await SharedPreferences.getInstance();
//   String languageCode = _prefs.getString(LAGUAGE_CODE) ?? "en";
//   return _locale(languageCode);
// }

// Locale _locale(String languageCode) {
//   switch (languageCode) {
//     case ENGLISH:
//       return Locale(ENGLISH, 'US');
//     case FRANCAIS:
//       return Locale(FRANCAIS, "FR");
//     case ARABIC:
//       return Locale(ARABIC, "SA");
//     case TOUNSI:
//       return Locale(TOUNSI, "TN");
//     default:
//       return Locale(ENGLISH, 'US');
//   }
// }