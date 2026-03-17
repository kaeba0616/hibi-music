import 'package:flutter_test/flutter_test.dart';
import 'package:hidi/features/report/models/report_models.dart';
import 'package:hidi/features/report/viewmodels/report_viewmodel.dart';

void main() {
  group('ReportFormState', () {
    test('initial state has no selected reason', () {
      const state = ReportFormState(
        targetType: ReportTargetType.post,
        targetId: 42,
      );

      expect(state.selectedReason, isNull);
      expect(state.description, isEmpty);
      expect(state.isSubmitting, isFalse);
      expect(state.isSuccess, isFalse);
      expect(state.errorMessage, isNull);
      expect(state.isDuplicate, isFalse);
    });

    test('canSubmit is false when no reason selected', () {
      const state = ReportFormState(
        targetType: ReportTargetType.post,
        targetId: 42,
      );

      expect(state.canSubmit, isFalse);
    });

    test('canSubmit is true when reason is selected', () {
      const state = ReportFormState(
        targetType: ReportTargetType.post,
        targetId: 42,
        selectedReason: ReportReason.spam,
      );

      expect(state.canSubmit, isTrue);
    });

    test('canSubmit is false when submitting', () {
      const state = ReportFormState(
        targetType: ReportTargetType.post,
        targetId: 42,
        selectedReason: ReportReason.spam,
        isSubmitting: true,
      );

      expect(state.canSubmit, isFalse);
    });

    test('canSubmit is false when already successful', () {
      const state = ReportFormState(
        targetType: ReportTargetType.post,
        targetId: 42,
        selectedReason: ReportReason.spam,
        isSuccess: true,
      );

      expect(state.canSubmit, isFalse);
    });

    test('canSubmit is false when duplicate', () {
      const state = ReportFormState(
        targetType: ReportTargetType.post,
        targetId: 42,
        selectedReason: ReportReason.spam,
        isDuplicate: true,
      );

      expect(state.canSubmit, isFalse);
    });

    test('showDescriptionField is true only for OTHER reason', () {
      const stateSpam = ReportFormState(
        targetType: ReportTargetType.post,
        targetId: 42,
        selectedReason: ReportReason.spam,
      );
      expect(stateSpam.showDescriptionField, isFalse);

      const stateOther = ReportFormState(
        targetType: ReportTargetType.post,
        targetId: 42,
        selectedReason: ReportReason.other,
      );
      expect(stateOther.showDescriptionField, isTrue);
    });

    test('copyWith updates values correctly', () {
      const original = ReportFormState(
        targetType: ReportTargetType.post,
        targetId: 42,
      );

      final updated = original.copyWith(
        selectedReason: ReportReason.abuse,
        description: 'Test description',
      );

      expect(updated.selectedReason, ReportReason.abuse);
      expect(updated.description, 'Test description');
      expect(updated.targetType, ReportTargetType.post);
      expect(updated.targetId, 42);
    });

    test('copyWith can clear selectedReason', () {
      const original = ReportFormState(
        targetType: ReportTargetType.post,
        targetId: 42,
        selectedReason: ReportReason.spam,
      );

      final updated = original.copyWith(clearSelectedReason: true);

      expect(updated.selectedReason, isNull);
    });

    test('copyWith can clear errorMessage', () {
      const original = ReportFormState(
        targetType: ReportTargetType.post,
        targetId: 42,
        errorMessage: 'Error',
      );

      final updated = original.copyWith(clearErrorMessage: true);

      expect(updated.errorMessage, isNull);
    });
  });

  group('getReportTargetDescription', () {
    test('returns correct description for POST', () {
      expect(
        getReportTargetDescription(ReportTargetType.post),
        '이 게시글을 신고하는 이유를 선택해주세요',
      );
    });

    test('returns correct description for COMMENT', () {
      expect(
        getReportTargetDescription(ReportTargetType.comment),
        '이 댓글을 신고하는 이유를 선택해주세요',
      );
    });

    test('returns correct description for MEMBER', () {
      expect(
        getReportTargetDescription(ReportTargetType.member),
        '이 사용자를 신고하는 이유를 선택해주세요',
      );
    });
  });
}
