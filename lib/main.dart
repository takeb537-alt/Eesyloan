import 'package:flutter/material.dart';

void main() {
  runApp(const EasyLoanApp());
}

class EasyLoanApp extends StatelessWidget {
  const EasyLoanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1000026560.jpg wala white background
      backgroundColor: Colors.white, 
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Aapka registered logo
            Image.asset(
              'assets/icon/app_icon.png',
              width: 200, // Size aap adjust kar sakte hain
            ),
            const SizedBox(height: 20),
            // Text jo 1000026560.jpg mein dikh raha hai
            const Text(
              "EasyLoan",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A4D80), // Blue shade matching the logo
              ),
            ),
            const Text(
              "Your Categories, Your Amount.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
