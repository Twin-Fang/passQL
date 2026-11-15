package com.passql.submission.service;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.common.util.ServiceTimeZone;
import com.passql.common.util.Sha256Hex;
import com.passql.meta.constant.CertType;
import com.passql.submission.constant.ExamAnswerRoundStatus;
import com.passql.submission.constant.ExamAnswerSheetSource;
import com.passql.submission.constant.MockExamSubject;
import com.passql.submission.dto.examanswer.ExamAnswerGradingResponse;
import com.passql.submission.dto.examanswer.ExamAnswerRoundResponse;
import com.passql.submission.dto.examanswer.ExamAnswerScoreRangeResponse;
import com.passql.submission.dto.examanswer.ExamAnswerSheetResponse;
import com.passql.submission.dto.examanswer.ExamAnswerSheetSubmitRequest;
import com.passql.submission.dto.examanswer.ExamAnswerSubjectScoreResponse;
import com.passql.submission.entity.ExamAnswerRound;
import com.passql.submission.entity.ExamAnswerSheet;
import com.passql.submission.repository.ExamAnswerRoundRepository;
import com.passql.submission.repository.ExamAnswerSheetRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.UUID;
import java.util.regex.Pattern;

/**
 * 공개 가답안·OMR 가채점 (#1075, 로그인 불필요): 회차 조회, 답안 제출(갱신), 내 답안 조회
 * 득표·분포는 ExamAnswerSnapshotCache (최대 60초 지연), 클라이언트 토큰은 SHA-256 hex 로만 저장
 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ExamAnswerService {

    // 클라이언트 토큰 형식 (요청 본문 검증과 같은 규칙, 경로 변수 검사용)
    private static final Pattern CLIENT_TOKEN_PATTERN = Pattern.compile("^[A-Za-z0-9_-]{8,100}$");

    private final ExamAnswerRoundRepository examAnswerRoundRepository;
    private final ExamAnswerSheetRepository examAnswerSheetRepository;
    private final ExamAnswerSnapshotCache examAnswerSnapshotCache;

    /** 회차 가답안 (자격증·회차 번호) */
    public ExamAnswerRoundResponse getRound(String certTypeValue, int roundNumber) {
        return examAnswerSnapshotCache.get(findRound(certTypeValue, roundNumber)).response();
    }

    /** 답안 제출: 회차 확인(마감 거부) > 저장·갱신 > 채점 */
    @Transactional
    public ExamAnswerSheetResponse submitSheet(String certTypeValue, int roundNumber, ExamAnswerSheetSubmitRequest request,
                                               UUID memberUuid) {
        ExamAnswerRound round = findRound(certTypeValue, roundNumber);
        if (round.getStatus() == ExamAnswerRoundStatus.CLOSED) {
            throw new CustomException(ErrorCode.EXAM_ANSWER_ROUND_CLOSED);
        }
        ExamAnswerSheetSource source = request.source() == null || request.source().isBlank()
                ? ExamAnswerSheetSource.WEB
                : ExamAnswerSheetSource.fromRequestValue(request.source());

        // 회차·토큰 해시당 1장 (있으면 갱신)
        LocalDateTime submittedAt = LocalDateTime.now(ServiceTimeZone.ZONE);
        examAnswerSheetRepository.upsertSheet(UUID.randomUUID(), round.getExamAnswerRoundUuid(),
                Sha256Hex.of(request.clientToken()), memberUuid == null ? null : memberUuid.toString(),
                request.answers(), source.name(), submittedAt);
        log.info("[exam answer] sheet saved : round={} {}, source={}, isMember={}",
                round.getCertType(), round.getRoundNumber(), source, memberUuid != null);

        ExamAnswerRoundSnapshot snapshot = examAnswerSnapshotCache.get(round);
        return new ExamAnswerSheetResponse(round.getCertType().name(), round.getRoundNumber(), request.answers(),
                source.name(), submittedAt, gradeAnswers(request.answers(), snapshot));
    }

    /** 내 답안 + 채점 (클라이언트 토큰 기준) */
    public ExamAnswerSheetResponse getMySheet(String certTypeValue, int roundNumber, String clientToken) {
        if (clientToken == null || !CLIENT_TOKEN_PATTERN.matcher(clientToken).matches()) {
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE);
        }
        ExamAnswerRound round = findRound(certTypeValue, roundNumber);
        ExamAnswerSheet sheet = examAnswerSheetRepository
                .findByExamAnswerRoundUuidAndClientTokenHash(round.getExamAnswerRoundUuid(), Sha256Hex.of(clientToken))
                .orElseThrow(() -> new CustomException(ErrorCode.EXAM_ANSWER_SHEET_NOT_FOUND));

        ExamAnswerRoundSnapshot snapshot = examAnswerSnapshotCache.get(round);
        return new ExamAnswerSheetResponse(round.getCertType().name(), round.getRoundNumber(), sheet.getAnswers(),
                sheet.getSource().name(), sheet.getUpdatedAt(), gradeAnswers(sheet.getAnswers(), snapshot));
    }

    private ExamAnswerRound findRound(String certTypeValue, int roundNumber) {
        CertType certType = CertType.fromRequestValue(certTypeValue);
        return examAnswerRoundRepository.findByCertTypeAndRoundNumber(certType, roundNumber)
                .orElseThrow(() -> new CustomException(ErrorCode.EXAM_ANSWER_ROUND_NOT_FOUND));
    }

    /** 답 50자 + 집계 > 채점 응답 (과목 점수·범위·판정·상위 %·문항별) */
    private ExamAnswerGradingResponse gradeAnswers(String answers, ExamAnswerRoundSnapshot snapshot) {
        ExamAnswerGrader.ExamAnswerGrade grade = ExamAnswerGrader.grade(answers, snapshot.keys());
        return new ExamAnswerGradingResponse(
                toSubjectScoreResponse(MockExamSubject.SUBJECT_ONE, grade.subject1().score()),
                toSubjectScoreResponse(MockExamSubject.SUBJECT_TWO, grade.subject2().score()),
                grade.totalScore(),
                new ExamAnswerScoreRangeResponse(grade.minTotalScore(), grade.maxTotalScore()),
                grade.passStatus().name(),
                snapshot.calculateTopPercent(grade.totalScore()),
                grade.perQuestion());
    }

    private static ExamAnswerSubjectScoreResponse toSubjectScoreResponse(MockExamSubject subject, int score) {
        return new ExamAnswerSubjectScoreResponse(score, MockExamRule.maxScoreOf(subject),
                ExamAnswerGrader.isSubjectFailCut(subject, score));
    }
}
