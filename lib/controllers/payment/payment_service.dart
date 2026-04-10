import 'package:flutter/material.dart';
import 'package:rwnaqk/models/wallet_transfer_account.dart';

/// خدمة الدفع (مصدر بيانات المحافظ)
class PaymentService {
  /// جلب المحافظ من مصدر ثابت أو API
  List<WalletTransferAccount> getWalletAccounts() {
    return [
      WalletTransferAccount(
        id: 'jib',
        companyName: 'Jib',
        receiverName: 'Rwnaqk Store',
        walletNumber: '777123456',
        icon: Icons.account_balance_wallet_outlined,
      ),
      WalletTransferAccount(
        id: 'onecash',
        companyName: 'OneCash',
        receiverName: 'Rwnaqk Store',
        walletNumber: '775987654',
        icon: Icons.payments_outlined,
      ),
      WalletTransferAccount(
        id: 'kuraimi',
        companyName: 'Kuraimi',
        receiverName: 'Rwnaqk Store',
        walletNumber: '782456123',
        icon: Icons.account_balance_outlined,
      ),
    ];
  }
}
