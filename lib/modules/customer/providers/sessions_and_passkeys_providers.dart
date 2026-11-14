import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/core/di/core_providers.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/passkey_model.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/user_session_model.dart';

/// موفر قائمة الجلسات النشطة للمستخدم
final activeSessionsProvider =
    AsyncNotifierProvider<ActiveSessionsNotifier, List<UserSessionModel>>(
  ActiveSessionsNotifier.new,
);

class ActiveSessionsNotifier extends AsyncNotifier<List<UserSessionModel>> {
  @override
  Future<List<UserSessionModel>> build() async {
    final repo = ref.watch(authRepositoryProvider);
    return repo.getSessions();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(authRepositoryProvider).getSessions());
  }

  Future<void> revokeSession(int id) async {
    await ref.read(authRepositoryProvider).revokeSession(id);
    await refresh();
  }

  Future<void> revokeOtherSessions() async {
    await ref.read(authRepositoryProvider).revokeOtherSessions();
    await refresh();
  }
}

/// موفر قائمة مفاتيح المرور Passkeys
final passkeysProvider =
    AsyncNotifierProvider<PasskeysNotifier, List<PasskeyModel>>(
  PasskeysNotifier.new,
);

class PasskeysNotifier extends AsyncNotifier<List<PasskeyModel>> {
  @override
  Future<List<PasskeyModel>> build() async {
    final repo = ref.watch(authRepositoryProvider);
    return repo.getPasskeys();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(authRepositoryProvider).getPasskeys());
  }

  Future<PasskeyModel> storePasskey({
    required String name,
    String? credentialId,
    Map<String, dynamic>? credential,
  }) async {
    final result = await ref.read(authRepositoryProvider).storePasskey(
      name: name,
      credentialId: credentialId,
      credential: credential,
    );
    await refresh();
    return result;
  }

  Future<void> deletePasskey(int id) async {
    await ref.read(authRepositoryProvider).deletePasskey(id);
    await refresh();
  }
}

