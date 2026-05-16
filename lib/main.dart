import 'package:flutter/material.dart';
import 'screens/categories_screen.dart';

void main() {
  runApp(const EasyLoanApp());
}

class EasyLoanApp extends StatelessWidget {
  const EasyLoanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EasyLoan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF4F9F8), // Light background color like in the screenshots
        primaryColor: const Color(0xFF4A8B7C), // Theme green/blue accent color
        useMaterial3: true,
      ),
      // App start hote hi CategoriesScreen open hoga
      home: const CategoriesScreen(),
    );
  }
}
