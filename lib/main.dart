import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'signup_screen.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyBFcFsosjLCliziM1gjYhAJns49WDKQ5ws",
      authDomain: "jobportal-aae9e.firebaseapp.com",
      projectId: "jobportal-aae9e",
      storageBucket: "jobportal-aae9e.firebasestorage.app",
      messagingSenderId: "539158024352",
      appId: "1:539158024352:web:e1f60f5fca3c521e30f9c5",
      measurementId: "G-S9Q2N4HZ1E"
    ),
  );
  runApp(jobportal());
}

class jobportal extends StatelessWidget {
  const jobportal({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Job Portal',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SignupScreen(), // Start with signup
    );
  }
}