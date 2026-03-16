/// F12 Management - 관리자용 FAQ 모델
/// FAQ 관리에 사용되는 데이터 모델

import '../../faq/models/faq_models.dart';

/// 관리자용 FAQ 아이템
class AdminFAQItem {
  final int id;
  final FAQCategory category;
  final String question;
  final String answer;
  final int displayOrder;
  final bool isPublished;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const AdminFAQItem({
    required this.id,
    required this.category,
    required this.question,
    required this.answer,
    required this.displayOrder,
    required this.isPublished,
    required this.createdAt,
    this.updatedAt,
  });

  factory AdminFAQItem.fromJson(Map<String, dynamic> json) {
    return AdminFAQItem(
      id: json['id'] as int,
      category: FAQCategory.fromCode(json['category'] as String),
      question: json['question'] as String,
      answer: json['answer'] as String,
      displayOrder: json['displayOrder'] as int,
      isPublished: json['isPublished'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category.code,
      'question': question,
      'answer': answer,
      'displayOrder': displayOrder,
      'isPublished': isPublished,
    };
  }

  AdminFAQItem copyWith({
    int? id,
    FAQCategory? category,
    String? question,
    String? answer,
    int? displayOrder,
    bool? isPublished,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AdminFAQItem(
      id: id ?? this.id,
      category: category ?? this.category,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      displayOrder: displayOrder ?? this.displayOrder,
      isPublished: isPublished ?? this.isPublished,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// FAQ 목록 응답
class AdminFAQListResponse {
  final List<AdminFAQItem> faqs;
  final int totalCount;

  const AdminFAQListResponse({
    required this.faqs,
    required this.totalCount,
  });

  factory AdminFAQListResponse.fromJson(Map<String, dynamic> json) {
    return AdminFAQListResponse(
      faqs: (json['faqs'] as List)
          .map((e) => AdminFAQItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: json['totalCount'] as int,
    );
  }

  factory AdminFAQListResponse.empty() {
    return const AdminFAQListResponse(
      faqs: [],
      totalCount: 0,
    );
  }
}

/// FAQ 생성/수정 요청
class FAQSaveRequest {
  final int? id; // null이면 생성, 있으면 수정
  final FAQCategory category;
  final String question;
  final String answer;
  final int displayOrder;
  final bool isPublished;

  const FAQSaveRequest({
    this.id,
    required this.category,
    required this.question,
    required this.answer,
    required this.displayOrder,
    this.isPublished = true,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'category': category.code,
      'question': question,
      'answer': answer,
      'displayOrder': displayOrder,
      'isPublished': isPublished,
    };
  }

  String? validate() {
    if (question.trim().isEmpty) {
      return '질문을 입력해주세요';
    }
    if (question.length > 200) {
      return '질문은 200자 이하여야 합니다';
    }
    if (answer.trim().isEmpty) {
      return '답변을 입력해주세요';
    }
    if (answer.length > 2000) {
      return '답변은 2000자 이하여야 합니다';
    }
    return null;
  }

  bool get isCreate => id == null;
  bool get isUpdate => id != null;
}
