import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/app_provider.dart';
import '../utils/validators.dart';
import 'home_screen.dart';

class KycScreen extends StatefulWidget {
  final String mobile;
  const KycScreen({super.key, required this.mobile});
  @override
  State<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends State<KycScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _pan = TextEditingController();
  final _dob = TextEditingController();
  final _upi = TextEditingController();
  final _addr = TextEditingController();
  final _city = TextEditingController();
  final _pin = TextEditingController();
  String _state = 'Maharashtra';
  bool _terms = false, _loading = false;
  String? _faceImagePath;
  List<String> _faceImages = [];

  final _states = [
    'Andhra Pradesh','Arunachal Pradesh','Assam','Bihar','Chhattisgarh',
    'Goa','Gujarat','Haryana','Himachal Pradesh','Jharkhand','Karnataka',
    'Kerala','Madhya Pradesh','Maharashtra','Manipur','Meghalaya','Mizoram',
    'Nagaland','Odisha','Punjab','Rajasthan','Sikkim','Tamil Nadu',
    'Telangana','Tripura','Uttar Pradesh','Uttarakhand','West Bengal',
    'Delhi','Jammu & Kashmir',
  ];

  @override
  void dispose() {
    _name.dispose(); _pan.dispose(); _dob.dispose(); _upi.dispose();
    _addr.dispose(); _city.dispose(); _pin.dispose(); super.dispose();
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

  Future<void> _takeFacePhoto() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 80);
    if (img != null) {
      setState(() {
        _faceImages.add(img.path);
        _faceImagePath = img.path;
      });
      if (_faceImages.length < 3 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Photo ${_faceImages.length}/3 captured. '
              '${3 - _faceImages.length} more needed.'),
          backgroundColor: const Color(0xFF1565C0)));
      }
    }
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    if (_faceImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please complete face verification (3 photos)'),
        backgroundColor: Colors.red)); return;
    }
    if (!_terms) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please accept Terms & Conditions'),
        backgroundColor: Colors.red)); return;
    }
    setState(() => _loading = true);

    final user = UserModel(
      fullName: _name.text.trim(),
      mobile: widget.mobile,
      pan: _pan.text.trim().toUpperCase(),
      dob: _dob.text.trim(),
      upiId: _upi.text.trim(),
      address: _addr.text.trim(),
      city: _city.text.trim(),
      state: _state,
      pincode: _pin.text.trim(),
      faceImagePath: _faceImagePath ?? '',
      allImages: _faceImages,
    );

    final error = await context.read<AppProvider>().register(user);
    setState(() => _loading = false);

    if (error == 'mobile_exists') {
      showDialog(context: context, builder: (_) => AlertDialog(
        title: const Text('Already Registered'),
        content: const Text('This mobile number is already registered. Please login.'),
        actions: [TextButton(
          onPressed: () { Navigator.pop(context);
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const HomeScreen())); },
          child: const Text('Login'))],
      ));
    } else if (error == 'pan_exists') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('This PAN is already registered with another account.'),
        backgroundColor: Colors.red));
    } else if (error == null) {
      HapticFeedback.heavyImpact();
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
  }

  Widget _field(TextEditingController c, String label, String hint,
      IconData icon, String? Function(String?)? validator,
      {TextInputType? type, List<TextInputFormatter>? fmt, bool readOnly = false,
       VoidCallback? onTap}) {
    return TextFormField(
      controller: c, validator: validator, keyboardType: type,
      inputFormatters: fmt, readOnly: readOnly, onTap: onTap,
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
        padding: const EdgeInsets.all(20),
        child: Form(key: _form, child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                const Icon(Icons.phone, color: Color(0xFF1565C0)),
                const SizedBox(width: 10),
                Text('+91 ${widget.mobile}',
                  style: const TextStyle(fontWeight: FontWeight.bold,
                      color: Color(0xFF1565C0))),
              ])),
            const SizedBox(height: 20),
            _field(_name, 'Full Name', 'e.g. Rahul Sharma',
              Icons.person_outline, Validators.name,
              fmt: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))]),
            const SizedBox(height: 16),
            _field(_pan, 'PAN Card', 'ABCDE1234F',
              Icons.credit_card, Validators.pan,
              fmt: [_UpperCase(), LengthLimitingTextInputFormatter(10)]),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dob, readOnly: true, onTap: _pickDOB,
              validator: Validators.dob,
              decoration: InputDecoration(
                labelText: 'Date of Birth', hintText: 'DD/MM/YYYY',
                prefixIcon: const Icon(Icons.cake, color: Color(0xFF1565C0)),
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
            _field(_upi, 'UPI ID', 'name@upi',
              Icons.account_balance_wallet, Validators.upi,
              type: TextInputType.emailAddress),
            const SizedBox(height: 16),
            _field(_addr, 'Address Line 1', 'House no, Street',
              Icons.home, (v) => v == null || v.isEmpty ? 'Required' : null),
            const SizedBox(height: 16),
            _field(_city, 'City', 'e.g. Mumbai',
              Icons.location_city, (v) => v == null || v.isEmpty ? 'Required' : null),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _state,
              decoration: InputDecoration(
                labelText: 'State',
                prefixIcon: const Icon(Icons.map, color: Color(0xFF1565C0)),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12))),
              items: _states.map((s) => DropdownMenuItem(
                  value: s, child: Text(s))).toList(),
              onChanged: (v) => setState(() => _state = v ?? _state),
            ),
            const SizedBox(height: 16),
            _field(_pin, 'Pincode', '400001',
              Icons.pin, Validators.pincode,
              type: TextInputType.number,
              fmt: [FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6)]),
            const SizedBox(height: 24),

            // Face Verification
            const Text('Face Verification',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _faceImages.length < 3 ? _takeFacePhoto : null,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: _faceImages.length >= 3
                    ? const Color(0xFFE8F5E9) : const Color(0xFFE3F2FD),
                  border: Border.all(color: _faceImages.length >= 3
                    ? Colors.green : const Color(0xFF1565C0)),
                ),
                child: Column(children: [
                  Row(children: [
                    Icon(
                      _faceImages.length >= 3
                        ? Icons.verified_user : Icons.face,
                      color: _faceImages.length >= 3
                        ? Colors.green : const Color(0xFF1565C0), size: 36),
                    const SizedBox(width: 16),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _faceImages.length >= 3
                            ? '✅ Face Verified (${_faceImages.length}/3)'
                            : 'Tap to capture face (${_faceImages.length}/3)',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                        const Text(
                          'Take 3 selfies for liveness verification',
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ])),
                  ]),
                  if (_faceImages.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Row(children: _faceImages.map((p) =>
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 60, height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green, width: 2),
                          image: DecorationImage(
                            image: FileImage(File(p)),
                            fit: BoxFit.cover)),
                        child: const Align(
                          alignment: Alignment.topRight,
                          child: Icon(Icons.check_circle,
                              color: Colors.green, size: 18)),
                      )).toList()),
                  ],
                ]),
              ),
            ),
            const SizedBox(height: 24),
            Row(children: [
              Checkbox(value: _terms,
                onChanged: (v) => setState(() => _terms = v ?? false),
                activeColor: const Color(0xFF1565C0)),
              const Expanded(child: Text(
                'I agree to Terms & Conditions, Privacy Policy, '
                'and Permanent AutoPay Mandate',
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
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Create Account',
                      style: TextStyle(fontSize: 16,
                          fontWeight: FontWeight.bold)))),
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
