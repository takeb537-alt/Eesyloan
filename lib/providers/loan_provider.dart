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

  LoanProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/loan_data_v1.json');
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
}
