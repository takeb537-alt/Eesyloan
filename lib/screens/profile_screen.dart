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
    
    // Status completed count karne ke liye
    final done = p.loans.where((l) => l.status.toString().contains('completed')).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Avatar with Gradient
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                ),
              ),
              child: Center(
                child: Text(
                  u.name.isNotEmpty ? u.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              u.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              u.phone.isNotEmpty ? '+91 ${u.phone}' : 'No Phone',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // Personal Details Card
            _card('Personal Details', Icons.person_outline, [
              ['Name', u.name],
              ['Email', u.email.isNotEmpty ? u.email : '-'],
              ['User ID', u.id],
            ]),

            const SizedBox(height: 16),

            // Loan Statistics Card
            _card('Loan Statistics', Icons.bar_chart, [
              ['Total Loans', '$total'],
              ['Completed', '$done'],
              // FIX: Variable use ho raha hai, function () nahi
              ['On-Time Payments', '${p.onTimePayments}'],
              ['Max Credit', '₹${p.maxUnlockedAmount.toInt()}'],
            ]),

            const SizedBox(height: 24),

            // Logout / Reset Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showResetDialog(context, p),
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text('Logout / Reset', style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // Common Card Widget
  Widget _card(String title, IconData icon, List<List<String>> items) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item[0], style: const TextStyle(color: Colors.grey)),
                      Text(item[1], style: const TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  // Reset Dialog Logic
  void _showResetDialog(BuildContext context, LoanProvider p) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset Account?'),
        content: const Text('All data will be deleted. This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await p.logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const SplashScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
