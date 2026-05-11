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
  double get maxUnlockedAmount => 2000.0;
  
  // Property for Profile Screen
  int get onTimePayments {
    return _loans.where((l) => l.status == LoanStatus.completed && l.penalty == 0).length;
  }

  LoanProvider() {
    _init();
  }

  Future<void> _init() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/loan_v5.json');
      if (await file.exists()) {
        final data = json.decode(await file.readAsString());
        _loans = (data['loans'] as List).map((l) => LoanModel.fromMap(l)).toList();
        if (data['user'] != null) _user = UserModel.fromMap(data['user']);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error loading: $e");
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
      return _loans.firstWhere((l) => l.status == LoanStatus.active || l.status == LoanStatus.overdue);
    } catch (e) {
      return null;
    }
  }
}
