import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hidi/features/artists/models/artist_model.dart';
import 'package:hidi/features/daily-song/models/daily_song_model.dart';
import 'package:hidi/features/daily-song/views/widgets/related_song_tile.dart';

void main() {
  group('RelatedSongTile', () {
    late RelatedSong testSong;

    setUp(() {
      testSong = RelatedSong(
        id: 1,
        titleKor: '아이돌',
        titleJp: 'アイドル',
        artist: Artist(
          id: 1,
          nameKor: '요아소비',
          nameEng: 'YOASOBI',
          nameJp: 'YOASOBI',
          profileImage: '',
          songCount: 10,
          isFollowing: false,
        ),
        album: Album(
          id: 1,
          name: 'THE BOOK 3',
          imageUrl: '',
          releaseDate: DateTime(2023, 6, 21),
        ),
        reason: '같은 아티스트의 곡',
      );
    });

    Widget buildWidget({VoidCallback? onTap}) {
      return MaterialApp(
        home: Scaffold(
          body: RelatedSongTile(
            song: testSong,
            onTap: onTap ?? () {},
          ),
        ),
      );
    }

    testWidgets('곡 제목이 표시됨', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('아이돌'), findsOneWidget);
    });

    testWidgets('아티스트명이 표시됨', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('요아소비'), findsOneWidget);
    });

    testWidgets('선정 이유가 표시됨', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('같은 아티스트의 곡'), findsOneWidget);
    });

    testWidgets('탭 시 콜백이 호출됨', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(buildWidget(onTap: () => tapped = true));
      await tester.tap(find.byType(ListTile));
      expect(tapped, true);
    });
  });

  group('RelatedSong 모델', () {
    test('fromJson으로 생성 가능', () {
      final json = {
        'id': 1,
        'titleKor': '테스트곡',
        'titleJp': 'テスト曲',
        'reason': '분위기가 유사한 곡',
      };
      final song = RelatedSong.fromJson(json);
      expect(song.titleKor, '테스트곡');
      expect(song.reason, '분위기가 유사한 곡');
    });
  });
}
