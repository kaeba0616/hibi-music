package com.hibi.server.domain.question.entity;

import com.hibi.server.domain.member.entity.Member;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

/**
 * 문의 Entity (F10)
 */
@Entity
@Table(name = "questions", indexes = {
        @Index(name = "idx_questions_member_id", columnList = "member_id"),
        @Index(name = "idx_questions_type", columnList = "type"),
        @Index(name = "idx_questions_status", columnList = "status"),
        @Index(name = "idx_questions_created_at", columnList = "created_at")
})
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor(access = AccessLevel.PRIVATE)
@Builder
public class Question {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_id", nullable = false)
    private Member member;

    @Enumerated(EnumType.STRING)
    @Column(name = "type", nullable = false, length = 20)
    private QuestionType type;

    @Column(name = "title", nullable = false, length = 100)
    private String title;

    @Lob
    @Column(name = "content", nullable = false, columnDefinition = "TEXT")
    private String content;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 20)
    @Builder.Default
    private QuestionStatus status = QuestionStatus.RECEIVED;

    @Lob
    @Column(name = "answer", columnDefinition = "TEXT")
    private String answer;

    @Column(name = "answered_at")
    private LocalDateTime answeredAt;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    /**
     * 문의 생성 팩토리 메서드
     */
    public static Question of(Member member, QuestionType type, String title, String content) {
        return Question.builder()
                .member(member)
                .type(type)
                .title(title)
                .content(content)
                .status(QuestionStatus.RECEIVED)
                .build();
    }

    /**
     * 상태를 처리중으로 변경
     */
    public void markAsProcessing() {
        this.status = QuestionStatus.PROCESSING;
    }

    /**
     * 답변 등록
     */
    public void answer(String answer) {
        this.answer = answer;
        this.answeredAt = LocalDateTime.now();
        this.status = QuestionStatus.ANSWERED;
    }

    /**
     * 문의 번호 생성 (QT-YYYYMMDD-0001 형식)
     */
    public String getQuestionNumber() {
        String dateStr = String.format("%d%02d%02d",
                createdAt.getYear(),
                createdAt.getMonthValue(),
                createdAt.getDayOfMonth());
        return String.format("QT-%s-%04d", dateStr, id);
    }
}
