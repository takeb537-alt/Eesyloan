import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/loan_provider.dart';
import 'kyc_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _ctrl = PageController();
  int _page = 0;

  final _pages = [
    {'emoji': '⚡', 'title': 'Instant Loan',
     'sub': 'Get emergency funds in minutes.\nNo paperwork, no hassle.'},
    {'emoji': '📅', 'title': '15 Days Tenure',
     'sub': 'Flexible 15-day repayment period.\nRenew anytime you need.'},
    {'emoji': '💰', 'title': 'Easy Repayment',
     'sub': 'Pay full or partial amounts.\nSwipe to pay in one touch.'},
  ];

  void _finish() {
    context.read<LoanProvider>().completeOnboarding();
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => const KycScreen()));
  }

  void _next() {
    if (_page < 2) {
      _ctrl.nextPage(
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    } else { _finish(); }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        PageView.builder(
          controller: _ctrl,
          itemCount: 3,
          onPageChanged: (i) => setState(() => _page = i),
          itemBuilder: (_, i) => Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF1565C0),
                  Color(0xFF1565C0 + i * 0x001010)],
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
              ),
            ),
            child: Center(child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_pages[i]['emoji']!,
                      style: const TextStyle(fontSize: 90)),
                  const SizedBox(height: 32),
                  Text(_pages[i]['title']!, style: const TextStyle(
                    color: Colors.white, fontSize: 32,
                    fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  Text(_pages[i]['sub']!, style: const TextStyle(
                    color: Colors.white70, fontSize: 18, height: 1.5),
                    textAlign: TextAlign.center),
                ],
              ),
            )),
          ),
        ),
        Positioned(top: 52, right: 24,
          child: TextButton(onPressed: _finish,
            child: const Text('Skip',
              style: TextStyle(color: Colors.white, fontSize: 16)))),
        Positioned(bottom: 48, left: 24, right: 24,
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _page == i ? 24 : 8, height: 8,
                decoration: BoxDecoration(
                  color: _page == i ? Colors.white : Colors.white38,
                  borderRadius: BorderRadius.circular(4)),
              ))),
            const SizedBox(height: 32),
            SizedBox(width: double.infinity,
              child: ElevatedButton(onPressed: _next,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1565C0),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14))),
                child: Text(_page == 2 ? 'Get Started' : 'Next',
                  style: const TextStyle(fontSize: 16,
                      fontWeight: FontWeight.bold)))),
          ])),
      ]),
    );
  }
}
