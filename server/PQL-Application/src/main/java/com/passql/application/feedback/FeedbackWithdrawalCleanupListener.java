package com.passql.application.feedback;

import com.passql.application.storage.ObjectStorageClient;
import com.passql.member.event.MemberWithdrawnEvent;
import com.passql.meta.entity.Feedback;
import com.passql.meta.entity.FeedbackImage;
import com.passql.meta.repository.FeedbackImageRepository;
import com.passql.meta.repository.FeedbackRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationManager;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

/**
 * 회원 탈퇴 시 의견 첨부 정리 (탈퇴 트랜잭션 안): 사진 행·객체 삭제, 진단 정보·로그 객체 삭제
 * 글과 처리 상태는 남김 (관리자 처리 이력), 객체 삭제는 커밋 뒤
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class FeedbackWithdrawalCleanupListener {

    private final FeedbackRepository feedbackRepository;
    private final FeedbackImageRepository feedbackImageRepository;
    private final ObjectStorageClient objectStorageClient;

    @EventListener
    @Transactional
    public void cleanUpFeedbackAttachments(MemberWithdrawnEvent event) {
        List<Feedback> feedbacks = feedbackRepository.findByMemberUuid(event.memberUuid());
        if (feedbacks.isEmpty()) {
            return;
        }
        List<String> objectKeys = new ArrayList<>();

        // 사진 (행 삭제 + 객체 키 수집)
        List<UUID> feedbackUuids = feedbacks.stream().map(Feedback::getFeedbackUuid).toList();
        List<FeedbackImage> images = feedbackImageRepository.findByFeedbackUuidIn(feedbackUuids);
        images.forEach(image -> objectKeys.add(image.getObjectKey()));
        feedbackImageRepository.deleteAll(images);

        // 진단 정보·로그 (컬럼 비움 + 로그 객체 키 수집)
        int logs = 0;
        for (Feedback feedback : feedbacks) {
            if (feedback.hasLog()) {
                objectKeys.add(feedback.getLogObjectKey());
                logs++;
            }
            feedback.clearDiagnosticsForWithdrawal();
        }

        deleteObjectsAfterCommit(objectKeys);
        log.info("[feedback] withdrawal cleanup : feedbacks={}, images={}, logs={}", feedbacks.size(), images.size(), logs);
    }

    /** 커밋 뒤 객체 삭제 (롤백되면 객체 유지, 트랜잭션 없으면 즉시) */
    private void deleteObjectsAfterCommit(List<String> objectKeys) {
        if (objectKeys.isEmpty()) {
            return;
        }
        if (TransactionSynchronizationManager.isSynchronizationActive()) {
            TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization() {
                @Override
                public void afterCommit() {
                    objectKeys.forEach(objectStorageClient::deleteQuietly);
                }
            });
        } else {
            objectKeys.forEach(objectStorageClient::deleteQuietly);
        }
    }
}
