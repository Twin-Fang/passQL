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

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
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
public class FeedbackAttachmentReader {

    // 로그 뷰어에 보여 줄 해제 후 최대 크기 (4MB, 넘으면 뒤쪽만)
    private static final int MAX_LOG_TEXT_BYTES = 4 * 1024 * 1024;
    // 진단 그룹 표시 순서
    // 해제 후 읽기 상한 (64MB, 압축 폭탄의 CPU 사용 제한)
    private static final long MAX_INFLATED_READ_BYTES = 64L * 1024 * 1024;
    private static final int READ_CHUNK_BYTES = 8192;
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

    /** 로그 텍스트: gzip 해제 > UTF-8 (4MB 초과 시 뒤쪽 4MB 만), 로그 없으면 empty (DB 트랜잭션 밖 저장소 I/O) */
    public Optional<String> readLogText(UUID feedbackUuid) {
        Feedback feedback = feedbackService.getFeedback(feedbackUuid);
        if (!feedback.hasLog()) {
            return Optional.empty();
        }
        byte[] gzipBytes = objectStorageClient.read(feedback.getLogObjectKey());
        try (GZIPInputStream gzipInputStream = new GZIPInputStream(new ByteArrayInputStream(gzipBytes))) {
            return Optional.of(readTailText(gzipInputStream, MAX_LOG_TEXT_BYTES, MAX_INFLATED_READ_BYTES));
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

    /** 스트림 > 마지막 maxTailBytes 만 UTF-8 텍스트로 (원형 버퍼, 메모리는 입력 크기와 무관, readLimitBytes 초과분은 읽지 않음) */
    static String readTailText(InputStream inputStream, int maxTailBytes, long readLimitBytes) throws IOException {
        byte[] ring = new byte[maxTailBytes];
        byte[] chunk = new byte[READ_CHUNK_BYTES];
        long totalBytes = 0;
        int readBytes;
        while (totalBytes < readLimitBytes && (readBytes = inputStream.read(chunk)) != -1) {
            for (int i = 0; i < readBytes; i++) {
                ring[(int) ((totalBytes + i) % maxTailBytes)] = chunk[i];
            }
            totalBytes += readBytes;
        }
        if (totalBytes >= readLimitBytes) {
            log.warn("[feedback log] inflated read limit reached : limitBytes={}", readLimitBytes);
        }
        if (totalBytes <= maxTailBytes) {
            return new String(ring, 0, (int) totalBytes, StandardCharsets.UTF_8);
        }
        // 원형 버퍼를 시간순으로 펼침 (가장 오래된 위치부터)
        int oldestIndex = (int) (totalBytes % maxTailBytes);
        byte[] tail = new byte[maxTailBytes];
        System.arraycopy(ring, oldestIndex, tail, 0, maxTailBytes - oldestIndex);
        System.arraycopy(ring, 0, tail, maxTailBytes - oldestIndex, oldestIndex);
        // 첫 글자가 잘린 UTF-8 이면 건너뜀
        int start = 0;
        while (start < tail.length && (tail[start] & 0xC0) == 0x80) {
            start++;
        }
        return new String(tail, start, tail.length - start, StandardCharsets.UTF_8);
    }
}
