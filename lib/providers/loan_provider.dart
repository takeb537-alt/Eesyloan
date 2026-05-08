import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── User Model ───────────────────────────────────────────────────────────────
class UserModel {
  final String fullName, mobile, pan, dob, upiId;
  final List<String> faceImages;

  UserModel({
    required this.fullName,
    required this.mobile,
    required this.pan,
    required this.dob,
    required this.upiId,
    required this.faceImages,
  });

  Map<String, dynamic> toJson() => {
        'fullName': fullName, 'mobile': mobile, 'pan': pan,
        'dob': dob, 'upiId': upiId, 'faceImages': faceImages,
      };

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
        fullName: j['fullName'], mobile: j['mobile'], pan: j['pan'],
        dob: j['dob'], upiId: j['upiId'],
        faceImages: List<String>.from(j['faceImages'] ?? []),
      );
}

// ─── Loan Model ───────────────────────────────────────────────────────────────
enum LoanStatus { active, completed, overdue }

class LoanModel {
  final String id;
  final double amount, fee;
  double penalty;
  final DateTime appliedDate, dueDate;
  LoanStatus status;
  double amountPaid;
  String? pdfPath;

  LoanModel({
    required this.id, required this.amount, required this.fee,
    required this.penalty, required this.appliedDate, required this.dueDate,
    required this.status, this.amountPaid = 0, this.pdfPath,
  });

  double get principalDue => amount + fee + penalty;
  double get totalDue => principalDue - amountPaid;

  Map<String, dynamic> toJson() => {
        'id': id, 'amount': amount, 'fee': fee, 'penalty': penalty,
        'appliedDate': appliedDate.toIso8601String(),
        'dueDate': dueDate.toIso8601String(),
        'status': status.name, 'amountPaid': amountPaid, 'pdfPath': pdfPath,
      };

  factory LoanModel.fromJson(Map<String, dynamic> j) => LoanModel(
        id: j['id'],
        amount: (j['amount'] as num).toDouble(),
        fee: (j['fee'] as num).toDouble(),
        penalty: (j['penalty'] as num).toDouble(),
        appliedDate: DateTime.parse(j['appliedDate']),
        dueDate: DateTime.parse(j['dueDate']),
        status: LoanStatus.values.byName(j['status']),
        amountPaid: (j['amountPaid'] as num).toDouble(),
        pdfPath: j['pdfPath'],
      );
}

// ─── Penalty Calculator ───────────────────────────────────────────────────────
class PenaltyCalculator {
  static double calculate(double amount) {
    if (amount <= 100) return 50;
    if (amount <= 500) return 100;
    if (amount <= 1000) return 200;
    if (amount <= 1500) return 250;
    return 300;
  }

  static List<Map<String, String>> get schedule => [
        {'range': '₹100', 'penalty': '₹50'},
        {'range': '₹200 – ₹500', 'penalty': '₹100'},
        {'range': '₹600 – ₹1000', 'penalty': '₹200'},
        {'range': '₹1100 – ₹1500', 'penalty': '₹250'},
        {'range': '₹1600 – ₹2000', 'penalty': '₹300'},
      ];
}

// ─── Loan Provider ────────────────────────────────────────────────────────────
class LoanProvider extends ChangeNotifier {
  static const _kUser = 'user';
  static const _kLoans = 'loans';
  static const _kOnboarded = 'onboarded';
  static const _kOnTime = 'onTimeCount';

  UserModel? _user;
  List<LoanModel> _loans = [];
  bool _onboarded = false;
  int _onTimePayments = 0;

  UserModel? get user => _user;
  List<LoanModel> get loans => List.unmodifiable(_loans);
  bool get onboarded => _onboarded;
  int get onTimePayments => _onTimePayments;
  bool get isRegistered => _user != null;

  LoanModel? get activeLoan {
    try {
      return _loans.firstWhere(
        (l) => l.status == LoanStatus.active || l.status == LoanStatus.overdue,
      );
    } catch (_) {
      return null;
    }
  }

  double get maxUnlockedAmount {
    if (_onTimePayments >= 6) return 2000;
    if (_onTimePayments >= 3) return 1000;
    return 200;
  }

  Future<void> init() async {
    final p = await SharedPreferences.getInstance();
    _onboarded = p.getBool(_kOnboarded) ?? false;
    _onTimePayments = p.getInt(_kOnTime) ?? 0;
    final u = p.getString(_kUser);
    if (u != null) _user = UserModel.fromJson(jsonDecode(u));
    final l = p.getString(_kLoans);
    if (l != null) {
      _loans = (jsonDecode(l) as List).map((e) => LoanModel.fromJson(e)).toList();
    }
    _checkOverdue();
    notifyListeners();
  }

  void _checkOverdue() {
    final now = DateTime.now();
    for (final loan in _loans) {
      if (loan.status == LoanStatus.active && now.isAfter(loan.dueDate)) {
        loan.status = LoanStatus.overdue;
      }
    }
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    if (_user != null) await p.setString(_kUser, jsonEncode(_user!.toJson()));
    await p.setString(_kLoans, jsonEncode(_loans.map((l) => l.toJson()).toList()));
    await p.setInt(_kOnTime, _onTimePayments);
  }

  Future<void> completeOnboarding() async {
    _onboarded = true;
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kOnboarded, true);
    notifyListeners();
  }

  Future<void> register(UserModel user) async {
    _user = user;
    await _save();
    notifyListeners();
  }

  Future<LoanModel> applyLoan(double amount) async {
    final now = DateTime.now();
    final loan = LoanModel(
      id: 'EL${now.millisecondsSinceEpoch.toString().substring(7)}',
      amount: amount, fee: 100, penalty: 0,
      appliedDate: now,
      dueDate: now.add(const Duration(days: 15)),
      status: LoanStatus.active,
    );
    _loans.add(loan);
    await _save();
    notifyListeners();
    return loan;
  }

  Future<void> updateLoanPdf(String loanId, String path) async {
    final loan = _loans.firstWhere((l) => l.id == loanId);
    loan.pdfPath = path;
    await _save();
    notifyListeners();
  }

  Future<bool> makePayment(String loanId, double payAmount) async {
    final loan = _loans.firstWhere((l) => l.id == loanId);
    if (loan.status == LoanStatus.overdue && loan.penalty == 0) {
      loan.penalty = PenaltyCalculator.calculate(loan.amount);
    }
    loan.amountPaid += payAmount;
    if (loan.amountPaid >= loan.principalDue) {
      loan.status = LoanStatus.completed;
      if (DateTime.now().isBefore(loan.dueDate)) _onTimePayments++;
    }
    await _save();
    notifyListeners();
    return loan.status == LoanStatus.completed;
  }

  Future<void> logout() async {
    final p = await SharedPreferences.getInstance();
    await p.clear();
    _user = null;
    _loans = [];
    _onboarded = false;
    _onTimePayments = 0;
    notifyListeners();
  }
}
