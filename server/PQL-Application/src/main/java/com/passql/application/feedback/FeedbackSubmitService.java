package com.passql.application.feedback;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.passql.application.feedback.FeedbackAttachmentStorage.StoredObject;
import com.passql.application.storage.ObjectStorageClient;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.common.util.WebpImageHeader;
import com.passql.meta.dto.FeedbackDeviceColumns;
import com.passql.meta.dto.FeedbackSubmitRequest;
import com.passql.meta.dto.FeedbackSubmitResponse;
import com.passql.meta.entity.Feedback;
import com.passql.meta.entity.FeedbackImage;
import com.passql.meta.repository.FeedbackImageRepository;
import com.passql.meta.service.FeedbackService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

/**
 * 의견 전송: 검증 > 한도 > 저장소 확인 > DB 저장 > 첨부 업로드 (업로드 실패 시 트랜잭션 롤백)
 * 첨부가 있는데 저장소가 막히면 글만 저장하지 않고 전체 실패
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class FeedbackSubmitService {

    private static final String WEBP_CONTENT_TYPE = "image/webp";
    private static final String GZIP_CONTENT_TYPE = "application/gzip";
    // feedback 컬럼 길이 한도 (appVersion 40, platform 20, osVersion 40, deviceModel 100)
    private static final int MAX_APP_VERSION_LENGTH = 40;
    private static final int MAX_PLATFORM_LENGTH = 20;
    private static final int MAX_OS_VERSION_LENGTH = 40;
    private static final int MAX_DEVICE_MODEL_LENGTH = 100;

    private final FeedbackService feedbackService;
    private final FeedbackImageRepository feedbackImageRepository;
    private final FeedbackSubmitLimiter feedbackSubmitLimiter;
    private final FeedbackAttachmentStorage feedbackAttachmentStorage;
    private final ObjectStorageClient objectStorageClient;
    private final ObjectMapper objectMapper;

    /** 의견 1건 전송: 글 > 이미지 > 진단 > 로그 검증 > 한도 > 저장소 확인 > 저장 > 업로드 */
    @Transactional
    public FeedbackSubmitResponse submit(UUID memberUuid, FeedbackSubmitRequest request, List<MultipartFile> images,
                                         MultipartFile diagnostics, MultipartFile logFile) {
        // 요청 검증 (글, 이미지 장수·형식, 진단 JSON, 로그 gzip)
        String content = feedbackService.normalizeContent(request == null ? null : request.getContent());
        List<MultipartFile> imageFiles = images == null ? List.of() : images;
        FeedbackAttachmentValidator.validateImageCount(imageFiles.size());
        List<byte[]> imageBytesList = new ArrayList<>();
        List<WebpImageHeader.Dimensions> imageDimensions = new ArrayList<>();
        for (MultipartFile image : imageFiles) {
            rejectOversizedBeforeRead(image, FeedbackAttachmentValidator.MAX_IMAGE_BYTES, ErrorCode.FEEDBACK_IMAGE_INVALID);
            byte[] imageBytes = readBytes(image, ErrorCode.FEEDBACK_IMAGE_INVALID);
            imageDimensions.add(FeedbackAttachmentValidator.validateImage(imageBytes));
            imageBytesList.add(imageBytes);
        }
        byte[] diagnosticsBytes = null;
        JsonNode diagnosticsJson = null;
        if (diagnostics != null) {
            rejectOversizedBeforeRead(diagnostics, FeedbackAttachmentValidator.MAX_DIAGNOSTICS_BYTES, ErrorCode.FEEDBACK_ATTACHMENT_INVALID);
            diagnosticsBytes = readBytes(diagnostics, ErrorCode.FEEDBACK_ATTACHMENT_INVALID);
            diagnosticsJson = FeedbackAttachmentValidator.parseDiagnostics(diagnosticsBytes, objectMapper);
        }
        byte[] logBytes = null;
        if (logFile != null) {
            rejectOversizedBeforeRead(logFile, FeedbackAttachmentValidator.MAX_LOG_BYTES, ErrorCode.FEEDBACK_ATTACHMENT_INVALID);
            logBytes = readBytes(logFile, ErrorCode.FEEDBACK_ATTACHMENT_INVALID);
            FeedbackAttachmentValidator.validateLog(logBytes);
        }

        // 하루 한도 > 첨부가 있으면 저장소 활성 확인
        feedbackSubmitLimiter.acquireSubmitPermit(memberUuid);
        boolean hasAttachment = !imageBytesList.isEmpty() || logBytes != null;
        if (hasAttachment && !objectStorageClient.isEnabled()) {
            log.warn("[feedback submit] rejected 503 : storage disabled, member={}", memberUuid);
            throw new CustomException(ErrorCode.FEEDBACK_STORAGE_UNAVAILABLE);
        }

        // 의견 행 > 이미지 행 저장
        String diagnosticsText = diagnosticsBytes == null ? null : new String(diagnosticsBytes, StandardCharsets.UTF_8);
        FeedbackDeviceColumns deviceColumns = diagnosticsJson == null
                ? FeedbackDeviceColumns.empty() : extractDeviceColumns(diagnosticsJson);
        Feedback saved = feedbackService.createFeedback(memberUuid, content, deviceColumns, diagnosticsText,
                logBytes == null ? null : logBytes.length);
        List<StoredObject> storedObjects = new ArrayList<>();
        for (int sortOrder = 0; sortOrder < imageBytesList.size(); sortOrder++) {
            byte[] imageBytes = imageBytesList.get(sortOrder);
            WebpImageHeader.Dimensions dimensions = imageDimensions.get(sortOrder);
            FeedbackImage image = FeedbackImage.of(saved.getFeedbackUuid(), sortOrder, imageBytes.length,
                    dimensions.widthPixels(), dimensions.heightPixels());
            feedbackImageRepository.save(image);
            storedObjects.add(new StoredObject(image.getObjectKey(), imageBytes, WEBP_CONTENT_TYPE));
        }
        if (logBytes != null) {
            storedObjects.add(new StoredObject(saved.getLogObjectKey(), logBytes, GZIP_CONTENT_TYPE));
        }

        // 업로드 (실패 시 예외 > 트랜잭션 롤백)
        feedbackAttachmentStorage.uploadAll(storedObjects);
        return FeedbackSubmitResponse.from(saved);
    }

    /** 진단 JSON > 기기 컬럼 (app.appVersion, device.platform, device.osVersion, device.deviceModel, 컬럼 길이로 자름) */
    private static FeedbackDeviceColumns extractDeviceColumns(JsonNode diagnostics) {
        JsonNode device = diagnostics.path("device");
        return new FeedbackDeviceColumns(
                textOf(diagnostics.path("app").path("appVersion"), MAX_APP_VERSION_LENGTH),
                textOf(device.path("platform"), MAX_PLATFORM_LENGTH),
                textOf(device.path("osVersion"), MAX_OS_VERSION_LENGTH),
                textOf(device.path("deviceModel"), MAX_DEVICE_MODEL_LENGTH));
    }

    /** 값 노드 > 문자열 (없거나 객체·null 이면 null, 최대 길이로 자름) */
    private static String textOf(JsonNode node, int maxLength) {
        if (!node.isValueNode() || node.isNull()) {
            return null;
        }
        String text = node.asText();
        return text.length() > maxLength ? text.substring(0, maxLength) : text;
    }

    /** 읽기 전 크기 선확인: 빈 파트 > 형식 오류, 한도 초과 > 413 */
    private static void rejectOversizedBeforeRead(MultipartFile file, int maxBytes, ErrorCode errorCodeOnEmpty) {
        if (file.isEmpty()) {
            throw new CustomException(errorCodeOnEmpty);
        }
        if (file.getSize() > maxBytes) {
            throw new CustomException(ErrorCode.FEEDBACK_ATTACHMENT_TOO_LARGE);
        }
    }

    private static byte[] readBytes(MultipartFile file, ErrorCode errorCodeOnFailure) {
        try {
            return file.getBytes();
        } catch (IOException e) {
            throw new CustomException(errorCodeOnFailure, e);
        }
    }
}
