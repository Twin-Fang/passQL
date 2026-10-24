package com.passql.application.service;

import com.passql.common.util.TextPreview;
import com.passql.member.dto.MemberAdminListResponse;
import com.passql.member.dto.MemberSearchCondition;
import com.passql.member.service.MemberAdminService;
import com.passql.question.entity.Question;
import com.passql.question.repository.QuestionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * 관리자 전역 검색: 입력 1개 > 회원(UUID·닉네임)·문제(UUID) 후보
 * UUID 형식이면 회원·문제 정확 일치, 아니면 닉네임 부분 일치 (결과 최대 20건)
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AdminGlobalSearchService {

    // 회원 닉네임 검색 결과 최대 건수
    private static final int MAX_MEMBER_RESULT_COUNT = 20;
    // 문제 본문 미리보기 길이 (자)
    private static final int QUESTION_STEM_PREVIEW_LENGTH = 80;

    private final MemberAdminService memberAdminService;
    private final QuestionRepository questionRepository;

    /** 문제 검색 결과 1건 */
    public record QuestionHit(UUID questionUuid, String stemPreview, boolean isActive) {
    }

    /** 검색 결과 묶음 */
    public record Result(String keyword, List<MemberAdminListResponse> members, List<QuestionHit> questions) {
        public boolean isEmpty() {
            return members.isEmpty() && questions.isEmpty();
        }

        /** 결과가 정확히 1건이면 바로 이동할 경로 (회원 상세 또는 문제 상세) */
        public Optional<String> findSingleHitPath() {
            if (members.size() + questions.size() != 1) {
                return Optional.empty();
            }
            return members.isEmpty()
                    ? Optional.of("/admin/questions/" + questions.get(0).questionUuid())
                    : Optional.of("/admin/members/" + members.get(0).memberUuid());
        }
    }

    /** 검색어 > 결과 (빈 검색어는 빈 결과) */
    public Result search(String rawKeyword) {
        String keyword = rawKeyword == null ? "" : rawKeyword.trim();
        if (!StringUtils.hasText(keyword)) {
            return new Result(keyword, List.of(), List.of());
        }
        Optional<UUID> uuidKeyword = parseUuid(keyword);
        if (uuidKeyword.isPresent()) {
            return new Result(keyword, findMembersByUuid(uuidKeyword.get()), findQuestionsByUuid(uuidKeyword.get()));
        }
        return new Result(keyword, findMembersByNickname(keyword), List.of());
    }

    private List<MemberAdminListResponse> findMembersByUuid(UUID memberUuid) {
        return memberAdminService.findMemberListItem(memberUuid).map(List::of).orElse(List.of());
    }

    private List<MemberAdminListResponse> findMembersByNickname(String nickname) {
        MemberSearchCondition condition = new MemberSearchCondition();
        condition.setNickname(nickname);
        // 테스트 계정도 운영 중 문의 대상일 수 있어 포함
        condition.setIncludeTest(true);
        return memberAdminService.searchMembers(condition, PageRequest.of(0, MAX_MEMBER_RESULT_COUNT)).getContent();
    }

    private List<QuestionHit> findQuestionsByUuid(UUID questionUuid) {
        return questionRepository.findById(questionUuid)
                .map(this::toQuestionHit)
                .map(List::of)
                .orElse(List.of());
    }

    private QuestionHit toQuestionHit(Question question) {
        return new QuestionHit(question.getQuestionUuid(),
                TextPreview.truncateWithEllipsis(question.getStem(), QUESTION_STEM_PREVIEW_LENGTH),
                Boolean.TRUE.equals(question.getIsActive()));
    }

    private Optional<UUID> parseUuid(String text) {
        try {
            return Optional.of(UUID.fromString(text));
        } catch (IllegalArgumentException e) {
            return Optional.empty();
        }
    }
}
