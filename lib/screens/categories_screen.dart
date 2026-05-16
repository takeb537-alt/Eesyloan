import 'package:flutter/material.dart';
import 'home_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Pure white background as requested
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),
                
                // Logo Section: Logo and text structure matching image 1
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Outer decorative circles around the avatar
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.blue.withOpacity(0.3), width: 2),
                          ),
                        ),
                        // Profile Avatar
                        Container(
                          width: 65,
                          height: 65,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.teal.withOpacity(0.1),
                            border: Border.all(color: const Color(0xFF2B5B84), width: 2),
                          ),
                          child: const Icon(Icons.person, size: 45, color: Color(0xFF2B5B84)),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    
                    // App Name text layout
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                            children: [
                              TextSpan(text: 'Easy', style: TextStyle(color: Color(0xFF1D547F))),
                              TextSpan(text: 'Loan', style: TextStyle(color: Color(0xFF5CA37B))),
                            ],
                          ),
                        ),
                        const Text(
                          'Your Categories, Your Amount.',
                          style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const Spacer(),
                
                // "Get Started" Button that routes to HomeScreen
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      // Home Screen par navigate karne ke liye
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF63A393), // Button ka customized color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Get Started',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
