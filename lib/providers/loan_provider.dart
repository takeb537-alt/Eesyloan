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
  
  // 1. Getter: Agar UI me "provider.onTimePayments" likha ho
  int get onTimePayments => _countOnTime();

  // 2. Method: Agar UI me "provider.onTimePayments()" likha ho
  // Aapke screenshots ke hisaab se yahi line error fix karegi
  int onTimePayments() {
    return _countOnTime();
  }

  int _countOnTime() {
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
      final file = File('${dir.path}/loan_data_fixed.json');
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
