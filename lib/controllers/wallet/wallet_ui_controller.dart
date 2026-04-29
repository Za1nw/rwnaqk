import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/models/wallet/wallet_transaction_model.dart';

enum WalletWithdrawMethod { wallet, hawala }

class WalletUiController extends GetxController {
  final depositFormKey = GlobalKey<FormState>();
  final withdrawFormKey = GlobalKey<FormState>();
  final refundFormKey = GlobalKey<FormState>();

  final depositAmountController = TextEditingController();
  final withdrawAmountController = TextEditingController();
  final refundLookupController = TextEditingController();
  final withdrawWalletNameController = TextEditingController();
  final withdrawWalletNumberController = TextEditingController();
  final withdrawHawalaFullNameController = TextEditingController();
  final withdrawHawalaPhoneController = TextEditingController();

  final filter = WalletTransactionFilter.all.obs;
  final selectedTransaction = Rxn<WalletTransactionModel>();
  final selectedDepositWalletAccountIndex = 0.obs;
  final depositReceiptImage = Rxn<File>();
  final withdrawMethod = WalletWithdrawMethod.wallet.obs;
  final selectedWithdrawWalletAccountIndex = 0.obs;

  final List<double> suggestedAmounts = const [1000, 2500, 5000, 10000];

  void setFilter(WalletTransactionFilter value) {
    filter.value = value;
  }

  void setSelectedTransaction(WalletTransactionModel? value) {
    selectedTransaction.value = value;
  }

  void setDepositAmount(double value) {
    depositAmountController.text = value.toStringAsFixed(0);
  }

  void setSelectedDepositWalletAccountIndex(int value) {
    selectedDepositWalletAccountIndex.value = value;
  }

  void setDepositReceiptImage(File? file) {
    depositReceiptImage.value = file;
  }

  void setWithdrawMethod(WalletWithdrawMethod value) {
    withdrawMethod.value = value;
  }

  void setSelectedWithdrawWalletAccountIndex(int value) {
    selectedWithdrawWalletAccountIndex.value = value;
  }

  void setWithdrawAmount(double value) {
    withdrawAmountController.text = value.toStringAsFixed(0);
  }

  void clearDepositAmount() {
    depositAmountController.clear();
  }

  void clearDepositReceiptImage() {
    depositReceiptImage.value = null;
  }

  void clearWithdrawAmount() {
    withdrawAmountController.clear();
  }

  void clearWithdrawRecipientFields() {
    withdrawWalletNameController.clear();
    withdrawWalletNumberController.clear();
    withdrawHawalaFullNameController.clear();
    withdrawHawalaPhoneController.clear();
  }

  void clearRefundLookup() {
    refundLookupController.clear();
  }

  @override
  void onClose() {
    depositAmountController.dispose();
    withdrawAmountController.dispose();
    refundLookupController.dispose();
    withdrawWalletNameController.dispose();
    withdrawWalletNumberController.dispose();
    withdrawHawalaFullNameController.dispose();
    withdrawHawalaPhoneController.dispose();
    super.onClose();
  }
}
