import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/loan_model.dart';
import '../models/user_model.dart';

class LoanProvider with ChangeNotifier {
  List<LoanModel> _loans = [];
  UserModel _user = UserModel(id: '1', name: 'Smart User', email: 'user@itel.com', phone: '0000000000');

  // Getters
  List<LoanModel> get loans => _loans;
  UserModel get user => _user;
  double get maxUnlockedAmount => 2000.0;
  
  // Profile screen property
  int get onTimePayments {
    return _loans.where((l) => 
      l.status == LoanStatus.completed && l.penalty == 0
    ).length;
  }

  LoanProvider() {
    _initData();
  }

  Future<void> _initData() async {
    await _loadFromDisk();
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/loan_data_v3.json');
  }

  Future<void> _loadFromDisk() async {
    try {
      final file = await _getFile();
      if (await file.exists()) {
        final data = json.decode(await file.readAsString());
        _loans = (data['loans'] as List).map((l) => LoanModel.fromMap(l)).toList();
        if (data['user'] != null) _user = UserModel.fromMap(data['user']);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Load error: $e");
    }
  }

  Future<void> _saveToDisk() async {
    final file = await _getFile();
    final data = {
      'loans': _loans.map((l) => l.toMap()).toList(),
      'user': _user.toMap(),
    };
    await file.writeAsString(json.encode(data));
  }

  // Methods
  void addLoan(LoanModel loan) {
    _loans.add(loan);
    _saveToDisk();
    notifyListeners();
  }

  void updateLoan(LoanModel loan) {
    final index = _loans.indexWhere((l) => l.id == loan.id);
    if (index != -1) {
      _loans[index] = loan;
      _saveToDisk();
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _loans = [];
    _user = UserModel.empty();
    await _saveToDisk();
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
