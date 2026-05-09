import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/loan_provider.dart';
import 'repayment_screen.dart';

class MyLoansScreen extends StatelessWidget {
  const MyLoansScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final loans = context.watch<LoanProvider>().loans.reversed.toList();
    return Scaffold(
      appBar: AppBar(title: const Text('My Loans')),
      body: loans.isEmpty
        ? const Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text('No loans yet', style: TextStyle(
                fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold)),
            Text('Apply from Home tab',
                style: TextStyle(color: Colors.grey)),
          ]))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: loans.length,
            itemBuilder: (_, i) => _LoanCard(loan: loans[i])),
    );
  }
}

class _LoanCard extends StatelessWidget {
  final LoanModel loan;
  const _LoanCard({required this.loan});
  Color get _color => loan.status == LoanStatus.completed
    ? const Color(0xFF2E7D32) : loan.status == LoanStatus.overdue
    ? const Color(0xFFC62828) : const Color(0xFF1565C0);
  String get _label => loan.status.name.toUpperCase();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loan.status != LoanStatus.completed ? () => Navigator.push(
        context, MaterialPageRoute(
            builder: (_) => RepaymentScreen(loan: loan))) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16), color: Colors.white,
          border: Border.all(color: _color.withOpacity(0.3)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05),
              blurRadius: 10, offset: const Offset(0, 3))]),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _color.withOpacity(0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16))),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('ID: ${loan.id}', style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 13)),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: _color,
                      borderRadius: BorderRadius.circular(10)),
                  child: Text(_label, style: const TextStyle(
                      color: Colors.white, fontSize: 11,
                      fontWeight: FontWeight.bold))),
              ])),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              Row(children: [
                Expanded(child: _tile('Amount', '₹${loan.amount.toInt()}')),
                Expanded(child: _tile('Total Due',
                    '₹${loan.principalDue.toStringAsFixed(0)}')),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: _tile('Due Date',
                    DateFormat('dd MMM yyyy').format(loan.dueDate))),
                Expanded(child: _tile('Paid',
                    '₹${loan.amountPaid.toStringAsFixed(0)}',
                    green: true)),
              ]),
              if (loan.status != LoanStatus.completed) ...[
                const SizedBox(height: 12),
                SizedBox(width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => RepaymentScreen(loan: loan))),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _color,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                    child: const Text('Pay Now',
                        style: TextStyle(color: Colors.white)))),
              ],
            ])),
        ]),
      ),
    );
  }
  Widget _tile(String l, String v, {bool green=false}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(l, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
    Text(v, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15,
        color: green ? Colors.green : Colors.black87)),
  ]);
}
