class Validators {
  static String? validateName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Name is required';
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(v.trim()))
      return 'Letters only';
    if (v.trim().length < 3) return 'Min 3 characters';
    return null;
  }
  static String? validateMobile(String? v) {
    if (v == null || v.trim().isEmpty) return 'Mobile is required';
    if (!RegExp(r'^[6-9][0-9]{9}$').hasMatch(v.trim()))
      return 'Enter valid 10-digit mobile';
    return null;
  }
  static String? validatePAN(String? v) {
    if (v == null || v.trim().isEmpty) return 'PAN is required';
    if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(v.trim().toUpperCase()))
      return 'Invalid PAN (e.g. ABCDE1234F)';
    return null;
  }
  static String? validateUPI(String? v) {
    if (v == null || v.trim().isEmpty) return 'UPI ID is required';
    if (!v.contains('@')) return 'UPI must contain @';
    return null;
  }
  static String? validateDOB(String? v) {
    if (v == null || v.trim().isEmpty) return 'DOB is required';
    try {
      final p = v.split('/');
      if (p.length != 3) return 'Use DD/MM/YYYY';
      final dob = DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
      if (DateTime.now().difference(dob).inDays ~/ 365 < 18)
        return 'Must be 18+';
    } catch (_) { return 'Invalid date'; }
    return null;
  }
}
