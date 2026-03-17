package com.hibi.server.domain.question.service;

import com.hibi.server.domain.member.entity.Member;
import com.hibi.server.domain.member.repository.MemberRepository;
import com.hibi.server.domain.question.dto.request.QuestionCreateRequest;
import com.hibi.server.domain.question.dto.response.QuestionListResponse;
import com.hibi.server.domain.question.dto.response.QuestionResponse;
import com.hibi.server.domain.question.entity.Question;
import com.hibi.server.domain.question.entity.QuestionType;
import com.hibi.server.domain.question.repository.QuestionRepository;
import com.hibi.server.global.exception.CustomException;
import com.hibi.server.global.exception.ErrorCode;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;
import java.util.stream.Collectors;

/**
 * 문의 Service (F10)
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class QuestionService {

    private static final int DAILY_QUESTION_LIMIT = 3;

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
     * 오늘의 문의 작성 수 조회 (F17)
     */
    public long getTodayQuestionCount(Long memberId) {
        LocalDateTime startOfDay = LocalDate.now().atStartOfDay();
        return questionRepository.countTodayQuestionsByMemberId(memberId, startOfDay);
    }

    /**
     * 문의 생성 (F17: 일일 3개 제한 적용)
     */
    @Transactional
    public QuestionResponse createQuestion(QuestionCreateRequest request, Long memberId) {
        Member member = memberRepository.findById(memberId)
                .orElseThrow(() -> new IllegalArgumentException("회원을 찾을 수 없습니다."));

        // F17: 일일 문의 작성 제한 체크
        long todayCount = getTodayQuestionCount(memberId);
        if (todayCount >= DAILY_QUESTION_LIMIT) {
            throw new CustomException(ErrorCode.DAILY_QUESTION_LIMIT_EXCEEDED);
        }

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
