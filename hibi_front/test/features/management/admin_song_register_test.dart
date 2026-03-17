import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hidi/features/management/views/admin_song_register_view.dart';
import 'package:hidi/features/management/views/admin_scheduled_publish_view.dart';
import 'package:hidi/features/management/models/admin_song_models.dart';

void main() {
  group('AdminSongRegisterView', () {
    Widget buildWidget() {
      return const ProviderScope(
        child: MaterialApp(home: AdminSongRegisterView()),
      );
    }

    testWidgets('곡 등록 화면 렌더링', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();
      // 3언어 제목 필드가 있어야 함
      expect(find.byType(TextField), findsWidgets);
    });
  });

  group('AdminScheduledPublishView', () {
    Widget buildWidget() {
      return const ProviderScope(
        child: MaterialApp(home: AdminScheduledPublishView()),
      );
    }

    testWidgets('예약 게시 화면 렌더링', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();
      expect(find.byType(AdminScheduledPublishView), findsOneWidget);
    });
  });

  group('AdminSongModels', () {
    test('AdminSongCreateRequest 생성', () {
      final request = AdminSongCreateRequest(
        titleKor: '밤을 달리다',
        titleEng: 'Racing into the Night',
        titleJp: '夜に駆ける',
        artistId: 1,
      );
      expect(request.titleKor, '밤을 달리다');
      expect(request.artistId, 1);
    });
  });
}
