enum LoanStatus { pending, active, overdue, completed }

class LoanModel {
  final String id;
  final String userId;
  final double amount;
  final double interestRate;
  final int termMonths;
  final LoanStatus status;
  final DateTime startDate;
  final DateTime dueDate;
  final String purpose;

  LoanModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.interestRate,
    required this.termMonths,
    required this.status,
    required this.startDate,
    required this.dueDate,
    required this.purpose,
  });

  factory LoanModel.fromMap(Map<String, dynamic> map) {
    return LoanModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      interestRate: (map['interestRate'] ?? 0).toDouble(),
      termMonths: map['termMonths'] ?? 0,
      status: LoanStatus.values.firstWhere(
        (e) => e.name == (map['status'] ?? 'pending'),
        orElse: () => LoanStatus.pending,
      ),
      startDate: DateTime.tryParse(map['startDate'] ?? '') ?? DateTime.now(),
      dueDate: DateTime.tryParse(map['dueDate'] ?? '') ?? DateTime.now(),
      purpose: map['purpose'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'interestRate': interestRate,
      'termMonths': termMonths,
      'status': status.name,
      'startDate': startDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'purpose': purpose,
    };
  }

  LoanModel copyWith({
    String? id,
    String? userId,
    double? amount,
    double? interestRate,
    int? termMonths,
    LoanStatus? status,
    DateTime? startDate,
    DateTime? dueDate,
    String? purpose,
  }) {
    return LoanModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      interestRate: interestRate ?? this.interestRate,
      termMonths: termMonths ?? this.termMonths,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      purpose: purpose ?? this.purpose,
    );
  }
}
