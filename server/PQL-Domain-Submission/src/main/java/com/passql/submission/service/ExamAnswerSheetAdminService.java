package com.passql.submission.service;

import com.passql.common.audit.AdminAuditEvent;
import com.passql.common.audit.constant.AdminAuditAction;
import com.passql.common.audit.constant.AdminAuditTargetType;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.submission.dto.examanswer.AdminExamAnswerSheetRow;
import com.passql.submission.entity.ExamAnswerSheet;
import com.passql.submission.repository.ExamAnswerRoundRepository;
import com.passql.submission.repository.ExamAnswerSheetRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

/**
 * 관리자 가답안 답안지 (#1126): 회차 답안지 최근 목록, 테스트 제출 삭제
 * 삭제는 감사 로그(회차 대상, 답안지 UUID 요약) + 커밋 뒤 공개 집계 캐시 비움
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ExamAnswerSheetAdminService {

    // 화면에 보이는 클라이언트 토큰 해시 앞자리 수 (기기 구분용, 원본 해시 전체는 노출하지 않음)
    private static final int CLIENT_TOKEN_HASH_PREFIX_LENGTH = 6;

    private final ExamAnswerRoundRepository examAnswerRoundRepository;
    private final ExamAnswerSheetRepository examAnswerSheetRepository;
    private final ExamAnswerSnapshotCache examAnswerSnapshotCache;
    private final ApplicationEventPublisher eventPublisher;

    /** 회차 답안지 최근 제출순 100장 */
    public List<AdminExamAnswerSheetRow> getRecentSheets(UUID roundUuid) {
        return examAnswerSheetRepository.findTop100ByExamAnswerRoundUuidOrderByUpdatedAtDesc(roundUuid).stream()
                .map(ExamAnswerSheetAdminService::toSheetRow)
                .toList();
    }

    /** 답안지 1장 삭제: 회차 소속 확인 > 삭제 > 감사 로그 > 캐시 비움 */
    @Transactional
    public void deleteSheet(UUID roundUuid, UUID sheetUuid) {
        if (!examAnswerRoundRepository.existsById(roundUuid)) {
            throw new CustomException(ErrorCode.EXAM_ANSWER_ROUND_NOT_FOUND);
        }
        ExamAnswerSheet sheet = examAnswerSheetRepository.findById(sheetUuid)
                .filter(foundSheet -> foundSheet.getExamAnswerRoundUuid().equals(roundUuid))
                .orElseThrow(() -> new CustomException(ErrorCode.EXAM_ANSWER_SHEET_NOT_FOUND));
        examAnswerSheetRepository.delete(sheet);

        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.EXAM_ANSWER_ROUND, roundUuid,
                AdminAuditAction.DELETE, AdminAuditEvent.summary(
                        "sheetUuid", sheetUuid, "source", sheet.getSource().name(), "answers", sheet.getAnswers()), null));
        examAnswerSnapshotCache.evictAfterCommit(roundUuid);
    }

    private static AdminExamAnswerSheetRow toSheetRow(ExamAnswerSheet sheet) {
        return new AdminExamAnswerSheetRow(sheet.getExamAnswerSheetUuid(), sheet.getUpdatedAt(), sheet.getSource().name(),
                sheet.getClientTokenHash().substring(0, CLIENT_TOKEN_HASH_PREFIX_LENGTH), sheet.getAnswers());
    }
}
