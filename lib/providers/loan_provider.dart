import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/loan_model.dart';
import '../models/user_model.dart';

class LoanProvider with ChangeNotifier {
  List<LoanModel> _loans = [];
  UserModel _user = UserModel(id: '1', name: 'Smart User', email: '', phone: '');

  // Trick: Simple variable (Isse error kabhi nahi aayega)
  int onTimePayments = 0; 

  List<LoanModel> get loans => _loans;
  UserModel get user => _user;
  double get maxUnlockedAmount => 2500.0;

  LoanProvider() {
    _loadData();
  }

  // Logic to calculate stats
  void _calculateStats() {
    onTimePayments = _loans.where((l) => 
      l.status == LoanStatus.completed && l.penalty == 0
    ).length;
    notifyListeners();
  }

  Future<void> _loadData() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/loan_v_final_itel.json');
      if (await file.exists()) {
        final data = json.decode(await file.readAsString());
        _loans = (data['loans'] as List).map((l) => LoanModel.fromMap(l)).toList();
        if (data['user'] != null) _user = UserModel.fromMap(data['user']);
        _calculateStats();
      }
    } catch (e) {
      debugPrint("Load Error: $e");
    }
  }

  void addLoan(LoanModel loan) {
    _loans.add(loan);
    _calculateStats();
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

  Future<void> logout() async {
    _loans = [];
    _user = UserModel(id: '', name: 'Guest', email: '', phone: '');
    onTimePayments = 0;
    notifyListeners();
  }
}
