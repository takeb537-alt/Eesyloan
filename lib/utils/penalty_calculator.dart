class PenaltyCalculator {
  static int calculate(int loanAmount, int overdueDays) {
    if (overdueDays <= 0) return 0;
    
    int base;
    if (loanAmount <= 100) base = 50;
    else if (loanAmount <= 500) base = 100;
    else if (loanAmount <= 1000) base = 200;
    else if (loanAmount <= 1500) base = 250;
    else base = 300;

    double multiplier = 1.0;
    if (overdueDays <= 5) multiplier = 1.0;
    else if (overdueDays <= 10) multiplier = 1.25;
    else if (overdueDays <= 15) multiplier = 1.50;
    else if (overdueDays <= 20) multiplier = 1.75;
    else if (overdueDays <= 25) multiplier = 2.0;
    else multiplier = 3.0;

    return (base * multiplier).toInt();
  }

  static List<Map<String, String>> get schedule => [
    {'days': '1-5', 'penalty': 'Base Fee'},
    {'days': '6-10', 'penalty': '+25%'},
    {'days': '11-15', 'penalty': '+50%'},
    {'days': '16-20', 'penalty': '+75%'},
    {'days': '21-25', 'penalty': '+100%'},
    {'days': '26-30', 'penalty': '+200%'},
  ];
}
