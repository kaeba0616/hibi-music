/// 관리자 대시보드 뷰 테스트

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hidi/features/management/repos/admin_repo.dart';
import 'package:hidi/features/management/views/admin_dashboard_view.dart';

void main() {
  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        adminRepoProvider.overrideWithValue(AdminRepository(useMock: true)),
      ],
      child: const MaterialApp(
        home: AdminDashboardView(),
      ),
    );
  }

  group('AdminDashboardView', () {
    testWidgets('should show appbar initially', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(seconds: 1));

      // Appbar should be visible
      expect(find.text('관리자'), findsOneWidget);
    });

    testWidgets('should show dashboard title after loading', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('대시보드'), findsOneWidget);
      expect(find.text('관리 메뉴'), findsOneWidget);
    });

    testWidgets('should show stat cards after loading', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('미처리 신고'), findsOneWidget);
      expect(find.text('미답변 문의'), findsOneWidget);
      expect(find.text('전체 회원'), findsOneWidget);
      expect(find.text('전체 노래'), findsOneWidget);
    });

    testWidgets('should show menu items after loading', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('신고 관리'), findsOneWidget);
      expect(find.text('문의 관리'), findsOneWidget);
      expect(find.text('FAQ 관리'), findsOneWidget);
      expect(find.text('회원 관리'), findsOneWidget);
    });

    testWidgets('should show appbar with correct title', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('관리자'), findsOneWidget);
    });
  });
}
