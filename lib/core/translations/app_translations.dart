import 'package:get/get.dart';
import 'package:rwnaqk/core/translations/ar.dart';
import 'package:rwnaqk/core/translations/maps/account_translations.dart';
import 'package:rwnaqk/core/translations/maps/auth_translations.dart';
import 'package:rwnaqk/core/translations/maps/common_ui_translations.dart';
import 'package:rwnaqk/core/translations/maps/extra_ui_translations.dart';
import 'package:rwnaqk/core/translations/maps/mock_content_translations.dart';
import 'package:rwnaqk/core/translations/maps/shop_translations.dart';
import 'package:rwnaqk/core/translations/en.dart';

class AppTranslations extends Translations {
  static const Map<String, String> _enUS = {
    ...enCommonUiTranslations,
    ...enAuthTranslations,
    ...enAccountTranslations,
    ...enShopTranslations,
    ...enExtraUiTranslations,
    ...enMockContentTranslations,
    ...enWalletTranslations,
  };

  static const Map<String, String> _arYE = {
    ...arCommonUiTranslations,
    ...arAuthTranslations,
    ...arAccountTranslations,
    ...arShopTranslations,
    ...arExtraUiTranslations,
    ...arMockContentTranslations,
    ...arWalletTranslations,
  };

  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': _enUS,
        'ar_YE': _arYE,
      };
}
