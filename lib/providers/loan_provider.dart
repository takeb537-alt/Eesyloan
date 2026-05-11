import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/loan_model.dart';
import '../models/user_model.dart'; // Ensure this exists

class LoanProvider with ChangeNotifier {
  List<LoanModel> _loans = [];
  UserModel? _user; // Missing User storage
  
  List<LoanModel> get loans => _loans;
  
  // FIXED: Added missing getters for Profile Screen
  UserModel? get user => _user ?? UserModel(id: '1', name: 'User', email: '', phone: '');
  
  double get maxUnlockedAmount => 2000.0; // Default or calculated limit
  
  int get onTimePayments {
    return _loans.where((l) => l.status == LoanStatus.completed && l.penalty == 0).length;
  }

  LoanProvider() {
    _loadData();
  }

  // FIXED: Added logout method for Profile Screen
  Future<void> logout() async {
    _loans = [];
    _user = null;
    notifyListeners();
    // Clear local files if necessary
  }

  Future<File> get _localFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/loans_v2.json');
  }

  Future<void> _loadData() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        final content = await file.readAsString();
        final List<dynamic> jsonList = json.decode(content);
        _loans = jsonList.map((l) => LoanModel.fromMap(l)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Data load error: $e");
    }
  }

  Future<void> _saveData() async {
    final file = await _localFile;
    await file.writeAsString(json.encode(_loans.map((l) => l.toMap()).toList()));
  }

  void addLoan(LoanModel loan) {
    _loans.add(loan);
    _saveData();
    notifyListeners();
  }

  LoanModel? getActiveLoan() {
    try {
      return _loans.firstWhere((l) => l.status == LoanStatus.active || l.status == LoanStatus.overdue);
    } catch (e) {
      return null;
    }
  }

  // Method to update loan (for repayments)
  void updateLoan(LoanModel loan) {
    final index = _loans.indexWhere((l) => l.id == loan.id);
    if (index != -1) {
      _loans[index] = loan;
      _saveData();
      notifyListeners();
    }
  }
}
