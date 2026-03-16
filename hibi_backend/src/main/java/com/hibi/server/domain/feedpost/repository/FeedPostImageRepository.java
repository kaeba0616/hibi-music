package com.hibi.server.domain.feedpost.repository;

import com.hibi.server.domain.feedpost.entity.FeedPostImage;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface FeedPostImageRepository extends JpaRepository<FeedPostImage, Long> {

    /**
     * 게시글의 이미지 목록 조회 (순서대로)
     */
    List<FeedPostImage> findByFeedPostIdOrderByOrderIndexAsc(Long feedPostId);

    /**
     * 게시글의 이미지 모두 삭제
     */
    @Modifying
    @Query("DELETE FROM FeedPostImage i WHERE i.feedPost.id = :feedPostId")
    void deleteByFeedPostId(@Param("feedPostId") Long feedPostId);
}
