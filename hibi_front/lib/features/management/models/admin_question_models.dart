/// F12 Management - 관리자용 문의 모델
/// 문의 관리에 사용되는 데이터 모델

import '../../question/models/question_models.dart';

/// 관리자용 문의 목록 아이템
class AdminQuestionItem {
  final int id;
  final int memberId;
  final String memberNickname;
  final QuestionType type;
  final String title;
  final QuestionStatus status;
  final String questionNumber;
  final DateTime createdAt;

  const AdminQuestionItem({
    required this.id,
    required this.memberId,
    required this.memberNickname,
    required this.type,
    required this.title,
    required this.status,
    required this.questionNumber,
    required this.createdAt,
  });

  factory AdminQuestionItem.fromJson(Map<String, dynamic> json) {
    return AdminQuestionItem(
      id: json['id'] as int,
      memberId: json['memberId'] as int,
      memberNickname: json['memberNickname'] as String,
      type: QuestionType.fromString(json['type'] as String),
      title: json['title'] as String,
      status: QuestionStatus.fromString(json['status'] as String),
      questionNumber: json['questionNumber'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

/// 관리자용 문의 상세
class AdminQuestionDetail {
  final int id;
  final int memberId;
  final String memberNickname;
  final String memberEmail;
  final QuestionType type;
  final String title;
  final String content;
  final QuestionStatus status;
  final String? answer;
  final DateTime? answeredAt;
  final String questionNumber;
  final DateTime createdAt;

  const AdminQuestionDetail({
    required this.id,
    required this.memberId,
    required this.memberNickname,
    required this.memberEmail,
    required this.type,
    required this.title,
    required this.content,
    required this.status,
    this.answer,
    this.answeredAt,
    required this.questionNumber,
    required this.createdAt,
  });

  factory AdminQuestionDetail.fromJson(Map<String, dynamic> json) {
    return AdminQuestionDetail(
      id: json['id'] as int,
      memberId: json['memberId'] as int,
      memberNickname: json['memberNickname'] as String,
      memberEmail: json['memberEmail'] as String,
      type: QuestionType.fromString(json['type'] as String),
      title: json['title'] as String,
      content: json['content'] as String,
      status: QuestionStatus.fromString(json['status'] as String),
      answer: json['answer'] as String?,
      answeredAt: json['answeredAt'] != null
          ? DateTime.parse(json['answeredAt'] as String)
          : null,
      questionNumber: json['questionNumber'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  bool get hasAnswer => answer != null && answer!.isNotEmpty;
}

/// 문의 목록 응답
class AdminQuestionListResponse {
  final List<AdminQuestionItem> questions;
  final int totalCount;
  final int page;
  final int pageSize;

  const AdminQuestionListResponse({
    required this.questions,
    required this.totalCount,
    this.page = 0,
    this.pageSize = 20,
  });

  factory AdminQuestionListResponse.fromJson(Map<String, dynamic> json) {
    return AdminQuestionListResponse(
      questions: (json['questions'] as List)
          .map((e) => AdminQuestionItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: json['totalCount'] as int,
      page: json['page'] as int? ?? 0,
      pageSize: json['pageSize'] as int? ?? 20,
    );
  }

  factory AdminQuestionListResponse.empty() {
    return const AdminQuestionListResponse(
      questions: [],
      totalCount: 0,
    );
  }
}

/// 문의 답변 요청
class QuestionAnswerRequest {
  final int questionId;
  final String answer;

  const QuestionAnswerRequest({
    required this.questionId,
    required this.answer,
  });

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'answer': answer,
    };
  }

  String? validate() {
    if (answer.trim().isEmpty) {
      return '답변 내용을 입력해주세요';
    }
    if (answer.length > 2000) {
      return '답변은 2000자 이하여야 합니다';
    }
    return null;
  }
}
