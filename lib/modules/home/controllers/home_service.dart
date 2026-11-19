import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:rwnaqk_frontend/core/network/api_client.dart';
import 'package:rwnaqk_frontend/modules/home/data/home_local_cache.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_banner_item.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_category_item.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_product_item.dart';

/// كائن حمولة بيانات الشاشة الرئيسية المجمعة (Composite Payload)
class HomeBootstrapPayload {
  final List<HomeBannerItem> banners;
  final List<HomeCategoryItem> categories;
  final List<HomeProductItem> newItems;
  final List<HomeProductItem> popularItems;
  final List<HomeProductItem> flashSale;

  const HomeBootstrapPayload({
    this.banners = const [],
    this.categories = const [],
    this.newItems = const [],
    this.popularItems = const [],
    this.flashSale = const [],
  });

  factory HomeBootstrapPayload.fromJson(Map<String, dynamic> json) {
    final banners = (json['banners'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(HomeBannerItem.fromJson)
        .toList();

    final categories = (json['categories'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(HomeCategoryItem.fromJson)
        .toList();

    final newItems = (json['new_items'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(HomeProductItem.fromJson)
        .toList();

    final popularItems = (json['popular_items'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(HomeProductItem.fromJson)
        .toList();

    final flashSale = (json['flash_sale'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(HomeProductItem.fromJson)
        .toList();

    return HomeBootstrapPayload(
      banners: banners,
      categories: categories,
      newItems: newItems,
      popularItems: popularItems,
      flashSale: flashSale,
    );
  }
}

class HomeService {
  final HomeLocalCache _localCache;

  HomeService({HomeLocalCache? localCache})
      : _localCache = localCache ?? HomeLocalCache();

  /// جلب بيانات الشاشة الرئيسية كاملة مع دعم HTTP ETag والتخزين المؤقت المحلي
  /// يدعم:
  /// - إرسال ترويسة If-None-Match عند توفر ETag محلياً
  /// - قبول كود HTTP 304 واسترجاع البيانات المخزنة محلياً بسرعة فائقة (0 بايت شبكة)
  /// - إرسال Cache-Control: no-cache عند السحب للتحديث (Pull-to-Refresh)
  /// - تحديث الكاش المحلي والـ ETag عند استلام 200 OK
  /// - توفير البيانات المخزنة محلياً عند انقطاع الاتصال بالإنترنت
  Future<HomeBootstrapPayload?> fetchHomeBootstrap(
    ApiClient apiClient, {
    CancelToken? cancelToken,
    bool isRefresh = false,
  }) async {
    final cachedPayload = await _localCache.getCachedPayload();
    final savedEtag = await _localCache.getEtag();

    try {
      final headers = <String, dynamic>{};
      if (isRefresh) {
        headers['Cache-Control'] = 'no-cache';
      } else if (savedEtag != null && savedEtag.isNotEmpty) {
        headers['If-None-Match'] = savedEtag;
      }

      final response = await apiClient.get<dynamic>(
        '/api/v1/home/bootstrap',
        options: Options(
          headers: headers,
          validateStatus: (status) =>
              status != null &&
              ((status >= 200 && status < 300) || status == 304),
        ),
        cancelToken: cancelToken,
      );

      // الحالة الأولى: الخادم أعاد 304 Not Modified (البيانات لم تتغير)
      if (response.statusCode == 304) {
        debugPrint('[HomeService] Received 304 Not Modified. Utilizing local cached bootstrap.');
        if (cachedPayload != null) {
          return cachedPayload;
        }

        // في حال كان الـ ETag موجوداً لكن البيانات المحلية مفقودة/تالفة:
        return await fetchHomeBootstrap(
          apiClient,
          cancelToken: cancelToken,
          isRefresh: true,
        );
      }

      // الحالة الثانية: الخادم أعاد 200 OK (بيانات جديدة أو محدثة)
      var rawData = response.data;
      if (rawData is String) {
        try {
          rawData = jsonDecode(rawData);
        } catch (_) {}
      }

      if (rawData is Map<String, dynamic> && rawData['data'] is Map<String, dynamic>) {
        final payloadMap = rawData['data'] as Map<String, dynamic>;
        final newEtag = response.headers.value('etag');

        // حفظ البيانات الطازجة والـ ETag محلياً
        await _localCache.saveBootstrap(
          etag: newEtag,
          rawData: payloadMap,
        );

        return HomeBootstrapPayload.fromJson(payloadMap);
      }

      return cachedPayload;
    } catch (e) {
      debugPrint('[HomeService] Composite bootstrap fetch error: $e');

      // عند فشل الشبكة أو انقطاع الإنترنت: نخدم البيانات المحلية المحفوظة للمستخدم بسلاسة
      if (cachedPayload != null) {
        debugPrint('[HomeService] Serving local cached bootstrap data due to network error.');
        return cachedPayload;
      }

      return null;
    }
  }

  /// جلب البانرات الإعلانية المباشرة من خادم Laravel API
  Future<List<HomeBannerItem>> fetchBanners(
    ApiClient apiClient, {
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await apiClient.get<dynamic>(
        '/api/v1/banners',
        cancelToken: cancelToken,
      );
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] is List) {
        final list = data['data'] as List;
        return list
            .whereType<Map<String, dynamic>>()
            .map(HomeBannerItem.fromJson)
            .toList();
      }
      return const [];
    } catch (e) {
      debugPrint('[HomeService] Error fetching banners from API: $e');
      return const [];
    }
  }
}
