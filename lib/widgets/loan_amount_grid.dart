import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoanAmountGrid extends StatelessWidget {
  final int onTimePayments;
  final Function(double) onAmountSelected;
  const LoanAmountGrid(
      {super.key, required this.onTimePayments, required this.onAmountSelected});

  static const amounts = [100,200,300,400,500,600,700,800,900,1000,1500,2000];

  bool _unlocked(int a) {
    if (a <= 200) return true;
    if (a <= 1000 && onTimePayments >= 3) return true;
    if (a <= 2000 && onTimePayments >= 6) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, childAspectRatio: 1.3,
        crossAxisSpacing: 12, mainAxisSpacing: 12),
      itemCount: amounts.length,
      itemBuilder: (_, i) {
        final a = amounts[i];
        final ok = _unlocked(a);
        return GestureDetector(
          onTap: ok ? () { HapticFeedback.lightImpact();
            onAmountSelected(a.toDouble()); } : null,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: ok ? const LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
                begin: Alignment.topLeft, end: Alignment.bottomRight) : null,
              color: ok ? null : const Color(0xFFF5F5F5),
              border: ok ? null : Border.all(color: const Color(0xFFE0E0E0)),
              boxShadow: ok ? [BoxShadow(
                color: const Color(0xFF1565C0).withOpacity(0.3),
                blurRadius: 8, offset: const Offset(0, 4))] : null,
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center,
              children: ok ? [
                Text('₹$a', style: const TextStyle(color: Colors.white,
                    fontSize: 18, fontWeight: FontWeight.bold)),
                const Text('Tap to apply',
                    style: TextStyle(color: Colors.white70, fontSize: 10)),
              ] : [
                const Icon(Icons.lock_outline,
                    color: Color(0xFF9E9E9E), size: 18),
                const SizedBox(height: 4),
                Text('₹$a', style: const TextStyle(color: Color(0xFF9E9E9E),
                    fontSize: 16, fontWeight: FontWeight.bold)),
                const Text('Coming Soon',
                    style: TextStyle(color: Color(0xFFBDBDBD), fontSize: 9)),
              ],
            ),
          ),
        );
      },
    );
  }
}
