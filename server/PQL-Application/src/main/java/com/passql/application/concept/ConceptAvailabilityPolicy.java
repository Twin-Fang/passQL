package com.passql.application.concept;

import com.passql.meta.constant.AppSettingKeys;
import com.passql.meta.service.AppSettingService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.Arrays;
import java.util.Objects;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * 개념 학습 노출 판정: 공개 스위치(concept.is_published), 초안 미리보기 회원(concept.preview_member_uuids)
 * 설정 읽기 실패 > 비공개·미리보기 없음 (초안이 새어 나가지 않게)
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class ConceptAvailabilityPolicy {

    // app_settings concept.preview_member_uuids 구분자 (쉼표)
    private static final String PREVIEW_MEMBER_UUID_DELIMITER = ",";
    // 잘못된 목록 항목 로그 최대 길이 (자)
    private static final int INVALID_ENTRY_LOG_MAX_LENGTH = 40;

    private final AppSettingService appSettingService;

    /** 개념 학습 이용 가능: 공개됐거나 미리보기 회원 */
    public boolean isAvailableFor(UUID memberUuid) {
        return isPublished() || canSeeDrafts(memberUuid);
    }

    /** 초안까지 보기: 미리보기 회원만 */
    public boolean canSeeDrafts(UUID memberUuid) {
        return memberUuid != null && readPreviewMemberUuids().contains(memberUuid);
    }

    private boolean isPublished() {
        try {
            return appSettingService.getBooleanOrDefault(AppSettingKeys.CONCEPT_IS_PUBLISHED, false);
        } catch (RuntimeException e) {
            log.warn("[concept learning] publish switch read failed, treating as unpublished : reason={}", e.getClass().getSimpleName());
            return false;
        }
    }

    private Set<UUID> readPreviewMemberUuids() {
        String previewMemberUuidsText;
        try {
            previewMemberUuidsText = appSettingService.getString(AppSettingKeys.CONCEPT_PREVIEW_MEMBER_UUIDS);
        } catch (RuntimeException e) {
            log.warn("[concept learning] preview members read failed, treating as empty : reason={}", e.getClass().getSimpleName());
            return Set.of();
        }
        if (previewMemberUuidsText == null || previewMemberUuidsText.isBlank()) {
            return Set.of();
        }
        return Arrays.stream(previewMemberUuidsText.split(PREVIEW_MEMBER_UUID_DELIMITER))
            .map(String::trim)
            .filter(entry -> !entry.isEmpty())
            .map(this::parseUuidOrNull)
            .filter(Objects::nonNull)
            .collect(Collectors.toUnmodifiableSet());
    }

    private UUID parseUuidOrNull(String entry) {
        try {
            return UUID.fromString(entry);
        } catch (IllegalArgumentException e) {
            String sanitizedEntry = entry.replaceAll("[^0-9A-Za-z-]", "?");
            log.warn("[concept learning] invalid preview member entry ignored : entry={}",
                sanitizedEntry.substring(0, Math.min(sanitizedEntry.length(), INVALID_ENTRY_LOG_MAX_LENGTH)));
            return null;
        }
    }
}
