import 'package:flutter/material.dart';
import 'package:flutter_wjob/view/CV_Create_Screen/Add_Education_Screen.dart';
import 'package:flutter_wjob/view/CV_Create_Screen/create_cv_screen.dart';
import 'view/login_screen/Login_Screen.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  
  await SystemChannels.platform.invokeMethod<void>('SystemNavigator.initialize');

  try {
    await Printing.sharePdf(bytes: Uint8List(0), filename: 'dummy.pdf');
  } catch (e) {
    print('Printing plugin initialization check: $e');
  }
  
    
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WJOB',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'Roboto',
      ),
      home:  CreateCVScreen() ,//LoginScreen()//AddCoverLetterScreen() //const LoginScreen(),
    );
  }
}


