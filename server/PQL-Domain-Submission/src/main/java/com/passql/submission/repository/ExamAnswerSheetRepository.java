package com.passql.submission.repository;

import com.passql.submission.entity.ExamAnswerSheet;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ExamAnswerSheetRepository extends JpaRepository<ExamAnswerSheet, UUID> {

    Optional<ExamAnswerSheet> findByExamAnswerRoundUuidAndClientTokenHash(UUID examAnswerRoundUuid, String clientTokenHash);

    long countByExamAnswerRoundUuid(UUID examAnswerRoundUuid);

    /** 회차 전체 답안 문자열 (득표·점수 분포 집계용) */
    @Query("select s.answers from ExamAnswerSheet s where s.examAnswerRoundUuid = :roundUuid")
    List<String> findAllAnswersByRoundUuid(@Param("roundUuid") UUID roundUuid);

    /**
     * 답안 저장 (회차·토큰 해시당 1장, 있으면 답·경로·회원 갱신)
     * 동시 재제출에도 유니크 위반 없이 1장 유지 (PostgreSQL ON CONFLICT)
     * memberUuid 문자열: null 바인딩 타입 불명 회피 (CAST 로 uuid)
     */
    @Modifying
    @Query(value = """
        INSERT INTO exam_answer_sheet (exam_answer_sheet_uuid, exam_answer_round_uuid, client_token_hash, member_uuid,
                                       answers, source, created_at, updated_at)
        VALUES (:sheetUuid, :roundUuid, :clientTokenHash, CAST(:memberUuid AS uuid), :answers, :source, :now, :now)
        ON CONFLICT (exam_answer_round_uuid, client_token_hash) DO UPDATE
           SET answers     = EXCLUDED.answers,
               source      = EXCLUDED.source,
               member_uuid = COALESCE(EXCLUDED.member_uuid, exam_answer_sheet.member_uuid),
               updated_at  = EXCLUDED.updated_at
        """, nativeQuery = true)
    int upsertSheet(@Param("sheetUuid") UUID sheetUuid,
                    @Param("roundUuid") UUID roundUuid,
                    @Param("clientTokenHash") String clientTokenHash,
                    @Param("memberUuid") String memberUuid,
                    @Param("answers") String answers,
                    @Param("source") String source,
                    @Param("now") LocalDateTime now);
}
