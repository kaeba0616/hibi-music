/// F11 Report Mock 데이터
/// 테스트 및 개발용 Mock 신고 데이터

import '../models/report_models.dart';

/// Mock 신고 데이터 (5개 샘플)
final List<Report> mockReports = [
  Report(
    id: 1,
    reporterId: 1,
    targetType: ReportTargetType.post,
    targetId: 42,
    reason: ReportReason.spam,
    description: null,
    status: ReportStatus.pending,
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  Report(
    id: 2,
    reporterId: 1,
    targetType: ReportTargetType.comment,
    targetId: 156,
    reason: ReportReason.abuse,
    description: null,
    status: ReportStatus.reviewed,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
  Report(
    id: 3,
    reporterId: 2,
    targetType: ReportTargetType.member,
    targetId: 5,
    reason: ReportReason.inappropriate,
    description: null,
    status: ReportStatus.resolved,
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
  ),
  Report(
    id: 4,
    reporterId: 3,
    targetType: ReportTargetType.post,
    targetId: 78,
    reason: ReportReason.copyright,
    description: null,
    status: ReportStatus.dismissed,
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
  ),
  Report(
    id: 5,
    reporterId: 1,
    targetType: ReportTargetType.comment,
    targetId: 203,
    reason: ReportReason.other,
    description: '특정 아티스트를 지속적으로 비하하는 내용입니다.',
    status: ReportStatus.pending,
    createdAt: DateTime.now().subtract(const Duration(hours: 6)),
  ),
];

/// 이미 신고한 대상 목록 (중복 신고 체크용)
final Set<String> mockReportedTargets = {
  'POST_42', // targetType_targetId 형식
  'COMMENT_156',
};

/// Mock 신고 생성 결과
class MockReportResult {
  final bool success;
  final String? errorCode;
  final Report? report;

  const MockReportResult({
    required this.success,
    this.errorCode,
    this.report,
  });
}

/// Mock 신고 생성 함수
MockReportResult createMockReport(ReportCreateRequest request, int reporterId) {
  final targetKey = '${request.targetType.code}_${request.targetId}';

  // 중복 신고 체크
  if (mockReportedTargets.contains(targetKey)) {
    return const MockReportResult(
      success: false,
      errorCode: 'DUPLICATE_REPORT',
    );
  }

  // 신고 생성
  final newReport = Report(
    id: mockReports.length + 1,
    reporterId: reporterId,
    targetType: request.targetType,
    targetId: request.targetId,
    reason: request.reason,
    description: request.description,
    status: ReportStatus.pending,
    createdAt: DateTime.now(),
  );

  return MockReportResult(
    success: true,
    report: newReport,
  );
}
