import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sawtify/firebase_options.dart';
import 'package:sawtify/welcom.dart';
import 'utils/constants.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

   @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Login App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: kBackgroundColor,
        textTheme: Theme.of(context).textTheme.apply(
              bodyColor: kPrimaryColor,
              fontFamily: 'Montserrat',
            ),
      ),
     home: AnimatedSplashScreen(
        duration: 3000, 
        splash: Image.asset("assets/Backgrounds/animation.png"), 
        nextScreen: const Welcome(),
        splashTransition: SplashTransition.rotationTransition, 
          splashIconSize: 400,
      ),
   
    );
  }
}
