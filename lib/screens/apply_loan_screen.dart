import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import 'repayment_screen.dart';

class ApplyLoanScreen extends StatefulWidget {
  final double amount;
  const ApplyLoanScreen({super.key, required this.amount});
  @override
  State<ApplyLoanScreen> createState() => _ApplyLoanScreenState();
}

class _ApplyLoanScreenState extends State<ApplyLoanScreen> {
  bool _agreed = false, _loading = false;
  static const double _fee = 100;
  double get _total => widget.amount + _fee;
  DateTime get _due => DateTime.now().add(const Duration(days: 15));

  Future<void> _apply() async {
    if (!_agreed) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please agree to terms'),
        backgroundColor: Colors.red));
      return;
    }
    setState(() => _loading = true);
    HapticFeedback.mediumImpact();
    final p = context.read<AppProvider>();
    final result = await p.applyLoan(widget.amount);
    if (result == 'active_loan_exists') {
      setState(() => _loading = false);
      showDialog(context: context, builder: (_) => AlertDialog(
        title: const Text('Active Loan Exists'),
        content: const Text(
          'You already have an active loan. '
          'Please complete repayment before applying for a new loan.'),
        actions: [TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'))],
      ));
      return;
    }
    if (result == 'blacklisted') {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Your account is blacklisted due to non-payment.'),
        backgroundColor: Colors.red));
      return;
    }
    HapticFeedback.heavyImpact();
    final loan = p.activeLoan!;
    if (mounted) {
      Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (_) => RepaymentScreen(loan: loan)),
        (r) => r.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy');
    final penalty = PenaltyCalc.calculate(widget.amount);
    return Scaffold(
      appBar: AppBar(title: const Text('Apply for Loan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: double.infinity, padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20)),
            child: Column(children: [
              const Text('Loan Amount',
                style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 8),
              Text('₹${widget.amount.toInt()}', style: const TextStyle(
                color: Colors.white, fontSize: 48,
                fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20)),
                child: Text('Due: ${fmt.format(_due)}',
                  style: const TextStyle(color: Colors.white, fontSize: 14))),
            ])),
          const SizedBox(height: 20),
          const Text('Loan Breakdown',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _InfoCard(rows: [
            ['Principal', '₹${widget.amount.toInt()}', false],
            ['Processing Fee', '₹${_fee.toInt()}', false],
            ['Total Repayable', '₹${_total.toInt()}', true],
            ['Due Date', fmt.format(_due), false],
            ['Tenure', '15 Days', false],
          ]),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('Penalty Schedule', style: TextStyle(
                    fontWeight: FontWeight.bold, color: Color(0xFFE65100))),
                ]),
                const SizedBox(height: 8),
                Text(
                  'Late penalty: ₹${penalty.toInt()} added if not paid by due date.\n'
                  'Days 1-5: 0% | Days 6-10: 25% | Days 11-15: 50%\n'
                  'Days 16-20: 75% | Days 21-25: 100% | Days 26-30: 200%\n'
                  'After 30 days: Account BLACKLISTED.',
                  style: const TextStyle(color: Color(0xFFE65100), fontSize: 12,
                    height: 1.5)),
              ])),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200)),
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(Icons.lock, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Text('PERMANENT AutoPay Mandate', style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.red)),
                ]),
                SizedBox(height: 8),
                Text(
                  'By accepting, you authorize a PERMANENT AutoPay mandate. '
                  'This mandate CANNOT be cancelled until full loan repayment. '
                  'A ₹1 verification charge will be deducted to activate the mandate.',
                  style: TextStyle(color: Colors.red, fontSize: 12, height: 1.5)),
              ])),
          const SizedBox(height: 16),
          Container(height: 130,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!)),
            child: const SingleChildScrollView(child: Text(
              'TERMS & CONDITIONS\n\n'
              '1. Loan credited to UPI within 30 minutes of approval.\n'
              '2. Repayment due within 15 days of disbursement.\n'
              '3. Processing fee of ₹100 is non-refundable.\n'
              '4. Grace period of 5 days. Penalties apply after grace period.\n'
              '5. AutoPay mandate is permanent and irrevocable until full repayment.\n'
              '6. Account blacklisted after 30 days of non-payment.\n'
              '7. On-time repayment increases credit limit progressively.\n'
              '8. Partial payments accepted; remaining balance clears with penalty.',
              style: TextStyle(fontSize: 12, height: 1.5)))),
          const SizedBox(height: 12),
          Row(children: [
            Checkbox(value: _agreed,
              onChanged: (v) => setState(() => _agreed = v ?? false),
              activeColor: const Color(0xFF1565C0)),
            const Expanded(child: Text(
              'I agree to all terms, conditions, penalty schedule, '
              'and permanent AutoPay mandate.',
              style: TextStyle(fontSize: 13))),
          ]),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _apply,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14))),
              child: _loading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Apply Now 🚀',
                    style: TextStyle(fontSize: 16,
                      fontWeight: FontWeight.bold)))),
          const SizedBox(height: 32),
        ]),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<List<dynamic>> rows;
  const _InfoCard({required this.rows});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(14)),
      child: Column(children: rows.asMap().entries.map((e) {
        final r = e.value; final last = e.key == rows.length - 1;
        final first = e.key == 0;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: r[2] == true ? const Color(0xFFE3F2FD) : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: first ? const Radius.circular(14) : Radius.zero,
              topRight: first ? const Radius.circular(14) : Radius.zero,
              bottomLeft: last ? const Radius.circular(14) : Radius.zero,
              bottomRight: last ? const Radius.circular(14) : Radius.zero),
            border: last ? null : const Border(
              bottom: BorderSide(color: Color(0xFFEEEEEE)))),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(r[0], style: TextStyle(color: Colors.grey[700],
                fontWeight: r[2] == true ? FontWeight.bold : FontWeight.normal,
                fontSize: 14)),
              Text(r[1], style: TextStyle(fontSize: 14,
                fontWeight: r[2] == true ? FontWeight.bold : FontWeight.w500,
                color: r[2] == true ? const Color(0xFF1565C0) : Colors.black87)),
            ]));
      }).toList()),
    );
  }
}
