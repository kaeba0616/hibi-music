package com.hibi.server.domain.question.repository;

import com.hibi.server.domain.member.entity.Member;
import com.hibi.server.domain.question.entity.Question;
import com.hibi.server.domain.question.entity.QuestionStatus;
import com.hibi.server.domain.question.entity.QuestionType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

/**
 * 문의 Repository (F10)
 */
@Repository
public interface QuestionRepository extends JpaRepository<Question, Long> {

    /**
     * 특정 회원의 문의 목록 조회 (최신순)
     */
    List<Question> findByMemberOrderByCreatedAtDesc(Member member);

    /**
     * 특정 회원의 문의 목록 조회 (회원 ID로)
     */
    @Query("SELECT q FROM Question q WHERE q.member.id = :memberId ORDER BY q.createdAt DESC")
    List<Question> findByMemberIdOrderByCreatedAtDesc(@Param("memberId") Long memberId);

    /**
     * 특정 회원의 특정 문의 조회 (본인 확인용)
     */
    Optional<Question> findByIdAndMember(Long id, Member member);

    /**
     * 상태별 문의 조회 (관리자용)
     */
    List<Question> findByStatusOrderByCreatedAtAsc(QuestionStatus status);

    /**
     * 유형별 문의 조회 (관리자용)
     */
    List<Question> findByTypeOrderByCreatedAtDesc(QuestionType type);

    /**
     * 답변 대기 문의 조회 (관리자용 - 접수됨 + 처리중)
     */
    @Query("SELECT q FROM Question q WHERE q.status IN (:statuses) ORDER BY q.createdAt ASC")
    List<Question> findPendingQuestions(@Param("statuses") List<QuestionStatus> statuses);

    /**
     * 특정 회원의 문의 수 조회
     */
    long countByMember(Member member);

    // ========== F12 관리자 기능용 쿼리 메서드 ==========

    /**
     * 미답변 문의 수 조회 (대시보드용)
     */
    @Query("SELECT COUNT(q) FROM Question q WHERE q.status <> 'ANSWERED'")
    long countUnansweredQuestions();

    /**
     * 전체 문의 목록 조회 (관리자용)
     */
    @Query("SELECT q FROM Question q ORDER BY q.createdAt DESC")
    List<Question> findAllOrderByCreatedAtDesc();

    /**
     * 상태별 문의 목록 조회 (관리자용)
     */
    List<Question> findByStatusOrderByCreatedAtDesc(QuestionStatus status);

    /**
     * 특정 회원의 오늘 작성한 문의 수 조회 (F17 일일 3개 제한)
     */
    @Query("SELECT COUNT(q) FROM Question q WHERE q.member.id = :memberId AND q.createdAt >= :startOfDay")
    long countTodayQuestionsByMemberId(@Param("memberId") Long memberId, @Param("startOfDay") LocalDateTime startOfDay);
}
