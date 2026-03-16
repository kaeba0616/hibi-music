/// F11 Report 모델 정의
/// 신고 기능에 사용되는 데이터 모델

/// 신고 대상 유형
enum ReportTargetType {
  post('POST', '게시글'),
  comment('COMMENT', '댓글'),
  member('MEMBER', '사용자');

  const ReportTargetType(this.code, this.displayName);
  final String code;
  final String displayName;

  static ReportTargetType fromCode(String code) {
    return ReportTargetType.values.firstWhere(
      (e) => e.code == code,
      orElse: () => ReportTargetType.post,
    );
  }
}

/// 신고 사유
enum ReportReason {
  spam('SPAM', '스팸/광고'),
  abuse('ABUSE', '욕설/비방'),
  inappropriate('INAPPROPRIATE', '불쾌한 내용'),
  copyright('COPYRIGHT', '저작권 침해'),
  other('OTHER', '기타');

  const ReportReason(this.code, this.displayName);
  final String code;
  final String displayName;

  static ReportReason fromCode(String code) {
    return ReportReason.values.firstWhere(
      (e) => e.code == code,
      orElse: () => ReportReason.other,
    );
  }
}

/// 신고 처리 상태
enum ReportStatus {
  pending('PENDING', '대기중'),
  reviewed('REVIEWED', '검토됨'),
  resolved('RESOLVED', '처리완료'),
  dismissed('DISMISSED', '기각');

  const ReportStatus(this.code, this.displayName);
  final String code;
  final String displayName;

  static ReportStatus fromCode(String code) {
    return ReportStatus.values.firstWhere(
      (e) => e.code == code,
      orElse: () => ReportStatus.pending,
    );
  }
}

/// 신고 모델
class Report {
  final int id;
  final int reporterId;
  final ReportTargetType targetType;
  final int targetId;
  final ReportReason reason;
  final String? description;
  final ReportStatus status;
  final DateTime createdAt;

  const Report({
    required this.id,
    required this.reporterId,
    required this.targetType,
    required this.targetId,
    required this.reason,
    this.description,
    required this.status,
    required this.createdAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] as int,
      reporterId: json['reporterId'] as int,
      targetType: ReportTargetType.fromCode(json['targetType'] as String),
      targetId: json['targetId'] as int,
      reason: ReportReason.fromCode(json['reason'] as String),
      description: json['description'] as String?,
      status: ReportStatus.fromCode(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reporterId': reporterId,
      'targetType': targetType.code,
      'targetId': targetId,
      'reason': reason.code,
      'description': description,
      'status': status.code,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

/// 신고 생성 요청
class ReportCreateRequest {
  final ReportTargetType targetType;
  final int targetId;
  final ReportReason reason;
  final String? description;

  const ReportCreateRequest({
    required this.targetType,
    required this.targetId,
    required this.reason,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'targetType': targetType.code,
      'targetId': targetId,
      'reason': reason.code,
      if (description != null && description!.isNotEmpty)
        'description': description,
    };
  }
}
