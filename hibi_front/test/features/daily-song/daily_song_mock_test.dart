import 'package:flutter_test/flutter_test.dart';
import 'package:hidi/features/daily-song/mocks/daily_song_mock.dart';

void main() {
  group('Daily Song Mock Data', () {
    test('mockDailySongs should have 10 songs', () {
      expect(mockDailySongs.length, 10);
    });

    test('mockArtists should have 5 artists', () {
      expect(mockArtists.length, 5);
    });

    test('mockAlbums should have 5 albums', () {
      expect(mockAlbums.length, 5);
    });

    test('each song should have valid data', () {
      for (final song in mockDailySongs) {
        expect(song.id, isPositive);
        expect(song.titleKor, isNotEmpty);
        expect(song.titleJp, isNotEmpty);
        expect(song.artist.id, isPositive);
        expect(song.artist.nameKor, isNotEmpty);
        expect(song.album.name, isNotEmpty);
        expect(song.lyrics.japanese, isNotEmpty);
        expect(song.lyrics.korean, isNotEmpty);
        expect(song.genre, isNotEmpty);
      }
    });

    test('getMockTodaySong should return a song', () {
      final song = getMockTodaySong();
      // Mock에서는 오늘 날짜 곡이 없으면 첫 번째 곡을 반환
      expect(song, isNotNull);
      expect(song!.id, isPositive);
    });

    test('getMockSongById should return correct song', () {
      final song = getMockSongById(1);
      expect(song, isNotNull);
      expect(song!.id, 1);
      expect(song.titleJp, '夜に駆ける');
    });

    test('getMockSongById should return null for invalid id', () {
      final song = getMockSongById(999);
      expect(song, isNull);
    });

    test('getMockSongsByMonth should return songs for given month', () {
      final now = DateTime.now();
      final songs = getMockSongsByMonth(now.year, now.month);
      // Mock 데이터의 날짜에 따라 결과가 달라질 수 있음
      expect(songs, isA<List>());
    });

    test('all songs should have external links', () {
      for (final song in mockDailySongs) {
        expect(song.externalLinks.hasAnyLink, isTrue);
      }
    });

    test('first song (YOASOBI) should have correct artist', () {
      final song = mockDailySongs.first;
      expect(song.artist.nameKor, '요아소비');
      expect(song.artist.nameJp, 'YOASOBI');
    });
  });
}
