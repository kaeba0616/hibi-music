/// F12 Management - 관리자용 신고 모델
/// 신고 관리에 사용되는 데이터 모델

import '../../report/models/report_models.dart';

/// 관리자용 신고 상세 정보
class AdminReportDetail {
  final int id;
  final int reporterId;
  final String reporterNickname;
  final ReportTargetType targetType;
  final int targetId;
  final ReportReason reason;
  final String? description;
  final ReportStatus status;
  final DateTime createdAt;
  final ReportTargetContent? targetContent;

  const AdminReportDetail({
    required this.id,
    required this.reporterId,
    required this.reporterNickname,
    required this.targetType,
    required this.targetId,
    required this.reason,
    this.description,
    required this.status,
    required this.createdAt,
    this.targetContent,
  });

  factory AdminReportDetail.fromJson(Map<String, dynamic> json) {
    return AdminReportDetail(
      id: json['id'] as int,
      reporterId: json['reporterId'] as int,
      reporterNickname: json['reporterNickname'] as String,
      targetType: ReportTargetType.fromCode(json['targetType'] as String),
      targetId: json['targetId'] as int,
      reason: ReportReason.fromCode(json['reason'] as String),
      description: json['description'] as String?,
      status: ReportStatus.fromCode(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      targetContent: json['targetContent'] != null
          ? ReportTargetContent.fromJson(json['targetContent'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// 신고 대상 콘텐츠 정보
class ReportTargetContent {
  final int id;
  final String type; // POST, COMMENT, MEMBER
  final String? content; // 게시글/댓글 내용
  final String? authorNickname;
  final int? authorId;
  final String? profileImage; // 사용자 신고 시
  final DateTime? createdAt;

  const ReportTargetContent({
    required this.id,
    required this.type,
    this.content,
    this.authorNickname,
    this.authorId,
    this.profileImage,
    this.createdAt,
  });

  factory ReportTargetContent.fromJson(Map<String, dynamic> json) {
    return ReportTargetContent(
      id: json['id'] as int,
      type: json['type'] as String,
      content: json['content'] as String?,
      authorNickname: json['authorNickname'] as String?,
      authorId: json['authorId'] as int?,
      profileImage: json['profileImage'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }
}

/// 관리자용 신고 목록 아이템
class AdminReportItem {
  final int id;
  final String reporterNickname;
  final ReportTargetType targetType;
  final int targetId;
  final ReportReason reason;
  final ReportStatus status;
  final DateTime createdAt;

  const AdminReportItem({
    required this.id,
    required this.reporterNickname,
    required this.targetType,
    required this.targetId,
    required this.reason,
    required this.status,
    required this.createdAt,
  });

  factory AdminReportItem.fromJson(Map<String, dynamic> json) {
    return AdminReportItem(
      id: json['id'] as int,
      reporterNickname: json['reporterNickname'] as String,
      targetType: ReportTargetType.fromCode(json['targetType'] as String),
      targetId: json['targetId'] as int,
      reason: ReportReason.fromCode(json['reason'] as String),
      status: ReportStatus.fromCode(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  String get targetDescription {
    switch (targetType) {
      case ReportTargetType.post:
        return '게시글 #$targetId 신고';
      case ReportTargetType.comment:
        return '댓글 #$targetId 신고';
      case ReportTargetType.member:
        return '사용자 신고';
    }
  }
}

/// 신고 목록 응답
class AdminReportListResponse {
  final List<AdminReportItem> reports;
  final int totalCount;
  final int page;
  final int pageSize;

  const AdminReportListResponse({
    required this.reports,
    required this.totalCount,
    this.page = 0,
    this.pageSize = 20,
  });

  factory AdminReportListResponse.fromJson(Map<String, dynamic> json) {
    return AdminReportListResponse(
      reports: (json['reports'] as List)
          .map((e) => AdminReportItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: json['totalCount'] as int,
      page: json['page'] as int? ?? 0,
      pageSize: json['pageSize'] as int? ?? 20,
    );
  }

  factory AdminReportListResponse.empty() {
    return const AdminReportListResponse(
      reports: [],
      totalCount: 0,
    );
  }
}

/// 신고 처리 액션
enum ReportAction {
  deleteContent('DELETE_CONTENT', '콘텐츠 삭제'),
  warn('WARN', '경고'),
  dismiss('DISMISS', '기각');

  const ReportAction(this.code, this.displayName);
  final String code;
  final String displayName;
}

/// 신고 처리 요청
class ReportActionRequest {
  final int reportId;
  final ReportAction action;
  final String? note;

  const ReportActionRequest({
    required this.reportId,
    required this.action,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'reportId': reportId,
      'action': action.code,
      if (note != null && note!.isNotEmpty) 'note': note,
    };
  }
}
