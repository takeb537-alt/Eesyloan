import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/loan_model.dart';

class LoanProvider with ChangeNotifier {
  List<LoanModel> _loans = [];
  List<LoanModel> get loans => _loans;

  LoanProvider() {
    _loadLoans();
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/loans.json');
  }

  Future<void> _loadLoans() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        final content = await file.readAsString();
        final List<dynamic> jsonList = json.decode(content);
        _loans = jsonList.map((l) => LoanModel.fromMap(l)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error loading loans: $e");
    }
  }

  Future<void> _saveLoans() async {
    final file = await _localFile;
    final jsonList = _loans.map((l) => l.toMap()).toList();
    await file.writeAsString(json.encode(jsonList));
  }

  void addLoan(LoanModel loan) {
    _loans.add(loan);
    _saveLoans();
    notifyListeners();
  }

  void updateLoan(LoanModel loan) {
    final index = _loans.indexWhere((l) => l.id == loan.id);
    if (index != -1) {
      _loans[index] = loan;
      _saveLoans();
      notifyListeners();
    }
  }

  void repayLoan(String id, int amount) {
    final index = _loans.indexWhere((l) => l.id == id);
    if (index != -1) {
      final loan = _loans[index];
      final newPaid = loan.paidAmount + amount;
      final isDone = newPaid >= (loan.returnAmount + loan.penalty);
      
      _loans[index] = loan.copyWith(
        paidAmount: newPaid,
        status: isDone ? LoanStatus.completed : loan.status,
      );
      _saveLoans();
      notifyListeners();
    }
  }

  LoanModel? getActiveLoan() {
    try {
      return _loans.firstWhere((l) => l.status == LoanStatus.active || l.status == LoanStatus.overdue);
    } catch (e) {
      return null;
    }
  }
}
