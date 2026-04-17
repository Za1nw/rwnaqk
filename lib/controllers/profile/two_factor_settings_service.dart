import 'package:rwnaqk/core/services/auth/auth_session_service.dart';
import 'package:rwnaqk/core/services/auth/customer_auth_api_service.dart';

class TwoFactorSettingsState {
  const TwoFactorSettingsState({
    required this.enabled,
    required this.requiresConfirmation,
    required this.hasSetupData,
    this.manualSetupKey,
    this.qrCodeSvg,
    this.recoveryCodes = const <String>[],
  });

  final bool enabled;
  final bool requiresConfirmation;
  final bool hasSetupData;
  final String? manualSetupKey;
  final String? qrCodeSvg;
  final List<String> recoveryCodes;
}

class TwoFactorSettingsService {
  TwoFactorSettingsService(this._api, this._session);

  final CustomerAuthApiService _api;
  final AuthSessionService _session;

  String _tokenOrThrow() {
    final token = (_session.token.value ?? '').trim();
    if (token.isEmpty) {
      throw const AuthApiException(message: 'No active authenticated session.');
    }

    return token;
  }

  Future<TwoFactorSettingsState> fetchStatus() async {
    final response = await _api.twoFactorStatus(token: _tokenOrThrow());

    if (!response.isOk) {
      throw AuthApiException.fromResponse(
        response,
        fallbackMessage: 'Unable to load two-factor settings.',
      );
    }

    final body = response.body;
    if (body is! Map<String, dynamic>) {
      throw const AuthApiException(
        message: 'Unexpected two-factor status response.',
      );
    }

    return TwoFactorSettingsState(
      enabled: body['two_factor_enabled'] == true,
      requiresConfirmation: body['requires_confirmation'] == true,
      hasSetupData: body['has_setup_data'] == true,
    );
  }

  Future<TwoFactorSettingsState> enable() async {
    final response = await _api.enableTwoFactor(token: _tokenOrThrow());

    if (!response.isOk) {
      throw AuthApiException.fromResponse(
        response,
        fallbackMessage: 'Unable to enable two-factor authentication.',
      );
    }

    final body = response.body;
    if (body is! Map<String, dynamic>) {
      throw const AuthApiException(
        message: 'Unexpected enable two-factor response.',
      );
    }

    return TwoFactorSettingsState(
      enabled: body['two_factor_enabled'] == true,
      requiresConfirmation: body['requires_confirmation'] == true,
      hasSetupData: true,
      manualSetupKey: (body['secret_key'] ?? '').toString().trim(),
      qrCodeSvg: (body['qr_code_svg'] ?? '').toString().trim(),
      recoveryCodes: _extractRecoveryCodes(body['recovery_codes']),
    );
  }

  Future<String> confirm({required String code}) async {
    final response = await _api.confirmTwoFactor(
      token: _tokenOrThrow(),
      code: code.trim(),
    );

    if (!response.isOk) {
      throw AuthApiException.fromResponse(
        response,
        fallbackMessage: 'Unable to confirm two-factor authentication.',
      );
    }

    final body = response.body;

    if (body is Map<String, dynamic> && body['message'] is String) {
      return body['message'] as String;
    }

    return 'Two factor authentication confirmed successfully.';
  }

  Future<String> disable() async {
    final response = await _api.disableTwoFactor(token: _tokenOrThrow());

    if (!response.isOk) {
      throw AuthApiException.fromResponse(
        response,
        fallbackMessage: 'Unable to disable two-factor authentication.',
      );
    }

    final body = response.body;

    if (body is Map<String, dynamic> && body['message'] is String) {
      return body['message'] as String;
    }

    return 'Two factor authentication disabled successfully.';
  }

  Future<List<String>> fetchRecoveryCodes() async {
    final response = await _api.twoFactorRecoveryCodes(token: _tokenOrThrow());

    if (!response.isOk) {
      throw AuthApiException.fromResponse(
        response,
        fallbackMessage: 'Unable to load recovery codes.',
      );
    }

    final body = response.body;
    if (body is! Map<String, dynamic>) {
      throw const AuthApiException(
        message: 'Unexpected recovery codes response.',
      );
    }

    return _extractRecoveryCodes(body['recovery_codes']);
  }

  Future<List<String>> regenerateRecoveryCodes() async {
    final response = await _api.regenerateTwoFactorRecoveryCodes(
      token: _tokenOrThrow(),
    );

    if (!response.isOk) {
      throw AuthApiException.fromResponse(
        response,
        fallbackMessage: 'Unable to regenerate recovery codes.',
      );
    }

    final body = response.body;
    if (body is! Map<String, dynamic>) {
      throw const AuthApiException(
        message: 'Unexpected recovery codes response.',
      );
    }

    return _extractRecoveryCodes(body['recovery_codes']);
  }

  List<String> _extractRecoveryCodes(dynamic value) {
    if (value is! List) {
      return const <String>[];
    }

    return value
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }
}
