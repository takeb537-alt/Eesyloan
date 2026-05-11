import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/loan_model.dart';
import '../models/user_model.dart';

class LoanProvider with ChangeNotifier {
  List<LoanModel> _loans = [];
  UserModel _user = UserModel(id: '1', name: 'Itel User', email: '', phone: '');

  List<LoanModel> get loans => _loans;
  UserModel get user => _user;
  double get maxUnlockedAmount => 2500.0;
  
  // RASTA 1: Agar UI "provider.onTimePayments" maange
  int get onTimePayments => _logic();

  // RASTA 2: Agar UI "provider.onTimePayments()" maange (Brackets ke saath)
  int onTimePaymentsMethod() => _logic();
  
  // RASTA 3: Explicit Function (Just in case)
  int getOnTimePayments() => _logic();

  // Actual Logic function
  int _logic() {
    return _loans.where((l) => l.status == LoanStatus.completed && l.penalty == 0).length;
  }

  // Compiler ko forced handle dene ke liye
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #onTimePayments) {
      return _logic();
    }
    return super.noSuchMethod(invocation);
  }

  LoanProvider() { _load(); }

  Future<void> _load() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/final_fix.json');
      if (await file.exists()) {
        final data = json.decode(await file.readAsString());
        _loans = (data['loans'] as List).map((l) => LoanModel.fromMap(l)).toList();
        if (data['user'] != null) _user = UserModel.fromMap(data['user']);
        notifyListeners();
      }
    } catch (e) { debugPrint(e.toString()); }
  }

  void addLoan(LoanModel loan) { _loans.add(loan); notifyListeners(); }
  Future<void> logout() async { _loans = []; _user = UserModel(id: '', name: 'Guest', email: '', phone: ''); notifyListeners(); }
  LoanModel? getActiveLoan() {
    try { return _loans.firstWhere((l) => l.status == LoanStatus.active || l.status == LoanStatus.overdue); }
    catch (e) { return null; }
  }
}
