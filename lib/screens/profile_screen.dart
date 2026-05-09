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
    final done = p.loans.where((l) => l.status == LoanStatus.completed).length;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          Container(width: 88, height: 88,
            decoration: const BoxDecoration(shape: BoxShape.circle,
              gradient: LinearGradient(colors: [
                Color(0xFF1565C0), Color(0xFF42A5F5)])),
            child: Center(child: Text(
              u?.fullName.isNotEmpty == true
                  ? u!.fullName[0].toUpperCase() : '?',
              style: const TextStyle(color: Colors.white,
                  fontSize: 40, fontWeight: FontWeight.bold)))),
          const SizedBox(height: 12),
          Text(u?.fullName ?? '', style: const TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold)),
          Text('+91 ${u?.mobile ?? ''}',
            style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          _card('Personal Details', Icons.person_outline, [
            ['Name', u?.fullName ?? '-'],
            ['Mobile', '+91 ${u?.mobile ?? '-'}'],
            ['PAN', u?.pan ?? '-'],
            ['DOB', u?.dob ?? '-'],
            ['UPI', u?.upiId ?? '-'],
          ]),
          const SizedBox(height: 16),
          _card('Loan Statistics', Icons.bar_chart, [
            ['Total Loans', '$total'],
            ['Completed', '$done'],
            ['On-Time Payments', '${p.onTimePayments}'],
            ['Max Credit', '₹${p.maxUnlockedAmount.toInt()}'],
          ]),
          const SizedBox(height: 16),
          _penaltyCard(),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => showDialog(context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Reset Account?'),
                  content: const Text('All data will be deleted.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel')),
                    TextButton(
                      onPressed: () async {
                        await p.logout();
                        if (context.mounted) Navigator.pushAndRemoveUntil(
                          context, MaterialPageRoute(
                              builder: (_) => const SplashScreen()),
                              (r) => false);
                      },
                      child: const Text('Reset',
                          style: TextStyle(color: Colors.red))),
                  ])),
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text('Logout / Reset',
                  style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))))),
          const SizedBox(height: 32),
        ]),
      ),
    );
  }

  Widget _card(String title, IconData icon, List<List<String>> rows) =>
    Container(
      decoration: BoxDecoration(color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04),
            blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Row(children: [
            Icon(icon, color: const Color(0xFF1565C0), size: 20),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 15,
                color: Color(0xFF1565C0))),
          ])),
        const Divider(height: 1),
        Padding(padding: const EdgeInsets.all(16),
          child: Column(children: rows.map((r) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(children: [
              SizedBox(width: 120, child: Text(r[0],
                style: TextStyle(color: Colors.grey[600], fontSize: 13))),
              Expanded(child: Text(r[1], style: const TextStyle(
                  fontWeight: FontWeight.w500, fontSize: 13))),
            ]))).toList())),
      ]));

  Widget _penaltyCard() => Container(
    decoration: BoxDecoration(color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE0E0E0))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Padding(padding: EdgeInsets.fromLTRB(16, 14, 16, 8),
        child: Row(children: [
          Icon(Icons.warning_amber_rounded,
              color: Color(0xFF1565C0), size: 20),
          SizedBox(width: 8),
          Text('Penalty Schedule', style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 15,
              color: Color(0xFF1565C0))),
        ])),
      const Divider(height: 1),
      Padding(padding: const EdgeInsets.all(16),
        child: Column(children: PenaltyCalculator.schedule.map((r) =>
          Padding(padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(r['range']!,
                    style: const TextStyle(fontSize: 13)),
                Text(r['penalty']!, style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red, fontSize: 13)),
              ]))).toList())),
    ]));
}
