/// 관리자 모델 테스트

import 'package:flutter_test/flutter_test.dart';
import 'package:hidi/features/management/models/admin_models.dart';
import 'package:hidi/features/management/models/admin_faq_models.dart';
import 'package:hidi/features/management/models/admin_question_models.dart';
import 'package:hidi/features/faq/models/faq_models.dart';

void main() {
  group('AdminStats', () {
    test('should create AdminStats with correct values', () {
      final stats = AdminStats(
        totalMembers: 100,
        todayNewMembers: 5,
        totalFaqs: 500,
        todayNewReports: 10,
        pendingReports: 3,
        unansweredQuestions: 7,
      );

      expect(stats.totalMembers, 100);
      expect(stats.todayNewMembers, 5);
      expect(stats.totalFaqs, 500);
      expect(stats.todayNewReports, 10);
      expect(stats.pendingReports, 3);
      expect(stats.unansweredQuestions, 7);
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
      expect(SuspensionDuration.values, contains(SuspensionDuration.days7));
      expect(SuspensionDuration.values, contains(SuspensionDuration.days30));
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
        postCount: 5,
        followerCount: 20,
        followingCount: 15,
        reportReceivedCount: 0,
        reportSentCount: 0,
        createdAt: DateTime(2024, 1, 1),
      );

      expect(member.id, 1);
      expect(member.email, 'test@example.com');
      expect(member.nickname, 'TestUser');
      expect(member.role, MemberRole.user);
      expect(member.status, MemberStatus.active);
      expect(member.profileImage, isNull);
    });

    test('should create AdminMemberInfo with all values', () {
      final member = AdminMemberInfo(
        id: 1,
        email: 'admin@example.com',
        nickname: 'Admin',
        profileImage: 'https://example.com/image.jpg',
        role: MemberRole.admin,
        status: MemberStatus.active,
        commentCount: 100,
        postCount: 50,
        followerCount: 200,
        followingCount: 100,
        reportReceivedCount: 2,
        reportSentCount: 1,
        createdAt: DateTime(2024, 1, 1),
      );

      expect(member.profileImage, 'https://example.com/image.jpg');
    });
  });

  group('MemberSanctionRequest', () {
    test('should create sanction request for suspend', () {
      final request = MemberSanctionRequest(
        memberId: 1,
        sanctionType: 'SUSPEND',
        duration: SuspensionDuration.days7,
        reason: 'Rule violation',
      );

      expect(request.memberId, 1);
      expect(request.sanctionType, 'SUSPEND');
      expect(request.duration, SuspensionDuration.days7);
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

      expect(request.validate(), '답변 내용을 입력해주세요');
    });

    test('validate should return null when answer is not empty', () {
      final request = QuestionAnswerRequest(
        questionId: 1,
        answer: 'Hi',
      );

      expect(request.validate(), isNull);
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
