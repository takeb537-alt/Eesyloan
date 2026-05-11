import 'dart:convert';

enum LoanStatus { active, completed, overdue, defaulted }

class LoanModel {
  final String id;
  final String userId;
  final int amount;
  final int returnAmount;
  final DateTime dueDate;
  final LoanStatus status;
  final int penalty;
  final int paidAmount;
  final String? agreementPdfPath;
  final DateTime createdAt;

  LoanModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.returnAmount,
    required this.dueDate,
    required this.status,
    required this.penalty,
    required this.paidAmount,
    this.agreementPdfPath,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'returnAmount': returnAmount,
      'dueDate': dueDate.toIso8601String(),
      'status': status.name,
      'penalty': penalty,
      'paidAmount': paidAmount,
      'agreementPdfPath': agreementPdfPath,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory LoanModel.fromMap(Map<String, dynamic> map) {
    return LoanModel(
      id: map['id'],
      userId: map['userId'],
      amount: map['amount'],
      returnAmount: map['returnAmount'],
      dueDate: DateTime.parse(map['dueDate']),
      status: LoanStatus.values.byName(map['status']),
      penalty: map['penalty'],
      paidAmount: map['paidAmount'],
      agreementPdfPath: map['agreementPdfPath'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  String toJson() => json.encode(toMap());

  factory LoanModel.fromJson(String source) => LoanModel.fromMap(json.decode(source));

  LoanModel copyWith({
    LoanStatus? status,
    int? penalty,
    int? paidAmount,
    String? agreementPdfPath,
  }) {
    return LoanModel(
      id: this.id,
      userId: this.userId,
      amount: this.amount,
      returnAmount: this.returnAmount,
      dueDate: this.dueDate,
      status: status ?? this.status,
      penalty: penalty ?? this.penalty,
      paidAmount: paidAmount ?? this.paidAmount,
      agreementPdfPath: agreementPdfPath ?? this.agreementPdfPath,
      createdAt: this.createdAt,
    );
  }
}
