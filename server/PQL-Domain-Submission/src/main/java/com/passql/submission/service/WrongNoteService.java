package com.passql.submission.service;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.member.repository.MemberRepository;
import com.passql.submission.constant.MockExamSubject;
import com.passql.submission.constant.WrongQuestionSort;
import com.passql.submission.dto.WrongQuestionHistory;
import com.passql.submission.dto.WrongQuestionItem;
import com.passql.submission.dto.WrongQuestionRetrySetResponse;
import com.passql.submission.dto.WrongQuestionsResponse;
import com.passql.submission.repository.SubmissionRepository;
import com.passql.submission.util.QuestionStemPreview;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.sql.Timestamp;
import java.util.List;
import java.util.UUID;

/**
 * 오답 노트 (#1081): 과목·정렬·정리됨 필터 목록, 오답 다시 풀기 묶음
 * 회원의 오답 문제 전체를 한 번 읽고 고르기는 WrongNoteSelector 가 맡음
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class WrongNoteService {

    // 오답 목록 기본 개수 (@RequestParam defaultValue 용 문자열 상수)
    public static final String DEFAULT_WRONG_QUESTION_COUNT = "20";
    // 오답 목록 최대 개수 (한 번 응답)
    private static final int MAXIMUM_WRONG_QUESTION_COUNT = 100;
    // 다시 풀기 묶음 기본·최대 개수 (@RequestParam defaultValue 용 문자열 상수 포함)
    public static final String DEFAULT_RETRY_SET_SIZE = "10";
    private static final int MAXIMUM_RETRY_SET_SIZE = 10;

    private final SubmissionRepository submissionRepository;
    private final MemberRepository memberRepository;

    /** 오답 목록: 요청값 변환 > 이력 조회 > 고르기 > 개수 제한 */
    public WrongQuestionsResponse getWrongQuestions(
        UUID memberUuid, String subjectRequestValue, String sortRequestValue, boolean isResolvedIncluded, int size
    ) {
        MockExamSubject subject = MockExamSubject.fromFilterRequestValue(subjectRequestValue);
        WrongQuestionSort sort = WrongQuestionSort.fromRequestValue(sortRequestValue);
        List<WrongQuestionHistory> selected = WrongNoteSelector.select(
            loadHistories(memberUuid), subject, sort, isResolvedIncluded);

        List<WrongQuestionItem> items = selected.stream()
            .limit(clamp(size, MAXIMUM_WRONG_QUESTION_COUNT))
            .map(WrongNoteService::toWrongQuestionItem)
            .toList();
        return new WrongQuestionsResponse(items, selected.size());
    }

    /** 다시 풀기 묶음: 정리 안 된 오답 > 많이 틀린 순 > 최대 10개 UUID */
    public WrongQuestionRetrySetResponse getRetrySet(UUID memberUuid, String subjectRequestValue, int size) {
        MockExamSubject subject = MockExamSubject.fromFilterRequestValue(subjectRequestValue);
        List<UUID> questionUuids = WrongNoteSelector.select(
                loadHistories(memberUuid), subject, WrongQuestionSort.MOST_WRONG, false).stream()
            .limit(clamp(size, MAXIMUM_RETRY_SET_SIZE))
            .map(WrongQuestionHistory::questionUuid)
            .toList();
        return new WrongQuestionRetrySetResponse(questionUuids);
    }

    // 회원 확인 > 활성 문제의 오답 이력 전체
    private List<WrongQuestionHistory> loadHistories(UUID memberUuid) {
        if (!memberRepository.existsByMemberUuidAndIsDeletedFalse(memberUuid)) {
            throw new CustomException(ErrorCode.MEMBER_NOT_FOUND);
        }
        return submissionRepository.findWrongQuestionHistories(memberUuid.toString()).stream()
            .map(WrongNoteService::toWrongQuestionHistory)
            .toList();
    }

    // Object[] = { questionUuid, stem, topicName, topicCode, wrongCount, lastWrongAt, isLatestSubmissionCorrect }
    private static WrongQuestionHistory toWrongQuestionHistory(Object[] row) {
        return new WrongQuestionHistory(
            UUID.fromString((String) row[0]),
            (String) row[1],
            (String) row[2],
            (String) row[3],
            ((Number) row[4]).intValue(),
            row[5] == null ? null : ((Timestamp) row[5]).toLocalDateTime(),
            Boolean.TRUE.equals(row[6])
        );
    }

    private static WrongQuestionItem toWrongQuestionItem(WrongQuestionHistory history) {
        return new WrongQuestionItem(
            history.questionUuid(),
            QuestionStemPreview.toListPreview(history.stem()),
            history.topicName(),
            history.lastWrongAt(),
            history.wrongCount(),
            history.isResolved(),
            history.subject()
        );
    }

    // 요청 개수 1 ~ 최대 보정
    private static int clamp(int requestedSize, int maximumSize) {
        return Math.max(1, Math.min(requestedSize, maximumSize));
    }
}
