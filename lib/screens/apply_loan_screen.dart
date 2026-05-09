import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/loan_provider.dart';
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
    try {
      final p = context.read<LoanProvider>();
      final loan = await p.applyLoan(widget.amount);
      HapticFeedback.heavyImpact();
      if (mounted) {
        Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (_) => RepaymentScreen(loan: loan)),
          (r) => r.isFirst);
      }
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy');
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20)),
                child: Text('Due: ${fmt.format(_due)}',
                  style: const TextStyle(color: Colors.white, fontSize: 14))),
            ])),
          const SizedBox(height: 24),
          const Text('Payment Breakdown', style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _card([
            ['Principal', '₹${widget.amount.toInt()}', false],
            ['Processing Fee', '₹${_fee.toInt()}', false],
            ['Total Repayable', '₹${_total.toInt()}', true],
            ['Due Date', fmt.format(_due), false],
            ['Tenure', '15 Days', false],
          ]),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange)),
            child: Row(children: [
              const Icon(Icons.warning_amber_rounded,
                  color: Colors.orange, size: 28),
              const SizedBox(width: 12),
              Expanded(child: Text(
                'Late penalty: ₹${PenaltyCalculator.calculate(widget.amount).toInt()} added if not paid by due date.',
                style: const TextStyle(color: Color(0xFFE65100), fontSize: 13))),
            ])),
          const SizedBox(height: 16),
          Container(height: 120,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!)),
            child: const SingleChildScrollView(child: Text(
              '1. Loan credited to UPI within 24 hours.\n'
              '2. Repayment within 15 days.\n'
              '3. Processing fee of ₹100 applicable.\n'
              '4. One-time penalty on overdue payments.\n'
              '5. On-time repayment increases credit limit.\n'
              '6. Partial payments accepted.',
              style: TextStyle(fontSize: 12, height: 1.5)))),
          const SizedBox(height: 12),
          Row(children: [
            Checkbox(value: _agreed,
              onChanged: (v) => setState(() => _agreed = v ?? false),
              activeColor: const Color(0xFF1565C0)),
            const Expanded(child: Text(
              'I agree to all terms and conditions.',
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
                ? const SizedBox(height: 22, width: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Text('Apply Now 🚀',
                    style: TextStyle(fontSize: 16,
                        fontWeight: FontWeight.bold)))),
          const SizedBox(height: 32),
        ]),
      ),
    );
  }

  Widget _card(List<List<dynamic>> rows) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(14)),
      child: Column(children: rows.asMap().entries.map((e) {
        final r = e.value;
        final last = e.key == rows.length - 1;
        final first = e.key == 0;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                fontWeight: r[2] == true
                    ? FontWeight.bold : FontWeight.normal)),
              Text(r[1], style: TextStyle(
                fontWeight: r[2] == true
                    ? FontWeight.bold : FontWeight.w500,
                color: r[2] == true
                    ? const Color(0xFF1565C0) : Colors.black87)),
            ]));
      }).toList()),
    );
  }
}
