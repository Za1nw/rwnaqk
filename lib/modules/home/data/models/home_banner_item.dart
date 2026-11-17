import 'package:rwnaqk_frontend/core/constants/app_env.dart';

class HomeBannerItem {
  final String id;
  final String titleKey;
  final String subtitleKey;
  final String badgeKey;
  final String imageUrl;
  final String linkType;
  final String? linkValue;
  final Map<String, dynamic>? rawTranslations;

  const HomeBannerItem({
    required this.id,
    required this.titleKey,
    required this.subtitleKey,
    required this.badgeKey,
    required this.imageUrl,
    this.linkType = 'none',
    this.linkValue,
    this.rawTranslations,
  });

  /// تحويل مسار الصورة ليتوافق مع عنوان الخادم الحقيقي للهاتف أو المحاكي
  static String resolveImageUrl(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';
    var url = raw.trim();
    final baseUrl = AppEnv.apiBaseUrl.trim();
    if (baseUrl.isNotEmpty) {
      final baseUri = Uri.tryParse(baseUrl);
      if (baseUri != null && baseUri.hasAuthority) {
        if (url.startsWith('/')) {
          return '${baseUri.scheme}://${baseUri.authority}$url';
        }
        final imgUri = Uri.tryParse(url);
        if (imgUri != null &&
            (imgUri.host == '127.0.0.1' || imgUri.host == 'localhost')) {
          url = imgUri
              .replace(
                scheme: baseUri.scheme,
                host: baseUri.host,
                port: baseUri.hasPort ? baseUri.port : null,
              )
              .toString();
        }
      }
    }
    return url;
  }

  /// Factory from Laravel API response
  factory HomeBannerItem.fromJson(Map<String, dynamic> json) {
    final translations = json['translations'] as Map<String, dynamic>?;

    return HomeBannerItem(
      id: json['id']?.toString() ?? '',
      titleKey: json['title']?.toString() ?? '',
      subtitleKey: json['subtitle']?.toString() ?? '',
      badgeKey: json['badge']?.toString() ?? '',
      imageUrl: resolveImageUrl(json['image_url']?.toString()),
      linkType: json['link_type']?.toString() ?? 'none',
      linkValue: json['link_value']?.toString(),
      rawTranslations: translations,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': titleKey,
      'subtitle': subtitleKey,
      'badge': badgeKey,
      'image_url': imageUrl,
      'link_type': linkType,
      'link_value': linkValue,
      'translations': rawTranslations,
    };
  }
}
