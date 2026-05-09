class Validators {
  static String? name(String? v) {
    if (v == null || v.trim().isEmpty) return 'Name required';
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(v.trim())) return 'Letters only';
    if (v.trim().length < 3) return 'Min 3 characters';
    return null;
  }

  static String? mobile(String? v) {
    if (v == null || v.trim().isEmpty) return 'Mobile required';
    if (!RegExp(r'^[6-9][0-9]{9}$').hasMatch(v.trim()))
      return 'Valid 10-digit number required';
    return null;
  }

  static String? pan(String? v) {
    if (v == null || v.trim().isEmpty) return 'PAN required';
    if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$')
        .hasMatch(v.trim().toUpperCase()))
      return 'Invalid PAN (e.g. ABCDE1234F)';
    return null;
  }

  static String? upi(String? v) {
    if (v == null || v.trim().isEmpty) return 'UPI ID required';
    if (!v.contains('@')) return 'UPI must contain @';
    return null;
  }

  static String? pincode(String? v) {
    if (v == null || v.trim().isEmpty) return 'Pincode required';
    if (!RegExp(r'^[0-9]{6}$').hasMatch(v.trim())) return '6-digit pincode';
    return null;
  }

  static String? dob(String? v) {
    if (v == null || v.trim().isEmpty) return 'DOB required';
    try {
      final parts = v.split('/');
      if (parts.length != 3) return 'Use DD/MM/YYYY';
      final d = DateTime(int.parse(parts[2]), int.parse(parts[1]),
          int.parse(parts[0]));
      if (DateTime.now().difference(d).inDays ~/ 365 < 18) return 'Must be 18+';
    } catch (_) { return 'Invalid date'; }
    return null;
  }
}
