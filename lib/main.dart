import 'package:auth/AuthScreen/SignIn.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:easy_splash_screen/easy_splash_screen.dart';


void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home:EasySplashScreen(
          logo:const Image(image:AssetImage("assets/images/splash.png")),
          backgroundColor: Colors.black,
          showLoader: false,
          navigator: const SignIn(),
          durationInSeconds: 3,
        ));
  }
}
