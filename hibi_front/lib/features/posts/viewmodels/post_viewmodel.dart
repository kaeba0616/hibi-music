import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidi/features/posts/models/post_models.dart';
import 'package:hidi/features/posts/repos/post_repo.dart';
import 'package:hidi/features/posts/mocks/post_mock.dart';

/// 게시글 상세 상태
class PostDetailState {
  final Post? post;
  final bool isLoading;
  final String? error;

  PostDetailState({
    this.post,
    this.isLoading = false,
    this.error,
  });

  PostDetailState copyWith({
    Post? post,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return PostDetailState(
      post: post ?? this.post,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// 게시글 상세 ViewModel
class PostDetailViewModel extends FamilyNotifier<PostDetailState, int> {
  @override
  PostDetailState build(int postId) {
    // 초기 로드
    Future.microtask(() => loadPost(postId));
    return PostDetailState(isLoading: true);
  }

  PostRepository get _repo => ref.read(postRepoProvider);

  /// 게시글 상세 로드
  Future<void> loadPost(int postId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final post = await _repo.getPost(postId);
      if (post != null) {
        state = state.copyWith(post: post, isLoading: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: '게시글을 찾을 수 없습니다',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '게시글을 불러올 수 없습니다',
      );
    }
  }

  /// 좋아요 토글
  Future<void> toggleLike() async {
    final post = state.post;
    if (post == null) return;

    // 낙관적 업데이트
    state = state.copyWith(
      post: post.copyWith(
        isLiked: !post.isLiked,
        likeCount: post.isLiked ? post.likeCount - 1 : post.likeCount + 1,
      ),
    );

    // API 호출
    final success = await _repo.toggleLike(post.id);

    if (!success) {
      // 실패 시 롤백
      state = state.copyWith(post: post);
    }
  }

  /// 게시글 삭제
  Future<bool> deletePost() async {
    final post = state.post;
    if (post == null) return false;

    return await _repo.deletePost(post.id);
  }

  /// 현재 사용자 ID (본인 게시글 확인용)
  int get currentUserId => mockCurrentUserId;

  /// 본인 게시글 여부
  bool get isOwnPost => state.post?.isAuthor(currentUserId) ?? false;
}

/// 게시글 상세 Provider (postId 파라미터)
final postDetailViewModelProvider =
    NotifierProvider.family<PostDetailViewModel, PostDetailState, int>(
  () => PostDetailViewModel(),
);

/// 게시글 작성/수정 상태
class PostEditorState {
  final String content;
  final List<String> images;
  final TaggedSong? taggedSong;
  final bool isSubmitting;
  final String? error;

  PostEditorState({
    this.content = '',
    this.images = const [],
    this.taggedSong,
    this.isSubmitting = false,
    this.error,
  });

  PostEditorState copyWith({
    String? content,
    List<String>? images,
    TaggedSong? taggedSong,
    bool? isSubmitting,
    String? error,
    bool clearTaggedSong = false,
    bool clearError = false,
  }) {
    return PostEditorState(
      content: content ?? this.content,
      images: images ?? this.images,
      taggedSong: clearTaggedSong ? null : (taggedSong ?? this.taggedSong),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : (error ?? this.error),
    );
  }

  bool get canSubmit => content.trim().isNotEmpty && !isSubmitting;
}

/// 게시글 작성 ViewModel
class PostCreateViewModel extends Notifier<PostEditorState> {
  @override
  PostEditorState build() {
    return PostEditorState();
  }

  PostRepository get _repo => ref.read(postRepoProvider);

  /// 내용 변경
  void setContent(String content) {
    state = state.copyWith(content: content);
  }

  /// 이미지 추가
  void addImage(String imageUrl) {
    if (state.images.length >= 4) return;
    state = state.copyWith(images: [...state.images, imageUrl]);
  }

  /// 이미지 제거
  void removeImage(int index) {
    final images = List<String>.from(state.images);
    if (index >= 0 && index < images.length) {
      images.removeAt(index);
      state = state.copyWith(images: images);
    }
  }

  /// 노래 태그 설정
  void setTaggedSong(TaggedSong? song) {
    if (song == null) {
      state = state.copyWith(clearTaggedSong: true);
    } else {
      state = state.copyWith(taggedSong: song);
    }
  }

  /// 게시글 작성
  Future<Post?> submit() async {
    if (!state.canSubmit) return null;

    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final request = PostCreateRequest(
        content: state.content.trim(),
        images: state.images,
        taggedSongId: state.taggedSong?.id,
      );

      final post = await _repo.createPost(request);

      if (post != null) {
        state = state.copyWith(isSubmitting: false);
        return post;
      } else {
        state = state.copyWith(
          isSubmitting: false,
          error: '게시글 작성에 실패했습니다',
        );
        return null;
      }
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: '게시글 작성에 실패했습니다',
      );
      return null;
    }
  }

  /// 초기화
  void reset() {
    state = PostEditorState();
  }
}

/// 게시글 작성 Provider
final postCreateViewModelProvider =
    NotifierProvider<PostCreateViewModel, PostEditorState>(
  () => PostCreateViewModel(),
);

/// 게시글 수정 ViewModel
class PostEditViewModel extends FamilyNotifier<PostEditorState, int> {
  @override
  PostEditorState build(int postId) {
    // 초기 데이터 로드
    Future.microtask(() => loadPost(postId));
    return PostEditorState();
  }

  PostRepository get _repo => ref.read(postRepoProvider);
  int? _postId;

  /// 기존 게시글 로드
  Future<void> loadPost(int postId) async {
    _postId = postId;
    final post = await _repo.getPost(postId);
    if (post != null) {
      state = state.copyWith(
        content: post.content,
        images: post.images,
        taggedSong: post.taggedSong,
      );
    }
  }

  /// 내용 변경
  void setContent(String content) {
    state = state.copyWith(content: content);
  }

  /// 이미지 추가
  void addImage(String imageUrl) {
    if (state.images.length >= 4) return;
    state = state.copyWith(images: [...state.images, imageUrl]);
  }

  /// 이미지 제거
  void removeImage(int index) {
    final images = List<String>.from(state.images);
    if (index >= 0 && index < images.length) {
      images.removeAt(index);
      state = state.copyWith(images: images);
    }
  }

  /// 노래 태그 설정
  void setTaggedSong(TaggedSong? song) {
    if (song == null) {
      state = state.copyWith(clearTaggedSong: true);
    } else {
      state = state.copyWith(taggedSong: song);
    }
  }

  /// 게시글 수정
  Future<Post?> submit() async {
    if (!state.canSubmit || _postId == null) return null;

    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final request = PostUpdateRequest(
        content: state.content.trim(),
        images: state.images,
        taggedSongId: state.taggedSong?.id,
      );

      final post = await _repo.updatePost(_postId!, request);

      if (post != null) {
        state = state.copyWith(isSubmitting: false);
        return post;
      } else {
        state = state.copyWith(
          isSubmitting: false,
          error: '게시글 수정에 실패했습니다',
        );
        return null;
      }
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: '게시글 수정에 실패했습니다',
      );
      return null;
    }
  }
}

/// 게시글 수정 Provider (postId 파라미터)
final postEditViewModelProvider =
    NotifierProvider.family<PostEditViewModel, PostEditorState, int>(
  () => PostEditViewModel(),
);

/// 노래 검색 상태
class SongSearchState {
  final String query;
  final List<TaggedSong> results;
  final bool isSearching;

  SongSearchState({
    this.query = '',
    this.results = const [],
    this.isSearching = false,
  });

  SongSearchState copyWith({
    String? query,
    List<TaggedSong>? results,
    bool? isSearching,
  }) {
    return SongSearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      isSearching: isSearching ?? this.isSearching,
    );
  }
}

/// 노래 검색 ViewModel (노래 태그용)
class SongSearchViewModel extends Notifier<SongSearchState> {
  @override
  SongSearchState build() {
    return SongSearchState();
  }

  PostRepository get _repo => ref.read(postRepoProvider);

  /// 노래 검색
  Future<void> search(String query) async {
    state = state.copyWith(query: query, isSearching: true);

    try {
      final results = await _repo.searchSongs(query);
      state = state.copyWith(results: results, isSearching: false);
    } catch (e) {
      state = state.copyWith(results: [], isSearching: false);
    }
  }

  /// 초기화
  void reset() {
    state = SongSearchState();
  }
}

/// 노래 검색 Provider
final songSearchViewModelProvider =
    NotifierProvider<SongSearchViewModel, SongSearchState>(
  () => SongSearchViewModel(),
);
