import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'permission_screen.dart';
import 'otp_screen.dart';
import 'onboarding_screen.dart';
import 'home_screen.dart';

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
        vsync: this, duration: const Duration(milliseconds: 1400));
    _scale = Tween<double>(begin: 0.7, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _fade = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
    _ctrl.forward();
    Future.delayed(const Duration(seconds: 3), _navigate);
  }

  void _navigate() {
    if (!mounted) return;
    final p = context.read<AppProvider>();
    Widget next;
    if (!p.permsDone) {
      next = const PermissionScreen();
    } else if (!p.onboarded) {
      next = const OnboardingScreen();
    } else if (!p.loggedIn) {
      next = const OtpScreen();
    } else {
      next = const HomeScreen();
    }
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => next));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 110, height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                    ),
                    boxShadow: [BoxShadow(
                      color: const Color(0xFF1565C0).withOpacity(0.4),
                      blurRadius: 24, offset: const Offset(0, 8),
                    )],
                  ),
                  child: const Center(
                    child: Text('₹', style: TextStyle(
                      fontSize: 56, color: Colors.white,
                      fontWeight: FontWeight.bold,
                    )),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('EasyLoan', style: TextStyle(
                  fontSize: 38, fontWeight: FontWeight.bold,
                  color: Color(0xFF1565C0), letterSpacing: 1.5,
                )),
                const SizedBox(height: 8),
                const Text('Financial Freedom, Fast', style: TextStyle(
                  color: Colors.grey, fontSize: 15,
                )),
                const SizedBox(height: 48),
                const CircularProgressIndicator(
                  color: Color(0xFF1565C0), strokeWidth: 2.5),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
