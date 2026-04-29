import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rwnaqk/controllers/profile/profile_store_service.dart';
import 'package:rwnaqk/controllers/wallet/wallet_service.dart';
import 'package:rwnaqk/controllers/wallet/wallet_ui_controller.dart';
import 'package:rwnaqk/core/routes/wallet_routes.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';
import 'package:rwnaqk/core/utils/app_date_utils.dart';
import 'package:rwnaqk/core/utils/app_money_utils.dart';
import 'package:rwnaqk/models/wallet/refund_status_model.dart';
import 'package:rwnaqk/models/wallet/wallet_model.dart';
import 'package:rwnaqk/models/wallet/wallet_transaction_model.dart';
import 'package:rwnaqk/models/wallet_transfer_account.dart';

class WalletController extends GetxController {
  WalletController(this._service);

  static const double _hawalaFee = 500;
  static const String _descriptionMetaSeparator = '::';

  final WalletService _service;
  final _profileStore = Get.find<ProfileStoreService>();
  final _imagePicker = ImagePicker();

  late final WalletUiController ui;

  final wallet = Rxn<WalletModel>();
  final transactions = <WalletTransactionModel>[].obs;
  final filteredTransactions = <WalletTransactionModel>[].obs;
  final refundStatus = Rxn<RefundStatusModel>();

  final isWalletLoading = false.obs;
  final isTransactionsLoading = false.obs;
  final isSubmitting = false.obs;
  final isRefundLoading = false.obs;

  final walletError = RxnString();
  final transactionsError = RxnString();
  final refundError = RxnString();

  Rx<WalletTransactionFilter> get filter => ui.filter;
  Rxn<WalletTransactionModel> get selectedTransaction => ui.selectedTransaction;
  RxInt get selectedDepositWalletAccountIndex =>
      ui.selectedDepositWalletAccountIndex;
  Rx<WalletWithdrawMethod> get withdrawMethod => ui.withdrawMethod;
  RxInt get selectedWithdrawWalletAccountIndex =>
      ui.selectedWithdrawWalletAccountIndex;

  GlobalKey<FormState> get depositFormKey => ui.depositFormKey;
  GlobalKey<FormState> get withdrawFormKey => ui.withdrawFormKey;
  GlobalKey<FormState> get refundFormKey => ui.refundFormKey;

  TextEditingController get depositAmountController =>
      ui.depositAmountController;
  TextEditingController get withdrawAmountController =>
      ui.withdrawAmountController;
  TextEditingController get refundLookupController => ui.refundLookupController;
  TextEditingController get withdrawWalletNameController =>
      ui.withdrawWalletNameController;
  TextEditingController get withdrawWalletNumberController =>
      ui.withdrawWalletNumberController;
  TextEditingController get withdrawHawalaFullNameController =>
      ui.withdrawHawalaFullNameController;
  TextEditingController get withdrawHawalaPhoneController =>
      ui.withdrawHawalaPhoneController;

  List<double> get suggestedAmounts => ui.suggestedAmounts;
  RxList<WalletTransferAccount> get walletTransferAccounts =>
      _profileStore.walletAccounts;

  double get balance => wallet.value?.balance ?? 0;
  String get currency =>
      wallet.value?.currency ?? WalletService.defaultCurrency;
  File? get depositReceiptImage => ui.depositReceiptImage.value;
  bool get hasDepositReceiptImage => depositReceiptImage != null;
  bool get isWalletWithdrawMethod =>
      withdrawMethod.value == WalletWithdrawMethod.wallet;
  bool get isHawalaWithdrawMethod =>
      withdrawMethod.value == WalletWithdrawMethod.hawala;
  double get withdrawHawalaFee => isHawalaWithdrawMethod ? _hawalaFee : 0;

  bool get hasWalletData => wallet.value != null;
  bool get hasTransactions => filteredTransactions.isNotEmpty;

  List<WalletTransactionModel> get recentTransactionsPreview {
    return transactions.take(3).toList(growable: false);
  }

  String get walletUpdatedAtLabel {
    final value = wallet.value;
    if (value == null) return '--';

    return Tk.walletUpdatedAt.trParams({
      'date': AppDateUtils.formatYmdHm(value.updatedAt),
    });
  }

  WalletTransferAccount? get selectedDepositWalletAccount {
    final accounts = walletTransferAccounts;
    if (accounts.isEmpty) return null;

    final index = selectedDepositWalletAccountIndex.value;
    final safeIndex = index < 0
        ? 0
        : (index >= accounts.length ? accounts.length - 1 : index);

    return accounts[safeIndex];
  }

  WalletTransferAccount? get selectedWithdrawWalletAccount {
    final accounts = walletTransferAccounts;
    if (accounts.isEmpty) return null;

    final index = selectedWithdrawWalletAccountIndex.value;
    final safeIndex = index < 0
        ? 0
        : (index >= accounts.length ? accounts.length - 1 : index);

    return accounts[safeIndex];
  }

  double? get withdrawRequestedAmount =>
      _parseAmount(withdrawAmountController.text);

  double get withdrawNetAmount {
    final requested = withdrawRequestedAmount ?? 0;
    final net = requested - withdrawHawalaFee;
    return net <= 0 ? 0 : net;
  }

  @override
  void onInit() {
    super.onInit();

    ui = Get.find<WalletUiController>();
    ever<List<WalletTransferAccount>>(walletTransferAccounts, (accounts) {
      if (accounts.isEmpty) {
        ui.setSelectedDepositWalletAccountIndex(0);
        return;
      }

      final index = selectedDepositWalletAccountIndex.value;
      if (index < 0 || index >= accounts.length) {
        ui.setSelectedDepositWalletAccountIndex(0);
      }
    });
    ever<List<WalletTransferAccount>>(walletTransferAccounts, (accounts) {
      if (accounts.isEmpty) {
        ui.setSelectedWithdrawWalletAccountIndex(0);
        return;
      }

      final index = selectedWithdrawWalletAccountIndex.value;
      if (index < 0 || index >= accounts.length) {
        ui.setSelectedWithdrawWalletAccountIndex(0);
      }
    });
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future.wait([
      fetchWalletBalance(),
      fetchWalletTransactions(),
    ]);
  }

  Future<void> refreshWallet() async {
    await Future.wait([
      fetchWalletBalance(),
      fetchWalletTransactions(),
    ]);
  }

  Future<void> fetchWalletBalance() async {
    isWalletLoading.value = true;
    walletError.value = null;

    try {
      wallet.value = await _service.fetchWalletBalance();
    } catch (_) {
      walletError.value = Tk.walletLoadFailed.tr;
    } finally {
      isWalletLoading.value = false;
    }
  }

  Future<void> fetchWalletTransactions() async {
    isTransactionsLoading.value = true;
    transactionsError.value = null;

    try {
      transactions.assignAll(await _service.fetchWalletTransactions());
      filterTransactions();
    } catch (_) {
      transactionsError.value = Tk.walletLoadFailed.tr;
      filteredTransactions.clear();
    } finally {
      isTransactionsLoading.value = false;
    }
  }

  Future<bool> depositBalance([double? amount]) async {
    final parsedAmount = amount ?? _parseAmount(depositAmountController.text);
    if (!_isValidPositiveAmount(parsedAmount)) {
      _showError(Tk.walletErrorInvalidAmount.tr);
      return false;
    }

    final selectedAccount = selectedDepositWalletAccount;
    if (selectedAccount == null) {
      _showError(Tk.walletNoTransferAccounts.tr);
      return false;
    }

    if (!hasDepositReceiptImage) {
      _showError(Tk.walletDepositReceiptRequired.tr);
      return false;
    }

    isSubmitting.value = true;

    try {
      final value = parsedAmount!;
      final transaction = await _service.submitDepositRequest(
        amount: value,
        status: WalletTransactionStatus.pending,
        description: _buildDescription(
          Tk.walletDescriptionDepositReview,
          selectedAccount.companyName,
        ),
      );
      transactions.insert(0, transaction);
      filterTransactions();
      ui.clearDepositAmount();
      ui.clearDepositReceiptImage();

      Get.snackbar(
        Tk.commonSuccess.tr,
        Tk.walletDepositRequestSubmitted.trParams({
          'amount': formatMoney(value),
        }),
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (_) {
      _showError(Tk.commonUnexpectedError.tr);
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> withdrawBalance([double? amount]) async {
    final parsedAmount = amount ?? _parseAmount(withdrawAmountController.text);
    if (!_isValidPositiveAmount(parsedAmount)) {
      _showError(Tk.walletErrorInvalidAmount.tr);
      return false;
    }

    if ((parsedAmount ?? 0) > balance) {
      _showError(Tk.walletErrorInsufficientBalance.tr);
      return false;
    }

    if (isHawalaWithdrawMethod && (parsedAmount ?? 0) <= withdrawHawalaFee) {
      _showError(Tk.walletErrorAmountBelowHawalaFee.tr);
      return false;
    }

    final currentWallet = wallet.value;
    if (currentWallet == null) {
      _showError(Tk.walletLoadFailed.tr);
      return false;
    }

    final withdrawValidationMessage = _validateWithdrawRequest();
    if (withdrawValidationMessage != null) {
      _showError(withdrawValidationMessage.tr);
      return false;
    }

    isSubmitting.value = true;

    try {
      final value = parsedAmount!;
      final netAmount =
          isHawalaWithdrawMethod ? value - withdrawHawalaFee : value;
      final description = isWalletWithdrawMethod
          ? _buildDescription(
              Tk.walletDescriptionWithdrawWalletRequest,
              selectedWithdrawWalletAccount?.companyName,
            )
          : Tk.walletDescriptionWithdrawHawalaRequest;

      final transaction = await _service.submitWithdrawRequest(
        amount: value,
        status: WalletTransactionStatus.pending,
        description: description,
      );

      wallet.value = _service.cachedWallet ?? currentWallet;
      transactions.insert(0, transaction);
      filterTransactions();
      ui.clearWithdrawAmount();
      ui.clearWithdrawRecipientFields();

      Get.snackbar(
        Tk.commonSuccess.tr,
        Tk.walletWithdrawRequestSubmitted.trParams({
          'amount': formatMoney(value),
          'net': formatMoney(netAmount),
        }),
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (_) {
      _showError(Tk.commonUnexpectedError.tr);
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<RefundStatusModel?> checkRefundStatus([String? lookup]) async {
    final query = (lookup ?? refundLookupController.text).trim();
    if (query.isEmpty) {
      final message = Tk.walletRefundCheckEmpty.tr;
      refundError.value = message;
      _showError(message);
      return null;
    }

    isRefundLoading.value = true;
    refundError.value = null;

    try {
      final result = await _service.checkRefundStatus(query);
      refundStatus.value = result;
      return result;
    } on WalletLookupException catch (e) {
      refundStatus.value = null;
      refundError.value = e.messageKey.tr;
      _showError(refundError.value ?? Tk.commonUnexpectedError.tr);
      return null;
    } catch (_) {
      refundStatus.value = null;
      refundError.value = Tk.commonUnexpectedError.tr;
      _showError(refundError.value ?? Tk.commonUnexpectedError.tr);
      return null;
    } finally {
      isRefundLoading.value = false;
    }
  }

  void filterTransactions([WalletTransactionFilter? nextFilter]) {
    if (nextFilter != null) {
      ui.setFilter(nextFilter);
    }

    filteredTransactions.assignAll(
      _service.filterTransactions(
        transactions: transactions,
        filter: filter.value,
      ),
    );
  }

  void setDepositSuggestion(double value) {
    ui.setDepositAmount(value);
  }

  void setSelectedDepositWalletAccountIndex(int value) {
    ui.setSelectedDepositWalletAccountIndex(value);
  }

  Future<void> pickDepositReceiptImage() async {
    final picked = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    ui.setDepositReceiptImage(File(picked.path));
  }

  void removeDepositReceiptImage() {
    ui.clearDepositReceiptImage();
  }

  void setWithdrawSuggestion(double value) {
    ui.setWithdrawAmount(value);
  }

  void setWithdrawMethod(WalletWithdrawMethod value) {
    ui.setWithdrawMethod(value);
  }

  void setSelectedWithdrawWalletAccountIndex(int value) {
    ui.setSelectedWithdrawWalletAccountIndex(value);
  }

  void openOperationDetails(WalletTransactionModel transaction) {
    ui.setSelectedTransaction(transaction);
    Get.toNamed(
      WalletRoutes.operationDetails,
      arguments: transaction,
    );
  }

  WalletTransactionModel? findTransactionById(String id) {
    return transactions.firstWhereOrNull((item) => item.id == id);
  }

  String typeLabel(String type) {
    switch (type) {
      case WalletTransactionType.deposit:
        return Tk.walletTypeDeposit.tr;
      case WalletTransactionType.withdraw:
        return Tk.walletTypeWithdraw.tr;
      case WalletTransactionType.refund:
        return Tk.walletTypeRefund.tr;
      default:
        return type;
    }
  }

  String statusLabel(String status) {
    switch (status) {
      case WalletTransactionStatus.pending:
        return Tk.walletStatusPending.tr;
      case WalletTransactionStatus.approved:
        return Tk.walletStatusApproved.tr;
      case WalletTransactionStatus.rejected:
        return Tk.walletStatusRejected.tr;
      case WalletTransactionStatus.refunded:
        return Tk.walletStatusRefunded.tr;
      case WalletTransactionStatus.completed:
        return Tk.walletStatusCompleted.tr;
      case WalletTransactionStatus.failed:
        return Tk.walletStatusFailed.tr;
      default:
        return status;
    }
  }

  String filterLabel(WalletTransactionFilter value) {
    switch (value) {
      case WalletTransactionFilter.deposit:
        return Tk.walletFilterDeposit.tr;
      case WalletTransactionFilter.withdraw:
        return Tk.walletFilterWithdraw.tr;
      case WalletTransactionFilter.refund:
        return Tk.walletFilterRefund.tr;
      case WalletTransactionFilter.all:
        return Tk.walletFilterAll.tr;
    }
  }

  String formatMoney(num value) {
    switch (currency.toUpperCase()) {
      case 'YER':
        return AppMoneyUtils.riyal(value);
      case 'SAR':
        return AppMoneyUtils.whole(value, suffix: ' SAR');
      case 'USD':
        return AppMoneyUtils.currency(
          value,
          symbol: r'$',
          trimZeroDecimals: true,
        );
      default:
        return AppMoneyUtils.whole(value, suffix: ' $currency');
    }
  }

  String formatTransactionAmount(WalletTransactionModel transaction) {
    final sign = transaction.isCredit ? '+' : '-';
    return '$sign ${formatMoney(transaction.amount)}';
  }

  String formatDate(DateTime date) {
    return AppDateUtils.formatYmdHm(date);
  }

  String resolveTransactionDescription(String raw) {
    if (raw.contains(_descriptionMetaSeparator)) {
      final parts = raw.split(_descriptionMetaSeparator);
      final key = parts.first.trim();
      final trailing = parts.skip(1).join(_descriptionMetaSeparator).trim();

      if (trailing.isEmpty) return key.tr;
      return '${key.tr} - $trailing';
    }

    return raw.tr;
  }

  String withdrawMethodLabel() {
    return isWalletWithdrawMethod
        ? Tk.walletWithdrawWalletTitle.tr
        : Tk.walletWithdrawHawalaTitle.tr;
  }

  String? validateDepositAmount(String? value) {
    if (!_isValidPositiveAmount(_parseAmount(value))) {
      return Tk.walletErrorInvalidAmount.tr;
    }

    return null;
  }

  String? validateWithdrawAmount(String? value) {
    final parsed = _parseAmount(value);
    if (!_isValidPositiveAmount(parsed)) {
      return Tk.walletErrorInvalidAmount.tr;
    }

    if ((parsed ?? 0) > balance) {
      return Tk.walletErrorInsufficientBalance.tr;
    }

    if (isHawalaWithdrawMethod && (parsed ?? 0) <= withdrawHawalaFee) {
      return Tk.walletErrorAmountBelowHawalaFee.tr;
    }

    return null;
  }

  String? validateWithdrawWalletName(String? value) {
    if (isWalletWithdrawMethod && (value ?? '').trim().isEmpty) {
      return Tk.walletErrorFullNameRequired.tr;
    }

    return null;
  }

  String? validateWithdrawWalletNumber(String? value) {
    if (isWalletWithdrawMethod && (value ?? '').trim().isEmpty) {
      return Tk.walletErrorWalletNumberRequired.tr;
    }

    return null;
  }

  String? validateWithdrawHawalaFullName(String? value) {
    if (isHawalaWithdrawMethod && (value ?? '').trim().isEmpty) {
      return Tk.walletErrorFullNameRequired.tr;
    }

    return null;
  }

  String? validateWithdrawHawalaPhone(String? value) {
    final text = (value ?? '').trim();
    if (isHawalaWithdrawMethod && text.isEmpty) {
      return Tk.walletErrorPhoneRequired.tr;
    }

    if (isHawalaWithdrawMethod && text.length < 7) {
      return Tk.walletErrorPhoneInvalid.tr;
    }

    return null;
  }

  String? validateRefundLookup(String? value) {
    if ((value ?? '').trim().isEmpty) {
      return Tk.walletRefundCheckEmpty.tr;
    }

    return null;
  }

  double? _parseAmount(String? raw) {
    final normalized = (raw ?? '').replaceAll(',', '').trim();
    if (normalized.isEmpty) return null;
    return double.tryParse(normalized);
  }

  bool _isValidPositiveAmount(double? value) {
    return value != null && value > 0;
  }

  String? _validateWithdrawRequest() {
    if (isWalletWithdrawMethod) {
      if (selectedWithdrawWalletAccount == null) {
        return Tk.walletNoTransferAccounts;
      }

      if ((withdrawWalletNameController.text).trim().isEmpty) {
        return Tk.walletErrorFullNameRequired;
      }

      if ((withdrawWalletNumberController.text).trim().isEmpty) {
        return Tk.walletErrorWalletNumberRequired;
      }

      return null;
    }

    if ((withdrawHawalaFullNameController.text).trim().isEmpty) {
      return Tk.walletErrorFullNameRequired;
    }

    final phone = withdrawHawalaPhoneController.text.trim();
    if (phone.isEmpty) {
      return Tk.walletErrorPhoneRequired;
    }

    if (phone.length < 7) {
      return Tk.walletErrorPhoneInvalid;
    }

    return null;
  }

  String _buildDescription(String key, [String? trailing]) {
    final suffix = (trailing ?? '').trim();
    if (suffix.isEmpty) return key;
    return '$key$_descriptionMetaSeparator$suffix';
  }

  void _showError(String message) {
    Get.snackbar(
      Tk.commonError.tr,
      message,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
