import 'package:flutter_test/flutter_test.dart';
import 'package:hidi/features/artists/models/artist_model.dart';
import 'package:hidi/features/daily-song/models/daily_song_model.dart';

void main() {
  group('DailySong Model', () {
    test('should create DailySong from JSON', () {
      final json = {
        'id': 1,
        'titleKor': '밤을 달리다',
        'titleJp': '夜に駆ける',
        'artist': {
          'id': 1,
          'nameKor': '요아소비',
          'nameEng': 'YOASOBI',
          'nameJp': 'YOASOBI',
        },
        'album': {
          'id': 1,
          'name': 'THE BOOK',
          'imageUrl': 'https://example.com/album.jpg',
          'releaseDate': '2021-01-06T00:00:00.000',
        },
        'lyrics': {
          'japanese': '沈むように溶けてゆくように',
          'korean': '가라앉듯이 녹아가듯이',
        },
        'genre': 'J-Pop',
        'recommendedDate': '2026-02-03T00:00:00.000',
        'externalLinks': {
          'spotify': 'https://spotify.com/track/123',
          'youtube': 'https://youtube.com/watch?v=123',
        },
        'isLiked': false,
        'likeCount': 1000,
      };

      final song = DailySong.fromJson(json);

      expect(song.id, 1);
      expect(song.titleKor, '밤을 달리다');
      expect(song.titleJp, '夜に駆ける');
      expect(song.artist.nameKor, '요아소비');
      expect(song.album.name, 'THE BOOK');
      expect(song.lyrics.japanese, '沈むように溶けてゆくように');
      expect(song.lyrics.korean, '가라앉듯이 녹아가듯이');
      expect(song.genre, 'J-Pop');
      expect(song.isLiked, false);
      expect(song.likeCount, 1000);
      expect(song.externalLinks.spotify, 'https://spotify.com/track/123');
      expect(song.externalLinks.youtube, 'https://youtube.com/watch?v=123');
      expect(song.externalLinks.appleMusic, isNull);
    });

    test('should convert DailySong to JSON', () {
      final song = DailySong(
        id: 1,
        titleKor: '밤을 달리다',
        titleJp: '夜に駆ける',
        artist: Artist(
          id: 1,
          nameKor: '요아소비',
          nameEng: 'YOASOBI',
          nameJp: 'YOASOBI',
        ),
        album: Album(
          id: 1,
          name: 'THE BOOK',
          imageUrl: 'https://example.com/album.jpg',
          releaseDate: DateTime(2021, 1, 6),
        ),
        lyrics: Lyrics(
          japanese: '沈むように',
          korean: '가라앉듯이',
        ),
        genre: 'J-Pop',
        recommendedDate: DateTime(2026, 2, 3),
        externalLinks: ExternalLinks(
          spotify: 'https://spotify.com/track/123',
        ),
        isLiked: true,
        likeCount: 500,
      );

      final json = song.toJson();

      expect(json['id'], 1);
      expect(json['titleKor'], '밤을 달리다');
      expect(json['titleJp'], '夜に駆ける');
      expect(json['artist']['nameKor'], '요아소비');
      expect(json['album']['name'], 'THE BOOK');
      expect(json['isLiked'], true);
      expect(json['likeCount'], 500);
    });

    test('should create copy with updated values', () {
      final song = DailySong(
        id: 1,
        titleKor: '밤을 달리다',
        titleJp: '夜に駆ける',
        artist: Artist.empty(),
        album: Album.empty(),
        lyrics: Lyrics.empty(),
        genre: 'J-Pop',
        recommendedDate: DateTime.now(),
        externalLinks: ExternalLinks.empty(),
        isLiked: false,
        likeCount: 100,
      );

      final updatedSong = song.copyWith(
        isLiked: true,
        likeCount: 101,
      );

      expect(song.isLiked, false);
      expect(song.likeCount, 100);
      expect(updatedSong.isLiked, true);
      expect(updatedSong.likeCount, 101);
      expect(updatedSong.titleKor, '밤을 달리다'); // 변경되지 않은 값
    });

    test('should create empty DailySong', () {
      final song = DailySong.empty();

      expect(song.id, 0);
      expect(song.titleKor, '');
      expect(song.titleJp, '');
      expect(song.isLiked, false);
      expect(song.likeCount, 0);
    });
  });

  group('Album Model', () {
    test('should create Album from JSON', () {
      final json = {
        'id': 1,
        'name': 'THE BOOK',
        'imageUrl': 'https://example.com/album.jpg',
        'releaseDate': '2021-01-06T00:00:00.000',
      };

      final album = Album.fromJson(json);

      expect(album.id, 1);
      expect(album.name, 'THE BOOK');
      expect(album.imageUrl, 'https://example.com/album.jpg');
      expect(album.releaseDate.year, 2021);
      expect(album.releaseDate.month, 1);
      expect(album.releaseDate.day, 6);
    });
  });

  group('Lyrics Model', () {
    test('should create Lyrics from JSON', () {
      final json = {
        'japanese': '沈むように',
        'korean': '가라앉듯이',
      };

      final lyrics = Lyrics.fromJson(json);

      expect(lyrics.japanese, '沈むように');
      expect(lyrics.korean, '가라앉듯이');
    });

    test('should create empty Lyrics', () {
      final lyrics = Lyrics.empty();

      expect(lyrics.japanese, '');
      expect(lyrics.korean, '');
    });
  });

  group('ExternalLinks Model', () {
    test('should detect hasAnyLink correctly', () {
      final linksWithSpotify = ExternalLinks(spotify: 'https://spotify.com');
      final emptyLinks = ExternalLinks.empty();

      expect(linksWithSpotify.hasAnyLink, true);
      expect(emptyLinks.hasAnyLink, false);
    });
  });
}
