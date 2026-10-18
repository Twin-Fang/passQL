package com.passql.application.community;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.common.util.WebpImageHeader;
import com.passql.question.constant.CommunityImageStatus;
import com.passql.question.constant.CommunityTargetType;
import com.passql.question.dto.community.CommunityImageResponse;
import com.passql.question.dto.community.CommunityImageUploadResponse;
import com.passql.question.entity.CommunityImage;
import com.passql.question.entity.CommunityPost;
import com.passql.question.entity.CommunityPostImage;
import com.passql.question.repository.CommunityImageRepository;
import com.passql.question.repository.CommunityPostImageRepository;
import com.passql.question.repository.CommunityPostRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationManager;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * 커뮤니티 이미지: 업로드(검증 > 한도 > 저장), 글 첨부(tmp > posts 이동), 서버 스트리밍 조회, 글 삭제 시 정리, 미첨부 정리
 * 숨김은 이미지 행을 바꾸지 않고 연결된 글 상태를 따름 (VISIBLE 글만 타인에게 노출)
 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class CommunityImageService {

    // 글당 최대 첨부 수
    public static final int MAX_IMAGES_PER_POST = 2;
    // 회원별 누적 저장 상한 (50MB, 원본+썸네일 합)
    static final long MAX_STORED_BYTES_PER_MEMBER = 50L * 1024 * 1024;
    // 조회 size 요청값
    private static final String SIZE_THUMBNAIL = "thumbnail";
    private static final String SIZE_FULL = "full";
    private static final String IMAGE_URL_PREFIX = "/api/community/images/";
    // 미첨부 이미지 보관 시간 / 정리 1회 처리 건수
    private static final int ORPHAN_RETENTION_HOURS = 24;
    private static final int ORPHAN_CLEANUP_BATCH_SIZE = 200;

    private final CommunityImageRepository communityImageRepository;
    private final CommunityPostImageRepository communityPostImageRepository;
    private final CommunityPostRepository communityPostRepository;
    private final CommunityImageStorageClient communityImageStorageClient;
    private final CommunityWriteLimiter communityWriteLimiter;
    private final CommunitySolveService communitySolveService;

    /** 업로드: 저장소 확인 > 크기 선확인 > 업로드 한도 > 규격 검증(원본, 썸네일) > 누적 용량 > tmp/ 저장 > 행 저장 */
    @Transactional
    public CommunityImageUploadResponse upload(UUID memberUuid, MultipartFile image, MultipartFile thumbnail) {
        communityImageStorageClient.requireEnabled();
        rejectOversizedBeforeRead(image, CommunityImageValidator.MAX_IMAGE_BYTES);
        rejectOversizedBeforeRead(thumbnail, CommunityImageValidator.MAX_THUMBNAIL_BYTES);
        communityWriteLimiter.acquireImageUploadPermit(memberUuid);

        byte[] imageBytes = readBytes(image);
        byte[] thumbnailBytes = readBytes(thumbnail);
        WebpImageHeader.Dimensions dimensions = CommunityImageValidator.validate(imageBytes, CommunityImageValidator.MAX_IMAGE_BYTES);
        CommunityImageValidator.validate(thumbnailBytes, CommunityImageValidator.MAX_THUMBNAIL_BYTES);
        long storedBytes = communityImageRepository.sumStoredBytesOfOwner(memberUuid);
        if (storedBytes + imageBytes.length + thumbnailBytes.length > MAX_STORED_BYTES_PER_MEMBER) {
            log.warn("[community image] rejected 400 : quota exceeded, member={}", memberUuid);
            throw new CustomException(ErrorCode.COMMUNITY_IMAGE_QUOTA_EXCEEDED);
        }

        UUID imageUuid = UUID.randomUUID();
        CommunityImage saved = CommunityImage.createTemp(imageUuid, memberUuid, imageBytes.length, thumbnailBytes.length,
                dimensions.widthPixels(), dimensions.heightPixels());
        communityImageStorageClient.putWebp(saved.getObjectKey(), imageBytes);
        communityImageStorageClient.putWebp(saved.getThumbnailKey(), thumbnailBytes);
        communityImageRepository.save(saved);
        log.info("[community image] uploaded : image={}, bytes={}, thumbnailBytes={}, size={}x{}", imageUuid,
                imageBytes.length, thumbnailBytes.length, dimensions.widthPixels(), dimensions.heightPixels());
        return new CommunityImageUploadResponse(imageUuid, saved.getObjectKey(), fullUrlOf(imageUuid), thumbnailUrlOf(imageUuid),
                dimensions.widthPixels(), dimensions.heightPixels());
    }

    /** 요청 이미지 목록 정규화: null > 빈 목록, 2장 초과·null·중복 거절 */
    public List<UUID> normalizeImageUuids(List<UUID> requestedImageUuids) {
        if (requestedImageUuids == null || requestedImageUuids.isEmpty()) {
            return List.of();
        }
        if (requestedImageUuids.size() > MAX_IMAGES_PER_POST) {
            throw new CustomException(ErrorCode.COMMUNITY_IMAGE_TOO_MANY);
        }
        Set<UUID> distinctUuids = new HashSet<>(requestedImageUuids);
        if (distinctUuids.contains(null) || distinctUuids.size() != requestedImageUuids.size()) {
            throw new CustomException(ErrorCode.COMMUNITY_IMAGE_INVALID_ATTACHMENT);
        }
        return List.copyOf(requestedImageUuids);
    }

    /** 글 첨부: 행 잠금 > 본인 소유·TEMP 확인 > community/tmp 객체를 community/images·thumbs 로 복사 > ATTACHED + 연결 행 > 커밋 뒤 tmp 삭제 */
    @Transactional
    public void attachToPost(UUID postUuid, UUID authorMemberUuid, List<UUID> imageUuids) {
        if (imageUuids.isEmpty()) {
            return;
        }
        communityImageStorageClient.requireEnabled();
        Map<UUID, CommunityImage> imageByUuid = communityImageRepository.findAllForAttach(imageUuids).stream()
                .collect(Collectors.toMap(CommunityImage::getImageUuid, Function.identity()));
        boolean isEveryImageAttachable = imageByUuid.size() == imageUuids.size() && imageByUuid.values().stream()
                .allMatch(found -> found.isTemp() && found.isOwnedBy(authorMemberUuid));
        if (!isEveryImageAttachable) {
            log.warn("[community image] rejected 400 : not attachable, post={}", postUuid);
            throw new CustomException(ErrorCode.COMMUNITY_IMAGE_INVALID_ATTACHMENT);
        }

        List<String> temporaryKeys = new ArrayList<>();
        for (int sortOrder = 0; sortOrder < imageUuids.size(); sortOrder++) {
            CommunityImage image = imageByUuid.get(imageUuids.get(sortOrder));
            temporaryKeys.add(image.getObjectKey());
            temporaryKeys.add(image.getThumbnailKey());
            String fullKey = CommunityImage.attachedFullKeyOf(image.getImageUuid());
            String thumbnailKey = CommunityImage.attachedThumbnailKeyOf(image.getImageUuid());
            communityImageStorageClient.copy(image.getObjectKey(), fullKey);
            communityImageStorageClient.copy(image.getThumbnailKey(), thumbnailKey);
            image.markAttached(fullKey, thumbnailKey);
            communityPostImageRepository.save(CommunityPostImage.of(postUuid, image.getImageUuid(), sortOrder));
        }
        deleteObjectsAfterCommit(temporaryKeys);
        log.info("[community image] attached : post={}, count={}", postUuid, imageUuids.size());
    }

    /** 글 목록용 이미지 응답: 글 UUID > 첨부 순서대로 이미지 (삭제된 이미지 제외) */
    public Map<UUID, List<CommunityImageResponse>> getImageResponsesByPost(Collection<UUID> postUuids) {
        if (postUuids.isEmpty()) {
            return Map.of();
        }
        List<CommunityPostImage> links = communityPostImageRepository.findByPostUuidInOrderBySortOrderAsc(postUuids);
        Map<UUID, CommunityImage> imageByUuid = communityImageRepository
                .findAllById(links.stream().map(CommunityPostImage::getImageUuid).toList()).stream()
                .filter(found -> found.getStatus() == CommunityImageStatus.ATTACHED)
                .collect(Collectors.toMap(CommunityImage::getImageUuid, Function.identity()));
        Map<UUID, List<CommunityImageResponse>> responsesByPostUuid = new LinkedHashMap<>();
        for (CommunityPostImage link : links) {
            CommunityImage image = imageByUuid.get(link.getImageUuid());
            if (image != null) {
                responsesByPostUuid.computeIfAbsent(link.getPostUuid(), key -> new ArrayList<>()).add(toResponse(image));
            }
        }
        return responsesByPostUuid;
    }

    /**
     * 이미지 바이트 조회: 존재·접근 확인 > 저장소에서 읽기 (size = thumbnail | full, 기본 full)
     * 접근 조건: TEMP 는 올린 본인만, ATTACHED 는 노출 중 글(문제 글은 풀이 후) 또는 글 작성자 본인
     */
    public byte[] readImageBytes(UUID viewerMemberUuid, UUID imageUuid, String sizeRequestValue) {
        boolean isThumbnail = isThumbnailRequested(sizeRequestValue);
        CommunityImage image = communityImageRepository.findById(imageUuid)
                .filter(found -> found.getStatus() != CommunityImageStatus.DELETED)
                .orElseThrow(() -> new CustomException(ErrorCode.COMMUNITY_IMAGE_NOT_FOUND));
        requireViewable(viewerMemberUuid, image);
        return communityImageStorageClient.read(isThumbnail ? image.getThumbnailKey() : image.getObjectKey());
    }

    /** 글 삭제 시 이미지 정리 (본인·관리자 삭제 공통): 연결 이미지 DELETED > 커밋 뒤 객체 삭제 */
    @Transactional
    public void deleteImagesOfPost(UUID postUuid) {
        List<CommunityPostImage> links = communityPostImageRepository.findByPostUuidInOrderBySortOrderAsc(List.of(postUuid));
        List<String> objectKeys = new ArrayList<>();
        for (CommunityImage image : communityImageRepository.findAllById(links.stream().map(CommunityPostImage::getImageUuid).toList())) {
            if (image.getStatus() != CommunityImageStatus.DELETED) {
                objectKeys.add(image.getObjectKey());
                objectKeys.add(image.getThumbnailKey());
                image.markDeleted();
            }
        }
        deleteObjectsAfterCommit(objectKeys);
    }

    /** 24시간 지난 미첨부(TEMP) 이미지 정리 (스케줄러): 객체 삭제 > DELETED, 처리 건수 반환 */
    @Transactional
    public int cleanUpOrphanTemporaryImages(LocalDateTime now) {
        if (!communityImageStorageClient.isEnabled()) {
            return 0;
        }
        List<CommunityImage> orphans = communityImageRepository.findByStatusAndCreatedAtBefore(CommunityImageStatus.TEMP,
                now.minusHours(ORPHAN_RETENTION_HOURS), PageRequest.of(0, ORPHAN_CLEANUP_BATCH_SIZE));
        for (CommunityImage orphan : orphans) {
            communityImageStorageClient.deleteQuietly(orphan.getObjectKey());
            communityImageStorageClient.deleteQuietly(orphan.getThumbnailKey());
            orphan.markDeleted();
        }
        if (!orphans.isEmpty()) {
            log.info("[community image] orphan temporary images cleaned : count={}", orphans.size());
        }
        return orphans.size();
    }

    private void requireViewable(UUID viewerMemberUuid, CommunityImage image) {
        if (image.isTemp()) {
            if (!image.isOwnedBy(viewerMemberUuid)) {
                throw new CustomException(ErrorCode.COMMUNITY_IMAGE_NOT_FOUND);
            }
            return;
        }
        CommunityPostImage link = communityPostImageRepository.findByImageUuid(image.getImageUuid()).stream().findFirst()
                .orElseThrow(() -> new CustomException(ErrorCode.COMMUNITY_IMAGE_NOT_FOUND));
        CommunityPost post = communityPostRepository.findById(link.getPostUuid())
                .orElseThrow(() -> new CustomException(ErrorCode.COMMUNITY_IMAGE_NOT_FOUND));
        if (post.isAuthoredBy(viewerMemberUuid)) {
            return;
        }
        if (!post.isVisible()) {
            throw new CustomException(ErrorCode.COMMUNITY_IMAGE_NOT_FOUND);
        }
        if (post.getTargetType() == CommunityTargetType.QUESTION && post.getTargetUuid() != null) {
            communitySolveService.requireSolved(viewerMemberUuid, post.getTargetUuid());
        }
    }

    private static boolean isThumbnailRequested(String sizeRequestValue) {
        if (sizeRequestValue == null || sizeRequestValue.isBlank() || SIZE_FULL.equalsIgnoreCase(sizeRequestValue)) {
            return false;
        }
        if (SIZE_THUMBNAIL.equalsIgnoreCase(sizeRequestValue)) {
            return true;
        }
        throw new CustomException(ErrorCode.INVALID_INPUT_VALUE, "size");
    }

    /** 본문을 읽기 전에 선언된 크기로 먼저 거절 (메모리 보호) */
    private static void rejectOversizedBeforeRead(MultipartFile file, int maxBytes) {
        if (file == null || file.isEmpty()) {
            throw new CustomException(ErrorCode.COMMUNITY_IMAGE_INVALID_FORMAT);
        }
        if (file.getSize() > maxBytes) {
            throw new CustomException(ErrorCode.COMMUNITY_IMAGE_TOO_LARGE);
        }
    }

    private static byte[] readBytes(MultipartFile file) {
        try {
            return file.getBytes();
        } catch (IOException e) {
            throw new CustomException(ErrorCode.COMMUNITY_IMAGE_INVALID_FORMAT);
        }
    }

    /** 트랜잭션이 있으면 커밋 뒤, 없으면 즉시 객체 삭제 (롤백되면 객체를 지우지 않음) */
    private void deleteObjectsAfterCommit(List<String> objectKeys) {
        if (objectKeys.isEmpty()) {
            return;
        }
        if (TransactionSynchronizationManager.isSynchronizationActive()) {
            TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization() {
                @Override
                public void afterCommit() {
                    objectKeys.forEach(communityImageStorageClient::deleteQuietly);
                }
            });
        } else {
            objectKeys.forEach(communityImageStorageClient::deleteQuietly);
        }
    }

    private static CommunityImageResponse toResponse(CommunityImage image) {
        return new CommunityImageResponse(image.getImageUuid(), fullUrlOf(image.getImageUuid()),
                thumbnailUrlOf(image.getImageUuid()), image.getWidthPixels(), image.getHeightPixels());
    }

    private static String fullUrlOf(UUID imageUuid) {
        return IMAGE_URL_PREFIX + imageUuid;
    }

    private static String thumbnailUrlOf(UUID imageUuid) {
        return IMAGE_URL_PREFIX + imageUuid + "?size=" + SIZE_THUMBNAIL;
    }
}
