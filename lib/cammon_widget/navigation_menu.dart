// import 'package:catchTn/api_service.dart';
// import 'package:catchTn/localization/demo_localization.dart';
// import 'package:catchTn/view/Menu/about.dart';
// import 'package:catchTn/view/Menu/aide.dart';
// import 'package:catchTn/view/Menu/depense.dart';
// import 'package:catchTn/view/Menu/edit_car.dart';
// import 'package:catchTn/view/Menu/profile_view.dart';
// import 'package:catchTn/view/Menu/ride_history.dart';
// import 'package:catchTn/view/Menu/termes.dart';
// import 'package:catchTn/view/login/login_driver.dart';
// import 'package:flutter/material.dart';
// import 'package:catchTn/cammon/color_extension.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class NavigationMenu extends StatefulWidget {
//   const NavigationMenu({Key? key}) : super(key: key);

//   @override
//   State<NavigationMenu> createState() => _NavigationMenuState();
// }

// class _NavigationMenuState extends State<NavigationMenu> {
//   late Future<Map<String, dynamic>> _userProfile;
//   String _profilePicUrl = '';
//   String _name = '';
//   String _email = '';
//   String _phone = '';
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//   }

//   Future<void> _loadUserData() async {
//     try {
//       final userData = await ApiService().getUserData();
//       if (userData != null) {
//         print("==> Données utilisateur reçues : $userData");
//         String? fullPic = userData['profile_pic'];

//         if (fullPic != null) {
//           // Supprimer l'extension si présente (.png, .jpg, etc.)
//           String cleanPic = fullPic.split('.').first;
//           print("==> Nom du fichier sans extension : $cleanPic");

//           setState(() {
//             _profilePicUrl = cleanPic;
//           });
//         }

//         setState(() {
//           _name = userData['name'] ?? '';
//           _phone = userData['phone'] ?? '';
//           _email = userData['email'] ?? '';
//           _isLoading = false;
//         });
//       } else {
//         print("==> Aucune donnée utilisateur trouvée.");
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       print("==> Erreur lors de la récupération des données utilisateur : $e");
//       setState(() {
//         _isLoading = false;
//       });
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Échec du chargement des données : $e')),
//         );
//       }
//     }
//   }

//   Future<void> logout(BuildContext context) async {
//     final apiService = ApiService();
//     try {
//       await apiService.logout();
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       await prefs.remove("auth_token"); 
//       if (mounted) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const LoginDriver()),
//         );
//       }
//     } catch (e) {
//       print("ERROR: Logout failed: $e");
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Logout failed: $e')),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
//     final screenWidth = MediaQuery.of(context).size.width;

//     return Drawer(
//       backgroundColor: Colors.white,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           // -- Profile Header --
//           Padding(
//             padding: const EdgeInsets.only(top: 100),
//             child: GestureDetector(
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => ProfileView()),
//                 );
//               },
//               child: Container(
//                 color: Colors.white,
//                 padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
//                 child: Row(
//                   children: [
//                     CircleAvatar(
//                       radius: 35,
//                       backgroundColor: Colors.black,
//                       child: const Icon(
//                         Icons.person,
//                         size: 40,
//                         color: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             _name,
//                             style: TextStyle(
//                               fontSize: 20,
//                               fontWeight: FontWeight.w500,
//                               color: TColor.black,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             _email,
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: TColor.placeholder,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           // -- Menu Items --
//           Expanded(
//             child: Container(
//               color: Colors.white,
//               child: ListView(
//                 padding: EdgeInsets.zero,
//                 children: [
//                   Container(
//                     margin: const EdgeInsets.only(left: 18),
//                     height: 36,
//                     width: 277,
//                     decoration: BoxDecoration(
//                       color: TColor.primary,
//                       borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(18),
//                       ),
//                     ),
//                     padding: isArabic
//                       ? const EdgeInsets.only(left: 180)
//                       : const EdgeInsets.only(left: 70),
//                     alignment : Alignment.centerLeft, 
//                     child: Text(
//                       DemoLocalization.of(context)?.translate('Home') ?? 'Home',
//                       style: TextStyle(color: Colors.white),
//                     ),
//                   ),
//                   Container(
//                     margin: const EdgeInsets.only(top:10,left: 30),
//                     child: Column(
//                       children: [
//                         ListTile(
//                           leading: Image.asset(
//                             "assets/Icone/Groupe9614.png",
//                             width: screenWidth * 0.06,
//                           ),
//                           title: Text(DemoLocalization.of(context)?.translate('car') ?? 'Car'),
//                           onTap: () => Navigator.push(
//                             context,
//                             MaterialPageRoute(builder: (context) => EditCar()),
//                           ),
//                         ),
//                         ListTile(
//                           leading: Image.asset(
//                             "assets/Icone/Fichier27.png",
//                             width: screenWidth * 0.06,
//                           ),
//                           title: Text(DemoLocalization.of(context)?.translate('Depenses') ?? 'Depenses'),
//                           onTap: () => Navigator.push(
//                             context,
//                             MaterialPageRoute(builder: (context) => Depense()),
//                           ),
//                         ),
//                         ListTile(
//                           leading: Image.asset(
//                             "assets/Icone/Fichier26.png",
//                             width: screenWidth * 0.06,
//                           ),
//                           title: Text(DemoLocalization.of(context)?.translate('Wallet') ?? 'Wallet'),
//                           onTap: () => Navigator.pop(context),
//                         ),
//                         ListTile(
//                           leading: Image.asset(
//                             "assets/Icone/Fichier25.png",
//                             width: screenWidth * 0.06,
//                           ),
//                           title: Text(DemoLocalization.of(context)?.translate('Ride_history') ?? 'Ride history'),
//                           onTap: () => Navigator.push(
//                             context,
//                             MaterialPageRoute(builder: (context) => RideHistory()),
//                           ),
//                         ),
//                         ListTile(
//                           leading: Image.asset(
//                             "assets/Icone/Fichier24.png",
//                             width: screenWidth * 0.06,
//                           ),
//                           title: Text(DemoLocalization.of(context)?.translate('Support') ?? 'Support'),
//                           onTap: () => Navigator.push(
//                             context,
//                             MaterialPageRoute(builder: (context) => Aide()),
//                           ),
//                         ),
//                         ListTile(
//                           leading: Image.asset(
//                             "assets/Icone/Fichier23.png",
//                             width: screenWidth * 0.06,
//                           ),
//                           title: Text(DemoLocalization.of(context)?.translate('About') ?? 'About'),
//                           onTap: () => Navigator.push(
//                             context,
//                             MaterialPageRoute(builder: (context) => About()),
//                           ),
//                         ),
//                         ListTile(
//                           leading: Image.asset(
//                             "assets/Icone/Fichier22.png",
//                             width: screenWidth * 0.06,
//                           ),
//                           title: Text(DemoLocalization.of(context)?.translate('CGE') ?? 'CGE'),
//                           onTap: () => Navigator.pushReplacement(
//                             context,
//                             MaterialPageRoute(builder: (context) => Termes()),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           // -- Sign Out & Gear Icon at the Bottom --
//           Container(
//             color: Colors.white,
//             padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 40),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Flexible(
//                   child: GestureDetector(
//                     onTap: () {
//                       logout(context);
//                     },
//                     child: Container(
//                       margin: const EdgeInsets.only(left: 40),
//                       child:TextButton(
//                         onPressed: () {
//                           logout(context);
//                         },
//                         style: TextButton.styleFrom(
//                           padding: EdgeInsets.zero, 
//                         ),
//                         child: Row(
//                           children: [
//                             Image.asset(
//                               "assets/Icone/Fichier16.png",
//                               width: screenWidth * 0.05,
//                             ),
//                             const SizedBox(width: 18),
//                             Text(
//                               DemoLocalization.of(context)?.translate('Sign_Out') ?? 'Sign Out',
//                               style: TextStyle(
//                                 color: TColor.primary,
//                                 fontSize: 17,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: Image.asset(
//                     "assets/Icone/Fichier21.png",
//                     width: screenWidth * 0.06,
//                   ),
//                   onPressed: () {
//                     // Handle Settings
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }