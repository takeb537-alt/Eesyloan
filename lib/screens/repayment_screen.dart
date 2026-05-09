import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/loan_provider.dart';
import '../widgets/swipe_to_pay.dart';
import 'home_screen.dart';

class RepaymentScreen extends StatefulWidget {
  final LoanModel loan;
  const RepaymentScreen({super.key, required this.loan});
  @override
  State<RepaymentScreen> createState() => _RepaymentScreenState();
}

class _RepaymentScreenState extends State<RepaymentScreen> {
  final _partialCtrl = TextEditingController();
  bool _showPartial = false, _paying = false;
  String? _partialErr;

  LoanModel get _loan => context.read<LoanProvider>().loans
      .firstWhere((l) => l.id == widget.loan.id, orElse: () => widget.loan);
  bool get _overdue => _loan.status == LoanStatus.overdue;
  double get _penalty => _overdue ? PenaltyCalculator.calculate(_loan.amount) : 0;
  double get _due => _loan.amount + _loan.fee + _penalty - _loan.amountPaid;

  @override
  void dispose() { _partialCtrl.dispose(); super.dispose(); }

  Future<void> _payFull() async {
    setState(() => _paying = true);
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 600));
    final done = await context.read<LoanProvider>().makePayment(_loan.id, _due);
    if (mounted) _showSuccess(done, _due);
    setState(() => _paying = false);
  }

  Future<void> _payPartial() async {
    final amt = double.tryParse(_partialCtrl.text.trim());
    if (amt == null || amt < 10) {
      setState(() => _partialErr = 'Min ₹10'); return;
    }
    if (amt > _due) {
      setState(() => _partialErr = 'Max ₹${_due.toStringAsFixed(0)}'); return;
    }
    setState(() { _partialErr = null; _paying = true; });
    HapticFeedback.mediumImpact();
    final done = await context.read<LoanProvider>().makePayment(_loan.id, amt);
    if (mounted) _showSuccess(done, amt);
    setState(() => _paying = false);
  }

  void _showSuccess(bool done, double amt) {
    showDialog(context: context, barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 12),
          Icon(done ? Icons.check_circle : Icons.payment,
            color: done ? Colors.green : const Color(0xFF1565C0), size: 72),
          const SizedBox(height: 16),
          Text(done ? 'Loan Closed! 🎉' : 'Payment Received',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('₹${amt.toStringAsFixed(0)} paid successfully',
            style: const TextStyle(color: Colors.grey)),
        ]),
        actions: [TextButton(
          onPressed: () {
            Navigator.pop(context);
            if (done) Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (r) => false);
            else Navigator.pop(context);
          },
          child: const Text('OK', style: TextStyle(
              color: Color(0xFF1565C0), fontWeight: FontWeight.bold)))],
      ));
  }

  @override
  Widget build(BuildContext context) {
    final loan = _loan;
    final days = loan.dueDate.difference(DateTime.now()).inDays;
    return Scaffold(
      appBar: AppBar(title: const Text('Loan Repayment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (_overdue) Container(
            width: double.infinity, padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red)),
            child: Row(children: [
              const Icon(Icons.warning, color: Colors.red),
              const SizedBox(width: 10),
              Expanded(child: Text(
                'OVERDUE! Penalty ₹${_penalty.toInt()} added.',
                style: const TextStyle(color: Colors.red,
                    fontWeight: FontWeight.bold))),
            ])),
          Container(
            width: double.infinity, padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: _overdue
                ? [const Color(0xFFC62828), const Color(0xFFE53935)]
                : [const Color(0xFF0D47A1), const Color(0xFF1976D2)],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20)),
            child: Column(children: [
              const Text('Total Due', style: TextStyle(
                  color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 8),
              Text('₹${_due.toStringAsFixed(0)}', style: const TextStyle(
                color: Colors.white, fontSize: 44,
                fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _chip('Due', DateFormat('dd MMM').format(loan.dueDate)),
                  _chip(_overdue ? 'Late' : 'Left',
                      '${_overdue ? days.abs() : days}d'),
                  _chip('ID', loan.id),
                ]),
            ])),
          const SizedBox(height: 20),
          _row('Principal', '₹${loan.amount.toInt()}'),
          _row('Fee', '₹${loan.fee.toInt()}'),
          if (_overdue) _row('Penalty', '₹${_penalty.toInt()}', red: true),
          if (loan.amountPaid > 0) _row('Paid',
              '-₹${loan.amountPaid.toStringAsFixed(0)}', green: true),
          const Divider(height: 24),
          _row('Total Due', '₹${_due.toStringAsFixed(0)}', bold: true),
          const SizedBox(height: 28),
          const Text('Full Payment', style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _paying ? const Center(child: CircularProgressIndicator())
            : SwipeToPayWidget(amount: _due, onPaymentComplete: _payFull),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => setState(() => _showPartial = !_showPartial),
            child: Row(children: [
              const Text('Partial Payment', style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold)),
              Icon(_showPartial ? Icons.expand_less : Icons.expand_more,
                  color: const Color(0xFF1565C0)),
            ])),
          if (_showPartial) ...[
            const SizedBox(height: 12),
            TextField(controller: _partialCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Amount (min ₹10)',
                prefixText: '₹ ', errorText: _partialErr,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: Color(0xFF1565C0), width: 2)))),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _paying ? null : _payPartial,
                icon: const Icon(Icons.payment),
                label: const Text('Pay Partial Amount'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: const Color(0xFF1565C0)))),
          ],
          const SizedBox(height: 32),
        ]),
      ),
    );
  }

  Widget _chip(String l, String v) => Column(children: [
    Text(l, style: const TextStyle(color: Colors.white70, fontSize: 11)),
    Text(v, style: const TextStyle(color: Colors.white,
        fontWeight: FontWeight.bold, fontSize: 12)),
  ]);

  Widget _row(String l, String v,
      {bool bold=false, bool red=false, bool green=false}) =>
    Padding(padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(l, style: TextStyle(color: Colors.grey[700],
            fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        Text(v, style: TextStyle(fontWeight: bold
            ? FontWeight.bold : FontWeight.w500,
          color: red ? Colors.red : green ? Colors.green
              : bold ? const Color(0xFF1565C0) : Colors.black87)),
      ]));
}
