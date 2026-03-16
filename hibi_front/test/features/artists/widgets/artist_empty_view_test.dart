import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hidi/features/artists/views/widgets/artist_empty_view.dart';

void main() {
  group('ArtistEmptyView Widget', () {
    testWidgets('shows default empty message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ArtistEmptyView(),
          ),
        ),
      );

      expect(find.text('등록된 아티스트가 없습니다'), findsOneWidget);
      expect(find.byIcon(Icons.mic_off), findsOneWidget);
    });

    testWidgets('shows following empty message when isFollowingFilter is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ArtistEmptyView(isFollowingFilter: true),
          ),
        ),
      );

      expect(find.text('팔로우 중인 아티스트가 없습니다'), findsOneWidget);
      expect(find.text('아티스트를 팔로우해보세요!'), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });

    testWidgets('shows search empty message when searchQuery is provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ArtistEmptyView(searchQuery: 'YOASOBI'),
          ),
        ),
      );

      expect(find.text('"YOASOBI"에 대한 결과가 없습니다'), findsOneWidget);
      expect(find.byIcon(Icons.search_off), findsOneWidget);
    });
  });
}
