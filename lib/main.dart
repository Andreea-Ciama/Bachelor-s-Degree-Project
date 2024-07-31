import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '/screens/welcome_screen.dart';
import '/screens/signin_screen.dart';
import '/screens/signup_screen.dart';
import '/screens/homepagePatient.dart';
import '/screens/homepageDoctor.dart';
import '/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Family Medicine',
      theme: lightMode,
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/signin': (context) => const SignInScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/doctorHome': (context) => HomePageDoctor(),
        '/patientHome': (context) => HomePagePatient(),
      },
    );
  }
}
