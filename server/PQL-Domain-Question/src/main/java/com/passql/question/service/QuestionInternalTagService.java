package com.passql.question.service;

import com.passql.common.audit.AdminAuditEvent;
import com.passql.common.audit.constant.AdminAuditAction;
import com.passql.common.audit.constant.AdminAuditTargetType;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.question.constant.QuestionInternalTagNamespace;
import com.passql.question.dto.AdminInternalTagBulkUpdateRequest;
import com.passql.question.dto.AdminInternalTagBulkUpdateResult;
import com.passql.question.dto.AdminInternalTagSummaryGroup;
import com.passql.question.dto.QuestionInternalTagGroup;
import com.passql.question.dto.QuestionInternalTagNormalizeResult;
import com.passql.question.entity.QuestionInternalTag;
import com.passql.question.repository.QuestionInternalTagCountProjection;
import com.passql.question.repository.QuestionInternalTagRepository;
import com.passql.question.repository.QuestionRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.Collection;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.TreeSet;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * 문제 내부 관리 태그: 조회, 1건 교체, 일괄 붙이기·떼기, 태그별 문제 수 요약, 네임스페이스 묶음 (#1117)
 * 관리자·가져오기 전용 (사용자 API 미노출), 규칙은 QuestionInternalTagRule
 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class QuestionInternalTagService {

    // 일괄 변경 1회 최대 문제 수 (최신 경향 일괄 API 와 같은 크기 제한)
    static final int MAXIMUM_BULK_UPDATE_QUESTION_COUNT = 200;
    // 네임스페이스 없는·목록 밖 태그 묶음 이름
    private static final String OTHER_GROUP_LABEL = "기타";
    // 감사 로그 before·after 키
    private static final String AUDIT_FIELD_INTERNAL_TAGS = "internalTags";

    private final QuestionInternalTagRepository questionInternalTagRepository;
    private final QuestionRepository questionRepository;
    private final ApplicationEventPublisher eventPublisher;

    /** 문제 1건 태그 (태그 이름순) */
    public List<String> getTags(UUID questionUuid) {
        return questionInternalTagRepository.findByQuestionUuidOrderByTagAsc(questionUuid).stream()
                .map(QuestionInternalTag::getTag)
                .toList();
    }

    /** 문제 여러 건 태그 (태그 없는 문제는 키 없음, 태그 이름순) */
    public Map<UUID, List<String>> getTagsByQuestionUuid(Collection<UUID> questionUuids) {
        if (questionUuids.isEmpty()) {
            return Map.of();
        }
        return questionInternalTagRepository.findByQuestionUuidIn(questionUuids).stream()
                .collect(Collectors.groupingBy(QuestionInternalTag::getQuestionUuid,
                        Collectors.mapping(QuestionInternalTag::getTag,
                                Collectors.collectingAndThen(Collectors.toCollection(TreeSet::new), List::copyOf))));
    }

    /**
     * 문제 1건 태그 교체: 문제 확인 > 정규화·검증 > 같으면 그대로 > 삭제 후 저장 > 감사 기록
     * 잘못된 태그 > INVALID_INPUT_VALUE (사유 포함)
     */
    @Transactional
    public List<String> replaceTags(UUID questionUuid, List<String> rawTags) {
        if (!questionRepository.existsById(questionUuid)) {
            throw new CustomException(ErrorCode.QUESTION_NOT_FOUND);
        }
        List<String> newTags = normalizeOrThrow(rawTags);
        List<String> currentTags = getTags(questionUuid);
        if (Set.copyOf(currentTags).equals(Set.copyOf(newTags))) {
            return currentTags;
        }
        saveTags(questionUuid, currentTags, newTags);
        return getTags(questionUuid);
    }

    /**
     * 일괄 붙이기·떼기: 요청 검증 > 문제 조회 > 문제별 (현재 - 뗄 태그 + 붙일 태그) > 최대 개수 초과면 건너뜀 > 바뀐 문제만 저장
     */
    @Transactional
    public AdminInternalTagBulkUpdateResult updateTagsInBulk(AdminInternalTagBulkUpdateRequest request) {
        Set<UUID> questionUuids = validateBulkUpdateRequest(request);
        List<String> addTags = normalizeOrThrow(request.addTags());
        List<String> removeTags = normalizeOrThrow(request.removeTags());
        if (addTags.isEmpty() && removeTags.isEmpty()) {
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE, "붙이거나 뗄 태그가 없습니다.");
        }

        Set<UUID> existingQuestionUuids = questionRepository.findAllById(questionUuids).stream()
                .map(question -> question.getQuestionUuid())
                .collect(Collectors.toSet());
        List<UUID> notFoundQuestionUuids = questionUuids.stream()
                .filter(questionUuid -> !existingQuestionUuids.contains(questionUuid))
                .toList();
        Map<UUID, List<String>> currentTagsByQuestionUuid = getTagsByQuestionUuid(existingQuestionUuids);

        int changedCount = 0;
        List<UUID> tagLimitExceededQuestionUuids = new ArrayList<>();
        for (UUID questionUuid : questionUuids) {
            if (!existingQuestionUuids.contains(questionUuid)) {
                continue;
            }
            List<String> currentTags = currentTagsByQuestionUuid.getOrDefault(questionUuid, List.of());
            Set<String> newTags = new LinkedHashSet<>(currentTags);
            removeTags.forEach(newTags::remove);
            newTags.addAll(addTags);
            if (newTags.equals(Set.copyOf(currentTags))) {
                continue;
            }
            if (newTags.size() > QuestionInternalTagRule.MAXIMUM_TAG_COUNT_PER_QUESTION) {
                tagLimitExceededQuestionUuids.add(questionUuid);
                continue;
            }
            saveTags(questionUuid, currentTags, List.copyOf(newTags));
            changedCount++;
        }
        log.info("[question internal tag] bulk updated : requested={}, changed={}, notFound={}, limitExceeded={}",
                questionUuids.size(), changedCount, notFoundQuestionUuids.size(), tagLimitExceededQuestionUuids.size());
        return new AdminInternalTagBulkUpdateResult(questionUuids.size(), changedCount, notFoundQuestionUuids,
                tagLimitExceededQuestionUuids);
    }

    /** 태그별 문제 수 요약: 네임스페이스 선언 순서 > 기타, 묶음 안은 태그 이름순 */
    public List<AdminInternalTagSummaryGroup> getTagSummary() {
        List<QuestionInternalTagCountProjection> tagCounts = questionInternalTagRepository.countQuestionsByTag();
        return groupByNamespace(tagCounts, QuestionInternalTagCountProjection::getTag).entrySet().stream()
                .map(entry -> new AdminInternalTagSummaryGroup(
                        prefixOrNull(entry.getKey()), labelOf(entry.getKey()),
                        entry.getValue().stream()
                                .map(tagCount -> new AdminInternalTagSummaryGroup.TagCount(tagCount.getTag(),
                                        displayValueOf(entry.getKey(), tagCount.getTag()),
                                        tagCount.getQuestionCount(), tagCount.getActiveQuestionCount()))
                                .toList()))
                .toList();
    }

    /** 태그 목록 > 네임스페이스 묶음 (관리자 목록·상세 표시용, 출처 63-17 / 유형 T41 / 기타 new-type) */
    public static List<QuestionInternalTagGroup> toTagGroups(List<String> tags) {
        if (tags == null || tags.isEmpty()) {
            return List.of();
        }
        return groupByNamespace(tags, Function.identity()).entrySet().stream()
                .map(entry -> new QuestionInternalTagGroup(prefixOrNull(entry.getKey()), labelOf(entry.getKey()),
                        entry.getValue().stream().map(tag -> displayValueOf(entry.getKey(), tag)).toList()))
                .toList();
    }

    // ── private ──────────────────────────────────────────────

    /** 기존 행 삭제 > 새 태그 저장 > 감사 기록 (before·after) */
    private void saveTags(UUID questionUuid, List<String> currentTags, List<String> newTags) {
        questionInternalTagRepository.deleteByQuestionUuid(questionUuid);
        questionInternalTagRepository.saveAll(newTags.stream()
                .map(tag -> QuestionInternalTag.builder().questionUuid(questionUuid).tag(tag).build())
                .toList());
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.QUESTION, questionUuid,
                AdminAuditAction.UPDATE,
                Map.of(AUDIT_FIELD_INTERNAL_TAGS, String.join(",", currentTags)),
                Map.of(AUDIT_FIELD_INTERNAL_TAGS, String.join(",", newTags))));
    }

    /** 태그 목록 정규화 (거부 시 INVALID_INPUT_VALUE + 사유) */
    private static List<String> normalizeOrThrow(List<String> rawTags) {
        QuestionInternalTagNormalizeResult result = QuestionInternalTagRule.normalizeTags(rawTags);
        if (!result.isValid()) {
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE, result.rejectReason());
        }
        return result.tags();
    }

    /** 일괄 요청 검증 (UUID 1개 이상·최대 개수·null 없음) > 중복 제거한 UUID */
    private static Set<UUID> validateBulkUpdateRequest(AdminInternalTagBulkUpdateRequest request) {
        if (request == null || request.questionUuids() == null || request.questionUuids().isEmpty()
                || request.questionUuids().size() > MAXIMUM_BULK_UPDATE_QUESTION_COUNT
                || request.questionUuids().stream().anyMatch(Objects::isNull)) {
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE);
        }
        return new LinkedHashSet<>(request.questionUuids());
    }

    /** 항목 > 네임스페이스 묶음 (선언 순서, 기타 묶음 키 null 은 맨 뒤, 묶음 안 태그 이름순) */
    private static <T> Map<QuestionInternalTagNamespace, List<T>> groupByNamespace(Collection<T> items,
                                                                                    Function<T, String> tagGetter) {
        Map<QuestionInternalTagNamespace, List<T>> itemsByNamespace = new LinkedHashMap<>();
        for (QuestionInternalTagNamespace namespace : QuestionInternalTagNamespace.values()) {
            itemsByNamespace.put(namespace, new ArrayList<>());
        }
        List<T> otherItems = new ArrayList<>();
        for (T item : items) {
            QuestionInternalTagNamespace namespace = QuestionInternalTagNamespace.fromTagOrNull(tagGetter.apply(item));
            (namespace == null ? otherItems : itemsByNamespace.get(namespace)).add(item);
        }
        itemsByNamespace.put(null, otherItems);
        Map<QuestionInternalTagNamespace, List<T>> nonEmptyGroups = new LinkedHashMap<>();
        itemsByNamespace.forEach((namespace, groupItems) -> {
            if (!groupItems.isEmpty()) {
                groupItems.sort((left, right) -> tagGetter.apply(left).compareTo(tagGetter.apply(right)));
                nonEmptyGroups.put(namespace, groupItems);
            }
        });
        return nonEmptyGroups;
    }

    private static String prefixOrNull(QuestionInternalTagNamespace namespace) {
        return namespace == null ? null : namespace.getPrefix();
    }

    private static String labelOf(QuestionInternalTagNamespace namespace) {
        return namespace == null ? OTHER_GROUP_LABEL : namespace.getLabel();
    }

    // 목록 네임스페이스는 값만, 기타 묶음은 태그 전체
    private static String displayValueOf(QuestionInternalTagNamespace namespace, String tag) {
        return namespace == null ? tag : namespace.toDisplayValue(tag);
    }
}
