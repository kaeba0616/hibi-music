/// F12 Management Mock 데이터
/// 관리자 기능 테스트용 Mock 데이터

import '../../faq/models/faq_models.dart';
import '../../question/models/question_models.dart';
import '../../report/models/report_models.dart';
import '../models/admin_models.dart';
import '../models/admin_report_models.dart';
import '../models/admin_question_models.dart';
import '../models/admin_faq_models.dart';

/// Mock 대시보드 통계
final mockAdminStats = AdminStats(
  pendingReports: 15,
  unansweredQuestions: 8,
  totalMembers: 1234,
  totalFaqs: 14,
  todayNewMembers: 5,
  todayNewReports: 3,
);

/// Mock 신고 목록
final List<AdminReportItem> mockAdminReports = [
  AdminReportItem(
    id: 1,
    reporterNickname: 'user123',
    targetType: ReportTargetType.post,
    targetId: 42,
    reason: ReportReason.spam,
    status: ReportStatus.pending,
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  AdminReportItem(
    id: 2,
    reporterNickname: 'fan_jpop',
    targetType: ReportTargetType.comment,
    targetId: 156,
    reason: ReportReason.abuse,
    status: ReportStatus.pending,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
  AdminReportItem(
    id: 3,
    reporterNickname: 'music_lover',
    targetType: ReportTargetType.member,
    targetId: 5,
    reason: ReportReason.inappropriate,
    status: ReportStatus.pending,
    createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 5)),
  ),
  AdminReportItem(
    id: 4,
    reporterNickname: 'good_user',
    targetType: ReportTargetType.post,
    targetId: 78,
    reason: ReportReason.copyright,
    status: ReportStatus.resolved,
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
  ),
  AdminReportItem(
    id: 5,
    reporterNickname: 'jpop_fan99',
    targetType: ReportTargetType.comment,
    targetId: 203,
    reason: ReportReason.other,
    status: ReportStatus.dismissed,
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
  ),
];

/// Mock 신고 상세
AdminReportDetail getMockReportDetail(int id) {
  final item = mockAdminReports.firstWhere(
    (r) => r.id == id,
    orElse: () => mockAdminReports.first,
  );

  return AdminReportDetail(
    id: item.id,
    reporterId: 10,
    reporterNickname: item.reporterNickname,
    targetType: item.targetType,
    targetId: item.targetId,
    reason: item.reason,
    description: item.reason == ReportReason.other
        ? '특정 아티스트를 지속적으로 비하하는 내용입니다.'
        : null,
    status: item.status,
    createdAt: item.createdAt,
    targetContent: ReportTargetContent(
      id: item.targetId,
      type: item.targetType.code,
      content: item.targetType == ReportTargetType.member
          ? null
          : '오늘의 JPOP 추천합니다~ [스팸 링크가 포함된 부적절한 내용]',
      authorNickname: item.targetType == ReportTargetType.member
          ? 'bad_user'
          : 'spammer',
      authorId: item.targetType == ReportTargetType.member ? item.targetId : 99,
      profileImage: null,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  );
}

/// Mock 문의 목록
final List<AdminQuestionItem> mockAdminQuestions = [
  AdminQuestionItem(
    id: 1,
    memberId: 10,
    memberNickname: 'user123',
    type: QuestionType.account,
    title: '로그인이 안 돼요',
    status: QuestionStatus.received,
    questionNumber: 'QT-20260203-0001',
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  AdminQuestionItem(
    id: 2,
    memberId: 11,
    memberNickname: 'fan_jpop',
    type: QuestionType.service,
    title: '추천곡이 안 나와요',
    status: QuestionStatus.processing,
    questionNumber: 'QT-20260202-0005',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
  AdminQuestionItem(
    id: 3,
    memberId: 12,
    memberNickname: 'dev_user',
    type: QuestionType.bug,
    title: '앱이 갑자기 종료됩니다',
    status: QuestionStatus.answered,
    questionNumber: 'QT-20260201-0003',
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
  ),
  AdminQuestionItem(
    id: 4,
    memberId: 13,
    memberNickname: 'music_lover',
    type: QuestionType.feature,
    title: '플레이리스트 기능 추가해주세요',
    status: QuestionStatus.received,
    questionNumber: 'QT-20260131-0002',
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
  ),
  AdminQuestionItem(
    id: 5,
    memberId: 14,
    memberNickname: 'new_user',
    type: QuestionType.other,
    title: '프리미엄 서비스는 언제 출시되나요?',
    status: QuestionStatus.answered,
    questionNumber: 'QT-20260130-0001',
    createdAt: DateTime.now().subtract(const Duration(days: 4)),
  ),
];

/// Mock 문의 상세
AdminQuestionDetail getMockQuestionDetail(int id) {
  final item = mockAdminQuestions.firstWhere(
    (q) => q.id == id,
    orElse: () => mockAdminQuestions.first,
  );

  return AdminQuestionDetail(
    id: item.id,
    memberId: item.memberId,
    memberNickname: item.memberNickname,
    memberEmail: '${item.memberNickname}@example.com',
    type: item.type,
    title: item.title,
    content: '앱을 다시 설치해도 로그인이 안 됩니다.\n이메일은 test@example.com 입니다.\n비밀번호 재설정도 시도해봤는데 안 되네요.',
    status: item.status,
    answer: item.status == QuestionStatus.answered
        ? '안녕하세요, hibi입니다.\n\n불편을 드려 죄송합니다.\n비밀번호 재설정 링크를 다시 전송해드렸습니다.\n메일함을 확인해주세요.\n\n감사합니다.'
        : null,
    answeredAt: item.status == QuestionStatus.answered
        ? item.createdAt.add(const Duration(hours: 5))
        : null,
    questionNumber: item.questionNumber,
    createdAt: item.createdAt,
  );
}

/// Mock FAQ 목록
final List<AdminFAQItem> mockAdminFaqs = [
  AdminFAQItem(
    id: 1,
    category: FAQCategory.account,
    question: '회원가입은 어떻게 하나요?',
    answer: '1. 앱을 다운로드합니다.\n2. 이메일과 비밀번호를 입력합니다.\n3. 가입 완료!',
    displayOrder: 1,
    isPublished: true,
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
  ),
  AdminFAQItem(
    id: 2,
    category: FAQCategory.account,
    question: '비밀번호를 잊어버렸어요',
    answer: '로그인 화면에서 "비밀번호 찾기"를 눌러주세요. 등록된 이메일로 재설정 링크가 발송됩니다.',
    displayOrder: 2,
    isPublished: true,
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
  ),
  AdminFAQItem(
    id: 3,
    category: FAQCategory.service,
    question: '추천곡은 어떻게 선정되나요?',
    answer: 'hibi 음악 큐레이터가 매일 엄선한 JPOP 곡을 추천해드립니다.',
    displayOrder: 1,
    isPublished: true,
    createdAt: DateTime.now().subtract(const Duration(days: 25)),
  ),
  AdminFAQItem(
    id: 4,
    category: FAQCategory.service,
    question: '과거 추천곡은 어디서 볼 수 있나요?',
    answer: '캘린더 탭에서 과거 추천곡을 확인할 수 있습니다.',
    displayOrder: 2,
    isPublished: true,
    createdAt: DateTime.now().subtract(const Duration(days: 25)),
  ),
  AdminFAQItem(
    id: 5,
    category: FAQCategory.community,
    question: '게시글은 어떻게 작성하나요?',
    answer: '피드 탭에서 + 버튼을 눌러 게시글을 작성할 수 있습니다. 텍스트와 이미지(최대 4장)를 첨부할 수 있습니다.',
    displayOrder: 1,
    isPublished: true,
    createdAt: DateTime.now().subtract(const Duration(days: 20)),
  ),
  AdminFAQItem(
    id: 6,
    category: FAQCategory.other,
    question: '문의는 어디서 하나요?',
    answer: '설정 > 문의하기 메뉴에서 문의를 남겨주시면 운영팀이 확인 후 답변드립니다.',
    displayOrder: 1,
    isPublished: true,
    createdAt: DateTime.now().subtract(const Duration(days: 15)),
  ),
];

/// Mock 사용자 목록
final List<AdminMemberInfo> mockAdminMembers = [
  AdminMemberInfo(
    id: 1,
    email: 'user123@example.com',
    nickname: 'user123',
    profileImage: null,
    role: MemberRole.user,
    status: MemberStatus.active,
    createdAt: DateTime(2025, 12, 1),
    postCount: 15,
    commentCount: 42,
    followerCount: 23,
    followingCount: 18,
    reportReceivedCount: 0,
    reportSentCount: 2,
  ),
  AdminMemberInfo(
    id: 2,
    email: 'fan_jpop@example.com',
    nickname: 'fan_jpop',
    profileImage: null,
    role: MemberRole.user,
    status: MemberStatus.active,
    createdAt: DateTime(2025, 11, 15),
    postCount: 42,
    commentCount: 128,
    followerCount: 156,
    followingCount: 89,
    reportReceivedCount: 1,
    reportSentCount: 5,
  ),
  AdminMemberInfo(
    id: 3,
    email: 'bad_user@example.com',
    nickname: 'bad_user',
    profileImage: null,
    role: MemberRole.user,
    status: MemberStatus.suspended,
    createdAt: DateTime(2025, 10, 1),
    postCount: 5,
    commentCount: 12,
    followerCount: 2,
    followingCount: 10,
    reportReceivedCount: 8,
    reportSentCount: 0,
  ),
  AdminMemberInfo(
    id: 4,
    email: 'music_lover@example.com',
    nickname: 'music_lover',
    profileImage: null,
    role: MemberRole.user,
    status: MemberStatus.active,
    createdAt: DateTime(2025, 9, 20),
    postCount: 28,
    commentCount: 95,
    followerCount: 67,
    followingCount: 45,
    reportReceivedCount: 0,
    reportSentCount: 1,
  ),
  AdminMemberInfo(
    id: 5,
    email: 'admin@hibi.app',
    nickname: 'hibi_admin',
    profileImage: null,
    role: MemberRole.admin,
    status: MemberStatus.active,
    createdAt: DateTime(2025, 1, 1),
    postCount: 0,
    commentCount: 0,
    followerCount: 0,
    followingCount: 0,
    reportReceivedCount: 0,
    reportSentCount: 0,
  ),
];

/// Mock 사용자 상세
AdminMemberInfo getMockMemberDetail(int id) {
  return mockAdminMembers.firstWhere(
    (m) => m.id == id,
    orElse: () => mockAdminMembers.first,
  );
}
