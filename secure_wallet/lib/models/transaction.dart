// Модель транзакции: направление, сумма, адрес, статус и дата
class Transaction {
  final String id;
  final String type; // 'send' или 'receive'
  final double amount;
  final String address;
  final String status; // 'pending', 'completed', 'failed'
  final DateTime timestamp;
  final String currency;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.address,
    required this.status,
    required this.timestamp,
    required this.currency,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      type: json['type'],
      amount: (json['amount'] as num).toDouble(),
      address: json['address'],
      status: json['status'],
      timestamp: DateTime.parse(json['timestamp']),
      currency: json['currency'],
    );
  }

  bool get isSent => type == 'send';
}
