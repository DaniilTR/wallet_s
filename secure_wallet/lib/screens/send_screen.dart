import 'package:flutter/material.dart';
import '../config/theme.dart';
// Экран отправки средств: выбор кошелька, ввод адреса и суммы, оценка комиссии
import '../models/wallet.dart';
import '../services/wallet_service.dart';

/// Экран отправки средств (Send):
/// - выбор исходного кошелька,
/// - ввод адреса получателя и суммы,
/// - подсказка по сетевой комиссии и итоговой сумме,
/// - выполнение транзакции через WalletService.
class SendScreen extends StatefulWidget {
  const SendScreen({super.key});

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  final WalletService _walletService = WalletService();
  late Future<List<Wallet>> _walletsFuture;

  final addressController = TextEditingController();
  final amountController = TextEditingController();
  Wallet? selectedWallet;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _walletsFuture = _walletService.getWallets().then((ws) {
      // По умолчанию выбираем BSC токен, если он есть
      final bsc = ws.where((w) => w.id == 'bsc_token').toList();
      if (bsc.isNotEmpty) selectedWallet = bsc.first;
      return ws;
    });
  }

  @override
  void dispose() {
    addressController.dispose();
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Send'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildSelectWalletSection(),
              const SizedBox(height: 32),
              _buildRecipientSection(),
              const SizedBox(height: 32),
              _buildAmountSection(),
              const SizedBox(height: 32),
              _buildNetworkFeeSection(),
              const SizedBox(height: 40),
              _buildSendButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// Секция выбора кошелька-источника. Подсвечивает выбранный.
  Widget _buildSelectWalletSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Wallet',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<Wallet>>(
          future: _walletsFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const CircularProgressIndicator();

            final wallets = snapshot.data!;
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: wallets.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final wallet = wallets[index];
                final isSelected = selectedWallet?.id == wallet.id;

                return GestureDetector(
                  onTap: () => setState(() => selectedWallet = wallet),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primary
                            : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: isSelected ? AppTheme.primary : Colors.transparent,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: wallet.color,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            wallet.symbol,
                            style: TextStyle(
                              color: wallet.color,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                wallet.name,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${wallet.balance} ${wallet.symbol}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle,
                            color: AppTheme.primary,
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  /// Секция ввода адреса получателя. Позволяет очистить поле.
  Widget _buildRecipientSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recipient Address',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: addressController,
          decoration: InputDecoration(
            hintText: 'Enter recipient address',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.primary,
                width: 2,
              ),
            ),
            suffixIcon: addressController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() => addressController.clear()),
                  )
                : null,
          ),
          onChanged: (_) => setState(() {}),
          maxLines: 3,
          minLines: 1,
        ),
      ],
    );
  }

  /// Секция ввода суммы перевода. Есть быстрый выбор Max (всё доступное).
  Widget _buildAmountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amount',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: '0.00',
            prefixText:
                selectedWallet != null ? '${selectedWallet!.symbol} ' : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF0098EA),
                width: 2,
              ),
            ),
            suffixIcon: Padding(
              padding: const EdgeInsets.all(12),
              child: GestureDetector(
                onTap: selectedWallet != null
                    ? () => setState(() => amountController.text =
                        selectedWallet!.balance.toString())
                    : null,
                child: Text(
                  'Max',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  /// Информация о сетевой комиссии и итоговой сумме.
  /// Для BSC комиссия считается в BNB, для прочих — фиксированный пример.
  Widget _buildNetworkFeeSection() {
    final isBscToken = selectedWallet?.id == 'bsc_token';
    final isBscNative = selectedWallet?.id == 'bsc_native';
    final isBsc = isBscToken || isBscNative;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Network Fee',
                  style: Theme.of(context).textTheme.bodyMedium),
              Text(
                isBsc
                    ? (isBscNative
                        ? '~0.0003 BNB (Testnet)'
                        : '~0.0005 BNB (Testnet)')
                    : '0.0001 ${selectedWallet?.symbol ?? 'BTC'}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                isBsc
                    ? '${(double.tryParse(amountController.text) ?? 0)} ${selectedWallet?.symbol ?? ''} + fee in BNB'
                    : '${(double.tryParse(amountController.text) ?? 0) + 0.0001} ${selectedWallet?.symbol ?? 'BTC'}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.primary,
                    ),
              ),
            ],
          ),
          if (isBsc) ...[
            const SizedBox(height: 12),
            Text(
              'Для отправки в BSC Testnet на кошельке должны быть тестовые BNB для оплаты газа. ',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey[700]),
            ),
          ]
        ],
      ),
    );
  }

  /// Кнопка отправки. Доступна только при валидных данных.
  Widget _buildSendButton() {
    final isValid = selectedWallet != null &&
        addressController.text.isNotEmpty &&
        amountController.text.isNotEmpty &&
        (double.tryParse(amountController.text) ?? 0) > 0;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isValid && !isLoading ? _sendTransaction : null,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: AppTheme.primary,
          disabledBackgroundColor: Colors.grey.shade400,
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Send',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }

  /// Выполнить отправку транзакции через WalletService с обработкой ошибок.
  Future<void> _sendTransaction() async {
    setState(() => isLoading = true);

    try {
      final success = await _walletService.sendTransaction(
        fromWalletId: selectedWallet!.id,
        toAddress: addressController.text,
        amount: double.parse(amountController.text),
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transaction sent successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) Navigator.pop(context);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }
}
