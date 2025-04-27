import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class AddCar extends StatefulWidget {
  @override
  _AddCarState createState() => _AddCarState();
}

class _AddCarState extends State<AddCar> {
  File? _imageFile;
  Uint8List? _imageBytes;
  TextEditingController _ownerController = TextEditingController();
  TextEditingController _markController = TextEditingController();
  TextEditingController _modelController = TextEditingController();
  TextEditingController _taxiNumberController = TextEditingController();
  TextEditingController _immatController = TextEditingController();
  TextEditingController _cricaDateController = TextEditingController();
  bool _hurtEnabled = false;
  File? _driverLicenseFile;
  File? _registrationFile;
  File? _insuranceFile;
  List<String> carTypes = ['ECONOMY', 'PREMIUM', 'VIP'];
  String? _selectedCarType = 'ECONOMY';

  // Modifiez la fonction getDoc comme ceci :
Future<Map<String, dynamic>?> getDoc(File? file, String type) async {
  if (file == null) return null;

  try {
    final originalSize = await file.length();
    print('Taille originale: ${originalSize} bytes');

    // Rejeter directement les fichiers > 5 Mo (trop longs à compresser)
    if (originalSize > 5 * 1024 * 1024) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Fichier trop volumineux (max 5 Mo)")),
      );
      return null;
    }

    Uint8List compressedBytes = await file.readAsBytes();
    bool isImage = file.path.toLowerCase().endsWith('.jpg') || 
                   file.path.toLowerCase().endsWith('.jpeg') || 
                   file.path.toLowerCase().endsWith('.png');

    if (isImage) {
      int quality = 50; // Commencez avec une qualité plus basse
      int maxAttempts = 4;
      int targetSize = 90 * 1024; // Cible 90 Ko pour rester sous 100 Ko

      for (int attempt = 0; attempt < maxAttempts; attempt++) {
        compressedBytes = await FlutterImageCompress.compressWithList(
          compressedBytes,
          minHeight: 600,  // Réduire la résolution
          minWidth: 600,
          quality: quality,
        );

        print('Tentative ${attempt + 1}: ${compressedBytes.lengthInBytes} bytes');

        // Si la taille est acceptable, sortir de la boucle
        if (compressedBytes.lengthInBytes <= targetSize) break;

        // Réduire la qualité pour la prochaine tentative
        quality -= 15;
        if (quality < 20) quality = 20; // Qualité minimale de 20%
      }
    }

    // Vérification finale (ne pas dépasser 100 Ko)
    if (compressedBytes.lengthInBytes > 102400) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Le fichier est trop lourd après compression")),
      );
      return null;
    }

    return {
      "type": type,
      "file": base64Encode(compressedBytes),
      "name": file.path.split('/').last,
      "note": "",
    };
  } catch (e) {
    print('Erreur de compression: $e');
    return null;
  }
}

// Modifiez _pickDocument pour accepter jusqu'à 10MB avant compression
Future<void> _pickDocument(String type) async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
  );
  
  if (result != null && result.files.isNotEmpty) {
    PlatformFile file = result.files.first;
    if (!kIsWeb && file.path != null) {
      final newFile = File(file.path!);
      // Augmentez la limite à 10MB car nous compresserons ensuite
      if (newFile.lengthSync() > 5 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Le fichier est trop volumineux (max 5MB)")),
        );
        return;
      }

      
      setState(() {
        switch (type) {
          case 'driver_license':
            _driverLicenseFile = newFile;
            break;
          case 'vehicle_registration':
            _registrationFile = newFile;
            break;
          case 'car_insurance':
            _insuranceFile = newFile;
            break;
        }
      });
    }
  }
}
  Future<void> _addCar() async {
    List<Map<String, dynamic>> documents = [];
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(child: CircularProgressIndicator());
      },
    );

    // Future<Map<String, dynamic>?> getDoc(File? file, String type) async {
    //   if (file == null) return null;
    //   final bytes = await file.readAsBytes();
    //   return {
    //     "type": type,
    //     "file": base64Encode(bytes),
    //     "name": file.path.split('/').last,
    //     "note": ""
    //   };
    // }

    final doc1 = await getDoc(_driverLicenseFile, "driver_license");
    final doc2 = await getDoc(_registrationFile, "vehicle_registration");
    final doc3 = await getDoc(_insuranceFile, "car_insurance");
  
    if (doc1 != null) documents.add(doc1);
    if (doc2 != null) documents.add(doc2);
    if (doc3 != null) documents.add(doc3);


    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Car added successfully")),
    );

   
  }

  Future<void> _pickImageFromGallery() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png']);
    if (result != null) {
      PlatformFile file = result.files.first;
      setState(() {
        if (kIsWeb) {
          _imageBytes = file.bytes;
        } else {
          _imageFile = File(file.path!);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 120,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF006AFF), Color(0xFF1CA7C2)],
            ),
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                "add_car_title",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
              
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCarType,
                  items: carTypes.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCarType = newValue;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: "car_type",
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                // const SizedBox(height: 16),
                // GestureDetector(
                //   onTap: () async {
                //     DateTime? pickedDate = await showDatePicker(
                //       context: context,
                //       initialDate: DateTime.now(),
                //       firstDate: DateTime(2000), 
                //       lastDate: DateTime(2100), 
                //     );

                //     if (pickedDate != null) {
                //       String formattedDate = "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
                //       setState(() {
                //         _cricaDateController.text = formattedDate;
                //       });
                //     }
                //   },
                //   child: AbsorbPointer( 
                //     child: RoundTextFiled(
                //       controller: _cricaDateController,
                //       hintText: tr("select_date"),
                //       keyboardType: TextInputType.none, 
                //     ),
                //   ),
                // ),

                SizedBox(height: 6),

                Center(
                  child: Row(
                    children : [
                      Expanded(
                        child: GestureDetector(
                        onTap: () => _pickDocument('driver_license'),
                        child: Container(
                          height: 104,
                          width: 104,
                          color: Colors.grey[300],
                          child: _driverLicenseFile != null || _imageBytes != null
                              ? _imageBytes != null
                                  ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                                  : Image.file(_driverLicenseFile!, fit: BoxFit.cover)
                              : Center(
                                  child: SizedBox(
                                    height: 27, 
                                    width: 36,  
                                    child: Image.asset("assets/Icone/Fichier30.png"),
                                  ),
                                ),
                        ),
                                            ),
                      ),
                    SizedBox(width : 18),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _pickDocument('vehicle_registration'),
                        child: Container(
                          height: 104,
                          width: 104,
                          color: Colors.grey[300],
                          child: _registrationFile != null || _imageBytes != null
                              ? _imageBytes != null
                                  ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                                  : Image.file(_registrationFile!, fit: BoxFit.cover)
                              : Center(
                                  child: SizedBox(
                                    height: 27, 
                                    width: 36,  
                                    child: Image.asset("assets/Icone/Fichier30.png"),
                                  ),
                                ),
                        ),
                      ),
                    ),
                    SizedBox(width : 18),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _pickDocument('car_insurance'),
                        child: Container(
                          height: 104,
                          width: 104,
                          color: Colors.grey[300],
                          child: _insuranceFile != null || _imageBytes != null
                              ? _imageBytes != null
                                  ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                                  : Image.file(_insuranceFile!, fit: BoxFit.cover)
                              : Center(
                                  child: SizedBox(
                                    height: 27, 
                                    width: 36,  
                                    child: Image.asset("assets/Icone/Fichier30.png"),
                                  ),
                                ),
                        ),
                      ),
                    ),
                    
                    ]
                  ),
                ),
                SizedBox(height: 30),

               
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
