import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/loan_model.dart';
import '../models/user_model.dart'; // Ensure this file exists

class LoanProvider with ChangeNotifier {
  List<LoanModel> _loans = [];
  UserModel _user = UserModel(
    id: '1', 
    name: 'User Name', 
    email: 'user@example.com', 
    phone: '9876543210'
  );

  // Getters for UI Screens
  List<LoanModel> get loans => _loans;
  UserModel get user => _user; // Profile screen needs this
  
  // Dashboard/Profile stats
  double get maxUnlockedAmount => 2000.0;
  
  int get onTimePayments {
    return _loans.where((l) => 
      l.status == LoanStatus.completed && l.penalty == 0
    ).length;
  }

  LoanProvider() {
    _loadInitialData();
  }

  // Load data from local storage
  Future<void> _loadInitialData() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/loan_data.json');
      
      if (await file.exists()) {
        final Map<String, dynamic> data = json.decode(await file.readAsString());
        
        if (data['loans'] != null) {
          _loans = (data['loans'] as List)
              .map((item) => LoanModel.fromMap(item))
              .toList();
        }
        if (data['user'] != null) {
          _user = UserModel.fromMap(data['user']);
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error loading data: $e");
    }
  }

  // Save data to local storage
  Future<void> _saveToDisk() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/loan_data.json');
      
      final dataToSave = {
        'loans': _loans.map((l) => l.toMap()).toList(),
        'user': _user.toMap(),
      };
      
      await file.writeAsString(json.encode(dataToSave));
    } catch (e) {
      debugPrint("Error saving data: $e");
    }
  }

  // --- Actions ---

  void addLoan(LoanModel loan) {
    _loans.add(loan);
    _saveToDisk();
    notifyListeners();
  }

  void updateLoan(LoanModel updatedLoan) {
    final index = _loans.indexWhere((l) => l.id == updatedLoan.id);
    if (index != -1) {
      _loans[index] = updatedLoan;
      _saveToDisk();
      notifyListeners();
    }
  }

  // Profile Screen Logout
  Future<void> logout() async {
    _loans = [];
    _user = UserModel(id: '', name: 'Guest', email: '', phone: '');
    await _saveToDisk();
    notifyListeners();
  }

  // Used by Home Screen
  LoanModel? getActiveLoan() {
    try {
      return _loans.firstWhere(
        (l) => l.status == LoanStatus.active || l.status == LoanStatus.overdue
      );
    } catch (e) {
      return null;
    }
  }
}
