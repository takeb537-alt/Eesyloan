import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

// ─── Models ──────────────────────────────────────────────────────────────────

class UserModel {
  final String fullName, mobile, pan, dob, upiId, address,
      city, state, pincode, faceImagePath;
  final List<String> allImages;

  UserModel({
    required this.fullName, required this.mobile, required this.pan,
    required this.dob, required this.upiId, required this.address,
    required this.city, required this.state, required this.pincode,
    required this.faceImagePath, required this.allImages,
  });

  Map<String, dynamic> toJson() => {
    'fullName': fullName, 'mobile': mobile, 'pan': pan, 'dob': dob,
    'upiId': upiId, 'address': address, 'city': city, 'state': state,
    'pincode': pincode, 'faceImagePath': faceImagePath,
    'allImages': allImages,
  };

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
    fullName: j['fullName'] ?? '', mobile: j['mobile'] ?? '',
    pan: j['pan'] ?? '', dob: j['dob'] ?? '', upiId: j['upiId'] ?? '',
    address: j['address'] ?? '', city: j['city'] ?? '',
    state: j['state'] ?? '', pincode: j['pincode'] ?? '',
    faceImagePath: j['faceImagePath'] ?? '',
    allImages: List<String>.from(j['allImages'] ?? []),
  );
}

enum LoanStatus { active, completed, overdue, blacklisted }

class LoanModel {
  final String id, userId;
  final double amount, fee;
  double penalty, amountPaid;
  LoanStatus status;
  final DateTime appliedDate, dueDate;
  String? pdfPath;
  bool autopayActive;

  LoanModel({
    required this.id, required this.userId, required this.amount,
    required this.fee, required this.appliedDate, required this.dueDate,
    required this.status, this.penalty = 0, this.amountPaid = 0,
    this.pdfPath, this.autopayActive = true,
  });

  double get totalDue => amount + fee + penalty - amountPaid;
  double get principalDue => amount + fee + penalty;

  double calculatePenalty() {
    if (status == LoanStatus.completed) return 0;
    final days = DateTime.now().difference(dueDate).inDays;
    if (days <= 0) return 0;
    final base = amount * 0.1;
    if (days <= 5) return 0;
    if (days <= 10) return base * 0.25;
    if (days <= 15) return base * 0.50;
    if (days <= 20) return base * 0.75;
    if (days <= 25) return base * 1.0;
    if (days <= 30) return base * 2.0;
    return base * 3.0; // blacklist territory
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'userId': userId, 'amount': amount, 'fee': fee,
    'penalty': penalty, 'amountPaid': amountPaid, 'status': status.name,
    'appliedDate': appliedDate.toIso8601String(),
    'dueDate': dueDate.toIso8601String(),
    'pdfPath': pdfPath, 'autopayActive': autopayActive,
  };

  factory LoanModel.fromJson(Map<String, dynamic> j) => LoanModel(
    id: j['id'], userId: j['userId'],
    amount: (j['amount'] as num).toDouble(),
    fee: (j['fee'] as num).toDouble(),
    penalty: (j['penalty'] as num).toDouble(),
    amountPaid: (j['amountPaid'] as num).toDouble(),
    status: LoanStatus.values.byName(j['status']),
    appliedDate: DateTime.parse(j['appliedDate']),
    dueDate: DateTime.parse(j['dueDate']),
    pdfPath: j['pdfPath'], autopayActive: j['autopayActive'] ?? true,
  );
}

// ─── Penalty Helper ───────────────────────────────────────────────────────────
class PenaltyCalc {
  static double calculate(double amount) {
    if (amount <= 100) return 50;
    if (amount <= 500) return 100;
    if (amount <= 1000) return 200;
    if (amount <= 1500) return 250;
    return 300;
  }

  static List<Map<String, String>> get schedule => [
    {'range': '₹100', 'penalty': '₹50'},
    {'range': '₹200–₹500', 'penalty': '₹100'},
    {'range': '₹600–₹1000', 'penalty': '₹200'},
    {'range': '₹1100–₹1500', 'penalty': '₹250'},
    {'range': '₹1600–₹2000', 'penalty': '₹300'},
  ];
}

// ─── App Provider ─────────────────────────────────────────────────────────────
class AppProvider extends ChangeNotifier {
  // Keys
  static const _kUser = 'current_user';
  static const _kOnboarded = 'onboarded';
  static const _kOnTime = 'onTimeCount';
  static const _kDark = 'darkMode';
  static const _kLang = 'language';
  static const _kLoggedIn = 'loggedIn';
  static const _kPermsDone = 'permsDone';

  UserModel? _user;
  List<LoanModel> _loans = [];
  bool _onboarded = false;
  int _onTimePayments = 0;
  bool _isDark = false;
  String _language = 'en';
  bool _loggedIn = false;
  bool _permsDone = false;
  String _profilePhoto = '';

  // Getters
  UserModel? get user => _user;
  List<LoanModel> get loans => List.unmodifiable(_loans);
  bool get onboarded => _onboarded;
  int get onTimePayments => _onTimePayments;
  bool get isDark => _isDark;
  String get language => _language;
  bool get loggedIn => _loggedIn;
  bool get permsDone => _permsDone;
  bool get isRegistered => _user != null;
  String get profilePhoto => _profilePhoto;

  LoanModel? get activeLoan {
    try {
      return _loans.firstWhere(
        (l) => l.status == LoanStatus.active || l.status == LoanStatus.overdue,
      );
    } catch (_) { return null; }
  }

  double get maxUnlockedAmount {
    if (_onTimePayments >= 6) return 2000;
    if (_onTimePayments >= 3) return 1000;
    return 200;
  }

  bool get isBlacklisted {
    return _loans.any((l) => l.status == LoanStatus.blacklisted);
  }

  // ── Init ──
  Future<void> init() async {
    final p = await SharedPreferences.getInstance();
    _onboarded = p.getBool(_kOnboarded) ?? false;
    _onTimePayments = p.getInt(_kOnTime) ?? 0;
    _isDark = p.getBool(_kDark) ?? false;
    _language = p.getString(_kLang) ?? 'en';
    _loggedIn = p.getBool(_kLoggedIn) ?? false;
    _permsDone = p.getBool(_kPermsDone) ?? false;
    _profilePhoto = p.getString('profilePhoto') ?? '';

    final userJson = p.getString(_kUser);
    if (userJson != null) {
      _user = UserModel.fromJson(jsonDecode(userJson));
    }
    await _loadLoans();
    _checkOverdueAndBlacklist();
    notifyListeners();
  }

  Future<void> _loadLoans() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/loans.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        final list = jsonDecode(content) as List;
        _loans = list.map((e) => LoanModel.fromJson(e)).toList();
      }
    } catch (_) {}
  }

  Future<void> _saveLoans() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/loans.json');
      await file.writeAsString(jsonEncode(_loans.map((l) => l.toJson()).toList()));
    } catch (_) {}
  }

  void _checkOverdueAndBlacklist() {
    final now = DateTime.now();
    for (final loan in _loans) {
      if (loan.status == LoanStatus.active && now.isAfter(loan.dueDate)) {
        final days = now.difference(loan.dueDate).inDays;
        if (days > 30) {
          loan.status = LoanStatus.blacklisted;
        } else {
          loan.status = LoanStatus.overdue;
          loan.penalty = loan.calculatePenalty();
        }
      }
    }
  }

  // ── Onboarding ──
  Future<void> completeOnboarding() async {
    _onboarded = true;
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kOnboarded, true);
    notifyListeners();
  }

  // ── Permissions done ──
  Future<void> setPermsDone() async {
    _permsDone = true;
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kPermsDone, true);
    notifyListeners();
  }

  // ── Login / Logout ──
  Future<void> setLoggedIn(bool val) async {
    _loggedIn = val;
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kLoggedIn, val);
    notifyListeners();
  }

  // ── Register ──
  Future<String?> register(UserModel user) async {
    // Check duplicate mobile
    final existing = await _findUserByMobile(user.mobile);
    if (existing != null) return 'mobile_exists';
    // Check duplicate PAN
    final panExists = await _checkPanExists(user.pan);
    if (panExists) return 'pan_exists';

    _user = user;
    final p = await SharedPreferences.getInstance();
    await p.setString(_kUser, jsonEncode(user.toJson()));
    await _saveUserToFile(user);
    await setLoggedIn(true);
    notifyListeners();
    return null; // null = success
  }

  Future<UserModel?> _findUserByMobile(String mobile) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/users.json');
      if (!await file.exists()) return null;
      final list = jsonDecode(await file.readAsString()) as List;
      final found = list.where((u) => u['mobile'] == mobile).toList();
      if (found.isEmpty) return null;
      return UserModel.fromJson(found.first);
    } catch (_) { return null; }
  }

  Future<bool> _checkPanExists(String pan) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/users.json');
      if (!await file.exists()) return false;
      final list = jsonDecode(await file.readAsString()) as List;
      return list.any((u) => u['pan'] == pan.toUpperCase());
    } catch (_) { return false; }
  }

  Future<void> _saveUserToFile(UserModel user) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/users.json');
      List users = [];
      if (await file.exists()) {
        users = jsonDecode(await file.readAsString()) as List;
      }
      users.removeWhere((u) => u['mobile'] == user.mobile);
      users.add(user.toJson());
      await file.writeAsString(jsonEncode(users));
    } catch (_) {}
  }

  // ── Login check ──
  Future<bool> loginWithMobile(String mobile) async {
    final user = await _findUserByMobile(mobile);
    if (user == null) return false;
    _user = user;
    final p = await SharedPreferences.getInstance();
    await p.setString(_kUser, jsonEncode(user.toJson()));
    await setLoggedIn(true);
    notifyListeners();
    return true;
  }

  // ── Apply Loan ──
  Future<String?> applyLoan(double amount) async {
    if (activeLoan != null) return 'active_loan_exists';
    if (isBlacklisted) return 'blacklisted';

    final now = DateTime.now();
    final loan = LoanModel(
      id: 'EL${now.millisecondsSinceEpoch.toString().substring(5)}',
      userId: _user?.mobile ?? '',
      amount: amount,
      fee: 100,
      appliedDate: now,
      dueDate: now.add(const Duration(days: 15)),
      status: LoanStatus.active,
      autopayActive: true,
    );
    _loans.add(loan);
    await _saveLoans();
    notifyListeners();
    return loan.id; // return loan ID on success
  }

  Future<void> updateLoanPdf(String loanId, String path) async {
    final i = _loans.indexWhere((l) => l.id == loanId);
    if (i >= 0) {
      _loans[i].pdfPath = path;
      await _saveLoans();
      notifyListeners();
    }
  }

  Future<bool> makePayment(String loanId, double payAmount) async {
    final i = _loans.indexWhere((l) => l.id == loanId);
    if (i < 0) return false;
    final loan = _loans[i];

    if (loan.status == LoanStatus.overdue) {
      loan.penalty = loan.calculatePenalty();
    }
    loan.amountPaid += payAmount;
    if (loan.amountPaid >= loan.principalDue) {
      loan.status = LoanStatus.completed;
      loan.autopayActive = false;
      if (DateTime.now().isBefore(loan.dueDate)) _onTimePayments++;
      final p = await SharedPreferences.getInstance();
      await p.setInt(_kOnTime, _onTimePayments);
    }
    await _saveLoans();
    notifyListeners();
    return loan.status == LoanStatus.completed;
  }

  // ── Theme / Language ──
  Future<void> toggleDark() async {
    _isDark = !_isDark;
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kDark, _isDark);
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    _language = lang;
    final p = await SharedPreferences.getInstance();
    await p.setString(_kLang, lang);
    notifyListeners();
  }

  // ── Profile photo ──
  Future<void> setProfilePhoto(String path) async {
    _profilePhoto = path;
    final p = await SharedPreferences.getInstance();
    await p.setString('profilePhoto', path);
    notifyListeners();
  }

  // ── Logout ──
  Future<void> logout() async {
    _loggedIn = false;
    _user = null;
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kLoggedIn, false);
    await p.remove(_kUser);
    notifyListeners();
  }

  // ── Delete Account ──
  Future<void> deleteAccount() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final usersFile = File('${dir.path}/users.json');
      if (await usersFile.exists()) {
        List users = jsonDecode(await usersFile.readAsString()) as List;
        users.removeWhere((u) => u['mobile'] == _user?.mobile);
        await usersFile.writeAsString(jsonEncode(users));
      }
      // Remove user loans
      _loans.removeWhere((l) => l.userId == _user?.mobile);
      await _saveLoans();
    } catch (_) {}
    final p = await SharedPreferences.getInstance();
    await p.clear();
    _user = null;
    _loggedIn = false;
    _onTimePayments = 0;
    _loans = [];
    notifyListeners();
  }
}
