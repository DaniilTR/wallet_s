import 'package:flutter/material.dart';
import '../models/wallet.dart';
import '../services/wallet_service.dart';

// Экран отправки транзакции
class SendScreen extends StatefulWidget {
  const SendScreen({super.key});

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  // Сервис для работы с кошельками
  final WalletService _walletService = WalletService();
  // Future для получения списка кошельков
  late Future<List<Wallet>> _walletsFuture;

  // Контроллеры для полей ввода
  final addressController = TextEditingController();
  final amountController = TextEditingController();
  // Выбранный кошелек
  Wallet? selectedWallet;
  // Флаг загрузки
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Получаем список кошельков при инициализации
    _walletsFuture = _walletService.getWallets();
  }

  @override
  void dispose() {
    // Освобождаем ресурсы контроллеров
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
          // Возвращаемся на предыдущий экран
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Отправить'), // 'Send'
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Секция выбора кошелька
              _buildSelectWalletSection(),
              const SizedBox(height: 32),
              // Секция адреса получателя
              _buildRecipientSection(),
              const SizedBox(height: 32),
              // Секция ввода суммы
              _buildAmountSection(),
              const SizedBox(height: 32),
              // Секция комиссии сети
              _buildNetworkFeeSection(),
              const SizedBox(height: 40),
              // Кнопка отправки
              _buildSendButton(),
            ],
          ),
        ),
      ),
    );
  }

  // Виджет для выбора кошелька
  Widget _buildSelectWalletSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Выберите кошелек', // 'Select Wallet'
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
                            ? const Color(0xFF0098EA)
                            : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: isSelected
                          ? const Color(0xFF0098EA).withOpacity(0.05)
                          : Colors.transparent,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: wallet.color.withOpacity(0.1),
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
                            color: Color(0xFF0098EA),
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

  // Виджет для ввода адреса получателя
  Widget _buildRecipientSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Адрес получателя', // 'Recipient Address'
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: addressController,
          decoration: InputDecoration(
            hintText: 'Введите адрес получателя', // 'Enter recipient address'
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
            // Кнопка очистки поля
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

  // Виджет для ввода суммы
  Widget _buildAmountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Сумма', // 'Amount'
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: '0.00',
            prefixText: selectedWallet != null ? '${selectedWallet!.symbol} ' : null,
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
            // Кнопка для установки максимальной суммы
            suffixIcon: Padding(
              padding: const EdgeInsets.all(12),
              child: GestureDetector(
                onTap: selectedWallet != null
                    ? () => setState(() => amountController.text = selectedWallet!.balance.toString())
                    : null,
                child: Text(
                  'Макс', // 'Max'
                  style: TextStyle(
                    color: const Color(0xFF0098EA),
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

  // Виджет для отображения комиссии сети
  Widget _buildNetworkFeeSection() {
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
              Text(
                'Комиссия сети', // 'Network Fee'
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                '0.0001 ${selectedWallet?.symbol ?? 'BTC'}',
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
                'Итого', // 'Total'
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                '${(double.tryParse(amountController.text) ?? 0) + 0.0001} ${selectedWallet?.symbol ?? 'BTC'}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF0098EA),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Виджет для кнопки отправки
  Widget _buildSendButton() {
    // Проверяем валидность данных для отправки
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
          backgroundColor: const Color(0xFF0098EA),
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
          'Отправить', // 'Send'
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // Метод для отправки транзакции
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
              content: Text('Транзакция успешно отправлена!'), // 'Transaction sent successfully!'
              backgroundColor: Colors.green,
            ),
          );
          // Возвращаемся на предыдущий экран через 0.5 секунды
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) Navigator.pop(context);
          });
        }
      } else {
        // Обработка случая, когда транзакция не удалась, но исключение не было выброшено
         if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Не удалось отправить транзакцию'), // 'Failed to send transaction'
                backgroundColor: Colors.red,
              ),
            );
          }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'), // 'Error: $e'
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }
}
