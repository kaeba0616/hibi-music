import 'package:flutter_test/flutter_test.dart';
import 'package:hidi/features/users/mocks/my_comments_mock.dart';

void main() {
  group('MyComments Mock Data', () {
    test('Mock 댓글 목록이 5개임', () {
      expect(mockMyComments.length, 5);
    });

    test('각 댓글에 comment와 songInfo가 있음', () {
      for (final mc in mockMyComments) {
        expect(mc.comment.id, isNonZero);
        expect(mc.comment.content, isNotEmpty);
        expect(mc.songInfo.songTitle, isNotEmpty);
        expect(mc.songInfo.artistName, isNotEmpty);
        expect(mc.songInfo.songId, isNonZero);
      }
    });

    test('현재 사용자 작성자 정보가 있음', () {
      expect(mockCurrentAuthor.nickname, '나');
      expect(mockCurrentAuthor.username, 'current_user');
    });
  });
}
