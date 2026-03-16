package com.hibi.server.domain.question.service;

import com.hibi.server.domain.member.entity.Member;
import com.hibi.server.domain.member.repository.MemberRepository;
import com.hibi.server.domain.question.dto.request.QuestionCreateRequest;
import com.hibi.server.domain.question.dto.response.QuestionListResponse;
import com.hibi.server.domain.question.dto.response.QuestionResponse;
import com.hibi.server.domain.question.entity.Question;
import com.hibi.server.domain.question.entity.QuestionType;
import com.hibi.server.domain.question.repository.QuestionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

/**
 * 문의 Service (F10)
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class QuestionService {

    private final QuestionRepository questionRepository;
    private final MemberRepository memberRepository;

    /**
     * 본인 문의 목록 조회
     */
    public QuestionListResponse getMyQuestions(Long memberId) {
        List<Question> questions = questionRepository.findByMemberIdOrderByCreatedAtDesc(memberId);

        List<QuestionResponse> questionResponses = questions.stream()
                .map(QuestionResponse::from)
                .collect(Collectors.toList());

        return QuestionListResponse.of(questionResponses);
    }

    /**
     * 문의 상세 조회 (본인 문의만)
     */
    public QuestionResponse getQuestionById(Long id, Long memberId) {
        Question question = questionRepository.findById(id)
                .filter(q -> q.getMember().getId().equals(memberId))
                .orElseThrow(() -> new IllegalArgumentException("문의를 찾을 수 없습니다."));

        return QuestionResponse.from(question);
    }

    /**
     * 문의 생성
     */
    @Transactional
    public QuestionResponse createQuestion(QuestionCreateRequest request, Long memberId) {
        Member member = memberRepository.findById(memberId)
                .orElseThrow(() -> new IllegalArgumentException("회원을 찾을 수 없습니다."));

        QuestionType type = QuestionType.fromString(request.type());

        Question question = Question.of(
                member,
                type,
                request.title(),
                request.content()
        );

        Question savedQuestion = questionRepository.save(question);

        return QuestionResponse.from(savedQuestion);
    }
}
