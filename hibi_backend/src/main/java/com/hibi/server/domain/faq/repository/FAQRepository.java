package com.hibi.server.domain.faq.repository;

import com.hibi.server.domain.faq.entity.FAQ;
import com.hibi.server.domain.faq.entity.FAQCategory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface FAQRepository extends JpaRepository<FAQ, Long> {

    /**
     * 공개된 FAQ 목록 조회 (정렬: 카테고리 → 순서)
     */
    @Query("SELECT f FROM FAQ f WHERE f.isPublished = true ORDER BY f.category, f.displayOrder")
    List<FAQ> findAllPublished();

    /**
     * 카테고리별 공개된 FAQ 목록 조회
     */
    @Query("SELECT f FROM FAQ f WHERE f.isPublished = true AND f.category = :category ORDER BY f.displayOrder")
    List<FAQ> findByCategory(@Param("category") FAQCategory category);

    /**
     * 키워드 검색 (질문/답변에서 검색)
     */
    @Query("SELECT f FROM FAQ f WHERE f.isPublished = true AND " +
           "(LOWER(f.question) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
           "LOWER(f.answer) LIKE LOWER(CONCAT('%', :keyword, '%'))) " +
           "ORDER BY f.category, f.displayOrder")
    List<FAQ> searchByKeyword(@Param("keyword") String keyword);

    /**
     * 카테고리 + 키워드 검색
     */
    @Query("SELECT f FROM FAQ f WHERE f.isPublished = true AND f.category = :category AND " +
           "(LOWER(f.question) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
           "LOWER(f.answer) LIKE LOWER(CONCAT('%', :keyword, '%'))) " +
           "ORDER BY f.displayOrder")
    List<FAQ> searchByCategoryAndKeyword(
            @Param("category") FAQCategory category,
            @Param("keyword") String keyword
    );

    /**
     * 특정 카테고리의 FAQ 수 조회
     */
    long countByCategoryAndIsPublishedTrue(FAQCategory category);

    /**
     * 공개된 FAQ 수 조회
     */
    long countByIsPublishedTrue();

    /**
     * 관리자용: 모든 FAQ 조회 (공개/비공개 포함)
     */
    @Query("SELECT f FROM FAQ f ORDER BY f.category, f.displayOrder")
    List<FAQ> findAllForAdmin();

    // ========== F12 관리자 기능용 쿼리 메서드 ==========

    /**
     * 전체 FAQ 수 조회 (대시보드용)
     */
    long count();

    /**
     * 카테고리별 FAQ 목록 조회 (관리자용 - 비공개 포함)
     */
    @Query("SELECT f FROM FAQ f WHERE f.category = :category ORDER BY f.displayOrder")
    List<FAQ> findByCategoryForAdmin(@Param("category") FAQCategory category);
}
