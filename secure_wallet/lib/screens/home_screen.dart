import 'package:flutter/material.dart';
import '../config/theme.dart';
// Главный экран: общий баланс, список кошельков, последние транзакции
import 'package:intl/intl.dart';
import '../models/wallet.dart';
import '../models/transaction.dart';
import '../services/wallet_service.dart';
import '../services/auth_service.dart';
import '../widgets/wallet_card.dart';
import '../widgets/transaction_tile.dart';
import 'wallet_detail_screen.dart';
import 'send_screen.dart';

/// Главный экран приложения (Home):
/// - отображает сводный баланс по всем кошелькам,
/// - список кошельков пользователя,
/// - последние транзакции,
/// - быстрые действия (добавить кошелек / отправить перевод).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WalletService _walletService = WalletService();
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _walletService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _initFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                  child: _buildBalanceSection(),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
                  child: _buildWalletsSection(),
                ),
              ),
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

  /// Верхний app bar со статусом аккаунта и кнопкой настроек.
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      elevation: 0,
      pinned: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: Row(
        children: [
          const Text('Secure Wallet'),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'acct: ' + (AuthService().currentUser?.username ?? '—'),
              style: TextStyle(color: Colors.grey.shade800, fontSize: 12),
            ),
          ),
        ],
      ),
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
              child:
                  Icon(Icons.settings, size: 20, color: Colors.grey.shade700),
            ),
          ),
        ),
      ],
    );
  }

  /// Блок с общим балансом, конвертированным в USD, и кнопками действий.
  Widget _buildBalanceSection() {
    return FutureBuilder<List<Wallet>>(
      future: _walletService.getWallets(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final wallets = snapshot.data!;
        // Суммируем балансы корректно как числа, а не конкатенируем строки.
        final double totalBalance = wallets.fold<double>(
          0.0,
          (sum, w) => sum + (double.tryParse(w.balance) ?? 0.0),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Balance',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              // Форматируем валюту через intl (условный коэффициент конвертации)
              NumberFormat.currency(locale: 'en_US', symbol: '\$')
                  .format(totalBalance * 50000),
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.add,
                    label: 'Add',
                    onPressed: _showCreateWalletDialog,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.send,
                    label: 'Send',
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

  // Кнопка действия на главном экране (Add/Send)
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primary,
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

  /// Секция со списком кошельков. Переход на экран деталей при тапе.
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
              'Your Wallets',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: wallets.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final wallet = wallets[index];
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

  /// Секция последних транзакций (до 5 штук) с использованием TransactionTile.
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
              'Recent Transactions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
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

  /// Диалог создания/импорта кошелька: имя, валюта и адрес.
  void _showCreateWalletDialog() {
    final nameController = TextEditingController();
    String selectedCurrency = 'BNB';
    final addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add/Import Wallet'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Wallet Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedCurrency,
                decoration: const InputDecoration(
                  labelText: 'Currency',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'BNB', child: Text('BNB (BSC Testnet)')),
                  DropdownMenuItem(
                      value: 'T1PS', child: Text('T1PS Token (BEP-20)')),
                ],
                onChanged: (value) {
                  setState(() => selectedCurrency = value ?? 'BNB');
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Wallet Address (0x...)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final ok = await _walletService.createWallet(
                name: nameController.text.trim().isEmpty
                    ? selectedCurrency
                    : nameController.text.trim(),
                currency: selectedCurrency,
                address: addressController.text.trim(),
              );
              if (mounted) {
                Navigator.pop(context);
                if (ok) setState(() {});
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
