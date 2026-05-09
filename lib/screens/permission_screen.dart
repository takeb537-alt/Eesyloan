import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'onboarding_screen.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});
  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  bool _requesting = false;

  Future<void> _requestAll() async {
    setState(() => _requesting = true);

    final results = await [
      Permission.camera,
      Permission.storage,
      Permission.location,
      Permission.contacts,
    ].request();

    final denied = <String>[];
    final permanentDenied = <String>[];

    results.forEach((permission, status) {
      final name = permission.toString().split('.').last;
      if (status.isPermanentlyDenied) permanentDenied.add(name);
      else if (status.isDenied) denied.add(name);
    });

    if (permanentDenied.isNotEmpty && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text('Permissions Required'),
          content: Text(
            '${permanentDenied.join(", ")} permissions are permanently denied. '
            'Please open Settings and grant them manually.'),
          actions: [
            TextButton(
              onPressed: () { Navigator.pop(context); openAppSettings(); },
              child: const Text('Open Settings')),
          ],
        ),
      );
      setState(() => _requesting = false);
      return;
    }

    if (denied.isNotEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            '${denied.join(", ")} required. Please grant from settings.'),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 3),
      ));
      setState(() => _requesting = false);
      return;
    }

    // All granted
    await context.read<AppProvider>().setPermsDone();
    if (mounted) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const OnboardingScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.security, size: 80, color: Color(0xFF1565C0)),
              const SizedBox(height: 24),
              const Text('Permissions Required',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text(
                'EasyLoan needs the following permissions to work properly:',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),
              const SizedBox(height: 32),
              _permTile(Icons.camera_alt, 'Camera',
                  'For face verification & KYC'),
              _permTile(Icons.folder, 'Storage',
                  'To save loan documents & PDFs'),
              _permTile(Icons.location_on, 'Location',
                  'For address verification'),
              _permTile(Icons.contacts, 'Contacts',
                  'For emergency contact reference'),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _requesting ? null : _requestAll,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _requesting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Grant Permissions',
                        style: TextStyle(fontSize: 17,
                            fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _permTile(IconData icon, String title, String sub) =>
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Container(
          width: 46, height: 46,
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF1565C0)),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(sub, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        )),
      ]),
    );
}
