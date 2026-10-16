package com.passql.question.service;

import com.passql.common.audit.AdminAuditEvent;
import com.passql.common.audit.constant.AdminAuditAction;
import com.passql.common.audit.constant.AdminAuditTargetType;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.common.util.RequestEnumParser;
import com.passql.common.util.TextPreview;
import com.passql.meta.entity.Topic;
import com.passql.meta.repository.TopicRepository;
import com.passql.question.constant.ChoiceSetPolicy;
import com.passql.question.constant.ExecutionMode;
import com.passql.question.dto.*;
import com.passql.question.entity.Question;
import com.passql.question.repository.QuestionRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.stream.Collectors;

/**
 * 문제 JSON 가져오기·내보내기: 필터·UUID 내보내기, 배치 검증 집계, 등록/업데이트
 * 항목별 검증은 QuestionImportItemValidator, Oracle 문법 처리는 OracleSqlCompatibilityConverter
 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class QuestionImportExportService {

    private static final int IMPORT_LIMIT = 100;
    private static final int EXPORT_LIMIT = 500;

    private final QuestionRepository questionRepository;
    private final TopicRepository topicRepository;
    private final QuestionGenerateService questionGenerateService;
    private final QuestionService questionService;
    private final ApplicationEventPublisher eventPublisher;
    private final QuestionImportItemValidator importItemValidator;
    private final OracleSqlCompatibilityConverter oracleSqlCompatibilityConverter;
    private final CuratedChoiceSetWriter curatedChoiceSetWriter;

    // ── Export ────────────────────────────────────────────────────

    /**
     * 필터 조건 기반 전체 내보내기.
     */
    public List<QuestionExportDto> exportByFilter(String topicCode, Integer difficulty, String executionMode) {
        UUID topicUuid = null;
        if (topicCode != null && !topicCode.isBlank()) {
            topicUuid = topicRepository.findByCode(topicCode)
                    .map(Topic::getTopicUuid)
                    .orElseThrow(() -> new CustomException(ErrorCode.TOPIC_NOT_FOUND));
        }
        ExecutionMode mode = toExecutionModeOrNull(executionMode);

        List<Question> questions = questionRepository.findByFiltersAll(
                topicUuid, difficulty, mode, PageRequest.ofSize(EXPORT_LIMIT));
        if (questions.isEmpty()) {
            throw new CustomException(ErrorCode.EXPORT_NO_DATA);
        }
        return toExportDtos(questions);
    }

    /**
     * UUID 목록 기반 내보내기.
     */
    public List<QuestionExportDto> exportByUuids(List<UUID> questionUuids) {
        List<Question> questions = questionRepository.findAllById(questionUuids);
        if (questions.isEmpty()) {
            throw new CustomException(ErrorCode.EXPORT_NO_DATA);
        }
        return toExportDtos(questions);
    }

    // ── Validate ─────────────────────────────────────────────────

    /**
     * 배치 Sandbox 검증.
     */
    public ImportValidationResult validateBatch(List<QuestionExportDto> items) {
        if (items.size() > IMPORT_LIMIT) {
            throw new CustomException(ErrorCode.IMPORT_LIMIT_EXCEEDED);
        }

        List<ImportItemResult> results = new ArrayList<>();
        int success = 0;
        int failed = 0;
        int newCount = 0;
        int updateCount = 0;

        for (int i = 0; i < items.size(); i++) {
            QuestionExportDto item = items.get(i);
            String stemPreview = truncateStem(item.stem());
            String importAction = resolveImportAction(item);

            if ("UPDATE".equals(importAction)) {
                updateCount++;
            } else {
                newCount++;
            }

            ImportItemResult result = importItemValidator.validate(i, item, stemPreview, importAction);
            results.add(result);

            if ("FAIL".equals(result.sandboxStatus())) {
                failed++;
            } else {
                success++;
            }
        }

        return new ImportValidationResult(items.size(), success, failed, newCount, updateCount, results);
    }

    // ── Import ───────────────────────────────────────────────────

    /**
     * 검증 후 실제 등록/업데이트.
     * SUCCESS_ONLY 모드: 프론트에서 전달한 검증 결과의 sandboxStatus 목록을 기반으로 FAIL 항목을 스킵한다.
     * (Sandbox를 재실행하지 않음)
     */
    @Transactional
    public ImportResult importBatch(ImportRequest request) {
        List<QuestionExportDto> items = request.items();
        String importMode = request.importMode();
        List<String> sandboxStatuses = request.sandboxStatuses();

        if (items.size() > IMPORT_LIMIT) {
            throw new CustomException(ErrorCode.IMPORT_LIMIT_EXCEEDED);
        }

        boolean isSuccessOnly = "SUCCESS_ONLY".equals(importMode);

        // SUCCESS_ONLY인데 sandboxStatuses가 없으면 안전하게 전체 스킵
        if (isSuccessOnly && (sandboxStatuses == null || sandboxStatuses.size() != items.size())) {
            log.warn("[import-batch] SUCCESS_ONLY 모드인데 sandboxStatuses 누락/불일치. 전체 스킵.");
            return new ImportResult(0, 0, items.size());
        }

        // topicCode → UUID 매핑을 한번에 조회 (N+1 방지)
        Map<String, UUID> topicCodeToUuid = buildTopicCodeMap(items);

        int created = 0;
        int updated = 0;
        int skipped = 0;

        for (int i = 0; i < items.size(); i++) {
            QuestionExportDto item = items.get(i);

            // SUCCESS_ONLY 모드: FAIL 항목 스킵
            if (isSuccessOnly && "FAIL".equals(sandboxStatuses.get(i))) {
                skipped++;
                continue;
            }

            UUID topicUuid = topicCodeToUuid.get(item.topicCode());
            if (topicUuid == null) {
                skipped++;
                continue;
            }

            ExecutionMode mode = toExecutionModeOrNull(item.executionMode());
            if (mode == null) {
                skipped++;
                continue;
            }

            // 1:1 치환 가능한 Oracle 문법을 PostgreSQL 호환으로 변환 후 저장 (validate 단계와 동일하게 적용)
            String savedDdl       = oracleSqlCompatibilityConverter.translateOracleToPostgres(item.schemaDdl());
            String savedSample    = oracleSqlCompatibilityConverter.translateOracleToPostgres(item.schemaSampleData());
            String savedAnswerSql = oracleSqlCompatibilityConverter.translateOracleToPostgres(item.answerSql());

            // 치환 후에도 Oracle 전용 문법이 남아있으면 CONCEPT_ONLY로 자동 전환
            if (mode == ExecutionMode.EXECUTABLE
                    && oracleSqlCompatibilityConverter.detectOracleOnlySyntax(savedAnswerSql, savedDdl, savedSample, item.stem()) != null) {
                mode = ExecutionMode.CONCEPT_ONLY;
            }

            ChoiceSetPolicy policy = toChoiceSetPolicyOrAiOnly(item.choiceSetPolicy());

            // 고정 보기 규칙 재확인 (전체 등록 모드도 적용, 검증 결과 목록에 의존하지 않음)
            String choiceRejectReason = CuratedChoiceValidator.findRejectReason(policy, mode, item.choices());
            if (choiceRejectReason != null) {
                log.warn("[import-batch] skipped curated item : index={}, reason={}", i, choiceRejectReason);
                skipped++;
                continue;
            }

            if (item.questionUuid() != null && questionRepository.existsById(item.questionUuid())) {
                questionService.updateQuestion(
                        item.questionUuid(), item.stem(), null,
                        savedDdl, savedSample, item.schemaIntent(),
                        savedAnswerSql, item.hint(), item.difficulty(), mode,
                        topicUuid, null);
                // choiceSetPolicy는 updateQuestion에 파라미터가 없으므로 별도 업데이트
                questionService.updateChoiceSetPolicy(item.questionUuid(), policy);
                saveCuratedChoicesIfPresent(item.questionUuid(), item.choices());
                updated++;
            } else {
                Question createdQuestion = questionGenerateService.createQuestionOnly(
                        topicUuid, null, item.difficulty(), mode,
                        item.stem(), savedDdl, savedSample,
                        item.schemaIntent(), savedAnswerSql, item.hint(),
                        policy);
                saveCuratedChoicesIfPresent(createdQuestion.getQuestionUuid(), item.choices());
                created++;
            }
        }

        log.info("[import-batch] created={}, updated={}, skipped={}", created, updated, skipped);
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.QUESTION, null, AdminAuditAction.IMPORT,
                null, AdminAuditEvent.summary("importMode", importMode, "created", created, "updated", updated, "skipped", skipped)));
        return new ImportResult(created, updated, skipped);
    }

    /**
     * items의 topicCode들을 한번에 조회하여 topicCode → topicUuid 매핑 반환.
     */
    private Map<String, UUID> buildTopicCodeMap(List<QuestionExportDto> items) {
        Set<String> topicCodes = items.stream()
                .map(QuestionExportDto::topicCode)
                .filter(c -> c != null && !c.isBlank())
                .collect(Collectors.toSet());

        Map<String, UUID> map = new HashMap<>();
        for (String code : topicCodes) {
            topicRepository.findByCode(code).ifPresent(t -> map.put(code, t.getTopicUuid()));
        }
        return map;
    }

    // ── Private helpers ──────────────────────────────────────────

    /** 보기가 있으면 고정 세트 교체 (없으면 기존 세트 유지) */
    private void saveCuratedChoicesIfPresent(UUID questionUuid, List<CuratedChoiceDto> choices) {
        if (choices != null && !choices.isEmpty()) {
            curatedChoiceSetWriter.replaceCuratedSet(questionUuid, choices);
        }
    }

    private String resolveImportAction(QuestionExportDto item) {
        if (item.questionUuid() != null && questionRepository.existsById(item.questionUuid())) {
            return "UPDATE";
        }
        return "NEW";
    }

    private String truncateStem(String stem) {
        return TextPreview.truncateWithEllipsis(stem, TextPreview.SHORT_STEM_LENGTH);
    }

    /**
     * choiceSetPolicy 문자열 > enum (비었거나 모르는 값 > AI_ONLY)
     * 옛 내보내기 파일 호환: 정책 칸이 없거나 폐기된 값이어도 가져오기는 진행
     */
    private ChoiceSetPolicy toChoiceSetPolicyOrAiOnly(String value) {
        ChoiceSetPolicy policy = RequestEnumParser.parseOrNull(ChoiceSetPolicy.class, value);
        return policy != null ? policy : ChoiceSetPolicy.AI_ONLY;
    }

    /**
     * executionMode 문자열 > enum (비었거나 모르는 값 > null)
     * 가져오기는 항목별 FAIL·건너뜀으로 보고하고, 내보내기 필터는 조건 없음으로 처리하므로 예외 대신 null
     */
    private ExecutionMode toExecutionModeOrNull(String value) {
        return RequestEnumParser.parseOrNull(ExecutionMode.class, value);
    }

    /**
     * N+1 방지: Topic 전체를 한번에 조회하여 Map으로 변환 후 사용.
     */
    private List<QuestionExportDto> toExportDtos(List<Question> questions) {
        Set<UUID> topicUuids = questions.stream()
                .map(Question::getTopicUuid)
                .filter(Objects::nonNull)
                .collect(Collectors.toSet());

        Map<UUID, String> topicCodeMap = topicRepository.findAllById(topicUuids).stream()
                .collect(Collectors.toMap(Topic::getTopicUuid, Topic::getCode));

        return questions.stream().map(q -> new QuestionExportDto(
                q.getQuestionUuid(),
                topicCodeMap.getOrDefault(q.getTopicUuid(), null),
                q.getDifficulty(),
                q.getExecutionMode() != null ? q.getExecutionMode().name() : null,
                q.getChoiceSetPolicy() != null ? q.getChoiceSetPolicy().name() : null,
                q.getStem(),
                q.getHint(),
                q.getSchemaDdl(),
                q.getSchemaSampleData(),
                q.getSchemaIntent(),
                q.getAnswerSql(),
                q.getChoiceSetPolicy() == ChoiceSetPolicy.CURATED_ONLY ? questionService.findActiveCuratedChoices(q.getQuestionUuid()) : null
        )).toList();
    }
}
