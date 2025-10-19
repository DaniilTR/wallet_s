// Модель данных для транзакции
class Transaction {
  final String id; // Уникальный идентификатор
  final String type; // Тип транзакции: 'send' (отправлено) или 'receive' (получено)
  final double amount; // Сумма транзакции
  final String address; // Адрес получателя/отправителя
  final String status; // Статус: 'pending' (в ожидании), 'completed' (завершено), 'failed' (не удалось)
  final DateTime timestamp; // Временная метка
  final String currency; // Валюта

  // Конструктор
  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.address,
    required this.status,
    required this.timestamp,
    required this.currency,
  });

  // Фабричный метод для создания экземпляра из JSON
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

  // Геттер, чтобы проверить, была ли транзакция отправлена
  bool get isSent => type == 'send';
}
