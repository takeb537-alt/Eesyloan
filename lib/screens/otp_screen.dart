import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'kyc_screen.dart';
import 'home_screen.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});
  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _mobileCon = TextEditingController();
  final _otpCon = TextEditingController();
  bool _otpSent = false;
  bool _loading = false;
  String? _mobileError;
  // Demo OTP — in production replace with Firebase Phone Auth
  static const _demoOtp = '123456';

  void _sendOtp() async {
    final mobile = _mobileCon.text.trim();
    if (!RegExp(r'^[6-9][0-9]{9}$').hasMatch(mobile)) {
      setState(() => _mobileError = 'Enter valid 10-digit mobile number');
      return;
    }
    setState(() { _mobileError = null; _loading = true; });
    await Future.delayed(const Duration(seconds: 1)); // simulate
    setState(() { _otpSent = true; _loading = false; });
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('OTP sent! Use 123456 for testing'),
        backgroundColor: Color(0xFF1565C0),
      ));
  }

  void _verifyOtp() async {
    if (_otpCon.text.trim() != _demoOtp) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Invalid OTP. Use 123456 for demo'),
        backgroundColor: Colors.red));
      return;
    }
    setState(() => _loading = true);
    final mobile = _mobileCon.text.trim();
    final p = context.read<AppProvider>();

    // Check if already registered
    final exists = await p.loginWithMobile(mobile);
    if (exists) {
      if (mounted) Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else {
      // New user — go to KYC with mobile
      if (mounted) Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => KycScreen(mobile: mobile)));
    }
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _mobileCon.dispose(); _otpCon.dispose(); super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Center(
                child: Text('EasyLoan', style: TextStyle(
                  fontSize: 32, fontWeight: FontWeight.bold,
                  color: Color(0xFF1565C0)))),
              const SizedBox(height: 8),
              const Center(child: Text('Financial Freedom, Fast',
                style: TextStyle(color: Colors.grey))),
              const SizedBox(height: 56),
              const Text('Enter Mobile Number', style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text('We will send an OTP to verify your number',
                style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 28),
              TextField(
                controller: _mobileCon,
                keyboardType: TextInputType.phone,
                enabled: !_otpSent,
                maxLength: 10,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'Mobile Number',
                  hintText: '9876543210',
                  prefixText: '+91 ',
                  errorText: _mobileError,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: Color(0xFF1565C0), width: 2)),
                ),
              ),
              if (!_otpSent) ...[
                const SizedBox(height: 24),
                SizedBox(width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _sendOtp,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14))),
                    child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Send OTP',
                          style: TextStyle(fontSize: 16,
                              fontWeight: FontWeight.bold)))),
              ],
              if (_otpSent) ...[
                const SizedBox(height: 24),
                TextField(
                  controller: _otpCon,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'Enter OTP',
                    hintText: '123456',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: Color(0xFF1565C0), width: 2)),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14))),
                    child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Verify & Continue',
                          style: TextStyle(fontSize: 16,
                              fontWeight: FontWeight.bold)))),
                const SizedBox(height: 16),
                Center(child: TextButton(
                  onPressed: () => setState(() => _otpSent = false),
                  child: const Text('Change Number',
                    style: TextStyle(color: Color(0xFF1565C0))))),
              ],
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: const Row(children: [
                  Icon(Icons.info_outline, color: Colors.orange),
                  SizedBox(width: 10),
                  Expanded(child: Text(
                    'Demo mode: Use OTP 123456\n'
                    'Production: Firebase Phone Auth',
                    style: TextStyle(color: Color(0xFFE65100),
                        fontSize: 12))),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
