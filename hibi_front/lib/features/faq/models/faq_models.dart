/// FAQ 카테고리
enum FAQCategory {
  all,       // 전체
  account,   // 계정
  service,   // 서비스 이용
  community, // 커뮤니티
  other,     // 기타
}

extension FAQCategoryExtension on FAQCategory {
  String get label {
    switch (this) {
      case FAQCategory.all:
        return '전체';
      case FAQCategory.account:
        return '계정';
      case FAQCategory.service:
        return '서비스 이용';
      case FAQCategory.community:
        return '커뮤니티';
      case FAQCategory.other:
        return '기타';
    }
  }

  String get apiValue {
    switch (this) {
      case FAQCategory.all:
        return 'all';
      case FAQCategory.account:
        return 'account';
      case FAQCategory.service:
        return 'service';
      case FAQCategory.community:
        return 'community';
      case FAQCategory.other:
        return 'other';
    }
  }

  static FAQCategory fromString(String value) {
    switch (value.toLowerCase()) {
      case 'account':
        return FAQCategory.account;
      case 'service':
        return FAQCategory.service;
      case 'community':
        return FAQCategory.community;
      case 'other':
        return FAQCategory.other;
      default:
        return FAQCategory.all;
    }
  }
}

/// FAQ 모델
class FAQ {
  final int id;
  final String question;
  final String answer;
  final FAQCategory category;
  final int order;
  final bool isPublished;
  final DateTime createdAt;
  final DateTime? updatedAt;

  FAQ({
    required this.id,
    required this.question,
    required this.answer,
    required this.category,
    this.order = 0,
    this.isPublished = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory FAQ.fromJson(Map<String, dynamic> json) {
    return FAQ(
      id: json['id'] ?? 0,
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
      category: FAQCategoryExtension.fromString(json['category'] ?? 'other'),
      order: json['order'] ?? 0,
      isPublished: json['isPublished'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'category': category.apiValue,
      'order': order,
      'isPublished': isPublished,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// 검색 키워드 매칭 여부
  bool matchesKeyword(String keyword) {
    if (keyword.isEmpty) return true;
    final lowerKeyword = keyword.toLowerCase();
    return question.toLowerCase().contains(lowerKeyword) ||
        answer.toLowerCase().contains(lowerKeyword);
  }

  /// 카테고리 필터 매칭 여부
  bool matchesCategory(FAQCategory filterCategory) {
    if (filterCategory == FAQCategory.all) return true;
    return category == filterCategory;
  }
}

/// FAQ 목록 응답
class FAQListResponse {
  final List<FAQ> faqs;
  final int totalCount;

  FAQListResponse({
    required this.faqs,
    required this.totalCount,
  });

  factory FAQListResponse.fromJson(Map<String, dynamic> json) {
    final faqList = (json['faqs'] as List<dynamic>?)
            ?.map((e) => FAQ.fromJson(e))
            .toList() ??
        [];
    return FAQListResponse(
      faqs: faqList,
      totalCount: json['totalCount'] ?? faqList.length,
    );
  }

  factory FAQListResponse.empty() {
    return FAQListResponse(faqs: [], totalCount: 0);
  }

  bool get isEmpty => faqs.isEmpty;
}
