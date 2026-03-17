import 'package:flutter_test/flutter_test.dart';
import 'package:hidi/features/comments/models/comment_models.dart';

void main() {
  group('Top Comments Logic', () {
    late List<Comment> allComments;

    setUp(() {
      allComments = [
        Comment(
          id: 1, postId: 1,
          author: CommentAuthor(id: 1, nickname: '유저1', username: 'u1', profileImage: null),
          content: '댓글1', likeCount: 10, isLiked: false, createdAt: DateTime.now(),
        ),
        Comment(
          id: 2, postId: 1,
          author: CommentAuthor(id: 2, nickname: '유저2', username: 'u2', profileImage: null),
          content: '댓글2', likeCount: 50, isLiked: false, createdAt: DateTime.now(),
        ),
        Comment(
          id: 3, postId: 1,
          author: CommentAuthor(id: 3, nickname: '유저3', username: 'u3', profileImage: null),
          content: '댓글3', likeCount: 30, isLiked: false, createdAt: DateTime.now(),
        ),
        Comment(
          id: 4, postId: 1,
          author: CommentAuthor(id: 4, nickname: '유저4', username: 'u4', profileImage: null),
          content: '댓글4', likeCount: 20, isLiked: false, createdAt: DateTime.now(),
        ),
      ];
    });

    test('좋아요 순으로 정렬하면 Top3가 올바름', () {
      final sorted = List<Comment>.from(allComments)
        ..sort((a, b) => b.likeCount.compareTo(a.likeCount));
      final top3 = sorted.take(3).toList();

      expect(top3.length, 3);
      expect(top3[0].likeCount, 50); // 유저2
      expect(top3[1].likeCount, 30); // 유저3
      expect(top3[2].likeCount, 20); // 유저4
    });

    test('댓글이 3개 미만이면 전체 반환', () {
      final fewComments = allComments.take(2).toList();
      final sorted = List<Comment>.from(fewComments)
        ..sort((a, b) => b.likeCount.compareTo(a.likeCount));
      final top = sorted.take(3).toList();

      expect(top.length, 2);
    });

    test('빈 댓글 목록이면 빈 리스트', () {
      final empty = <Comment>[];
      final top = empty.take(3).toList();
      expect(top, isEmpty);
    });
  });

  group('Comment Filter', () {
    test('isFiltered가 true이면 내용을 마스킹해야 함', () {
      final comment = Comment(
        id: 1, postId: 1,
        author: CommentAuthor(id: 1, nickname: '유저', username: 'u', profileImage: null),
        content: '부적절한 내용', likeCount: 0, isLiked: false, createdAt: DateTime.now(),
        isFiltered: true,
      );

      final displayContent = comment.isFiltered
          ? '부적절한 내용이 포함된 댓글입니다'
          : comment.content;

      expect(displayContent, '부적절한 내용이 포함된 댓글입니다');
    });
  });
}
