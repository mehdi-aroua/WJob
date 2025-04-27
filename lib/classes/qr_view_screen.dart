// import 'package:flutter/material.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';

// class QRScannerScreen extends StatefulWidget {
//   @override
//   _QRScannerScreenState createState() => _QRScannerScreenState();
// }

// class _QRScannerScreenState extends State<QRScannerScreen> {
//   MobileScannerController cameraController = MobileScannerController();
//   String? scannedData; 
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//   }

//   Future<void> _initializeCamera() async {
//     try {
//       await cameraController.start();
//       setState(() {
//         _isLoading = false; 
//       });
//     } catch (e) {
//       print("Failed to initialize camera: $e");
//       setState(() {
//         _isLoading = false; 
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Failed to initialize camera: $e")),
//       );
//     }
//   }

//   @override
//   void dispose() {
//     cameraController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final scannerSize = size.width * 0.8;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Scan QR Code'),
//       ),
//       body: Stack(
//         children: [
//           ColorFiltered(
//             colorFilter: ColorFilter.mode(
//               Colors.black.withOpacity(0.6),
//               BlendMode.srcOut,
//             ),
//             child: Stack(
//               children: [
//                 Container(
//                   decoration: BoxDecoration(
//                     color: Colors.black,
//                     backgroundBlendMode: BlendMode.dstOut,
//                   ),
//                 ),
//                 Center(
//                   child: Container(
//                     width: scannerSize,
//                     height: scannerSize,
//                     decoration: BoxDecoration(
//                       color: Colors.transparent,
//                       borderRadius: BorderRadius.circular(16),
//                       border: Border.all(
//                         color: Colors.white,
//                         width: 2,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // QR Code Scanner (centered in the frame)
//           if (_isLoading)
//             Center(child: CircularProgressIndicator()) // Loading indicator
//           else
//             Center(
//               child: SizedBox(
//                 width: scannerSize,
//                 height: scannerSize,
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(16),
//                   child: MobileScanner(
//                     controller: cameraController,
//                     onDetect: (capture) {
//                       final List<Barcode> barcodes = capture.barcodes;
//                       for (final barcode in barcodes) {
//                         setState(() {
//                           scannedData = barcode.rawValue;
//                         });
//                         // Navigator.pop(context, scannedData);
//                       }
//                     },
//                   ),
//                 ),
//               ),
//             ),

//           // Display scanned data in a card
//           if (scannedData != null)
//             Positioned(
//               bottom: 20,
//               left: 20,
//               right: 20,
//               child: Card(
//                 elevation: 4,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Scanned Data:',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black87,
//                         ),
//                       ),
//                       SizedBox(height: 8),
//                       Text(
//                         scannedData!,
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Colors.grey[700],
//                         ),
//                       ),
//                       SizedBox(height: 16),
//                       Center(
//                         child: ElevatedButton(
//                           onPressed: () {
//                             setState(() {
//                               scannedData = null; // Clear the scanned data
//                             });
//                           },
//                           child: Text('Scan Again'),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }