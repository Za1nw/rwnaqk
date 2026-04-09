import 'package:flutter/material.dart';
/// يمثل حساب محفظة للتحويل (يتم التحكم فيه من الأدمن)
class WalletTransferAccount {
  final String id;
  final String companyName;
  final String receiverName;
  final String walletNumber;
  final IconData icon;
  const WalletTransferAccount({
    required this.id,
    required this.companyName,
    required this.receiverName,
    required this.walletNumber,
    required this.icon,
  });
}
