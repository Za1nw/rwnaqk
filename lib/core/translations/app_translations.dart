import 'package:get/get.dart';
import 'package:rwnaqk/core/translations/maps/account_translations.dart';
import 'package:rwnaqk/core/translations/maps/auth_translations.dart';
import 'package:rwnaqk/core/translations/maps/common_ui_translations.dart';
import 'package:rwnaqk/core/translations/maps/extra_ui_translations.dart';
import 'package:rwnaqk/core/translations/maps/mock_content_translations.dart';
import 'package:rwnaqk/core/translations/maps/shop_translations.dart';

class AppTranslations extends Translations {
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

  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': _enUS,
        'ar_YE': _arYE,
      };
}
