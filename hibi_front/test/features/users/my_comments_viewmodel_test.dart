import 'package:flutter_test/flutter_test.dart';
import 'package:hidi/features/users/models/my_comment.dart';
import 'package:hidi/features/users/repos/users_repos.dart';
import 'package:hidi/features/users/viewmodels/my_comments_viewmodel.dart';

class _FakeUserRepo extends UserRepository {
  @override
  Future<List<MyComment>> getMyComments() async => [
        MyComment.fromJson(const {
          'commentId': 11,
          'content': '실서버 댓글',
          'likeCount': 3,
          'createdAt': '2026-07-10T12:00:00',
          'songId': 7,
          'songTitle': 'アイドル',
          'artistName': 'YOASOBI',
        }),
      ];
}

void main() {
  group('MyComment.fromJson', () {
    test('백엔드 MyCommentResponse 필드를 매핑한다', () {
      final myComment = MyComment.fromJson(const {
        'commentId': 5,
        'content': '좋은 곡',
        'likeCount': 2,
        'createdAt': '2026-07-01T09:30:00',
        'songId': 10,
        'songTitle': '曲名',
        'artistName': '아티스트',
      });

      expect(myComment.comment.id, 5);
      expect(myComment.comment.content, '좋은 곡');
      expect(myComment.comment.likeCount, 2);
      expect(myComment.comment.createdAt, DateTime.parse('2026-07-01T09:30:00'));
      expect(myComment.songInfo.songId, 10);
      expect(myComment.songInfo.songTitle, '曲名');
      expect(myComment.songInfo.artistName, '아티스트');
    });
  });

  group('MyCommentsViewModel (실API 경로)', () {
    test('레포지토리에서 내 댓글 목록을 불러온다', () async {
      final viewModel = MyCommentsViewModel(
        useMock: false,
        userRepository: _FakeUserRepo(),
      );

      await viewModel.loadMyComments();

      expect(viewModel.state.isLoading, isFalse);
      expect(viewModel.state.comments, hasLength(1));
      expect(viewModel.state.comments.first.comment.content, '실서버 댓글');
      expect(viewModel.state.comments.first.songInfo.artistName, 'YOASOBI');
    });
  });
}
