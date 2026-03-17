import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidi/features/report/models/report_models.dart';
import 'package:hidi/features/report/views/report_bottom_sheet.dart';

void main() {
  Widget createTestWidget({
    required ReportTargetType targetType,
    required int targetId,
  }) {
    return ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: ReportBottomSheet(
            targetType: targetType,
            targetId: targetId,
          ),
        ),
      ),
    );
  }

  group('ReportBottomSheet', () {
    testWidgets('displays title and description', (tester) async {
      await tester.pumpWidget(createTestWidget(
        targetType: ReportTargetType.post,
        targetId: 42,
      ));

      // '신고하기' appears both as title and submit button
      expect(find.text('신고하기'), findsNWidgets(2));
      expect(
        find.text('이 게시글을 신고하는 이유를 선택해주세요'),
        findsOneWidget,
      );
    });

    testWidgets('displays all report reasons', (tester) async {
      await tester.pumpWidget(createTestWidget(
        targetType: ReportTargetType.post,
        targetId: 42,
      ));

      expect(find.text('스팸/광고'), findsOneWidget);
      expect(find.text('욕설/비방'), findsOneWidget);
      expect(find.text('불쾌한 내용'), findsOneWidget);
      expect(find.text('저작권 침해'), findsOneWidget);
      expect(find.text('기타'), findsOneWidget);
    });

    testWidgets('submit button is disabled initially', (tester) async {
      await tester.pumpWidget(createTestWidget(
        targetType: ReportTargetType.post,
        targetId: 42,
      ));

      final button = find.widgetWithText(ElevatedButton, '신고하기');
      expect(button, findsOneWidget);

      final elevatedButton = tester.widget<ElevatedButton>(button);
      expect(elevatedButton.onPressed, isNull);
    });

    testWidgets('selecting reason enables submit button', (tester) async {
      await tester.pumpWidget(createTestWidget(
        targetType: ReportTargetType.post,
        targetId: 42,
      ));

      // Tap on a reason
      await tester.tap(find.text('스팸/광고'));
      await tester.pumpAndSettle();

      final button = find.widgetWithText(ElevatedButton, '신고하기');
      final elevatedButton = tester.widget<ElevatedButton>(button);
      expect(elevatedButton.onPressed, isNotNull);
    });

    testWidgets('shows description field when OTHER is selected',
        (tester) async {
      await tester.pumpWidget(createTestWidget(
        targetType: ReportTargetType.post,
        targetId: 42,
      ));

      // Initially no description field
      expect(find.text('상세 내용 (선택)'), findsNothing);

      // Select "기타"
      await tester.tap(find.text('기타'));
      await tester.pumpAndSettle();

      // Description field should appear
      expect(find.text('상세 내용 (선택)'), findsOneWidget);
    });

    testWidgets('hides description field when other reason is selected',
        (tester) async {
      await tester.pumpWidget(createTestWidget(
        targetType: ReportTargetType.post,
        targetId: 42,
      ));

      // Select "기타" first
      await tester.tap(find.text('기타'));
      await tester.pumpAndSettle();
      expect(find.text('상세 내용 (선택)'), findsOneWidget);

      // Select different reason
      await tester.tap(find.text('스팸/광고'));
      await tester.pumpAndSettle();

      // Description field should be hidden
      expect(find.text('상세 내용 (선택)'), findsNothing);
    });

    testWidgets('displays correct description for COMMENT', (tester) async {
      await tester.pumpWidget(createTestWidget(
        targetType: ReportTargetType.comment,
        targetId: 100,
      ));

      expect(
        find.text('이 댓글을 신고하는 이유를 선택해주세요'),
        findsOneWidget,
      );
    });

    testWidgets('displays correct description for MEMBER', (tester) async {
      await tester.pumpWidget(createTestWidget(
        targetType: ReportTargetType.member,
        targetId: 5,
      ));

      expect(
        find.text('이 사용자를 신고하는 이유를 선택해주세요'),
        findsOneWidget,
      );
    });
  });
}
