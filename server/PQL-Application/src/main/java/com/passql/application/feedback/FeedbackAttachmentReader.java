package com.passql.application.feedback;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.passql.application.storage.ObjectStorageClient;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.meta.entity.Feedback;
import com.passql.meta.entity.FeedbackImage;
import com.passql.meta.repository.FeedbackImageRepository;
import com.passql.meta.service.FeedbackService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.zip.GZIPInputStream;

/**
 * 관리자 의견 첨부 조회: 이미지 목록·원본, 로그 gzip·텍스트, 진단 정보 그룹
 * 저장소 비활성·읽기 실패는 ObjectStorageException 그대로 전달 (화면은 "불러올 수 없음" 표시)
 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class FeedbackAttachmentReader {

    // 로그 뷰어에 보여 줄 해제 후 최대 크기 (4MB, 넘으면 뒤쪽만)
    private static final int MAX_LOG_TEXT_BYTES = 4 * 1024 * 1024;
    // 진단 그룹 표시 순서
    private static final List<String> DIAGNOSTICS_GROUP_ORDER = List.of("app", "device", "system", "meta");

    private final FeedbackService feedbackService;
    private final FeedbackImageRepository feedbackImageRepository;
    private final ObjectStorageClient objectStorageClient;
    private final ObjectMapper objectMapper;

    public boolean isStorageEnabled() {
        return objectStorageClient.isEnabled();
    }

    public List<FeedbackImage> findImages(UUID feedbackUuid) {
        return feedbackImageRepository.findByFeedbackUuidOrderBySortOrderAsc(feedbackUuid);
    }

    /** 이미지 1장 원본(WebP) 읽기, 없는 번호는 FEEDBACK_NOT_FOUND */
    public byte[] readImage(UUID feedbackUuid, int sortOrder) {
        FeedbackImage image = feedbackImageRepository.findByFeedbackUuidAndSortOrder(feedbackUuid, sortOrder)
            .orElseThrow(() -> new CustomException(ErrorCode.FEEDBACK_NOT_FOUND));
        return objectStorageClient.read(image.getObjectKey());
    }

    /** 로그 gzip 원본 읽기, 로그가 없으면 FEEDBACK_NOT_FOUND */
    public byte[] readLogGzip(UUID feedbackUuid) {
        Feedback feedback = feedbackService.getFeedback(feedbackUuid);
        if (!feedback.hasLog()) {
            throw new CustomException(ErrorCode.FEEDBACK_NOT_FOUND);
        }
        return objectStorageClient.read(feedback.getLogObjectKey());
    }

    /** 로그 텍스트: gzip 해제 > UTF-8 (4MB 초과 시 뒤쪽 4MB 만), 로그 없으면 empty */
    public Optional<String> readLogText(UUID feedbackUuid) {
        Feedback feedback = feedbackService.getFeedback(feedbackUuid);
        if (!feedback.hasLog()) {
            return Optional.empty();
        }
        byte[] gzipBytes = objectStorageClient.read(feedback.getLogObjectKey());
        try (GZIPInputStream gzipInputStream = new GZIPInputStream(new ByteArrayInputStream(gzipBytes))) {
            return Optional.of(toTailText(gzipInputStream.readAllBytes()));
        } catch (IOException e) {
            log.warn("[feedback log] gunzip failed : feedback={}, cause={}", feedbackUuid, e.getClass().getSimpleName());
            return Optional.of("(로그를 해제하지 못했어요)");
        }
    }

    /** 진단 JSON > 그룹별 항목 (app, device, system, meta 순, 없거나 깨졌으면 빈 맵) */
    public Map<String, Map<String, Object>> groupDiagnostics(Feedback feedback) {
        Map<String, Map<String, Object>> groups = new LinkedHashMap<>();
        if (feedback.getDiagnostics() == null) {
            return groups;
        }
        try {
            Map<String, Map<String, Object>> parsed = objectMapper.readValue(feedback.getDiagnostics(),
                new TypeReference<Map<String, Map<String, Object>>>() { });
            DIAGNOSTICS_GROUP_ORDER.stream().filter(parsed::containsKey).forEach(name -> groups.put(name, parsed.get(name)));
            // 정해진 그룹 외 키는 뒤에 그대로
            parsed.forEach(groups::putIfAbsent);
        } catch (IOException | RuntimeException e) {
            log.warn("[feedback diagnostics] parse failed : feedback={}, cause={}",
                feedback.getFeedbackUuid(), e.getClass().getSimpleName());
        }
        return groups;
    }

    // 최대 크기 초과 시 뒤쪽만 남김 (첫 글자가 잘린 UTF-8 이면 건너뜀)
    private String toTailText(byte[] bytes) {
        if (bytes.length <= MAX_LOG_TEXT_BYTES) {
            return new String(bytes, StandardCharsets.UTF_8);
        }
        int start = bytes.length - MAX_LOG_TEXT_BYTES;
        while (start < bytes.length && (bytes[start] & 0xC0) == 0x80) {
            start++;
        }
        return new String(Arrays.copyOfRange(bytes, start, bytes.length), StandardCharsets.UTF_8);
    }
}
