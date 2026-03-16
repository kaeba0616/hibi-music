/// 관리자 모델 테스트

import 'package:flutter_test/flutter_test.dart';
import 'package:hibi_front/features/management/models/admin_models.dart';
import 'package:hibi_front/features/management/models/admin_faq_models.dart';
import 'package:hibi_front/features/management/models/admin_question_models.dart';
import 'package:hibi_front/features/faq/models/faq_models.dart';

void main() {
  group('AdminStats', () {
    test('should create AdminStats with correct values', () {
      final stats = AdminStats(
        totalMembers: 100,
        todayNewMembers: 5,
        totalSongs: 500,
        todayNewSongs: 10,
        pendingReports: 3,
        pendingQuestions: 7,
      );

      expect(stats.totalMembers, 100);
      expect(stats.todayNewMembers, 5);
      expect(stats.totalSongs, 500);
      expect(stats.todayNewSongs, 10);
      expect(stats.pendingReports, 3);
      expect(stats.pendingQuestions, 7);
    });
  });

  group('MemberStatus', () {
    test('should have all expected values', () {
      expect(MemberStatus.values, contains(MemberStatus.active));
      expect(MemberStatus.values, contains(MemberStatus.suspended));
      expect(MemberStatus.values, contains(MemberStatus.banned));
    });
  });

  group('MemberRole', () {
    test('should have all expected values', () {
      expect(MemberRole.values, contains(MemberRole.user));
      expect(MemberRole.values, contains(MemberRole.admin));
    });
  });

  group('SuspensionDuration', () {
    test('should have all expected values', () {
      expect(SuspensionDuration.values, contains(SuspensionDuration.oneDay));
      expect(SuspensionDuration.values, contains(SuspensionDuration.threeDays));
      expect(SuspensionDuration.values, contains(SuspensionDuration.oneWeek));
      expect(SuspensionDuration.values, contains(SuspensionDuration.oneMonth));
      expect(SuspensionDuration.values, contains(SuspensionDuration.permanent));
    });
  });

  group('AdminMemberInfo', () {
    test('should create AdminMemberInfo with minimal values', () {
      final member = AdminMemberInfo(
        id: 1,
        email: 'test@example.com',
        nickname: 'TestUser',
        role: MemberRole.user,
        status: MemberStatus.active,
        commentCount: 10,
        likeCount: 50,
        reportCount: 0,
        createdAt: DateTime(2024, 1, 1),
      );

      expect(member.id, 1);
      expect(member.email, 'test@example.com');
      expect(member.nickname, 'TestUser');
      expect(member.role, MemberRole.user);
      expect(member.status, MemberStatus.active);
      expect(member.profileImageUrl, isNull);
      expect(member.lastLoginAt, isNull);
      expect(member.suspendedUntil, isNull);
    });

    test('should create AdminMemberInfo with all values', () {
      final now = DateTime.now();
      final member = AdminMemberInfo(
        id: 1,
        email: 'admin@example.com',
        nickname: 'Admin',
        profileImageUrl: 'https://example.com/image.jpg',
        role: MemberRole.admin,
        status: MemberStatus.active,
        commentCount: 100,
        likeCount: 500,
        reportCount: 2,
        lastLoginAt: now,
        createdAt: DateTime(2024, 1, 1),
      );

      expect(member.profileImageUrl, 'https://example.com/image.jpg');
      expect(member.lastLoginAt, now);
    });
  });

  group('MemberSanctionRequest', () {
    test('should create sanction request for suspend', () {
      final request = MemberSanctionRequest(
        memberId: 1,
        sanctionType: 'SUSPEND',
        duration: SuspensionDuration.oneWeek,
        reason: 'Rule violation',
      );

      expect(request.memberId, 1);
      expect(request.sanctionType, 'SUSPEND');
      expect(request.duration, SuspensionDuration.oneWeek);
      expect(request.reason, 'Rule violation');
    });

    test('should create sanction request for ban without duration', () {
      final request = MemberSanctionRequest(
        memberId: 1,
        sanctionType: 'BAN',
        reason: 'Serious violation',
      );

      expect(request.sanctionType, 'BAN');
      expect(request.duration, isNull);
    });
  });

  group('FAQSaveRequest', () {
    test('isCreate should return true when id is null', () {
      final request = FAQSaveRequest(
        category: FAQCategory.account,
        question: 'How to reset password?',
        answer: 'Click the reset button.',
        displayOrder: 1,
        isPublished: true,
      );

      expect(request.isCreate, true);
      expect(request.isUpdate, false);
    });

    test('isUpdate should return true when id is not null', () {
      final request = FAQSaveRequest(
        id: 1,
        category: FAQCategory.account,
        question: 'How to reset password?',
        answer: 'Click the reset button.',
        displayOrder: 1,
        isPublished: true,
      );

      expect(request.isCreate, false);
      expect(request.isUpdate, true);
    });

    test('validate should return error when question is empty', () {
      final request = FAQSaveRequest(
        category: FAQCategory.account,
        question: '',
        answer: 'Answer',
        displayOrder: 1,
        isPublished: true,
      );

      expect(request.validate(), '질문을 입력해주세요');
    });

    test('validate should return error when answer is empty', () {
      final request = FAQSaveRequest(
        category: FAQCategory.account,
        question: 'Question?',
        answer: '',
        displayOrder: 1,
        isPublished: true,
      );

      expect(request.validate(), '답변을 입력해주세요');
    });

    test('validate should return null when all fields are valid', () {
      final request = FAQSaveRequest(
        category: FAQCategory.account,
        question: 'Question?',
        answer: 'Answer',
        displayOrder: 1,
        isPublished: true,
      );

      expect(request.validate(), isNull);
    });
  });

  group('QuestionAnswerRequest', () {
    test('validate should return error when answer is empty', () {
      final request = QuestionAnswerRequest(
        questionId: 1,
        answer: '',
      );

      expect(request.validate(), '답변을 입력해주세요');
    });

    test('validate should return error when answer is too short', () {
      final request = QuestionAnswerRequest(
        questionId: 1,
        answer: 'Hi',
      );

      expect(request.validate(), '답변은 최소 10자 이상이어야 합니다');
    });

    test('validate should return null when answer is valid', () {
      final request = QuestionAnswerRequest(
        questionId: 1,
        answer: 'This is a valid answer with enough characters.',
      );

      expect(request.validate(), isNull);
    });
  });
}
