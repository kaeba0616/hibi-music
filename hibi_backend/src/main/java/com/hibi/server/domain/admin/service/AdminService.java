package com.hibi.server.domain.admin.service;

import com.hibi.server.domain.admin.dto.request.*;
import com.hibi.server.domain.admin.dto.response.*;
import com.hibi.server.domain.artist.entity.Artist;
import com.hibi.server.domain.artist.repository.ArtistRepository;
import com.hibi.server.domain.comment.entity.Comment;
import com.hibi.server.domain.comment.repository.CommentRepository;
import com.hibi.server.domain.faq.entity.FAQ;
import com.hibi.server.domain.faq.entity.FAQCategory;
import com.hibi.server.domain.faq.repository.FAQRepository;
import com.hibi.server.domain.feedpost.entity.FeedPost;
import com.hibi.server.domain.feedpost.repository.FeedPostRepository;
import com.hibi.server.domain.follow.repository.MemberFollowRepository;
import com.hibi.server.domain.member.entity.Member;
import com.hibi.server.domain.member.entity.MemberStatus;
import com.hibi.server.domain.member.repository.MemberRepository;
import com.hibi.server.domain.question.entity.Question;
import com.hibi.server.domain.question.entity.QuestionStatus;
import com.hibi.server.domain.question.repository.QuestionRepository;
import com.hibi.server.domain.report.entity.Report;
import com.hibi.server.domain.report.entity.ReportStatus;
import com.hibi.server.domain.report.entity.ReportTargetType;
import com.hibi.server.domain.report.repository.ReportRepository;
import com.hibi.server.domain.song.entity.RelatedSong;
import com.hibi.server.domain.song.entity.Song;
import com.hibi.server.domain.song.repository.RelatedSongRepository;
import com.hibi.server.domain.song.repository.SongRepository;
import com.hibi.server.global.exception.CustomException;
import com.hibi.server.global.exception.ErrorCode;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

/**
 * 관리자 서비스 (F12)
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AdminService {

    private final MemberRepository memberRepository;
    private final ReportRepository reportRepository;
    private final QuestionRepository questionRepository;
    private final FAQRepository faqRepository;
    private final FeedPostRepository feedPostRepository;
    private final CommentRepository commentRepository;
    private final MemberFollowRepository memberFollowRepository;
    private final SongRepository songRepository;
    private final ArtistRepository artistRepository;
    private final RelatedSongRepository relatedSongRepository;

    // ========== 대시보드 ==========

    /**
     * 대시보드 통계 조회
     */
    public AdminStatsResponse getStats() {
        long totalMembers = memberRepository.countByDeletedAtIsNull();
        long todayNewMembers = memberRepository.countTodayNewMembers();
        long pendingReports = reportRepository.countByStatus(ReportStatus.PENDING);
        long todayNewReports = reportRepository.countTodayReports();
        long unansweredQuestions = questionRepository.countUnansweredQuestions();
        long totalFaqs = faqRepository.count();

        return AdminStatsResponse.of(
                totalMembers,
                todayNewMembers,
                pendingReports,
                todayNewReports,
                unansweredQuestions,
                totalFaqs
        );
    }

    // ========== 회원 관리 ==========

    /**
     * 회원 목록 조회
     */
    public AdminMemberListResponse getMembers(MemberStatus status, String search, int page, int size) {
        Pageable pageable = PageRequest.of(page, size);
        Page<Member> memberPage;

        if (search != null && !search.isBlank()) {
            memberPage = memberRepository.searchForAdmin(search, pageable);
        } else if (status != null) {
            memberPage = memberRepository.findByStatusAndDeletedAtIsNullOrderByCreatedAtDesc(status, pageable);
        } else {
            memberPage = memberRepository.findByDeletedAtIsNullOrderByCreatedAtDesc(pageable);
        }

        List<AdminMemberResponse> members = memberPage.getContent().stream()
                .map(member -> AdminMemberResponse.from(
                        member,
                        getPostCount(member.getId()),
                        getCommentCount(member.getId()),
                        getFollowerCount(member.getId()),
                        getFollowingCount(member.getId()),
                        (int) reportRepository.countReceivedReportsByMemberId(member.getId()),
                        (int) reportRepository.countByReporterId(member.getId())
                ))
                .collect(Collectors.toList());

        return AdminMemberListResponse.of(members, memberPage.getTotalElements(), page, size);
    }

    /**
     * 회원 상세 조회
     */
    public AdminMemberResponse getMemberDetail(Long memberId) {
        Member member = memberRepository.findById(memberId)
                .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_NOT_FOUND));

        return AdminMemberResponse.from(
                member,
                getPostCount(memberId),
                getCommentCount(memberId),
                getFollowerCount(memberId),
                getFollowingCount(memberId),
                (int) reportRepository.countReceivedReportsByMemberId(memberId),
                (int) reportRepository.countByReporterId(memberId)
        );
    }

    /**
     * 회원 제재
     */
    @Transactional
    public void sanctionMember(MemberSanctionRequest request, Member admin) {
        Member member = memberRepository.findById(request.memberId())
                .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_NOT_FOUND));

        if (request.isSuspend()) {
            LocalDateTime until = request.durationDays() != null && request.durationDays() > 0
                    ? LocalDateTime.now().plusDays(request.durationDays())
                    : null; // null이면 영구 정지
            member.suspend(until, request.reason());
        } else if (request.isBan()) {
            member.ban(request.reason());
        }

        memberRepository.save(member);
    }

    /**
     * 회원 정지 해제
     */
    @Transactional
    public void unbanMember(Long memberId) {
        Member member = memberRepository.findById(memberId)
                .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_NOT_FOUND));

        member.unban();
        memberRepository.save(member);
    }

    // ========== 신고 관리 ==========

    /**
     * 신고 목록 조회
     */
    public AdminReportListResponse getReports(ReportStatus status, int page, int size) {
        Pageable pageable = PageRequest.of(page, size);
        Page<Report> reportPage;

        if (status != null) {
            reportPage = reportRepository.findByStatusOrderByCreatedAtDesc(status, pageable);
        } else {
            reportPage = reportRepository.findAllByOrderByCreatedAtDesc(pageable);
        }

        List<AdminReportResponse> reports = reportPage.getContent().stream()
                .map(AdminReportResponse::from)
                .collect(Collectors.toList());

        return AdminReportListResponse.of(reports, reportPage.getTotalElements(), page, size);
    }

    /**
     * 신고 상세 조회
     */
    public AdminReportResponse getReportDetail(Long reportId) {
        Report report = reportRepository.findById(reportId)
                .orElseThrow(() -> new CustomException(ErrorCode.REPORT_NOT_FOUND));

        AdminReportTargetContent targetContent = getTargetContent(report);
        return AdminReportResponse.from(report, targetContent);
    }

    /**
     * 신고 처리
     */
    @Transactional
    public void processReport(ReportActionRequest request, Member admin) {
        Report report = reportRepository.findById(request.reportId())
                .orElseThrow(() -> new CustomException(ErrorCode.REPORT_NOT_FOUND));

        ReportStatus newStatus;
        if (request.isDismiss()) {
            newStatus = ReportStatus.DISMISSED;
        } else {
            newStatus = ReportStatus.RESOLVED;

            // 추가 조치
            if (request.isDeleteContent()) {
                deleteTargetContent(report);
            }
            if (request.isSuspend()) {
                suspendTargetMember(report, request.suspensionDays(), request.note());
            }
            if (request.isBan()) {
                banTargetMember(report, request.note());
            }
        }

        report.resolve(newStatus, admin, request.note());
        reportRepository.save(report);
    }

    // ========== 문의 관리 ==========

    /**
     * 문의 목록 조회
     */
    public AdminQuestionListResponse getQuestions(QuestionStatus status, int page, int size) {
        List<Question> questions;

        if (status != null) {
            questions = questionRepository.findByStatusOrderByCreatedAtDesc(status);
        } else {
            questions = questionRepository.findAllOrderByCreatedAtDesc();
        }

        // 간단한 페이징 처리
        int start = page * size;
        int end = Math.min(start + size, questions.size());
        List<Question> pagedQuestions = questions.subList(start, end);

        List<AdminQuestionResponse> responses = pagedQuestions.stream()
                .map(AdminQuestionResponse::from)
                .collect(Collectors.toList());

        return AdminQuestionListResponse.of(responses, questions.size(), page, size);
    }

    /**
     * 문의 상세 조회
     */
    public AdminQuestionResponse getQuestionDetail(Long questionId) {
        Question question = questionRepository.findById(questionId)
                .orElseThrow(() -> new CustomException(ErrorCode.QUESTION_NOT_FOUND));

        return AdminQuestionResponse.from(question);
    }

    /**
     * 문의 답변
     */
    @Transactional
    public void answerQuestion(QuestionAnswerRequest request) {
        Question question = questionRepository.findById(request.questionId())
                .orElseThrow(() -> new CustomException(ErrorCode.QUESTION_NOT_FOUND));

        question.answer(request.answer());
        questionRepository.save(question);
    }

    // ========== FAQ 관리 ==========

    /**
     * FAQ 목록 조회 (관리자용 - 비공개 포함)
     */
    public AdminFAQListResponse getFaqs(FAQCategory category) {
        List<FAQ> faqs;

        if (category != null) {
            faqs = faqRepository.findByCategoryForAdmin(category);
        } else {
            faqs = faqRepository.findAllForAdmin();
        }

        List<AdminFAQResponse> responses = faqs.stream()
                .map(AdminFAQResponse::from)
                .collect(Collectors.toList());

        return AdminFAQListResponse.of(responses);
    }

    /**
     * FAQ 생성/수정
     */
    @Transactional
    public AdminFAQResponse saveFaq(FAQSaveRequest request) {
        FAQ faq;

        if (request.isCreate()) {
            faq = FAQ.of(
                    request.question(),
                    request.answer(),
                    request.getCategoryEnum(),
                    request.displayOrder()
            );
            if (!request.getIsPublishedOrDefault()) {
                faq.unpublish();
            }
        } else {
            faq = faqRepository.findById(request.id())
                    .orElseThrow(() -> new CustomException(ErrorCode.FAQ_NOT_FOUND));

            faq.updateContent(request.question(), request.answer());
            faq.updateCategory(request.getCategoryEnum());
            faq.updateDisplayOrder(request.displayOrder());

            if (request.getIsPublishedOrDefault()) {
                faq.publish();
            } else {
                faq.unpublish();
            }
        }

        FAQ saved = faqRepository.save(faq);
        return AdminFAQResponse.from(saved);
    }

    /**
     * FAQ 삭제
     */
    @Transactional
    public void deleteFaq(Long faqId) {
        if (!faqRepository.existsById(faqId)) {
            throw new CustomException(ErrorCode.FAQ_NOT_FOUND);
        }
        faqRepository.deleteById(faqId);
    }

    // ========== F18: 관리자 곡 등록 (Enhanced) ==========

    /**
     * 관리자 곡 등록 (상세)
     */
    @Transactional
    public void createAdminSong(AdminSongCreateRequest request) {
        Artist artist = artistRepository.findById(request.artistId())
                .orElseThrow(() -> new CustomException(ErrorCode.ENTITY_NOT_FOUND));

        Song song = Song.builder()
                .titleKor(request.titleKor())
                .titleEng(request.titleEng())
                .titleJp(request.titleJp())
                .artist(artist)
                .story(request.story())
                .lyricsJp(request.lyricsJp())
                .lyricsKr(request.lyricsKr())
                .linkYoutube(request.youtubeUrl())
                .build();

        Song savedSong = songRepository.save(song);

        // 연관곡 등록
        if (request.relatedSongIds() != null && !request.relatedSongIds().isEmpty()) {
            for (AdminSongCreateRequest.RelatedSongInput input : request.relatedSongIds()) {
                Song relatedSongRef = songRepository.findById(input.relatedSongId())
                        .orElseThrow(() -> new CustomException(ErrorCode.ENTITY_NOT_FOUND));

                RelatedSong relatedSong = RelatedSong.of(savedSong, relatedSongRef, input.reason());
                relatedSongRepository.save(relatedSong);
            }
        }
    }

    /**
     * 예약 게시 등록
     */
    @Transactional
    public void scheduleSongPublish(Long songId, SchedulePublishRequest request) {
        Song song = songRepository.findById(songId)
                .orElseThrow(() -> new CustomException(ErrorCode.ENTITY_NOT_FOUND));

        if (!song.isComplete()) {
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE);
        }

        song.updateScheduledPublishAt(request.scheduledAt());
        songRepository.save(song);
    }

    /**
     * 예약 취소
     */
    @Transactional
    public void cancelScheduledPublish(Long songId) {
        Song song = songRepository.findById(songId)
                .orElseThrow(() -> new CustomException(ErrorCode.ENTITY_NOT_FOUND));

        song.cancelSchedule();
        songRepository.save(song);
    }

    // ========== F18: 관리자 댓글 관리 ==========

    /**
     * 관리자 댓글 목록 조회
     */
    public AdminCommentListResponse getAdminComments(boolean onlyReported, int page, int size) {
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt"));
        Page<Comment> commentPage;

        if (onlyReported) {
            // 신고된 댓글만 조회 - 간단히 필터링된 댓글 조회
            commentPage = commentRepository.findAll(pageable);
            // 신고 수가 있는 댓글만 필터 (실제 구현에서는 별도 쿼리 사용)
        } else {
            commentPage = commentRepository.findAll(pageable);
        }

        List<AdminCommentResponse> comments = commentPage.getContent().stream()
                .map(comment -> {
                    int reportCount = (int) reportRepository.countByTargetTypeAndTargetId(
                            ReportTargetType.COMMENT, comment.getId());
                    return AdminCommentResponse.from(comment, reportCount);
                })
                .collect(Collectors.toList());

        if (onlyReported) {
            comments = comments.stream()
                    .filter(c -> c.reportCount() > 0)
                    .collect(Collectors.toList());
        }

        return AdminCommentListResponse.of(comments, commentPage.getTotalElements(), page, size);
    }

    /**
     * 관리자 댓글 삭제
     */
    @Transactional
    public void deleteAdminComment(Long commentId) {
        Comment comment = commentRepository.findById(commentId)
                .orElseThrow(() -> new CustomException(ErrorCode.ENTITY_NOT_FOUND));

        commentRepository.delete(comment);
    }

    // ========== Private 메서드 ==========

    private int getPostCount(Long memberId) {
        try {
            return (int) feedPostRepository.countByMemberId(memberId);
        } catch (Exception e) {
            return 0;
        }
    }

    private int getCommentCount(Long memberId) {
        try {
            return (int) commentRepository.countByMemberId(memberId);
        } catch (Exception e) {
            return 0;
        }
    }

    private int getFollowerCount(Long memberId) {
        try {
            return (int) memberFollowRepository.countByFollowingId(memberId);
        } catch (Exception e) {
            return 0;
        }
    }

    private int getFollowingCount(Long memberId) {
        try {
            return (int) memberFollowRepository.countByFollowerId(memberId);
        } catch (Exception e) {
            return 0;
        }
    }

    private AdminReportTargetContent getTargetContent(Report report) {
        try {
            switch (report.getTargetType()) {
                case POST -> {
                    return feedPostRepository.findById(report.getTargetId())
                            .map(post -> AdminReportTargetContent.ofPost(
                                    post.getId(),
                                    post.getContent(),
                                    post.getMember().getNickname(),
                                    post.getMember().getId(),
                                    post.getCreatedAt()
                            ))
                            .orElse(null);
                }
                case COMMENT -> {
                    return commentRepository.findById(report.getTargetId())
                            .map(comment -> AdminReportTargetContent.ofComment(
                                    comment.getId(),
                                    comment.getContent(),
                                    comment.getMember().getNickname(),
                                    comment.getMember().getId(),
                                    comment.getCreatedAt()
                            ))
                            .orElse(null);
                }
                case MEMBER -> {
                    return memberRepository.findById(report.getTargetId())
                            .map(member -> AdminReportTargetContent.ofMember(
                                    member.getId(),
                                    member.getNickname(),
                                    member.getProfileUrl(),
                                    member.getCreatedAt()
                            ))
                            .orElse(null);
                }
                default -> {
                    return null;
                }
            }
        } catch (Exception e) {
            return null;
        }
    }

    private void deleteTargetContent(Report report) {
        switch (report.getTargetType()) {
            case POST -> feedPostRepository.deleteById(report.getTargetId());
            case COMMENT -> commentRepository.deleteById(report.getTargetId());
            // MEMBER는 콘텐츠 삭제 대상 아님
        }
    }

    private void suspendTargetMember(Report report, Integer days, String reason) {
        Long memberId = getTargetMemberId(report);
        if (memberId != null) {
            memberRepository.findById(memberId).ifPresent(member -> {
                LocalDateTime until = days != null && days > 0
                        ? LocalDateTime.now().plusDays(days)
                        : null;
                member.suspend(until, reason);
                memberRepository.save(member);
            });
        }
    }

    private void banTargetMember(Report report, String reason) {
        Long memberId = getTargetMemberId(report);
        if (memberId != null) {
            memberRepository.findById(memberId).ifPresent(member -> {
                member.ban(reason);
                memberRepository.save(member);
            });
        }
    }

    private Long getTargetMemberId(Report report) {
        switch (report.getTargetType()) {
            case MEMBER -> {
                return report.getTargetId();
            }
            case POST -> {
                return feedPostRepository.findById(report.getTargetId())
                        .map(post -> post.getMember().getId())
                        .orElse(null);
            }
            case COMMENT -> {
                return commentRepository.findById(report.getTargetId())
                        .map(comment -> comment.getMember().getId())
                        .orElse(null);
            }
            default -> {
                return null;
            }
        }
    }
}
