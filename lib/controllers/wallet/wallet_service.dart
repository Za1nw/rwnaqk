import 'package:rwnaqk/core/translations/app_locale_keys.dart';
import 'package:rwnaqk/models/wallet/refund_status_model.dart';
import 'package:rwnaqk/models/wallet/wallet_model.dart';
import 'package:rwnaqk/models/wallet/wallet_transaction_model.dart';

class WalletService {
  static const defaultCurrency = 'YER';

  WalletModel? _wallet;
  List<WalletTransactionModel>? _transactions;

  Future<WalletModel> fetchWalletBalance() async {
    _ensureSeeded();
    await Future.delayed(const Duration(milliseconds: 350));

    return _wallet!.copyWith();
  }

  Future<List<WalletTransactionModel>> fetchWalletTransactions() async {
    _ensureSeeded();
    await Future.delayed(const Duration(milliseconds: 450));

    return List<WalletTransactionModel>.unmodifiable(_transactions!);
  }

  List<WalletTransactionModel> filterTransactions({
    required List<WalletTransactionModel> transactions,
    required WalletTransactionFilter filter,
  }) {
    switch (filter) {
      case WalletTransactionFilter.deposit:
        return transactions
            .where((item) => item.type == WalletTransactionType.deposit)
            .toList(growable: false);
      case WalletTransactionFilter.withdraw:
        return transactions
            .where((item) => item.type == WalletTransactionType.withdraw)
            .toList(growable: false);
      case WalletTransactionFilter.refund:
        return transactions
            .where((item) => item.type == WalletTransactionType.refund)
            .toList(growable: false);
      case WalletTransactionFilter.all:
        return transactions.toList(growable: false);
    }
  }

  WalletTransactionModel buildDepositTransaction(
    double amount, {
    String status = WalletTransactionStatus.completed,
    String description = Tk.walletDescriptionManualDeposit,
  }) {
    return WalletTransactionModel(
      id: _nextId('DEP'),
      type: WalletTransactionType.deposit,
      amount: amount,
      status: status,
      description: description,
      createdAt: DateTime.now(),
    );
  }

  WalletTransactionModel buildWithdrawTransaction(
    double amount, {
    String status = WalletTransactionStatus.completed,
    String description = Tk.walletDescriptionWithdrawRequest,
  }) {
    return WalletTransactionModel(
      id: _nextId('WDR'),
      type: WalletTransactionType.withdraw,
      amount: amount,
      status: status,
      description: description,
      createdAt: DateTime.now(),
    );
  }

  Future<WalletTransactionModel> submitDepositRequest({
    required double amount,
    required String description,
    String status = WalletTransactionStatus.pending,
  }) async {
    _ensureSeeded();
    await Future.delayed(const Duration(milliseconds: 250));

    final transaction = buildDepositTransaction(
      amount,
      status: status,
      description: description,
    );

    _transactions!.insert(0, transaction);
    return transaction;
  }

  Future<WalletTransactionModel> submitWithdrawRequest({
    required double amount,
    required String description,
    String status = WalletTransactionStatus.pending,
  }) async {
    _ensureSeeded();
    await Future.delayed(const Duration(milliseconds: 250));

    final currentWallet = _wallet!;
    final transaction = buildWithdrawTransaction(
      amount,
      status: status,
      description: description,
    );

    _wallet = currentWallet.copyWith(
      balance: currentWallet.balance - amount,
      updatedAt: DateTime.now(),
    );
    _transactions!.insert(0, transaction);

    return transaction;
  }

  WalletModel? get cachedWallet {
    final value = _wallet;
    return value?.copyWith();
  }

  Future<RefundStatusModel> checkRefundStatus(String lookupId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final key = lookupId.trim().toUpperCase();

    if (key == 'RF-1001' || key == 'ORD-10241') {
      return const RefundStatusModel(
        refundId: 'RF-1001',
        orderId: 'ORD-10241',
        amount: 6500,
        status: WalletTransactionStatus.refunded,
        message: Tk.walletRefundMessageRefunded,
      );
    }

    if (key == 'RF-1002' || key == 'ORD-10212') {
      return const RefundStatusModel(
        refundId: 'RF-1002',
        orderId: 'ORD-10212',
        amount: 1800,
        status: WalletTransactionStatus.pending,
        message: Tk.walletRefundMessagePending,
      );
    }

    if (key == 'RF-1003' || key == 'ORD-10188') {
      return const RefundStatusModel(
        refundId: 'RF-1003',
        orderId: 'ORD-10188',
        amount: 2500,
        status: WalletTransactionStatus.rejected,
        message: Tk.walletRefundMessageRejected,
      );
    }

    if (key == 'RF-1004' || key == 'ORD-10195') {
      return const RefundStatusModel(
        refundId: 'RF-1004',
        orderId: 'ORD-10195',
        amount: 3200,
        status: WalletTransactionStatus.approved,
        message: Tk.walletRefundMessageApproved,
      );
    }

    throw const WalletLookupException(Tk.walletRefundNotFound);
  }

  String _nextId(String prefix) {
    return '$prefix-${DateTime.now().millisecondsSinceEpoch}';
  }

  void _ensureSeeded() {
    if (_wallet != null && _transactions != null) return;

    final now = DateTime.now();

    _wallet = WalletModel(
      id: 'wallet-main',
      balance: 28750,
      currency: defaultCurrency,
      updatedAt: now.subtract(const Duration(minutes: 8)),
    );

    _transactions = [
      WalletTransactionModel(
        id: 'TXN-240501',
        type: WalletTransactionType.refund,
        amount: 6500,
        status: WalletTransactionStatus.refunded,
        description: Tk.walletDescriptionOrderRefund,
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      WalletTransactionModel(
        id: 'TXN-240498',
        type: WalletTransactionType.withdraw,
        amount: 4000,
        status: WalletTransactionStatus.completed,
        description: Tk.walletDescriptionWithdrawRequest,
        createdAt: now.subtract(const Duration(days: 1, hours: 2)),
      ),
      WalletTransactionModel(
        id: 'TXN-240493',
        type: WalletTransactionType.deposit,
        amount: 12000,
        status: WalletTransactionStatus.completed,
        description: Tk.walletDescriptionManualDeposit,
        createdAt: now.subtract(const Duration(days: 2, hours: 4)),
      ),
      WalletTransactionModel(
        id: 'TXN-240487',
        type: WalletTransactionType.refund,
        amount: 1800,
        status: WalletTransactionStatus.pending,
        description: Tk.walletDescriptionRefundReview,
        createdAt: now.subtract(const Duration(days: 3, hours: 7)),
      ),
    ];
  }
}

class WalletLookupException implements Exception {
  final String messageKey;

  const WalletLookupException(this.messageKey);
}
