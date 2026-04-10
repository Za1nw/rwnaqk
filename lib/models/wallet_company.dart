import 'package:flutter/material.dart';
import 'package:rwnaqk/models/wallet_transfer_account.dart';

class WalletCompany {
  final String name;
  final String? assetPath;
  final IconData? icon;

  const WalletCompany({
    required this.name,
    this.assetPath,
    this.icon,
  });

  factory WalletCompany.fromTransferAccount(
    WalletTransferAccount account, {
    String? assetPath,
  }) {
    return WalletCompany(
      name: account.companyName,
      assetPath: assetPath,
      icon: account.icon,
    );
  }
}
