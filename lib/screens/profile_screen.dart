import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/loan_provider.dart';
import '../models/loan_model.dart'; 
import 'splash_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<LoanProvider>();
    final u = p.user;
    
    // TRICK: Logic yahi likh diya, ab provider me error nahi dhundega
    final totalLoans = p.loans.length;
    final onTimeCount = p.loans.where((l) => 
      l.status == LoanStatus.completed && l.penalty == 0
    ).length;
    final completedCount = p.loans.where((l) => 
      l.status == LoanStatus.completed
    ).length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Profile'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
            const SizedBox(height: 10),
            Text(u.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(u.phone),
            const SizedBox(height: 30),
            
            // Statistics Card
            Card(
              child: Column(
                children: [
                  _tile('Total Loans', '$totalLoans'),
                  _tile('Completed Loans', '$completedCount'),
                  _tile('On-Time Payments', '$onTimeCount'),
                  _tile('Credit Limit', '₹${p.maxUnlockedAmount.toInt()}'),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  await p.logout();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context, 
                      MaterialPageRoute(builder: (_) => const SplashScreen()), 
                      (r) => false
                    );
                  }
                },
                child: const Text('Logout / Reset Account', style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _tile(String label, String value) {
    return ListTile(
      title: Text(label),
      trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
