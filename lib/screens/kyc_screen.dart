import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/loan_provider.dart';
import '../utils/validators.dart';
import 'home_screen.dart';

class KycScreen extends StatefulWidget {
  const KycScreen({super.key});
  @override
  State<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends State<KycScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _mobile = TextEditingController();
  final _pan = TextEditingController();
  final _dob = TextEditingController();
  final _upi = TextEditingController();
  bool _terms = false, _loading = false;

  @override
  void dispose() {
    _name.dispose(); _mobile.dispose(); _pan.dispose();
    _dob.dispose(); _upi.dispose(); super.dispose();
  }

  Future<void> _pickDOB() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 22),
      firstDate: DateTime(1950),
      lastDate: DateTime(now.year - 18, now.month, now.day),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.light(
            primary: Color(0xFF1565C0))), child: child!),
    );
    if (d != null) _dob.text = DateFormat('dd/MM/yyyy').format(d);
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    if (!_terms) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please accept Terms & Conditions'),
        backgroundColor: Colors.red));
      return;
    }
    setState(() => _loading = true);
    await context.read<LoanProvider>().register(UserModel(
      fullName: _name.text.trim(), mobile: _mobile.text.trim(),
      pan: _pan.text.trim().toUpperCase(), dob: _dob.text.trim(),
      upiId: _upi.text.trim(), faceImages: [],
    ));
    if (mounted) {
      HapticFeedback.heavyImpact();
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
  }

  Widget _field(TextEditingController c, String label, String hint,
      IconData icon, String? Function(String?) validator,
      {TextInputType? type, List<TextInputFormatter>? fmt}) {
    return TextFormField(
      controller: c, validator: validator,
      keyboardType: type, inputFormatters: fmt,
      decoration: InputDecoration(
        labelText: label, hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF1565C0)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1565C0), width: 2)),
        errorStyle: const TextStyle(color: Colors.red),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('KYC Registration')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(key: _form, child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Create Your Account', style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold,
              color: Color(0xFF1565C0))),
            const SizedBox(height: 6),
            const Text('Fill in your details to get started',
              style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 28),
            _field(_name, 'Full Name', 'e.g. Rahul Sharma',
              Icons.person_outline, Validators.validateName,
              fmt: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))]),
            const SizedBox(height: 16),
            _field(_mobile, 'Mobile Number', 'e.g. 9876543210',
              Icons.phone_outlined, Validators.validateMobile,
              type: TextInputType.phone,
              fmt: [FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10)]),
            const SizedBox(height: 16),
            _field(_pan, 'PAN Card', 'e.g. ABCDE1234F',
              Icons.credit_card, Validators.validatePAN,
              fmt: [_UpperCase(), LengthLimitingTextInputFormatter(10)]),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dob, readOnly: true, onTap: _pickDOB,
              validator: Validators.validateDOB,
              decoration: InputDecoration(
                labelText: 'Date of Birth', hintText: 'DD/MM/YYYY',
                prefixIcon: const Icon(Icons.cake_outlined,
                    color: Color(0xFF1565C0)),
                suffixIcon: const Icon(Icons.calendar_today,
                    color: Color(0xFF1565C0)),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: Color(0xFF1565C0), width: 2)),
                errorStyle: const TextStyle(color: Colors.red),
              ),
            ),
            const SizedBox(height: 16),
            _field(_upi, 'UPI ID', 'e.g. name@upi',
              Icons.account_balance_wallet_outlined,
              Validators.validateUPI,
              type: TextInputType.emailAddress),
            const SizedBox(height: 24),
            Row(children: [
              Checkbox(value: _terms,
                onChanged: (v) => setState(() => _terms = v ?? false),
                activeColor: const Color(0xFF1565C0)),
              const Expanded(child: Text(
                'I agree to EasyLoan Terms & Conditions',
                style: TextStyle(fontSize: 13))),
            ]),
            const SizedBox(height: 24),
            SizedBox(width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14))),
                child: _loading
                  ? const SizedBox(height: 22, width: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                  : const Text('Create Account', style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              )),
            const SizedBox(height: 32),
          ],
        )),
      ),
    );
  }
}

class _UpperCase extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue o, TextEditingValue n) =>
      n.copyWith(text: n.text.toUpperCase());
}
