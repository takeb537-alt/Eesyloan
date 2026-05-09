import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'otp_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _ctrl = PageController();
  int _page = 0;

  final _pages = [
    _OBData('⚡', 'Instant Loan',
        'Get emergency funds in minutes.\nNo paperwork, no hassle.'),
    _OBData('📅', '15 Days Tenure',
        'Flexible 15-day repayment period.\nNo hidden charges.'),
    _OBData('💰', 'Easy Repayment',
        'Swipe to pay instantly.\nPartial payments accepted.'),
    _OBData('🔒', 'Permanent AutoPay',
        'One-time mandate activation.\nCannot be cancelled until full repayment.'),
  ];

  void _finish() async {
    await context.read<AppProvider>().completeOnboarding();
    if (mounted) Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const OtpScreen()));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        PageView.builder(
          controller: _ctrl,
          itemCount: _pages.length,
          onPageChanged: (i) => setState(() => _page = i),
          itemBuilder: (_, i) => Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
              ),
            ),
            child: Center(child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_pages[i].emoji,
                      style: const TextStyle(fontSize: 90)),
                  const SizedBox(height: 32),
                  Text(_pages[i].title, style: const TextStyle(
                    color: Colors.white, fontSize: 30,
                    fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  Text(_pages[i].sub, style: const TextStyle(
                    color: Colors.white70, fontSize: 17, height: 1.6),
                    textAlign: TextAlign.center),
                ],
              ),
            )),
          ),
        ),
        Positioned(top: 52, right: 20,
          child: TextButton(onPressed: _finish,
            child: const Text('Skip',
              style: TextStyle(color: Colors.white, fontSize: 16)))),
        Positioned(bottom: 48, left: 24, right: 24,
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) =>
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _page == i ? 28 : 8, height: 8,
                  decoration: BoxDecoration(
                    color: _page == i ? Colors.white : Colors.white38,
                    borderRadius: BorderRadius.circular(4)),
                ))),
            const SizedBox(height: 28),
            SizedBox(width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_page < _pages.length - 1) {
                    _ctrl.nextPage(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut);
                  } else { _finish(); }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1565C0),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14))),
                child: Text(
                  _page == _pages.length - 1 ? 'Get Started' : 'Next',
                  style: const TextStyle(fontSize: 16,
                      fontWeight: FontWeight.bold)))),
          ])),
      ]),
    );
  }
}

class _OBData {
  final String emoji, title, sub;
  _OBData(this.emoji, this.title, this.sub);
}
