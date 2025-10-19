import 'package:flutter/material.dart';
import '../models/wallet.dart';
import '../models/transaction.dart';
import '../services/wallet_service.dart';
import '../widgets/wallet_card.dart';
import '../widgets/transaction_tile.dart';
import 'wallet_detail_screen.dart';
import 'send_screen.dart';

// Главный экран приложения
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Сервис для работы с кошельками
  final WalletService _walletService = WalletService();
  // Future для отслеживания инициализации
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    // Инициализация сервиса кошельков
    _initFuture = _walletService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Используем FutureBuilder для отображения данных после инициализации
      body: FutureBuilder(
        future: _initFuture,
        builder: (context, snapshot) {
          // Показываем индикатор загрузки во время ожидания
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Основной контент экрана
          return CustomScrollView(
            slivers: [
              // AppBar
              _buildSliverAppBar(),
              // Секция с общим балансом
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                  child: _buildBalanceSection(),
                ),
              ),
              // Секция с кошельками
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
                  child: _buildWalletsSection(),
                ),
              ),
              // Секция с последними транзакциями
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
                  child: _buildTransactionsSection(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Виджет для AppBar
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      elevation: 0,
      pinned: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: const Text('Secure Wallet'),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.settings, size: 20, color: Colors.grey.shade700),
            ),
          ),
        ),
      ],
    );
  }

  // Виджет для секции с балансом
  Widget _buildBalanceSection() {
    return FutureBuilder<List<Wallet>>(
      future: _walletService.getWallets(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final wallets = snapshot.data!;
        // Считаем общий баланс
        double totalBalance = wallets.fold(0, (sum, w) => sum + w.balance);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Общий баланс', // 'Total Balance'
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              // Отображаем общий баланс (в данном случае, с заглушкой курса)
              '\$${(totalBalance * 50000).toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                // Кнопка "Добавить"
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.add,
                    label: 'Добавить',
                    onPressed: _showCreateWalletDialog,
                  ),
                ),
                const SizedBox(width: 12),
                // Кнопка "Отправить"
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.send,
                    label: 'Отправить',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SendScreen()),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // Виджет для кнопок действий
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0098EA),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  // Виджет для секции с кошельками
  Widget _buildWalletsSection() {
    return FutureBuilder<List<Wallet>>(
      future: _walletService.getWallets(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final wallets = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ваши кошельки', // 'Your Wallets'
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            // Список кошельков
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: wallets.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final wallet = wallets[index];
                // Навигация на экран деталей кошелька
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WalletDetailScreen(wallet: wallet),
                    ),
                  ),
                  child: WalletCard(wallet: wallet),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // Виджет для секции с транзакциями
  Widget _buildTransactionsSection() {
    return FutureBuilder<List<Transaction>>(
      future: _walletService.getTransactions(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final transactions = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Последние транзакции', // 'Recent Transactions'
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            // Список последних транзакций
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.take(5).length,
              separatorBuilder: (_, __) => const Divider(height: 12),
              itemBuilder: (context, index) {
                return TransactionTile(transaction: transactions[index]);
              },
            ),
          ],
        );
      },
    );
  }

  // Показывает диалог создания нового кошелька
  void _showCreateWalletDialog() {
    final nameController = TextEditingController();
    String selectedCurrency = 'BTC';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Создать новый кошелек'), // 'Create New Wallet'
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Поле для названия кошелька
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Название кошелька', // 'Wallet Name'
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // Выпадающий список для выбора валюты
              DropdownButtonFormField<String>(
                value: selectedCurrency,
                decoration: const InputDecoration(
                  labelText: 'Валюта', // 'Currency'
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'BTC', child: Text('Bitcoin')),
                  DropdownMenuItem(value: 'ETH', child: Text('Ethereum')),
                  DropdownMenuItem(value: 'USDT', child: Text('USDT')),
                  DropdownMenuItem(value: 'USDC', child: Text('USDC')),
                ],
                onChanged: (value) {
                  setState(() => selectedCurrency = value ?? 'BTC');
                },
              ),
            ],
          ),
        ),
        actions: [
          // Кнопка "Отмена"
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'), // 'Cancel'
          ),
          // Кнопка "Создать"
          ElevatedButton(
            onPressed: () {
              // Создаем кошелек
              _walletService.createWallet(
                name: nameController.text,
                currency: selectedCurrency,
              );
              Navigator.pop(context);
              // Обновляем состояние для отображения нового кошелька
              setState(() {});
            },
            child: const Text('Создать'), // 'Create'
          ),
        ],
      ),
    );
  }
}
