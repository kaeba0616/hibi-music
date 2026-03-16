import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidi/env.dart';
import 'package:hidi/features/authentication/repos/authentication_repo.dart';
import 'package:http/http.dart' as http;
import '../mocks/faq_mock.dart' as mock;
import '../models/faq_models.dart';

/// FAQ Repository
class FAQRepository {
  final bool useMock;
  final basehost = Env.basehost;
  final basepath = "/api/v1/faqs";

  FAQRepository({this.useMock = false});

  /// FAQ 목록 조회
  Future<List<FAQ>> getFAQs({
    FAQCategory? category,
    String? keyword,
  }) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return mock.getFAQList(category: category, keyword: keyword);
    }

    // Real API
    final queryParams = <String, String>{};
    if (category != null && category != FAQCategory.all) {
      queryParams['category'] = category.apiValue;
    }
    if (keyword != null && keyword.isNotEmpty) {
      queryParams['keyword'] = keyword;
    }

    final uri = Uri.http(basehost, basepath, queryParams.isNotEmpty ? queryParams : null);

    try {
      final response = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
        },
      );

      log("getFAQs: ${response.statusCode}");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body)["data"];
        if (data == null) return [];

        final List<dynamic> faqs = data["faqs"] ?? [];
        return faqs.map((json) => FAQ.fromJson(json)).toList();
      }

      log("Error: getFAQs - ${response.body}");
      return [];
    } catch (e) {
      log("Error: getFAQs - $e");
      return [];
    }
  }

  /// 카테고리별로 그룹화된 FAQ 조회
  Future<Map<FAQCategory, List<FAQ>>> getGroupedFAQs({
    FAQCategory? category,
    String? keyword,
  }) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return mock.getGroupedFAQs(category: category, keyword: keyword);
    }

    // Real API - FAQ 목록 조회 후 그룹화
    final faqs = await getFAQs(category: category, keyword: keyword);

    final Map<FAQCategory, List<FAQ>> grouped = {};
    for (final faq in faqs) {
      grouped.putIfAbsent(faq.category, () => []);
      grouped[faq.category]!.add(faq);
    }

    return grouped;
  }

  /// 단일 FAQ 조회
  Future<FAQ?> getFAQById(int id) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 200));
      try {
        return mock.mockFAQs.firstWhere((faq) => faq.id == id);
      } catch (e) {
        return null;
      }
    }

    // Real API
    final uri = Uri.http(basehost, "$basepath/$id");

    try {
      final response = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
        },
      );

      log("getFAQById: ${response.statusCode}");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body)["data"];
        if (data == null) return null;
        return FAQ.fromJson(data);
      }

      log("Error: getFAQById - ${response.body}");
      return null;
    } catch (e) {
      log("Error: getFAQById - $e");
      return null;
    }
  }
}

/// Mock Provider 패턴 적용
final faqRepoProvider = Provider<FAQRepository>((ref) {
  const useMock = String.fromEnvironment('USE_MOCK', defaultValue: 'true') == 'true';
  return FAQRepository(useMock: useMock);
});
