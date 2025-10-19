import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/wallet.dart';
import '../models/transaction.dart';
import '../services/wallet_service.dart';
import '../widgets/transaction_tile.dart';

// Экран деталей кошелька
class WalletDetailScreen extends StatefulWidget {
  final Wallet wallet; // Кошелек для отображения

  const WalletDetailScreen({required this.wallet, super.key});

  @override
  State<WalletDetailScreen> createState() => _WalletDetailScreenState();
}

class _WalletDetailScreenState extends State<WalletDetailScreen> {
  // Сервис для работы с кошельками
  final WalletService _walletService = WalletService();
  // Future для получения списка транзакций
  late Future<List<Transaction>> _transactionsFuture;

  @override
  void initState() {
    super.initState();
    // Получаем транзакции для данного кошелька при инициализации
    _transactionsFuture = _walletService.getWalletTransactions(widget.wallet.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          // Возвращаемся на предыдущий экран
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.wallet.name),
        actions: [
          // Кнопка для отображения опций кошелька
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showWalletOptions(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Заголовок кошелька с балансом
            _buildWalletHeader(),
            const SizedBox(height: 24),
            // Кнопки действий
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildActionButtons(),
            ),
            const SizedBox(height: 32),
            // Секция с адресом кошелька
            _buildAddressSection(),
            const SizedBox(height: 32),
            // Секция с транзакциями
            _buildTransactionsSection(),
          ],
        ),
      ),
    );
  }

  // Виджет для заголовка кошелька
  Widget _buildWalletHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        // Градиентный фон
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.wallet.color.withOpacity(0.8),
            widget.wallet.color.withOpacity(0.4),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.wallet.currency,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.wallet.balance} ${widget.wallet.symbol}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            // Отображение баланса в USD (с заглушкой курса)
            Text(
              '\$${(widget.wallet.balance * 50000).toStringAsFixed(2)}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Виджет для кнопок действий
  Widget _buildActionButtons() {
    return Row(
      children: [
        _buildActionIconButton(
          icon: Icons.send,
          label: 'Отправить', // 'Send'
          onPressed: () => Navigator.pop(context), // TODO: реализовать навигацию для отправки
        ),
        const SizedBox(width: 12),
        _buildActionIconButton(
          icon: Icons.call_received,
          label: 'Получить', // 'Receive'
          onPressed: _showReceiveDialog,
        ),
        const SizedBox(width: 12),
        _buildActionIconButton(
          icon: Icons.refresh,
          label: 'Обновить', // 'Refresh'
          onPressed: () => setState(() {}), // TODO: реализовать логику обновления
        ),
      ],
    );
  }

  // Виджет для иконки с текстом
  Widget _buildActionIconButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              Icon(icon, size: 24, color: const Color(0xFF0098EA)),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Виджет для секции с адресом кошелька
  Widget _buildAddressSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Адрес кошелька', // 'Wallet Address'
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          // Копирование адреса по нажатию
          GestureDetector(
            onTap: _copyAddress,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SelectableText(
                      widget.wallet.address,
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.copy,
                    size: 18,
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Нажмите, чтобы скопировать адрес', // 'Tap to copy address'
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // Виджет для секции с транзакциями
  Widget _buildTransactionsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Транзакции', // 'Transactions'
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          FutureBuilder<List<Transaction>>(
            future: _transactionsFuture,
            builder: (context, snapshot) {
              // Показываем индикатор загрузки
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // Если нет данных или список пуст
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Text(
                      'Нет транзакций', // 'No transactions'
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                );
              }

              final transactions = snapshot.data!;
              // Список транзакций
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactions.length,
                separatorBuilder: (_, __) => const Divider(height: 24),
                itemBuilder: (context, index) {
                  return TransactionTile(transaction: transactions[index]);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // Копирует адрес в буфер обмена
  void _copyAddress() {
    Clipboard.setData(ClipboardData(text: widget.wallet.address));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Адрес скопирован!'), // 'Address copied!'
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Показывает диалог для получения средств
  void _showReceiveDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Получить'), // 'Receive'
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SelectableText(
                widget.wallet.address,
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Готово'), // 'Done'
          ),
          ElevatedButton(
            onPressed: _copyAddress,
            child: const Text('Копировать адрес'), // 'Copy Address'
          ),
        ],
      ),
    );
  }

  // Показывает опции кошелька
  void _showWalletOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Переименовать'), // 'Rename'
              onTap: () => Navigator.pop(context), // TODO: реализовать переименование
            ),
            ListTile(
              leading: const Icon(Icons.backup),
              title: const Text('Резервное копирование'), // 'Backup'
              onTap: () => Navigator.pop(context), // TODO: реализовать резервное копирование
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Удалить', style: TextStyle(color: Colors.red)), // 'Delete'
              onTap: () => Navigator.pop(context), // TODO: реализовать удаление
            ),
          ],
        ),
      ),
    );
  }
}
