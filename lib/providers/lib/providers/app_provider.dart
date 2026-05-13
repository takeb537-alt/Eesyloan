import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import 'loan_provider.dart';

class AppProvider extends ChangeNotifier {
  UserModel? _user;
  final LoanProvider loanProvider = LoanProvider();

  UserModel? get user => _user;

  void setUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
