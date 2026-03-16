package com.hibi.server.domain.post.service;

import com.hibi.server.domain.member.entity.Member;
import com.hibi.server.domain.member.repository.MemberRepository;
import com.hibi.server.domain.post.dto.request.PostCreateRequest;
import com.hibi.server.domain.post.dto.request.PostUpdateRequest;
import com.hibi.server.domain.post.dto.response.PostResponse;
import com.hibi.server.domain.post.entity.Post;
import com.hibi.server.domain.post.repository.PostRepository;
import com.hibi.server.domain.song.entity.Song;
import com.hibi.server.domain.song.repository.SongRepository;
import com.hibi.server.global.exception.CustomException;
import com.hibi.server.global.exception.ErrorCode;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.swing.text.html.Option;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class PostService {

    private final PostRepository postRepository;
    private final SongRepository songRepository;
    private final MemberRepository memberRepository;

    @Transactional
    public PostResponse create(PostCreateRequest request) {
        if (postRepository.existsByPostedAt(request.postedAt())) {
            throw new CustomException(ErrorCode.POST_ALREADY_EXISTS);
        }
        Song song = songRepository.findById(request.songId())
                .orElseThrow(() -> new CustomException(ErrorCode.ENTITY_NOT_FOUND));

        Member member = memberRepository.findById(request.memberId())
                .orElseThrow(() -> new CustomException(ErrorCode.ENTITY_NOT_FOUND));

        Post post = Post.of(request, song, member);
        Post saved = postRepository.save(post);

        return PostResponse.from(saved);
    }

    public PostResponse getById(Long id) {
        Post post = postRepository.findById(id)
                .orElseThrow(() -> new CustomException(ErrorCode.ENTITY_NOT_FOUND));
        return PostResponse.from(post);
    }

    public List<PostResponse> getAll() {
        return postRepository.findAllAsDto(); // DTO 직접 조회 메서드 사용
    }

    @Transactional
    public PostResponse update(Long id, PostUpdateRequest request) {
        Post post = postRepository.findById(id)
                .orElseThrow(() -> new CustomException(ErrorCode.ENTITY_NOT_FOUND));
        post.update(request);
        return PostResponse.from(post);
    }

    @Transactional
    public void delete(Long id) {
        if (!postRepository.existsById(id)) {
            throw new CustomException(ErrorCode.ENTITY_NOT_FOUND);
        }
        postRepository.deleteById(id);
    }

    public PostResponse getByPostedAt(LocalDate date) {
        return postRepository.findByPostedAt(date)
                .orElseThrow(() -> new CustomException(ErrorCode.ENTITY_NOT_FOUND));
    }

    public List<PostResponse> getByPostedAtBetween(LocalDate startDate, LocalDate endDate) {
        return postRepository.findByPostedAtBetween(startDate, endDate);
    }
}