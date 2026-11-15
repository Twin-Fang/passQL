package com.passql.submission.service;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.question.repository.QuestionRepository;
import com.passql.submission.constant.MockExamSubject;
import com.passql.submission.dto.QuestionBookmarkItem;
import com.passql.submission.dto.QuestionBookmarkPracticeSetResponse;
import com.passql.submission.dto.QuestionBookmarkStatusResponse;
import com.passql.submission.dto.QuestionBookmarksResponse;
import com.passql.submission.entity.QuestionBookmark;
import com.passql.submission.repository.QuestionBookmarkRepository;
import com.passql.submission.util.QuestionStemPreview;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.sql.Timestamp;
import java.util.List;
import java.util.UUID;

/**
 * 문제 즐겨찾기 (#1082): 추가·해제(같은 요청 반복해도 같은 결과), 목록, 풀기 묶음, 상세 표시 여부
 * 등급 제한 없음 (무료 포함 전원 무제한)
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class QuestionBookmarkService {

    // 목록 기본·최대 페이지 크기 (@RequestParam defaultValue 용 문자열 상수 포함)
    public static final String DEFAULT_PAGE_SIZE = "20";
    private static final int MAXIMUM_PAGE_SIZE = 50;
    // 풀기 묶음 기본·최대 개수
    public static final String DEFAULT_PRACTICE_SET_SIZE = "10";
    private static final int MAXIMUM_PRACTICE_SET_SIZE = 10;

    private final QuestionBookmarkRepository questionBookmarkRepository;
    private final QuestionRepository questionRepository;

    /** 추가: 활성 문제 확인 > 없을 때만 저장 */
    @Transactional
    public QuestionBookmarkStatusResponse addBookmark(UUID memberUuid, UUID questionUuid) {
        if (!questionRepository.existsByQuestionUuidAndIsActiveTrue(questionUuid)) {
            throw new CustomException(ErrorCode.QUESTION_NOT_FOUND);
        }
        if (!questionBookmarkRepository.existsByMemberUuidAndQuestionUuid(memberUuid, questionUuid)) {
            questionBookmarkRepository.save(QuestionBookmark.builder()
                .memberUuid(memberUuid)
                .questionUuid(questionUuid)
                .build());
        }
        return new QuestionBookmarkStatusResponse(questionUuid, true);
    }

    /** 해제: 있으면 삭제 (없어도 성공) */
    @Transactional
    public QuestionBookmarkStatusResponse removeBookmark(UUID memberUuid, UUID questionUuid) {
        questionBookmarkRepository.deleteByMemberUuidAndQuestionUuid(memberUuid, questionUuid);
        return new QuestionBookmarkStatusResponse(questionUuid, false);
    }

    /** 문제 상세 별 표시 여부 */
    public boolean isBookmarked(UUID memberUuid, UUID questionUuid) {
        return questionBookmarkRepository.existsByMemberUuidAndQuestionUuid(memberUuid, questionUuid);
    }

    /** 목록 한 페이지 (page 0부터, 크기 1~50 보정) */
    public QuestionBookmarksResponse getBookmarks(UUID memberUuid, int page, int size) {
        int pageIndex = Math.max(0, page);
        int pageSize = Math.max(1, Math.min(size, MAXIMUM_PAGE_SIZE));
        List<QuestionBookmarkItem> items = questionBookmarkRepository
            .findBookmarkPage(memberUuid.toString(), pageSize, pageIndex * pageSize).stream()
            .map(QuestionBookmarkService::toQuestionBookmarkItem)
            .toList();
        long totalCount = questionBookmarkRepository.countActiveBookmarks(memberUuid.toString());
        boolean hasNext = (long) (pageIndex + 1) * pageSize < totalCount;
        return new QuestionBookmarksResponse(items, totalCount, pageIndex, hasNext);
    }

    /** 풀기 묶음: 활성 즐겨찾기 문제 무작위 최대 10개 */
    public QuestionBookmarkPracticeSetResponse getPracticeSet(UUID memberUuid, int size) {
        int setSize = Math.max(1, Math.min(size, MAXIMUM_PRACTICE_SET_SIZE));
        List<UUID> questionUuids = questionBookmarkRepository
            .findRandomBookmarkedQuestionUuids(memberUuid.toString(), setSize).stream()
            .map(UUID::fromString)
            .toList();
        return new QuestionBookmarkPracticeSetResponse(questionUuids);
    }

    // Object[] = { questionUuid, stem, topicName, topicCode, bookmarkedAt }
    private static QuestionBookmarkItem toQuestionBookmarkItem(Object[] row) {
        return new QuestionBookmarkItem(
            UUID.fromString((String) row[0]),
            QuestionStemPreview.toListPreview((String) row[1]),
            (String) row[2],
            MockExamSubject.fromTopicCode((String) row[3]),
            row[4] == null ? null : ((Timestamp) row[4]).toLocalDateTime()
        );
    }
}
