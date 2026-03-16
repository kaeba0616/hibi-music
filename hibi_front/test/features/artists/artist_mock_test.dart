import 'package:flutter_test/flutter_test.dart';
import 'package:hidi/features/artists/mocks/artist_mock.dart';

void main() {
  group('Artist Mock Data', () {
    test('mockArtists contains expected number of artists', () {
      expect(mockArtists.length, 6);
    });

    test('mockArtists have all required fields', () {
      for (final artist in mockArtists) {
        expect(artist.id, isPositive);
        expect(artist.nameKor, isNotEmpty);
        expect(artist.nameEng, isNotEmpty);
        expect(artist.nameJp, isNotEmpty);
        expect(artist.profileImage, isNotNull);
        expect(artist.description, isNotNull);
        expect(artist.followerCount, isNonNegative);
        expect(artist.songCount, isNonNegative);
      }
    });

    test('mockArtistSongs contains songs for each artist', () {
      expect(mockArtistSongs[1], isNotEmpty); // YOASOBI
      expect(mockArtistSongs[2], isNotEmpty); // Aimyon
      expect(mockArtistSongs[3], isNotEmpty); // Official髭男dism
      expect(mockArtistSongs[4], isNotEmpty); // Ado
      expect(mockArtistSongs[5], isNotEmpty); // imase
      expect(mockArtistSongs[6], isNotEmpty); // RADWIMPS
    });
  });

  group('getMockArtists', () {
    test('returns all artists when no filter', () {
      final artists = getMockArtists();
      expect(artists.length, 6);
    });

    test('returns only following artists when followingOnly is true', () {
      final artists = getMockArtists(followingOnly: true);
      expect(artists.every((a) => a.isFollowing), true);
    });

    test('filters by search query', () {
      final artists = getMockArtists(searchQuery: 'YOASOBI');
      expect(artists.length, 1);
      expect(artists.first.nameEng, 'YOASOBI');
    });

    test('filters by Korean name search', () {
      final artists = getMockArtists(searchQuery: '요아소비');
      expect(artists.length, 1);
      expect(artists.first.nameKor, '요아소비');
    });

    test('returns empty list for non-matching search', () {
      final artists = getMockArtists(searchQuery: 'NonExistentArtist');
      expect(artists.isEmpty, true);
    });
  });

  group('getMockArtistDetail', () {
    test('returns artist detail for valid id', () {
      final detail = getMockArtistDetail(1);
      expect(detail, isNotNull);
      expect(detail!.artist.id, 1);
      expect(detail.artist.nameKor, '요아소비');
      expect(detail.songs, isNotEmpty);
    });

    test('returns null for invalid id', () {
      final detail = getMockArtistDetail(999);
      expect(detail, isNull);
    });
  });

  group('toggleMockFollow', () {
    test('toggles follow status', () {
      // Get initial state
      final initialArtist = mockArtists.firstWhere((a) => a.id == 2);
      final initialFollowing = initialArtist.isFollowing;
      final initialFollowerCount = initialArtist.followerCount;

      // Toggle follow
      final updated = toggleMockFollow(2);

      expect(updated.isFollowing, !initialFollowing);
      if (initialFollowing) {
        expect(updated.followerCount, initialFollowerCount - 1);
      } else {
        expect(updated.followerCount, initialFollowerCount + 1);
      }

      // Toggle back to restore state
      toggleMockFollow(2);
    });

    test('returns empty artist for invalid id', () {
      final result = toggleMockFollow(999);
      expect(result.id, 0);
    });
  });
}
