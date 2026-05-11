import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/loan_provider.dart';
import 'splash_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<LoanProvider>();
    final u = p.user; 
    
    final total = p.loans.length;
    final done = p.loans.where((l) => l.status.toString().contains('completed')).length;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [Colors.blue, Colors.blueAccent]),
              ),
              child: Center(
                child: Text(
                  u.name.isNotEmpty ? u.name[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              u.name, 
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              u.phone.isNotEmpty ? '+91 ${u.phone}' : 'No Phone Number',
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 24),

            _card('Personal Details', Icons.person_outline, [
              ['Name', u.name],
              ['Email', u.email.isNotEmpty ? u.email : '-'],
              ['User ID', u.id],
            ]),

            const SizedBox(height: 16),

            _card('Loan Statistics', Icons.bar_chart, [
              ['Total Loans', '$total'],
              ['Completed', '$done'],
              ['On-Time Payments', '${p.onTimePayments}'],
              ['Max Credit', '₹${p.maxUnlockedAmount.toInt()}'],
            ]),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showResetDialog(context, p),
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text('Logout / Reset Account', style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(String title, IconData icon, List<List<String>> items) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue[800]),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 24),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item[0], style: const TextStyle(color: Colors.grey, fontSize: 15)),
                  Text(item[1], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context, LoanProvider p) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Account?'),
        content: const Text('Kya aap sure hain? Saara data delete ho jayega
        
