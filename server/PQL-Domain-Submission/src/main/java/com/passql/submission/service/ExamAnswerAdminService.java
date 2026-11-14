package com.passql.submission.service;

import com.passql.common.audit.AdminAuditEvent;
import com.passql.common.audit.constant.AdminAuditAction;
import com.passql.common.audit.constant.AdminAuditTargetType;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.common.util.RequestEnumParser;
import com.passql.meta.constant.CertType;
import com.passql.submission.constant.ExamAnswerItemStatus;
import com.passql.submission.constant.ExamAnswerRoundStatus;
import com.passql.submission.dto.examanswer.AdminExamAnswerItemRow;
import com.passql.submission.dto.examanswer.AdminExamAnswerItemUpdateRequest;
import com.passql.submission.dto.examanswer.AdminExamAnswerItemsUpdateResult;
import com.passql.submission.dto.examanswer.AdminExamAnswerRoundCreateRequest;
import com.passql.submission.dto.examanswer.AdminExamAnswerRoundRow;
import com.passql.submission.dto.examanswer.AdminExamAnswerRoundUpdateRequest;
import com.passql.submission.dto.examanswer.ExamAnswerItemResponse;
import com.passql.submission.entity.ExamAnswerItem;
import com.passql.submission.entity.ExamAnswerRound;
import com.passql.submission.repository.ExamAnswerItemRepository;
import com.passql.submission.repository.ExamAnswerRoundRepository;
import com.passql.submission.repository.ExamAnswerSheetRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.function.Function;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

/**
 * 관리자 가답안 (#1075): 회차 목록·생성(문항 50행)·수정, 문항 일괄 수정, 공식 정답 일괄 반영, 득표 현황
 * 변경은 커밋 뒤 공개 집계 캐시를 비움
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ExamAnswerAdminService {

    // 복수 정답 형식 (예: "2,3")
    private static final Pattern ALTERNATIVE_ANSWERS_PATTERN = Pattern.compile("^[1-4](,[1-4]){0,3}$");
    // 문항 입력 최대 길이 (exam_answer_item 컬럼 길이와 같게)
    private static final int MAX_CONCEPT_TITLE_LENGTH = 200;
    private static final int MAX_CONCEPT_TAGS_LENGTH = 300;
    private static final int MAX_TOPIC_CODE_LENGTH = 50;
    private static final int MAX_NOTE_LENGTH = 500;

    private final ExamAnswerRoundRepository examAnswerRoundRepository;
    private final ExamAnswerItemRepository examAnswerItemRepository;
    private final ExamAnswerSheetRepository examAnswerSheetRepository;
    private final ExamAnswerSnapshotLoader examAnswerSnapshotLoader;
    private final ExamAnswerSnapshotCache examAnswerSnapshotCache;
    private final ApplicationEventPublisher eventPublisher;

    public List<AdminExamAnswerRoundRow> getRounds() {
        return examAnswerRoundRepository.findAllByOrderByExamDateDescRoundNumberDesc().stream()
                .map(this::toRoundRow)
                .toList();
    }

    public AdminExamAnswerRoundRow getRound(UUID roundUuid) {
        return toRoundRow(findRound(roundUuid));
    }

    /** 문항 편집 행 50개 (운영 입력값 + 지금 득표, 캐시 없이 새로 계산) */
    public List<AdminExamAnswerItemRow> getItemRows(UUID roundUuid) {
        ExamAnswerRound round = findRound(roundUuid);
        Map<Integer, ExamAnswerItemResponse> publicItemByQuestionNo = examAnswerSnapshotLoader.load(round).response().items()
                .stream().collect(Collectors.toMap(ExamAnswerItemResponse::questionNo, Function.identity()));
        return examAnswerItemRepository.findAllByExamAnswerRoundUuidOrderByQuestionNoAsc(roundUuid).stream()
                .map(item -> toItemRow(item, publicItemByQuestionNo.get(item.getQuestionNo())))
                .toList();
    }

    /** 회차 생성: 중복 검사 > 회차 저장 > 빈 문항 50행 */
    @Transactional
    public UUID createRound(AdminExamAnswerRoundCreateRequest request) {
        CertType certType = CertType.fromRequestValue(request.certType());
        if (examAnswerRoundRepository.existsByCertTypeAndRoundNumber(certType, request.roundNumber())) {
            throw new CustomException(ErrorCode.EXAM_ANSWER_ROUND_DUPLICATE);
        }
        ExamAnswerRound round = examAnswerRoundRepository.save(ExamAnswerRound.builder()
                .certType(certType)
                .roundNumber(request.roundNumber())
                .examDate(request.examDate())
                .title(request.title().trim())
                .notice(blankToNull(request.notice()))
                .build());

        List<ExamAnswerItem> items = new ArrayList<>(MockExamRule.TOTAL_QUESTION_COUNT);
        for (int questionNo = 1; questionNo <= MockExamRule.TOTAL_QUESTION_COUNT; questionNo++) {
            items.add(ExamAnswerItem.builder()
                    .examAnswerRoundUuid(round.getExamAnswerRoundUuid())
                    .questionNo(questionNo)
                    .subjectNo(ExamAnswerGrader.toSubjectNo(questionNo))
                    .build());
        }
        examAnswerItemRepository.saveAll(items);

        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.EXAM_ANSWER_ROUND, round.getExamAnswerRoundUuid(),
                AdminAuditAction.CREATE, null, AdminAuditEvent.summary(
                        "certType", certType.name(), "roundNumber", round.getRoundNumber(), "examDate", round.getExamDate())));
        return round.getExamAnswerRoundUuid();
    }

    /** 회차 정보 수정 (제목·시험일·상태·안내) */
    @Transactional
    public void updateRound(UUID roundUuid, AdminExamAnswerRoundUpdateRequest request) {
        ExamAnswerRound round = findRound(roundUuid);
        ExamAnswerRoundStatus beforeStatus = round.getStatus();
        round.setTitle(request.title().trim());
        round.setExamDate(request.examDate());
        round.setStatus(ExamAnswerRoundStatus.fromRequestValue(request.status()));
        round.setNotice(blankToNull(request.notice()));

        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.EXAM_ANSWER_ROUND, roundUuid,
                AdminAuditAction.UPDATE, AdminAuditEvent.summary("status", beforeStatus.name()),
                AdminAuditEvent.summary("status", round.getStatus().name(), "title", round.getTitle())));
        examAnswerSnapshotCache.evictAfterCommit(roundUuid);
    }

    /** 문항 일괄 수정 (null 필드 유지, "" / 0 은 지움) */
    @Transactional
    public AdminExamAnswerItemsUpdateResult updateItems(UUID roundUuid, List<AdminExamAnswerItemUpdateRequest> requests) {
        findRound(roundUuid);
        Map<Integer, ExamAnswerItem> itemByQuestionNo = findItemByQuestionNo(roundUuid);

        // 요청 검증 먼저 (전부 통과해야 반영) > 반영
        if (requests == null || requests.isEmpty()) {
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE, "수정할 문항이 없습니다.");
        }
        for (AdminExamAnswerItemUpdateRequest request : requests) {
            String rejectReason = findItemUpdateRejectReason(request, itemByQuestionNo);
            if (rejectReason != null) {
                throw new CustomException(ErrorCode.INVALID_INPUT_VALUE, rejectReason);
            }
        }
        for (AdminExamAnswerItemUpdateRequest request : requests) {
            applyItemUpdate(itemByQuestionNo.get(request.questionNo()), request);
        }

        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.EXAM_ANSWER_ROUND, roundUuid,
                AdminAuditAction.UPDATE, null, AdminAuditEvent.summary("updatedItemCount", requests.size())));
        examAnswerSnapshotCache.evictAfterCommit(roundUuid);
        return new AdminExamAnswerItemsUpdateResult(requests.size());
    }

    /** 공식 정답 50자 반영: 0 아닌 자리 > 운영 가답안 + OFFICIAL, 회차 OFFICIAL */
    @Transactional
    public AdminExamAnswerItemsUpdateResult applyOfficialAnswers(UUID roundUuid, String officialAnswers) {
        ExamAnswerRound round = findRound(roundUuid);
        Map<Integer, ExamAnswerItem> itemByQuestionNo = findItemByQuestionNo(roundUuid);

        int updatedCount = 0;
        for (int questionNo = 1; questionNo <= MockExamRule.TOTAL_QUESTION_COUNT; questionNo++) {
            int officialAnswer = officialAnswers.charAt(questionNo - 1) - '0';
            ExamAnswerItem item = itemByQuestionNo.get(questionNo);
            if (officialAnswer == 0 || item == null) {
                continue;
            }
            item.setOperatorAnswer(officialAnswer);
            item.setOperatorAnswerStatus(ExamAnswerItemStatus.OFFICIAL);
            updatedCount++;
        }
        round.setStatus(ExamAnswerRoundStatus.OFFICIAL);

        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.EXAM_ANSWER_ROUND, roundUuid,
                AdminAuditAction.UPDATE, null, AdminAuditEvent.summary("officialAnswers", officialAnswers)));
        examAnswerSnapshotCache.evictAfterCommit(roundUuid);
        return new AdminExamAnswerItemsUpdateResult(updatedCount);
    }

    /**
     * 문항 1개 요청 검사 > 거부 사유 (통과면 null)
     * 배열 본문은 @Valid 원소 검증이 오류 응답 규칙을 벗어나 여기서 직접 검사
     */
    private static String findItemUpdateRejectReason(AdminExamAnswerItemUpdateRequest request,
                                                     Map<Integer, ExamAnswerItem> itemByQuestionNo) {
        if (request == null || request.questionNo() == null || !itemByQuestionNo.containsKey(request.questionNo())) {
            return "없는 문항 번호: " + (request == null ? null : request.questionNo());
        }
        if (request.operatorAnswer() != null && (request.operatorAnswer() < 0 || request.operatorAnswer() > ExamAnswerKeyResolver.CHOICE_COUNT)) {
            return request.questionNo() + "번 운영 가답안은 0~4 입니다.";
        }
        if (request.operatorAnswerStatus() != null
                && RequestEnumParser.parseOrNull(ExamAnswerItemStatus.class, request.operatorAnswerStatus()) == null) {
            return request.questionNo() + "번 상태값이 올바르지 않습니다.";
        }
        if (request.alternativeAnswers() != null && !request.alternativeAnswers().isBlank()
                && !ALTERNATIVE_ANSWERS_PATTERN.matcher(request.alternativeAnswers().trim()).matches()) {
            return request.questionNo() + "번 복수 정답은 \"2,3\" 형식입니다.";
        }
        if (isTooLong(request.conceptTitle(), MAX_CONCEPT_TITLE_LENGTH) || isTooLong(request.conceptTags(), MAX_CONCEPT_TAGS_LENGTH)
                || isTooLong(request.topicCode(), MAX_TOPIC_CODE_LENGTH) || isTooLong(request.note(), MAX_NOTE_LENGTH)) {
            return request.questionNo() + "번 입력이 너무 깁니다.";
        }
        return null;
    }

    private static boolean isTooLong(String value, int maxLength) {
        return value != null && value.trim().length() > maxLength;
    }

    private void applyItemUpdate(ExamAnswerItem item, AdminExamAnswerItemUpdateRequest request) {
        if (request.conceptTitle() != null) {
            item.setConceptTitle(blankToNull(request.conceptTitle()));
        }
        if (request.conceptTags() != null) {
            item.setConceptTags(blankToNull(request.conceptTags()));
        }
        if (request.topicCode() != null) {
            item.setTopicCode(blankToNull(request.topicCode()));
        }
        if (request.operatorAnswer() != null) {
            item.setOperatorAnswer(request.operatorAnswer() == 0 ? null : request.operatorAnswer());
        }
        if (request.operatorAnswerStatus() != null) {
            item.setOperatorAnswerStatus(ExamAnswerItemStatus.fromRequestValue(request.operatorAnswerStatus()));
        }
        if (request.alternativeAnswers() != null) {
            item.setAlternativeAnswers(blankToNull(request.alternativeAnswers()));
        }
        if (request.note() != null) {
            item.setNote(blankToNull(request.note()));
        }
    }

    private ExamAnswerRound findRound(UUID roundUuid) {
        return examAnswerRoundRepository.findById(roundUuid)
                .orElseThrow(() -> new CustomException(ErrorCode.EXAM_ANSWER_ROUND_NOT_FOUND));
    }

    private Map<Integer, ExamAnswerItem> findItemByQuestionNo(UUID roundUuid) {
        return examAnswerItemRepository.findAllByExamAnswerRoundUuidOrderByQuestionNoAsc(roundUuid).stream()
                .collect(Collectors.toMap(ExamAnswerItem::getQuestionNo, Function.identity()));
    }

    private AdminExamAnswerRoundRow toRoundRow(ExamAnswerRound round) {
        return new AdminExamAnswerRoundRow(round.getExamAnswerRoundUuid(), round.getCertType().name(), round.getRoundNumber(),
                round.getExamDate(), round.getTitle(), round.getStatus().name(), round.getNotice(),
                examAnswerSheetRepository.countByExamAnswerRoundUuid(round.getExamAnswerRoundUuid()));
    }

    private static AdminExamAnswerItemRow toItemRow(ExamAnswerItem item, ExamAnswerItemResponse publicItem) {
        return new AdminExamAnswerItemRow(item.getQuestionNo(), item.getSubjectNo(), item.getConceptTitle(),
                item.getConceptTags(), item.getTopicCode(), item.getOperatorAnswer(), item.getOperatorAnswerStatus().name(),
                item.getAlternativeAnswers(), item.getNote(),
                publicItem == null ? null : publicItem.answer(),
                publicItem == null ? Map.of() : publicItem.tally(),
                publicItem == null ? 0 : publicItem.voteCount(),
                publicItem == null ? 0 : publicItem.agreementRate());
    }

    private static String blankToNull(String value) {
        return value == null || value.isBlank() ? null : value.trim();
    }
}
