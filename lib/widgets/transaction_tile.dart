import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';

// Виджет для отображения элемента списка транзакций
class TransactionTile extends StatelessWidget {
  final Transaction transaction; // Данные транзакции

  const TransactionTile({required this.transaction, super.key});

  @override
  Widget build(BuildContext context) {
    final isSent = transaction.isSent; // Отправлена ли транзакция
    // Цвет и иконка в зависимости от типа транзакции
    final color = isSent ? Colors.red.shade600 : Colors.green.shade600;
    final icon = isSent ? Icons.arrow_upward : Icons.arrow_downward;
    final label = isSent ? 'Отправлено' : 'Получено'; // 'Sent' or 'Received'

    return Row(
      children: [
        // Иконка транзакции
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        // Основная информация о транзакции
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Тип транзакции
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              // Адрес
              Text(
                _formatAddress(transaction.address),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              // Дата и время
              Text(
                DateFormat('MMM d, yyyy • HH:mm').format(transaction.timestamp),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade500,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        // Сумма и статус транзакции
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Сумма
            Text(
              '${isSent ? '-' : '+'}${transaction.amount} ${transaction.currency}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            // Статус
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(transaction.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _getStatusText(transaction.status),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: _getStatusColor(transaction.status),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Форматирует адрес для отображения
  String _formatAddress(String address) {
    if (address.length <= 16) return address;
    return '${address.substring(0, 8)}...${address.substring(address.length - 8)}';
  }

  // Возвращает текст статуса
  String _getStatusText(String status) {
    switch (status) {
      case 'completed':
        return 'Выполнено'; // 'Completed'
      case 'pending':
        return 'В ожидании'; // 'Pending'
      case 'failed':
        return 'Не удалось'; // 'Failed'
      default:
        return status;
    }
  }

  // Возвращает цвет статуса
  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
