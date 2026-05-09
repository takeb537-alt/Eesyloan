import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/loan_provider.dart';
import 'onboarding_screen.dart';
import 'home_screen.dart';
import 'kyc_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale, _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _scale = Tween<double>(begin: 0.6, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _fade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
    _ctrl.forward();
    Future.delayed(const Duration(seconds: 2), _navigate);
  }

  void _navigate() {
    if (!mounted) return;
    final p = context.read<LoanProvider>();
    Widget next = p.onboarded
        ? (p.isRegistered ? const HomeScreen() : const KycScreen())
        : const OnboardingScreen();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => next));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D47A1), Color(0xFF1976D2), Color(0xFF42A5F5)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: FadeTransition(opacity: _fade,
            child: ScaleTransition(scale: _scale,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 100, height: 100,
                  decoration: BoxDecoration(color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2),
                      blurRadius: 20, offset: const Offset(0, 8))],
                  ),
                  child: const Center(child: Text('₹', style: TextStyle(
                    fontSize: 52, color: Color(0xFF1565C0),
                    fontWeight: FontWeight.bold))),
                ),
                const SizedBox(height: 24),
                const Text('EasyLoan', style: TextStyle(color: Colors.white,
                  fontSize: 36, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Instant Emergency Loans',
                  style: TextStyle(color: Colors.white70, fontSize: 16)),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
