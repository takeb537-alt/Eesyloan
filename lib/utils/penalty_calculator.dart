class PenaltyCalculator {
  // Static method: Iska naam aur structure UI se 100% match karega
  static List<Map<String, String>> getSchedule() {
    return [
      {'days': '1-5', 'penalty': 'Base Fee (0%)'},
      {'days': '6-10', 'penalty': 'Base Fee + 25%'},
      {'days': '11-15', 'penalty': 'Base Fee + 50%'},
      {'days': '16-20', 'penalty': 'Base Fee + 75%'},
      {'days': '21-25', 'penalty': 'Base Fee + 100%'},
      {'days': '26-30', 'penalty': 'Base Fee + 200%'},
    ];
  }

  static int calculate(int loanAmount, int overdueDays) {
    if (overdueDays <= 0) return 0;
    int base = loanAmount <= 500 ? 100 : 250;
    return (base + (overdueDays * 10)).toInt();
  }
}
