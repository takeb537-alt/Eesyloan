import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/loan_provider.dart';
import '../widgets/loan_amount_grid.dart';
import 'apply_loan_screen.dart';
import 'repayment_screen.dart';
import 'my_loans_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _idx = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _idx, children: const [
        _HomeTab(), MyLoansScreen(), ProfileScreen()]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _idx,
        onDestinationSelected: (i) => setState(() => _idx = i),
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFBBDEFB),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined),
            label: 'Home',
            selectedIcon: Icon(Icons.home, color: Color(0xFF1565C0))),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined),
            label: 'My Loans',
            selectedIcon: Icon(Icons.receipt_long, color: Color(0xFF1565C0))),
          NavigationDestination(icon: Icon(Icons.person_outline),
            label: 'Profile',
            selectedIcon: Icon(Icons.person, color: Color(0xFF1565C0))),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();
  String _greet() {
    final h = DateTime.now().hour;
    return h < 12 ? 'Good Morning,' : h < 17 ? 'Good Afternoon,' : 'Good Evening,';
  }
  @override
  Widget build(BuildContext context) {
    final p = context.watch<LoanProvider>();
    final loan = p.activeLoan;
    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(expandedHeight: 170, pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(gradient: LinearGradient(
                colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                begin: Alignment.topLeft, end: Alignment.bottomRight)),
              child: SafeArea(child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_greet(), style: const TextStyle(
                                color: Colors.white70, fontSize: 14)),
                            Text(p.user?.fullName.split(' ').first ?? 'User',
                              style: const TextStyle(color: Colors.white,
                                  fontSize: 22, fontWeight: FontWeight.bold)),
                          ]),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20)),
                          child: Column(children: [
                            const Text('Credit Limit', style: TextStyle(
                                color: Colors.white70, fontSize: 11)),
                            Text('₹${p.maxUnlockedAmount.toInt()}',
                              style: const TextStyle(color: Colors.white,
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          ])),
                      ]),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 6),
                        Text('${p.onTimePayments} On-Time Payments',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12)),
                      ])),
                  ]),
              )),
            )),
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (loan != null) ...[
                _ActiveBanner(loan: loan),
                const SizedBox(height: 20)],
              const Text('Select Loan Amount', style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(loan != null
                ? 'Repay active loan to apply new'
                : 'Tap an amount to apply instantly',
                style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              const SizedBox(height: 16),
              AbsorbPointer(
                absorbing: loan != null,
                child: Opacity(opacity: loan != null ? 0.4 : 1.0,
                  child: LoanAmountGrid(
                    onTimePayments: p.onTimePayments,
                    onAmountSelected: (amt) {
                      HapticFeedback.mediumImpact();
                      Navigator.push(context, MaterialPageRoute(
                          builder: (_) => ApplyLoanScreen(amount: amt)));
                    }))),
              const SizedBox(height: 20),
            ]),
        )),
      ]),
    );
  }
}

class _ActiveBanner extends StatelessWidget {
  final LoanModel loan;
  const _ActiveBanner({required this.loan});
  @override
  Widget build(BuildContext context) {
    final days = loan.dueDate.difference(DateTime.now()).inDays;
    final late = days < 0;
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => RepaymentScreen(loan: loan))),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(colors: late
            ? [const Color(0xFFC62828), const Color(0xFFE53935)]
            : [const Color(0xFF1B5E20), const Color(0xFF2E7D32)]),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(late ? '⚠️ Loan Overdue!' : '📋 Active Loan',
              style: const TextStyle(color: Colors.white,
                  fontWeight: FontWeight.bold, fontSize: 16)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10)),
              child: Text(late ? '${days.abs()}d late' : '${days}d left',
                style: const TextStyle(color: Colors.white, fontSize: 12))),
          ]),
          const SizedBox(height: 8),
          Text('₹${loan.totalDue.toStringAsFixed(0)} due',
            style: const TextStyle(color: Colors.white,
                fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Due: ${DateFormat('dd MMM yyyy').format(loan.dueDate)}',
            style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8)),
            child: const Row(mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.touch_app, color: Colors.white, size: 16),
                SizedBox(width: 6),
                Text('Tap to Repay', style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
              ])),
        ]),
      ),
    );
  }
}
