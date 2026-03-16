/// 문의 유형
enum QuestionType {
  account('계정', 'account'),
  service('서비스 이용', 'service'),
  bug('버그 신고', 'bug'),
  feature('기능 제안', 'feature'),
  other('기타', 'other');

  final String label;
  final String apiValue;

  const QuestionType(this.label, this.apiValue);

  static QuestionType fromString(String value) {
    return QuestionType.values.firstWhere(
      (type) => type.apiValue == value.toLowerCase(),
      orElse: () => QuestionType.other,
    );
  }
}

/// 문의 상태
enum QuestionStatus {
  received('접수됨', 'received'),
  processing('처리중', 'processing'),
  answered('답변완료', 'answered');

  final String label;
  final String apiValue;

  const QuestionStatus(this.label, this.apiValue);

  static QuestionStatus fromString(String value) {
    return QuestionStatus.values.firstWhere(
      (status) => status.apiValue == value.toLowerCase(),
      orElse: () => QuestionStatus.received,
    );
  }
}

/// 문의 모델
class Question {
  final int id;
  final int memberId;
  final QuestionType type;
  final String title;
  final String content;
  final QuestionStatus status;
  final String? answer;
  final DateTime? answeredAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Question({
    required this.id,
    required this.memberId,
    required this.type,
    required this.title,
    required this.content,
    required this.status,
    this.answer,
    this.answeredAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as int,
      memberId: json['memberId'] as int,
      type: QuestionType.fromString(json['type'] as String),
      title: json['title'] as String,
      content: json['content'] as String,
      status: QuestionStatus.fromString(json['status'] as String),
      answer: json['answer'] as String?,
      answeredAt: json['answeredAt'] != null
          ? DateTime.parse(json['answeredAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memberId': memberId,
      'type': type.apiValue,
      'title': title,
      'content': content,
      'status': status.apiValue,
      'answer': answer,
      'answeredAt': answeredAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// 문의 번호 생성 (QT-YYYYMMDD-0001 형식)
  String get questionNumber {
    final dateStr =
        '${createdAt.year}${createdAt.month.toString().padLeft(2, '0')}${createdAt.day.toString().padLeft(2, '0')}';
    return 'QT-$dateStr-${id.toString().padLeft(4, '0')}';
  }

  Question copyWith({
    int? id,
    int? memberId,
    QuestionType? type,
    String? title,
    String? content,
    QuestionStatus? status,
    String? answer,
    DateTime? answeredAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Question(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      type: type ?? this.type,
      title: title ?? this.title,
      content: content ?? this.content,
      status: status ?? this.status,
      answer: answer ?? this.answer,
      answeredAt: answeredAt ?? this.answeredAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// 문의 작성 요청
class QuestionCreateRequest {
  final QuestionType type;
  final String title;
  final String content;

  QuestionCreateRequest({
    required this.type,
    required this.title,
    required this.content,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.apiValue,
      'title': title,
      'content': content,
    };
  }

  /// 유효성 검사
  String? validate() {
    if (title.isEmpty) {
      return '제목을 입력해주세요';
    }
    if (title.length > 100) {
      return '제목은 100자 이내로 입력해주세요';
    }
    if (content.isEmpty) {
      return '내용을 입력해주세요';
    }
    if (content.length < 10) {
      return '내용은 최소 10자 이상 입력해주세요';
    }
    if (content.length > 1000) {
      return '내용은 1000자 이내로 입력해주세요';
    }
    return null;
  }
}

/// 문의 목록 응답
class QuestionListResponse {
  final List<Question> questions;
  final int totalCount;

  QuestionListResponse({
    required this.questions,
    required this.totalCount,
  });

  factory QuestionListResponse.fromJson(Map<String, dynamic> json) {
    final questionsJson = json['questions'] as List<dynamic>? ?? [];
    return QuestionListResponse(
      questions:
          questionsJson.map((q) => Question.fromJson(q as Map<String, dynamic>)).toList(),
      totalCount: json['totalCount'] as int? ?? 0,
    );
  }

  factory QuestionListResponse.empty() {
    return QuestionListResponse(
      questions: [],
      totalCount: 0,
    );
  }
}
