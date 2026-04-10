import 'package:get/get.dart';
import 'package:rwnaqk/controllers/profile/profile_store_service.dart';
import 'package:rwnaqk/core/utils/app_checkout_utils.dart';
import 'package:rwnaqk/models/wallet_transfer_account.dart';

/// كنترولر منطق الدفع (Payment)
///
/// الهدف: عزل كل ما يتعلق بطريقة الدفع والمحافظ عن `CartController`.
class PaymentController extends GetxController {
  final _profileStore = Get.find<ProfileStoreService>();

  /// طريقة الدفع المختارة (مثلاً: 'cod' أو 'wallet')
  final paymentMethodId = 'cod'.obs;

  /// مؤشر المحفظة/الشركة المختارة ضمن المحافظ المتاحة
  final selectedWalletAccountIndex = 0.obs;

  /// المحافظ متاحة من الـ ProfileStore (admin-controlled)
  RxList<WalletTransferAccount> get walletAccounts => _profileStore.walletAccounts;

  bool get isWalletPayment => paymentMethodId.value == 'wallet';

  String get paymentMethodLabel =>
      AppCheckoutUtils.paymentMethodLabel(isWalletPayment: isWalletPayment);

  WalletTransferAccount? get selectedWalletAccount {
    final accounts = walletAccounts;
    if (accounts.isEmpty) return null;
    final i = selectedWalletAccountIndex.value;
    final clamped = i < 0 ? 0 : (i >= accounts.length ? accounts.length - 1 : i);
    return accounts[clamped];
  }

  void setPaymentMethodId(String id) => paymentMethodId.value = id;

  void setSelectedWalletAccountIndex(int index) {
    selectedWalletAccountIndex.value = index;
  }

  @override
  void onInit() {
    super.onInit();

    // Keep selected index valid when wallets list changes.
    ever<List<WalletTransferAccount>>(walletAccounts, (accounts) {
      if (accounts.isEmpty) {
        selectedWalletAccountIndex.value = 0;
        return;
      }
      final i = selectedWalletAccountIndex.value;
      if (i < 0 || i >= accounts.length) {
        selectedWalletAccountIndex.value = 0;
      }
    });
  }
}

