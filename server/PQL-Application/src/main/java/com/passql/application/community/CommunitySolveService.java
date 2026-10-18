package com.passql.application.community;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.meta.entity.Topic;
import com.passql.meta.repository.TopicRepository;
import com.passql.question.dto.community.SolveSnapshot;
import com.passql.question.entity.Question;
import com.passql.submission.entity.Submission;
import com.passql.submission.repository.SubmissionRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.UUID;

/**
 * 풀이 기반 커뮤니티 규칙: 풀이 전 접근 차단(정답 노출 방지), 풀이 스냅샷 생성·해석
 * 스냅샷은 서버가 제출 기록으로만 만든다 (클라이언트 값 불신)
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class CommunitySolveService {

    private final SubmissionRepository submissionRepository;
    private final TopicRepository topicRepository;
    private final ObjectMapper objectMapper;

    /** 이 문제 제출 기록이 없으면 COMMUNITY_SOLVE_REQUIRED (400) */
    public void requireSolved(UUID memberUuid, UUID questionUuid) {
        if (!submissionRepository.existsByMemberUuidAndQuestionUuid(memberUuid, questionUuid)) {
            log.warn("[community] rejected 400 : no submission, question={}", questionUuid);
            throw new CustomException(ErrorCode.COMMUNITY_SOLVE_REQUIRED);
        }
    }

    /**
     * 제출 기록 > 스냅샷 JSON
     * 정답 여부: 한 번이라도 맞힘, 시도 횟수: 처음 맞힌 제출까지(못 맞혔으면 전체), 시각: 결과를 정한 제출
     */
    public String buildSnapshotJson(UUID memberUuid, Question question) {
        List<Submission> submissions = submissionRepository
                .findByMemberUuidAndQuestionUuidOrderBySubmittedAtAsc(memberUuid, question.getQuestionUuid());
        if (submissions.isEmpty()) {
            log.warn("[community] rejected 400 : snapshot without submission, question={}", question.getQuestionUuid());
            throw new CustomException(ErrorCode.COMMUNITY_SOLVE_REQUIRED);
        }
        Submission deciding = submissions.stream().filter(Submission::getIsCorrect).findFirst()
                .orElse(submissions.get(submissions.size() - 1));
        SolveSnapshot snapshot = new SolveSnapshot(
                deciding.getIsCorrect(),
                submissions.indexOf(deciding) + 1,
                deciding.getSubmittedAt().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME),
                topicRepository.findById(question.getTopicUuid()).map(Topic::getCode).orElse(null),
                question.getDifficulty());
        try {
            return objectMapper.writeValueAsString(snapshot);
        } catch (JsonProcessingException e) {
            throw new CustomException(ErrorCode.INTERNAL_SERVER_ERROR);
        }
    }

    /** 저장된 JSON > 응답용 스냅샷 (없거나 깨졌으면 null) */
    public SolveSnapshot parseSnapshot(String snapshotJson) {
        if (snapshotJson == null || snapshotJson.isBlank()) {
            return null;
        }
        try {
            return objectMapper.readValue(snapshotJson, SolveSnapshot.class);
        } catch (JsonProcessingException e) {
            log.warn("[community] snapshot parse failed : {}", e.getClass().getSimpleName());
            return null;
        }
    }
}
