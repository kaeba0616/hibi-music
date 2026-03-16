import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hidi/features/posts/models/post_models.dart';
import 'package:hidi/features/posts/widgets/song_tag_card.dart';

void main() {
  final testSong = TaggedSong(
    id: 1,
    titleKor: '밤을 달리다',
    titleJp: '夜に駆ける',
    artistName: 'YOASOBI',
    albumImageUrl: null,
    albumName: 'THE BOOK',
    releaseYear: 2021,
  );

  group('SongTagCard', () {
    testWidgets('renders song title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SongTagCard(song: testSong),
          ),
        ),
      );

      expect(find.text('밤을 달리다'), findsOneWidget);
    });

    testWidgets('renders artist name', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SongTagCard(song: testSong),
          ),
        ),
      );

      expect(find.textContaining('YOASOBI'), findsOneWidget);
    });

    testWidgets('renders album name in non-compact mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SongTagCard(song: testSong, compact: false),
          ),
        ),
      );

      expect(find.textContaining('THE BOOK'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SongTagCard(
              song: testSong,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(SongTagCard));
      expect(tapped, isTrue);
    });

    testWidgets('shows remove button when onRemove is provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SongTagCard(
              song: testSong,
              onRemove: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('does not show remove button when onRemove is null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SongTagCard(
              song: testSong,
              onRemove: null,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('calls onRemove when remove button is tapped', (tester) async {
      bool removed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SongTagCard(
              song: testSong,
              onRemove: () => removed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.close));
      expect(removed, isTrue);
    });
  });

  group('SongSearchItem', () {
    testWidgets('renders song information', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SongSearchItem(
              song: testSong,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('밤을 달리다'), findsOneWidget);
      expect(find.textContaining('YOASOBI'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SongSearchItem(
              song: testSong,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(SongSearchItem));
      expect(tapped, isTrue);
    });
  });
}
