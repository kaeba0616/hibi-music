package com.hibi.server.support;

import com.hibi.server.domain.album.entity.Album;
import com.hibi.server.domain.artist.entity.Artist;
import com.hibi.server.domain.comment.entity.Comment;
import com.hibi.server.domain.faq.entity.FAQ;
import com.hibi.server.domain.faq.entity.FAQCategory;
import com.hibi.server.domain.feedpost.entity.FeedPost;
import com.hibi.server.domain.member.entity.Member;
import com.hibi.server.domain.member.entity.MemberStatus;
import com.hibi.server.domain.member.entity.ProviderType;
import com.hibi.server.domain.member.entity.UserRoleType;
import com.hibi.server.domain.question.entity.Question;
import com.hibi.server.domain.question.entity.QuestionType;
import com.hibi.server.domain.song.entity.Song;

import java.time.LocalDate;

/**
 * 테스트용 데이터 생성 헬퍼 클래스
 */
public class TestFixture {

    // ===== Member =====

    /**
     * 기본 테스트 회원 생성
     */
    public static Member createMember() {
        return Member.builder()
                .email("test@example.com")
                .password("encodedPassword123")
                .nickname("테스트유저")
                .provider(ProviderType.NATIVE)
                .role(UserRoleType.USER)
                .status(MemberStatus.ACTIVE)
                .build();
    }

    /**
     * 커스텀 이메일로 회원 생성
     */
    public static Member createMember(String email) {
        return Member.builder()
                .email(email)
                .password("encodedPassword123")
                .nickname("테스트유저_" + email.split("@")[0])
                .provider(ProviderType.NATIVE)
                .role(UserRoleType.USER)
                .status(MemberStatus.ACTIVE)
                .build();
    }

    /**
     * 커스텀 이메일과 닉네임으로 회원 생성
     */
    public static Member createMember(String email, String nickname) {
        return Member.builder()
                .email(email)
                .password("encodedPassword123")
                .nickname(nickname)
                .provider(ProviderType.NATIVE)
                .role(UserRoleType.USER)
                .status(MemberStatus.ACTIVE)
                .build();
    }

    /**
     * 관리자 회원 생성
     */
    public static Member createAdminMember() {
        return Member.builder()
                .email("admin@example.com")
                .password("encodedPassword123")
                .nickname("관리자")
                .provider(ProviderType.NATIVE)
                .role(UserRoleType.ADMIN)
                .status(MemberStatus.ACTIVE)
                .build();
    }

    /**
     * 정지된 회원 생성
     */
    public static Member createSuspendedMember() {
        return Member.builder()
                .email("suspended@example.com")
                .password("encodedPassword123")
                .nickname("정지회원")
                .provider(ProviderType.NATIVE)
                .role(UserRoleType.USER)
                .status(MemberStatus.SUSPENDED)
                .build();
    }

    // ===== Artist =====

    /**
     * 기본 아티스트 생성
     */
    public static Artist createArtist() {
        return Artist.builder()
                .nameKor("테스트 아티스트")
                .nameEng("Test Artist")
                .nameJp("テストアーティスト")
                .profileUrl("https://example.com/artist.jpg")
                .description("테스트 아티스트 설명")
                .build();
    }

    /**
     * 커스텀 이름으로 아티스트 생성
     */
    public static Artist createArtist(String nameKor) {
        return Artist.builder()
                .nameKor(nameKor)
                .nameEng(nameKor + " EN")
                .nameJp(nameKor + " JP")
                .profileUrl("https://example.com/artist.jpg")
                .description(nameKor + " 설명")
                .build();
    }

    // ===== Album =====

    /**
     * 기본 앨범 생성
     */
    public static Album createAlbum(Artist artist) {
        return Album.builder()
                .name("테스트 앨범")
                .imageUrl("https://example.com/album.jpg")
                .releaseDate(LocalDate.of(2024, 1, 1))
                .artist(artist)
                .build();
    }

    /**
     * 커스텀 이름으로 앨범 생성
     */
    public static Album createAlbum(String name, Artist artist) {
        return Album.builder()
                .name(name)
                .imageUrl("https://example.com/album.jpg")
                .releaseDate(LocalDate.of(2024, 1, 1))
                .artist(artist)
                .build();
    }

    // ===== Song =====

    /**
     * 기본 노래 생성
     */
    public static Song createSong(Artist artist) {
        return Song.builder()
                .titleKor("테스트 노래")
                .titleEng("Test Song")
                .titleJp("テストソング")
                .artist(artist)
                .genre("J-POP")
                .build();
    }

    /**
     * 커스텀 제목으로 노래 생성
     */
    public static Song createSong(String titleKor, Artist artist) {
        return Song.builder()
                .titleKor(titleKor)
                .titleEng(titleKor + " EN")
                .titleJp(titleKor + " JP")
                .artist(artist)
                .genre("J-POP")
                .build();
    }

    /**
     * 추천 날짜가 있는 노래 생성
     */
    public static Song createSongWithRecommendDate(Artist artist, LocalDate recommendDate) {
        return Song.builder()
                .titleKor("오늘의 노래")
                .titleEng("Daily Song")
                .titleJp("今日の曲")
                .artist(artist)
                .genre("J-POP")
                .recommendDate(recommendDate)
                .build();
    }

    /**
     * 앨범과 함께 노래 생성
     */
    public static Song createSong(Artist artist, Album album) {
        return Song.builder()
                .titleKor("테스트 노래")
                .titleEng("Test Song")
                .titleJp("テストソング")
                .artist(artist)
                .album(album)
                .genre("J-POP")
                .build();
    }

    // ===== FeedPost =====

    /**
     * 기본 피드 게시글 생성
     */
    public static FeedPost createFeedPost(Member member) {
        return FeedPost.builder()
                .member(member)
                .content("테스트 게시글 내용입니다.")
                .build();
    }

    /**
     * 커스텀 내용으로 피드 게시글 생성
     */
    public static FeedPost createFeedPost(Member member, String content) {
        return FeedPost.builder()
                .member(member)
                .content(content)
                .build();
    }

    /**
     * 태그된 노래와 함께 피드 게시글 생성
     */
    public static FeedPost createFeedPost(Member member, Song taggedSong) {
        return FeedPost.builder()
                .member(member)
                .content("테스트 게시글 내용입니다.")
                .taggedSong(taggedSong)
                .build();
    }

    // ===== Comment =====

    /**
     * 기본 댓글 생성
     */
    public static Comment createComment(FeedPost feedPost, Member member) {
        return Comment.builder()
                .feedPost(feedPost)
                .member(member)
                .content("테스트 댓글입니다.")
                .build();
    }

    /**
     * 커스텀 내용으로 댓글 생성
     */
    public static Comment createComment(FeedPost feedPost, Member member, String content) {
        return Comment.builder()
                .feedPost(feedPost)
                .member(member)
                .content(content)
                .build();
    }

    /**
     * 대댓글 생성
     */
    public static Comment createReply(FeedPost feedPost, Member member, Comment parent) {
        return Comment.builder()
                .feedPost(feedPost)
                .member(member)
                .content("테스트 대댓글입니다.")
                .parent(parent)
                .build();
    }

    // ===== FAQ =====

    /**
     * 기본 FAQ 생성
     */
    public static FAQ createFAQ() {
        return FAQ.builder()
                .question("자주 묻는 질문입니다.")
                .answer("답변 내용입니다.")
                .category(FAQCategory.SERVICE)
                .displayOrder(0)
                .isPublished(true)
                .build();
    }

    /**
     * 커스텀 카테고리로 FAQ 생성
     */
    public static FAQ createFAQ(FAQCategory category) {
        return FAQ.builder()
                .question("자주 묻는 질문입니다. (" + category.getLabel() + ")")
                .answer("답변 내용입니다.")
                .category(category)
                .displayOrder(0)
                .isPublished(true)
                .build();
    }

    /**
     * 커스텀 질문/답변으로 FAQ 생성
     */
    public static FAQ createFAQ(String question, String answer, FAQCategory category) {
        return FAQ.builder()
                .question(question)
                .answer(answer)
                .category(category)
                .displayOrder(0)
                .isPublished(true)
                .build();
    }

    // ===== Question =====

    /**
     * 기본 문의 생성
     */
    public static Question createQuestion(Member member) {
        return Question.builder()
                .member(member)
                .type(QuestionType.SERVICE)
                .title("문의 제목입니다.")
                .content("문의 내용입니다.")
                .build();
    }

    /**
     * 커스텀 타입으로 문의 생성
     */
    public static Question createQuestion(Member member, QuestionType type) {
        return Question.builder()
                .member(member)
                .type(type)
                .title("문의 제목입니다.")
                .content("문의 내용입니다.")
                .build();
    }
}
