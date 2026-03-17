import 'package:flutter_test/flutter_test.dart';
import 'package:hidi/features/management/models/admin_song_models.dart';
import 'package:hidi/features/management/mocks/admin_song_mock.dart';

void main() {
  group('AdminSongCreateRequest', () {
    test('필수 필드로 생성 가능', () {
      final request = AdminSongCreateRequest(
        titleKor: '밤을 달리다',
        titleJp: '夜に駆ける',
        artistId: 1,
      );
      expect(request.titleKor, '밤을 달리다');
      expect(request.titleJp, '夜に駆ける');
      expect(request.artistId, 1);
      expect(request.relatedSongs, isEmpty);
    });

    test('선택 필드 포함하여 생성 가능', () {
      final request = AdminSongCreateRequest(
        titleKor: '밤을 달리다',
        titleEng: 'Racing into the Night',
        titleJp: '夜に駆ける',
        artistId: 1,
        story: '이 곡은 소설을 기반으로 만들어졌습니다',
        youtubeUrl: 'https://youtube.com/watch?v=test',
      );
      expect(request.titleEng, 'Racing into the Night');
      expect(request.story, isNotNull);
      expect(request.youtubeUrl, contains('youtube'));
    });
  });

  group('Admin Song Mock Data', () {
    test('Mock 아티스트 제안 목록이 있음', () {
      expect(mockArtistSuggestions.isNotEmpty, isTrue);
    });

    test('Mock 예약 게시 목록이 있음', () {
      expect(mockScheduledSongs.isNotEmpty, isTrue);
    });

    test('Mock 관리자 댓글 목록이 있음', () {
      expect(mockAdminComments.isNotEmpty, isTrue);
    });

    test('각 예약 게시 항목에 필수 정보가 있음', () {
      for (final item in mockScheduledSongs) {
        expect(item.songTitle, isNotEmpty);
        expect(item.scheduledAt, isNotNull);
      }
    });
  });
}
