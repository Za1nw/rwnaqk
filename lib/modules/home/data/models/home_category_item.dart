import 'package:rwnaqk_frontend/core/constants/app_env.dart';

class HomeCategoryItem {
  final String id;
  final String name;
  final int count;
  final List<String> imageUrls;
  final String? parentId;
  final bool isFeatured;
  final bool isTop;

  const HomeCategoryItem({
    required this.id,
    required this.name,
    required this.count,
    required this.imageUrls,
    this.parentId,
    this.isFeatured = false,
    this.isTop = false,
  });

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

  factory HomeCategoryItem.fromJson(Map<String, dynamic> json) {
    final rawImages =
        json['image_urls'] ??
        json['images'] ??
        json['image'] ??
        json['feature_image'] ??
        json['image_url'];
    final parsedImages = <String>[];
    if (rawImages is List) {
      for (final item in rawImages) {
        final resolved = resolveImageUrl(item?.toString());
        if (resolved.isNotEmpty) {
          parsedImages.add(resolved);
        }
      }
    } else if (rawImages is String && rawImages.isNotEmpty) {
      final resolved = resolveImageUrl(rawImages);
      if (resolved.isNotEmpty) {
        parsedImages.add(resolved);
      }
    }

    return HomeCategoryItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['title']?.toString() ?? '',
      count:
          int.tryParse(
            json['count']?.toString() ??
                json['products_count']?.toString() ??
                '0',
          ) ??
          0,
      imageUrls: parsedImages,
      parentId: json['parent_id']?.toString(),
      isFeatured: json['is_featured'] == true,
      isTop: json['is_top'] == true,
    );
  }
}
