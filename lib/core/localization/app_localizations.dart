import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rwnaqk_frontend/core/translations/maps/account_translations.dart';
import 'package:rwnaqk_frontend/core/translations/maps/auth_translations.dart';
import 'package:rwnaqk_frontend/core/translations/maps/common_ui_translations.dart';
import 'package:rwnaqk_frontend/core/translations/maps/extra_ui_translations.dart';
import 'package:rwnaqk_frontend/core/translations/maps/mock_content_translations.dart';
import 'package:rwnaqk_frontend/core/translations/maps/shop_translations.dart';

/// Store and resolve localized strings without depending on GetX.
class AppTranslations {
  AppTranslations._();

  static const Locale defaultLocale = Locale('ar', 'YE');
  static const Locale fallbackLocale = Locale('en', 'US');

  static Locale _currentLocale = defaultLocale;
  static Locale get currentLocale => _currentLocale;

  static void setLocale(Locale locale) {
    _currentLocale = locale;
  }

  static const Map<String, String> _enUS = {
    ...enCommonUiTranslations,
    ...enAuthTranslations,
    ...enAccountTranslations,
    ...enShopTranslations,
    ...enExtraUiTranslations,
    ...enMockContentTranslations,
  };

  static const Map<String, String> _arYE = {
    ...arCommonUiTranslations,
    ...arAuthTranslations,
    ...arAccountTranslations,
    ...arShopTranslations,
    ...arExtraUiTranslations,
    ...arMockContentTranslations,
  };

  static const Map<String, Map<String, String>> keys = {
    'en_US': _enUS,
    'en': _enUS,
    'ar_YE': _arYE,
    'ar': _arYE,
  };

  /// Translate a string key using current or fallback locale.
  static String translate(String key) {
    final languageKey = _localeToKey(_currentLocale);
    final map = keys[languageKey] ?? keys['ar_YE'] ?? _arYE;

    if (map.containsKey(key)) {
      return map[key]!;
    }

    // Fallback to English
    if (_enUS.containsKey(key)) {
      return _enUS[key]!;
    }

    // Return key as fallback
    return key;
  }

  static String translateArgs(String key, List<String> args) {
    var text = translate(key);
    for (final arg in args) {
      text = text.replaceFirst('%s', arg);
    }
    return text;
  }

  static String translateParams(String key, Map<String, String> params) {
    var text = translate(key);
    params.forEach((paramKey, paramVal) {
      text = text.replaceAll('@$paramKey', paramVal);
    });
    return text;
  }

  static String _localeToKey(Locale locale) {
    if (locale.countryCode != null && locale.countryCode!.isNotEmpty) {
      final composite = '${locale.languageCode}_${locale.countryCode}';
      if (keys.containsKey(composite)) return composite;
    }
    if (keys.containsKey(locale.languageCode)) {
      return locale.languageCode;
    }
    return locale.languageCode == 'en' ? 'en_US' : 'ar_YE';
  }
}

/// Zero-breakage extension replacing GetX's `.tr` syntax on Strings.
extension AppTranslationStringX on String {
  String get tr => AppTranslations.translate(this);

  String trArgs([List<String> args = const []]) =>
      AppTranslations.translateArgs(this, args);

  String trParams([Map<String, String> params = const {}]) =>
      AppTranslations.translateParams(this, params);
}

/// Native Flutter [LocalizationsDelegate] for [AppLocalizations].
class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const List<Locale> supportedLocales = [
    Locale('ar', 'YE'),
    Locale('en', 'US'),
  ];

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  String translate(String key) => AppTranslations.translate(key);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['ar', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    AppTranslations.setLocale(locale);
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

/// SharedPreferences key for locale persistence
const String kAppLocaleStorageKey = 'app_locale_code';

/// Riverpod provider managing the reactive application locale.
final appLocaleProvider =
    NotifierProvider<AppLocaleNotifier, Locale>(AppLocaleNotifier.new);

class AppLocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    // Try to restore from SharedPreferences synchronously if available or set default
    final savedCode = _readInitialSavedLocale();
    final initial = _parseLocale(savedCode);
    AppTranslations.setLocale(initial);
    return initial;
  }

  String? _readInitialSavedLocale() {
    try {
      final prefs = ref.read(sharedPreferencesInstanceProvider);
      return prefs?.getString(kAppLocaleStorageKey);
    } catch (_) {
      return null;
    }
  }

  Future<void> setLocale(Locale newLocale) async {
    state = newLocale;
    AppTranslations.setLocale(newLocale);
    try {
      final prefs = ref.read(sharedPreferencesInstanceProvider);
      if (prefs != null) {
        final code = newLocale.countryCode != null && newLocale.countryCode!.isNotEmpty
            ? '${newLocale.languageCode}_${newLocale.countryCode}'
            : newLocale.languageCode;
        await prefs.setString(kAppLocaleStorageKey, code);
      }
    } catch (_) {}
  }

  static Locale _parseLocale(String? code) {
    if (code == null || code.isEmpty) {
      return AppTranslations.defaultLocale;
    }
    if (code.startsWith('en')) {
      return const Locale('en', 'US');
    }
    return const Locale('ar', 'YE');
  }
}

/// Optional provider for accessing SharedPreferences instance if registered.
final sharedPreferencesInstanceProvider =
    Provider<SharedPreferences?>((ref) => null);
