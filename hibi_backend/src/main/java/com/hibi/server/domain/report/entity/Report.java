package com.hibi.server.domain.report.entity;

import com.hibi.server.domain.member.entity.Member;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

/**
 * 신고 Entity (F11)
 */
@Entity
@Table(name = "reports", indexes = {
        @Index(name = "idx_reports_reporter_id", columnList = "reporter_id"),
        @Index(name = "idx_reports_target", columnList = "target_type, target_id"),
        @Index(name = "idx_reports_status", columnList = "status"),
        @Index(name = "idx_reports_created_at", columnList = "created_at")
}, uniqueConstraints = {
        // 동일 사용자가 동일 대상에 대해 중복 신고 방지 (AC-F11-7)
        @UniqueConstraint(
                name = "uk_reports_reporter_target",
                columnNames = {"reporter_id", "target_type", "target_id"}
        )
})
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor(access = AccessLevel.PRIVATE)
@Builder
public class Report {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "reporter_id", nullable = false)
    private Member reporter;

    @Enumerated(EnumType.STRING)
    @Column(name = "target_type", nullable = false, length = 20)
    private ReportTargetType targetType;

    @Column(name = "target_id", nullable = false)
    private Long targetId;

    @Enumerated(EnumType.STRING)
    @Column(name = "reason", nullable = false, length = 20)
    private ReportReason reason;

    @Column(name = "description", length = 300)
    private String description;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 20)
    @Builder.Default
    private ReportStatus status = ReportStatus.PENDING;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @Column(name = "admin_note", length = 500)
    private String adminNote;

    @Column(name = "resolved_at")
    private LocalDateTime resolvedAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "resolved_by")
    private Member resolvedBy;

    /**
     * 신고 생성 팩토리 메서드
     */
    public static Report of(Member reporter, ReportTargetType targetType, Long targetId,
                            ReportReason reason, String description) {
        return Report.builder()
                .reporter(reporter)
                .targetType(targetType)
                .targetId(targetId)
                .reason(reason)
                .description(description)
                .status(ReportStatus.PENDING)
                .build();
    }

    /**
     * 게시글 신고 생성
     */
    public static Report ofPost(Member reporter, Long postId, ReportReason reason, String description) {
        return of(reporter, ReportTargetType.POST, postId, reason, description);
    }

    /**
     * 댓글 신고 생성
     */
    public static Report ofComment(Member reporter, Long commentId, ReportReason reason, String description) {
        return of(reporter, ReportTargetType.COMMENT, commentId, reason, description);
    }

    /**
     * 사용자 신고 생성
     */
    public static Report ofMember(Member reporter, Long memberId, ReportReason reason, String description) {
        return of(reporter, ReportTargetType.MEMBER, memberId, reason, description);
    }

    /**
     * 상태를 검토됨으로 변경
     */
    public void markAsReviewed() {
        this.status = ReportStatus.REVIEWED;
    }

    /**
     * 상태를 처리완료로 변경
     */
    public void markAsResolved() {
        this.status = ReportStatus.RESOLVED;
    }

    /**
     * 상태를 기각으로 변경
     */
    public void markAsDismissed() {
        this.status = ReportStatus.DISMISSED;
    }

    /**
     * 신고 처리 (관리자용)
     */
    public void resolve(ReportStatus status, Member admin, String note) {
        this.status = status;
        this.resolvedBy = admin;
        this.adminNote = note;
        this.resolvedAt = LocalDateTime.now();
    }
}
