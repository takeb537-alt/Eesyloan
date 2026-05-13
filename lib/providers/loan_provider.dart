import 'package:flutter/foundation.dart';
import '../models/loan_model.dart';

class LoanProvider extends ChangeNotifier {
  List<LoanModel> _loans = [];
  UserModel? _dummy; // ignore this, just for structure

  List<LoanModel> get loans => _loans;

  // activeLoan getter — yahi missing tha!
  LoanModel? get activeLoan {
    try {
      return _loans.firstWhere(
        (l) => l.status == LoanStatus.active || l.status == LoanStatus.overdue,
      );
    } catch (e) {
      return null;
    }
  }

  // onTimePayments getter — yahi missing tha!
  int get onTimePayments {
    return _loans
        .where((l) => l.status == LoanStatus.completed)
        .length;
  }

  void setLoans(List<LoanModel> loans) {
    _loans = loans;
    notifyListeners();
  }

  void addLoan(LoanModel loan) {
    _loans.add(loan);
    notifyListeners();
  }

  void updateLoan(LoanModel updatedLoan) {
    final index = _loans.indexWhere((l) => l.id == updatedLoan.id);
    if (index != -1) {
      _loans[index] = updatedLoan;
      notifyListeners();
    }
  }

  void removeLoan(String loanId) {
    _loans.removeWhere((l) => l.id == loanId);
    notifyListeners();
  }

  void loadFromData(Map<String, dynamic> data) {
    if (data['loans'] != null) {
      _loans = (data['loans'] as List)
          .map((l) => LoanModel.fromMap(l))
          .toList();
      notifyListeners();
    }
  }
}
