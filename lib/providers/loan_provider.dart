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
  
  // 1. ISSE ERROR KHATAM HOGA: Agar UI "p.onTimePayments" (Property) maange
  int get onTimePayments => _calculateOnTime();

  // 2. ISSE BHI ERROR KHATAM HOGA: Agar UI "p.onTimePayments()" (Method) maange
  int onTimePaymentsMethod() => _calculateOnTime(); 
  
  // Backwards compatibility ke liye: Agar UI specific brackets maang raha hai
  int getOnTimePayments() => _calculateOnTime();

  int _calculateOnTime() {
    return _loans.where((l) => 
      l.status == LoanStatus.completed && l.penalty == 0
    ).length;
  }

  LoanProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/loan_v_final_final.json');
      if (await file.exists()) {
        final data = json.decode(await file.readAsString());
        _loans = (data['loans'] as List).map((l) => LoanModel.fromMap(l)).toList();
        if (data['user'] != null) _user = UserModel.fromMap(data['user']);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Load Error: $e");
    }
  }

  void addLoan(LoanModel loan) {
    _loans.add(loan);
    notifyListeners();
  }

  Future<void> logout() async {
    _loans = [];
    _user = UserModel(id: '', name: 'Guest', email: '', phone: '');
    notifyListeners();
  }

  LoanModel? getActiveLoan() {
    try {
      return _loans.firstWhere((l) => 
        l.status == LoanStatus.active || l.status == LoanStatus.overdue
      );
    } catch (e) {
      return null;
    }
  }
}
