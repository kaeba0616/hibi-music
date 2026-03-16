import 'package:flutter_test/flutter_test.dart';
import 'package:hibi_front/features/report/models/report_models.dart';

void main() {
  group('ReportTargetType', () {
    test('fromCode returns correct enum value', () {
      expect(ReportTargetType.fromCode('POST'), ReportTargetType.post);
      expect(ReportTargetType.fromCode('COMMENT'), ReportTargetType.comment);
      expect(ReportTargetType.fromCode('MEMBER'), ReportTargetType.member);
    });

    test('fromCode returns default for unknown code', () {
      expect(ReportTargetType.fromCode('UNKNOWN'), ReportTargetType.post);
    });

    test('displayName returns Korean text', () {
      expect(ReportTargetType.post.displayName, '게시글');
      expect(ReportTargetType.comment.displayName, '댓글');
      expect(ReportTargetType.member.displayName, '사용자');
    });
  });

  group('ReportReason', () {
    test('fromCode returns correct enum value', () {
      expect(ReportReason.fromCode('SPAM'), ReportReason.spam);
      expect(ReportReason.fromCode('ABUSE'), ReportReason.abuse);
      expect(ReportReason.fromCode('INAPPROPRIATE'), ReportReason.inappropriate);
      expect(ReportReason.fromCode('COPYRIGHT'), ReportReason.copyright);
      expect(ReportReason.fromCode('OTHER'), ReportReason.other);
    });

    test('fromCode returns default for unknown code', () {
      expect(ReportReason.fromCode('UNKNOWN'), ReportReason.other);
    });

    test('displayName returns Korean text', () {
      expect(ReportReason.spam.displayName, '스팸/광고');
      expect(ReportReason.abuse.displayName, '욕설/비방');
      expect(ReportReason.inappropriate.displayName, '불쾌한 내용');
      expect(ReportReason.copyright.displayName, '저작권 침해');
      expect(ReportReason.other.displayName, '기타');
    });
  });

  group('ReportStatus', () {
    test('fromCode returns correct enum value', () {
      expect(ReportStatus.fromCode('PENDING'), ReportStatus.pending);
      expect(ReportStatus.fromCode('REVIEWED'), ReportStatus.reviewed);
      expect(ReportStatus.fromCode('RESOLVED'), ReportStatus.resolved);
      expect(ReportStatus.fromCode('DISMISSED'), ReportStatus.dismissed);
    });

    test('fromCode returns default for unknown code', () {
      expect(ReportStatus.fromCode('UNKNOWN'), ReportStatus.pending);
    });
  });

  group('Report', () {
    test('fromJson creates Report correctly', () {
      final json = {
        'id': 1,
        'reporterId': 10,
        'targetType': 'POST',
        'targetId': 42,
        'reason': 'SPAM',
        'description': null,
        'status': 'PENDING',
        'createdAt': '2024-01-15T10:30:00',
      };

      final report = Report.fromJson(json);

      expect(report.id, 1);
      expect(report.reporterId, 10);
      expect(report.targetType, ReportTargetType.post);
      expect(report.targetId, 42);
      expect(report.reason, ReportReason.spam);
      expect(report.description, isNull);
      expect(report.status, ReportStatus.pending);
    });

    test('fromJson with description', () {
      final json = {
        'id': 2,
        'reporterId': 10,
        'targetType': 'COMMENT',
        'targetId': 100,
        'reason': 'OTHER',
        'description': '부적절한 내용입니다',
        'status': 'REVIEWED',
        'createdAt': '2024-01-15T10:30:00',
      };

      final report = Report.fromJson(json);

      expect(report.reason, ReportReason.other);
      expect(report.description, '부적절한 내용입니다');
    });

    test('toJson converts Report to Map', () {
      final report = Report(
        id: 1,
        reporterId: 10,
        targetType: ReportTargetType.post,
        targetId: 42,
        reason: ReportReason.spam,
        description: null,
        status: ReportStatus.pending,
        createdAt: DateTime(2024, 1, 15, 10, 30),
      );

      final json = report.toJson();

      expect(json['id'], 1);
      expect(json['reporterId'], 10);
      expect(json['targetType'], 'POST');
      expect(json['targetId'], 42);
      expect(json['reason'], 'SPAM');
      expect(json['status'], 'PENDING');
    });
  });

  group('ReportCreateRequest', () {
    test('toJson without description', () {
      final request = ReportCreateRequest(
        targetType: ReportTargetType.post,
        targetId: 42,
        reason: ReportReason.spam,
      );

      final json = request.toJson();

      expect(json['targetType'], 'POST');
      expect(json['targetId'], 42);
      expect(json['reason'], 'SPAM');
      expect(json.containsKey('description'), isFalse);
    });

    test('toJson with description', () {
      final request = ReportCreateRequest(
        targetType: ReportTargetType.comment,
        targetId: 100,
        reason: ReportReason.other,
        description: '기타 사유 설명',
      );

      final json = request.toJson();

      expect(json['targetType'], 'COMMENT');
      expect(json['targetId'], 100);
      expect(json['reason'], 'OTHER');
      expect(json['description'], '기타 사유 설명');
    });

    test('toJson excludes empty description', () {
      final request = ReportCreateRequest(
        targetType: ReportTargetType.member,
        targetId: 5,
        reason: ReportReason.abuse,
        description: '',
      );

      final json = request.toJson();

      expect(json.containsKey('description'), isFalse);
    });
  });
}
