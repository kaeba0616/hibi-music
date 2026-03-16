import 'package:flutter_test/flutter_test.dart';
import 'package:hidi/features/artists/models/artist_model.dart';
import 'package:hidi/features/artists/models/artist_song_model.dart';
import 'package:hidi/features/artists/models/artist_detail_model.dart';

void main() {
  group('Artist Model', () {
    test('creates Artist from JSON correctly', () {
      final json = {
        'id': 1,
        'nameKor': '요아소비',
        'nameEng': 'YOASOBI',
        'nameJp': 'YOASOBI',
        'profileImage': 'https://example.com/profile.jpg',
        'description': '일본의 음악 유닛',
        'followerCount': 1000,
        'songCount': 15,
        'isFollowing': true,
      };

      final artist = Artist.fromJson(json);

      expect(artist.id, 1);
      expect(artist.nameKor, '요아소비');
      expect(artist.nameEng, 'YOASOBI');
      expect(artist.nameJp, 'YOASOBI');
      expect(artist.profileImage, 'https://example.com/profile.jpg');
      expect(artist.description, '일본의 음악 유닛');
      expect(artist.followerCount, 1000);
      expect(artist.songCount, 15);
      expect(artist.isFollowing, true);
    });

    test('converts Artist to JSON correctly', () {
      final artist = Artist(
        id: 1,
        nameKor: '요아소비',
        nameEng: 'YOASOBI',
        nameJp: 'YOASOBI',
        profileImage: 'https://example.com/profile.jpg',
        description: '일본의 음악 유닛',
        followerCount: 1000,
        songCount: 15,
        isFollowing: true,
      );

      final json = artist.toJson();

      expect(json['id'], 1);
      expect(json['nameKor'], '요아소비');
      expect(json['nameEng'], 'YOASOBI');
      expect(json['nameJp'], 'YOASOBI');
      expect(json['profileImage'], 'https://example.com/profile.jpg');
      expect(json['description'], '일본의 음악 유닛');
      expect(json['followerCount'], 1000);
      expect(json['songCount'], 15);
      expect(json['isFollowing'], true);
    });

    test('creates empty Artist with default values', () {
      final artist = Artist.empty();

      expect(artist.id, 0);
      expect(artist.nameKor, '히비');
      expect(artist.nameEng, 'Hibi');
      expect(artist.nameJp, '日々');
      expect(artist.profileImage, null);
      expect(artist.description, null);
      expect(artist.followerCount, 0);
      expect(artist.songCount, 0);
      expect(artist.isFollowing, false);
    });

    test('copyWith creates new Artist with updated values', () {
      final artist = Artist(
        id: 1,
        nameKor: '요아소비',
        nameEng: 'YOASOBI',
        nameJp: 'YOASOBI',
        followerCount: 1000,
        isFollowing: false,
      );

      final updated = artist.copyWith(
        followerCount: 1001,
        isFollowing: true,
      );

      expect(updated.id, 1);
      expect(updated.nameKor, '요아소비');
      expect(updated.followerCount, 1001);
      expect(updated.isFollowing, true);
    });
  });

  group('ArtistSong Model', () {
    test('creates ArtistSong from JSON correctly', () {
      final json = {
        'id': 1,
        'titleKor': '밤을 달리다',
        'titleJp': '夜に駆ける',
        'albumName': 'THE BOOK',
        'albumImageUrl': 'https://example.com/album.jpg',
        'releaseYear': 2020,
      };

      final song = ArtistSong.fromJson(json);

      expect(song.id, 1);
      expect(song.titleKor, '밤을 달리다');
      expect(song.titleJp, '夜に駆ける');
      expect(song.albumName, 'THE BOOK');
      expect(song.albumImageUrl, 'https://example.com/album.jpg');
      expect(song.releaseYear, 2020);
    });

    test('converts ArtistSong to JSON correctly', () {
      final song = ArtistSong(
        id: 1,
        titleKor: '밤을 달리다',
        titleJp: '夜に駆ける',
        albumName: 'THE BOOK',
        albumImageUrl: 'https://example.com/album.jpg',
        releaseYear: 2020,
      );

      final json = song.toJson();

      expect(json['id'], 1);
      expect(json['titleKor'], '밤을 달리다');
      expect(json['titleJp'], '夜に駆ける');
      expect(json['albumName'], 'THE BOOK');
      expect(json['albumImageUrl'], 'https://example.com/album.jpg');
      expect(json['releaseYear'], 2020);
    });
  });

  group('ArtistDetail Model', () {
    test('creates ArtistDetail from JSON correctly', () {
      final json = {
        'id': 1,
        'nameKor': '요아소비',
        'nameEng': 'YOASOBI',
        'nameJp': 'YOASOBI',
        'profileImage': 'https://example.com/profile.jpg',
        'description': '일본의 음악 유닛',
        'followerCount': 1000,
        'songCount': 15,
        'isFollowing': true,
        'songs': [
          {
            'id': 1,
            'titleKor': '밤을 달리다',
            'titleJp': '夜に駆ける',
            'albumName': 'THE BOOK',
            'releaseYear': 2020,
          },
        ],
      };

      final detail = ArtistDetail.fromJson(json);

      expect(detail.artist.id, 1);
      expect(detail.artist.nameKor, '요아소비');
      expect(detail.songs.length, 1);
      expect(detail.songs[0].titleKor, '밤을 달리다');
    });

    test('copyWith creates new ArtistDetail with updated values', () {
      final artist = Artist(
        id: 1,
        nameKor: '요아소비',
        nameEng: 'YOASOBI',
        nameJp: 'YOASOBI',
        isFollowing: false,
      );

      final detail = ArtistDetail(artist: artist, songs: []);

      final updatedArtist = artist.copyWith(isFollowing: true);
      final updated = detail.copyWith(artist: updatedArtist);

      expect(updated.artist.isFollowing, true);
    });
  });
}
