import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hidi/features/artists/models/artist_model.dart';
import 'package:hidi/features/artists/views/widgets/artist_card.dart';

void main() {
  group('ArtistCard Widget', () {
    testWidgets('displays artist name correctly', (tester) async {
      final artist = Artist(
        id: 1,
        nameKor: '요아소비',
        nameEng: 'YOASOBI',
        nameJp: 'YOASOBI',
        songCount: 15,
        isFollowing: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ArtistCard(artist: artist),
          ),
        ),
      );

      expect(find.text('요아소비'), findsOneWidget);
    });

    testWidgets('displays song count correctly', (tester) async {
      final artist = Artist(
        id: 1,
        nameKor: '요아소비',
        nameEng: 'YOASOBI',
        nameJp: 'YOASOBI',
        songCount: 15,
        isFollowing: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ArtistCard(artist: artist),
          ),
        ),
      );

      expect(find.text('15곡'), findsOneWidget);
    });

    testWidgets('shows follow icon when following', (tester) async {
      final artist = Artist(
        id: 1,
        nameKor: '요아소비',
        nameEng: 'YOASOBI',
        nameJp: 'YOASOBI',
        songCount: 15,
        isFollowing: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ArtistCard(artist: artist),
          ),
        ),
      );

      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('hides follow icon when not following', (tester) async {
      final artist = Artist(
        id: 1,
        nameKor: '요아소비',
        nameEng: 'YOASOBI',
        nameJp: 'YOASOBI',
        songCount: 15,
        isFollowing: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ArtistCard(artist: artist),
          ),
        ),
      );

      expect(find.byIcon(Icons.favorite), findsNothing);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;
      final artist = Artist(
        id: 1,
        nameKor: '요아소비',
        nameEng: 'YOASOBI',
        nameJp: 'YOASOBI',
        songCount: 15,
        isFollowing: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ArtistCard(
              artist: artist,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ArtistCard));
      expect(tapped, true);
    });

    testWidgets('shows default icon when no profile image', (tester) async {
      final artist = Artist(
        id: 1,
        nameKor: '요아소비',
        nameEng: 'YOASOBI',
        nameJp: 'YOASOBI',
        profileImage: null,
        songCount: 15,
        isFollowing: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ArtistCard(artist: artist),
          ),
        ),
      );

      expect(find.byIcon(Icons.person), findsOneWidget);
    });
  });
}
