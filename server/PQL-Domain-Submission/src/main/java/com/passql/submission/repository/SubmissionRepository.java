package com.passql.submission.repository;

import com.passql.submission.dto.RecentAttemptProjection;
import com.passql.submission.dto.SolvedQuestionProjection;
import com.passql.submission.entity.Submission;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface SubmissionRepository extends JpaRepository<Submission, UUID> {

    List<Submission> findByMemberUuidOrderBySubmittedAtDesc(UUID memberUuid);

    /** 관리자 회원 상세: 제출 이력 한 페이지 */
    Page<Submission> findPageByMemberUuidOrderBySubmittedAtDesc(UUID memberUuid, Pageable pageable);

    /** 회원이 이 문제에 마지막으로 낸 답안. AI 해설이 어떤 선택지 세트를 봤는지 찾을 때 쓴다. */
    Optional<Submission> findFirstByMemberUuidAndQuestionUuidOrderBySubmittedAtDesc(UUID memberUuid, UUID questionUuid);

    /** 회원이 이 문제의 특정 선택지 세트로 마지막으로 낸 답안 (해설 조회 권한 확인: 제출한 세트만 해설 공개, #521) */
    Optional<Submission> findFirstByMemberUuidAndQuestionUuidAndChoiceSetUuidOrderBySubmittedAtDesc(
            UUID memberUuid, UUID questionUuid, UUID choiceSetUuid);

    /** 커뮤니티: 이 문제를 풀어 본(제출 기록이 있는) 회원인지 */
    boolean existsByMemberUuidAndQuestionUuid(UUID memberUuid, UUID questionUuid);

    /** 기간 [from, to) 안에 제출한 서로 다른 문제 수 (하루 문제 수 제한용, 같은 문제 재제출은 1건) */
    @Query("""
            SELECT COUNT(DISTINCT s.questionUuid) FROM Submission s
            WHERE s.memberUuid = :memberUuid AND s.submittedAt >= :from AND s.submittedAt < :to
            """)
    long countDistinctQuestionsSubmittedBetween(@Param("memberUuid") UUID memberUuid,
                                                @Param("from") LocalDateTime from,
                                                @Param("to") LocalDateTime to);

    /** 위와 같되 제외 문제(오늘의 문제 배정분)는 뺀다. 제외 목록이 비면 호출하지 말 것(빈 NOT IN 방지) */
    @Query("""
            SELECT COUNT(DISTINCT s.questionUuid) FROM Submission s
            WHERE s.memberUuid = :memberUuid AND s.submittedAt >= :from AND s.submittedAt < :to
              AND s.questionUuid NOT IN :excludedQuestionUuids
            """)
    long countDistinctQuestionsSubmittedBetweenExcluding(@Param("memberUuid") UUID memberUuid,
                                                         @Param("from") LocalDateTime from,
                                                         @Param("to") LocalDateTime to,
                                                         @Param("excludedQuestionUuids") java.util.Collection<UUID> excludedQuestionUuids);

    /** 커뮤니티 풀이 스냅샷: 이 문제 제출을 시간순으로 */
    List<Submission> findByMemberUuidAndQuestionUuidOrderBySubmittedAtAsc(UUID memberUuid, UUID questionUuid);

    /** 커뮤니티 카드: 후보 문제 중 내가 푼 문제 */
    @Query("SELECT DISTINCT s.questionUuid FROM Submission s WHERE s.memberUuid = :memberUuid AND s.questionUuid IN :questionUuids")
    List<UUID> findSolvedQuestionUuids(@Param("memberUuid") UUID memberUuid,
                                       @Param("questionUuids") java.util.Collection<UUID> questionUuids);

    /** 회원이 한 번이라도 제출한 문제 uuid 전체 (랜덤 풀기에서 안 푼 문제 우선 선별용) */
    @Query("SELECT DISTINCT s.questionUuid FROM Submission s WHERE s.memberUuid = :memberUuid")
    List<UUID> findAllSubmittedQuestionUuids(@Param("memberUuid") UUID memberUuid);

    /** 커뮤니티 '내가 푼 문제' 피드: 내가 푼 문제와 오답 제출 여부 */
    @Query("""
            SELECT s.questionUuid AS questionUuid, MAX(CASE WHEN s.isCorrect = false THEN 1 ELSE 0 END) AS hasWrongSubmission
            FROM Submission s WHERE s.memberUuid = :memberUuid GROUP BY s.questionUuid
            """)
    List<SolvedQuestionProjection> findSolvedQuestionsWithWrongFlag(@Param("memberUuid") UUID memberUuid);

    // 기간 안의 마지막 제출 — 완료한 오늘의 세트를 다시 열 때 문제별 정오를 복원하는 데 쓴다 (#372)
    Optional<Submission> findFirstByMemberUuidAndQuestionUuidAndSubmittedAtBetweenOrderBySubmittedAtDesc(
            UUID memberUuid, UUID questionUuid, java.time.LocalDateTime from, java.time.LocalDateTime to);

    /** 한 풀이 세션(sessionUuid)에서 회원이 제출한 답안. 점수를 서버가 직접 계산할 때 쓴다. */
    List<Submission> findByMemberUuidAndSessionUuidOrderBySubmittedAtAsc(UUID memberUuid, UUID sessionUuid);

    /** 기준 시각 이후 회원이 여러 문제에 낸 답안 (세션 무관, 오늘의 세트 첫 제출 채점용 #561) */
    List<Submission> findByMemberUuidAndQuestionUuidInAndSubmittedAtGreaterThanEqualOrderBySubmittedAtAsc(
            UUID memberUuid, java.util.Collection<UUID> questionUuids, LocalDateTime since);

    long countByMemberUuid(UUID memberUuid);

    long countByMemberUuidAndIsCorrectTrue(UUID memberUuid);

    @Query("SELECT COUNT(DISTINCT s.questionUuid) FROM Submission s WHERE s.memberUuid = :memberUuid")
    long countDistinctQuestionUuidByMemberUuid(@Param("memberUuid") UUID memberUuid);

    boolean existsByMemberUuidAndQuestionUuidAndSubmittedAtBetween(
            UUID memberUuid, UUID questionUuid, LocalDateTime start, LocalDateTime end);

    // PostgreSQL: String → uuid 캐스트는 ::uuid가 아닌 CAST(:param AS uuid) 사용 (Hibernate 파라미터 파싱 호환)
    @Query(value = "WITH latest AS (SELECT question_uuid, is_correct, ROW_NUMBER() OVER (PARTITION BY question_uuid ORDER BY submitted_at DESC) rn FROM submission WHERE member_uuid = CAST(:memberUuid AS uuid)) SELECT COALESCE(AVG(CASE WHEN is_correct=true THEN 1.0 ELSE 0.0 END),0) FROM latest WHERE rn=1", nativeQuery = true)
    Double calculateCorrectRateByMemberUuid(@Param("memberUuid") String memberUuid);

    // 풀이 날짜 목록 (submitted_at 은 서버 로컬 KST 저장값, 컨테이너 TZ=Asia/Seoul > 변환 없이 DATE) (#560)
    @Query(value =
        "SELECT DISTINCT DATE(s.submitted_at) " +
        "FROM submission s " +
        "WHERE s.member_uuid = CAST(:memberUuid AS uuid) " +
        "ORDER BY 1 DESC",
        nativeQuery = true)
    List<java.sql.Date> findSubmissionDatesByMemberUuid(@Param("memberUuid") String memberUuid);

    /**
     * Readiness 계산용 최근 시도 투영 (Accuracy + lastStudiedAt 단일 조회).
     *
     * 정렬 안정성: 동시각 tiebreaker로 submissionUuid DESC 추가.
     * 호출부에서 {@code ReadinessConstants.RECENT_PAGE}로 상위 N개만 가져온다.
     *
     * 결과의 첫 원소 submittedAt이 마지막 학습 시각이므로 별도 MAX 쿼리가 불필요.
     */
    @Query("SELECT new com.passql.submission.dto.RecentAttemptProjection(s.isCorrect, s.submittedAt) " +
           "FROM Submission s " +
           "WHERE s.memberUuid = :memberUuid " +
           "ORDER BY s.submittedAt DESC, s.submissionUuid DESC")
    List<RecentAttemptProjection> findRecentAttemptsByMemberUuid(
        @Param("memberUuid") UUID memberUuid,
        Pageable pageable
    );

    /**
     * 최근 :since 이후에 제출된 문제들 중 "활성 토픽"의 distinct 개수.
     *
     * 네이티브 쿼리로 작성한 이유:
     *  - Submission 엔티티에 Question/Topic 연관관계(@ManyToOne)가 없어 JPQL theta-join을 쓰면
     *    파서/옵티마이저 이슈(데카르트 조인 → HashJoin 최적화 실패)가 생길 수 있음
     *  - JPQL FQN 참조는 부분 컨텍스트 테스트(@DataJpaTest)에서 엔티티 클래스 로딩 순서 의존성을 가짐
     *  - 기존 {@code calculateCorrectRateByMemberUuid}가 이미 네이티브 쿼리를 쓰고 있어 컨벤션 일관
     *
     * ReadinessCalculator의 Coverage 분자.
     */
    @Query(value =
        "SELECT COUNT(DISTINCT q.topic_uuid) " +
        "FROM submission s " +
        "JOIN question q ON q.question_uuid = s.question_uuid " +
        "JOIN topic t ON t.topic_uuid = q.topic_uuid " +
        // PostgreSQL: CAST(:param AS uuid) 사용 (::uuid는 Hibernate 파라미터 파싱 오류 유발)
        "WHERE s.member_uuid = CAST(:memberUuid AS uuid) " +
        "  AND s.submitted_at >= :since " +
        "  AND t.is_active = true",
        nativeQuery = true)
    long countDistinctRecentActiveTopicsByMemberUuid(
        @Param("memberUuid") String memberUuid,
        @Param("since") LocalDateTime since
    );

    /**
     * 히트맵용 날짜별 풀이/정답 수 집계.
     *
     * 기존 인덱스 idx_submission_member_submitted (member_uuid, submitted_at) 활용.
     * to 파라미터는 exclusive upper bound — Service에서 (to + 1일).atStartOfDay()로 전달.
     *
     * @return Object[] = { java.sql.Date date, long solvedCount, long correctCount }
     */
    @Query(value =
        // submitted_at 은 서버 로컬 KST 저장값 (컨테이너 TZ=Asia/Seoul) > 변환 없이 DATE (#560)
        "SELECT DATE(s.submitted_at) AS date, " +
        "       COUNT(*)              AS solved_count, " +
        "       SUM(CASE WHEN s.is_correct THEN 1 ELSE 0 END) AS correct_count " +
        "FROM submission s " +
        "WHERE s.member_uuid = CAST(:memberUuid AS uuid) " +
        "  AND s.submitted_at >= :fromDate " +
        "  AND s.submitted_at < :toDateExclusive " +
        "GROUP BY DATE(s.submitted_at) " +
        "ORDER BY date ASC",
        nativeQuery = true)
    List<Object[]> findHeatmapByMemberUuid(
        @Param("memberUuid") String memberUuid,
        @Param("fromDate") LocalDateTime fromDate,
        @Param("toDateExclusive") LocalDateTime toDateExclusive
    );

    /** 특정 시간 이후 제출 건수 (대시보드 오늘 제출 집계용) */
    long countBySubmittedAtAfter(LocalDateTime since);

    /**
     * 최근 N건의 오답 문제 UUID 목록 조회 (RAG 추천 쿼리 벡터용).
     *
     * 동일 문제를 여러 번 틀렸어도 1번만 포함 (DISTINCT).
     * 최신 오답 순으로 정렬하여 최근 학습 맥락을 반영한다.
     */
    @Query(value =
        // GROUP BY로 최신 오답 시각 기준 정렬 — DISTINCT + ORDER BY MAX()는 PostgreSQL에서 허용되지 않음
        "SELECT CAST(s.question_uuid AS varchar) " +
        "FROM submission s " +
        "WHERE s.member_uuid = CAST(:memberUuid AS uuid) " +
        "  AND s.is_correct = false " +
        "GROUP BY s.question_uuid " +
        "ORDER BY MAX(s.submitted_at) DESC " +
        "LIMIT :limit",
        nativeQuery = true)
    List<String> findRecentWrongQuestionUuids(
        @Param("memberUuid") String memberUuid,
        @Param("limit") int limit
    );

    /**
     * 회원이 최근 푼 문제 UUID 목록 조회 (Qdrant must_not 필터용).
     *
     * 전량 조회 시 페이로드 과부하 우려가 있어 최근 N건으로 제한.
     * 추천에서 최근 풀어본 문제를 제외하는 용도이므로 오래된 기록까지 제외할 필요 없음.
     */
    @Query(value =
        "SELECT CAST(s.question_uuid AS varchar) " +
        "FROM submission s " +
        "WHERE s.member_uuid = CAST(:memberUuid AS uuid) " +
        "GROUP BY s.question_uuid " +
        "ORDER BY MAX(s.submitted_at) DESC " +
        "LIMIT :limit",
        nativeQuery = true)
    List<String> findSolvedQuestionUuids(
        @Param("memberUuid") String memberUuid,
        @Param("limit") int limit
    );

    /**
     * 최근 N건 시도의 문제 평균 난이도 (Difficulty 계산용).
     *
     * JPQL은 LIMIT 미지원이라 네이티브 쿼리 사용.
     * 이력 없으면 null 반환.
     */
    @Query(value =
        "SELECT AVG(q.difficulty) " +
        "FROM ( " +
        "  SELECT s.question_uuid " +
        "  FROM submission s " +
        "  WHERE s.member_uuid = CAST(:memberUuid AS uuid) " +
        "  ORDER BY s.submitted_at DESC, s.submission_uuid DESC " +
        "  LIMIT :limitCount " +
        ") recent " +
        "JOIN question q ON q.question_uuid = recent.question_uuid",
        nativeQuery = true)
    Double findAvgDifficultyOfRecentAttempts(
        @Param("memberUuid") String memberUuid,
        @Param("limitCount") int limitCount
    );

    /**
     * 전체 이력 중 틀렸다가 이후 정답을 낸 DISTINCT 문제 수 (Retry 분자).
     */
    @Query(value =
        "SELECT COUNT(DISTINCT s1.question_uuid) " +
        "FROM submission s1 " +
        "WHERE s1.member_uuid = CAST(:memberUuid AS uuid) " +
        "  AND s1.is_correct = false " +
        "  AND EXISTS ( " +
        "    SELECT 1 FROM submission s2 " +
        "    WHERE s2.member_uuid = s1.member_uuid " +
        "      AND s2.question_uuid = s1.question_uuid " +
        "      AND s2.is_correct = true " +
        "      AND s2.submitted_at > s1.submitted_at " +
        "  )",
        nativeQuery = true)
    long countRetriedAndCorrectQuestions(@Param("memberUuid") String memberUuid);

    /**
     * 전체 이력 중 한 번이라도 틀린 DISTINCT 문제 수 (Retry 분모).
     */
    @Query(value =
        "SELECT COUNT(DISTINCT question_uuid) " +
        "FROM submission " +
        "WHERE member_uuid = CAST(:memberUuid AS uuid) " +
        "  AND is_correct = false",
        nativeQuery = true)
    long countDistinctWrongQuestions(@Param("memberUuid") String memberUuid);

    /**
     * 최근 N일 내 활성 토픽별 제출 건수 (Spread 계산용).
     *
     * @return Object[] = { String topicUuid, long count }
     */
    @Query(value =
        "SELECT CAST(q.topic_uuid AS varchar), COUNT(*) AS cnt " +
        "FROM submission s " +
        "JOIN question q ON q.question_uuid = s.question_uuid " +
        "JOIN topic t ON t.topic_uuid = q.topic_uuid " +
        "WHERE s.member_uuid = CAST(:memberUuid AS uuid) " +
        "  AND s.submitted_at >= :since " +
        "  AND t.is_active = true " +
        "GROUP BY q.topic_uuid",
        nativeQuery = true)
    List<Object[]> findTopicSubmissionCountsAfter(
        @Param("memberUuid") String memberUuid,
        @Param("since") LocalDateTime since
    );

    @Modifying
    @Transactional
    void deleteByQuestionUuid(UUID questionUuid);

    // 문제 전체 기준 오답 제출 보정
    @Modifying
    @Transactional
    @Query("UPDATE Submission s SET s.isCorrect = true WHERE s.questionUuid = :questionUuid AND s.isCorrect = false")
    int correctAllByQuestionUuid(@Param("questionUuid") UUID questionUuid);

    // 선택지 세트 기준 오답 제출 보정
    @Modifying
    @Transactional
    @Query("UPDATE Submission s SET s.isCorrect = true WHERE s.choiceSetUuid = :choiceSetUuid AND s.isCorrect = false")
    int correctAllByChoiceSetUuid(@Param("choiceSetUuid") UUID choiceSetUuid);

    // PostgreSQL: CAST(:param AS uuid) 사용 (::uuid는 Hibernate 파라미터 파싱 오류 유발)
    @Query(value = """
        WITH latest AS (
            SELECT s.question_uuid,
                   q.topic_uuid,
                   s.is_correct,
                   ROW_NUMBER() OVER (PARTITION BY s.question_uuid ORDER BY s.submitted_at DESC, s.submission_uuid DESC) AS rn
            FROM submission s
            JOIN question q ON s.question_uuid = q.question_uuid
            WHERE s.member_uuid = CAST(:memberUuid AS uuid)
              AND s.submitted_at >= :since
        )
        SELECT topic_uuid,
               COUNT(*) AS solved_count,
               AVG(CASE WHEN is_correct = true THEN 1.0 ELSE 0.0 END) AS correct_rate
        FROM latest
        WHERE rn = 1
        GROUP BY topic_uuid
        """, nativeQuery = true)
    List<Object[]> findTopicStatsAfter(@Param("memberUuid") String memberUuid,
                                       @Param("since") LocalDateTime since);

    /**
     * 세션 내 제출 목록을 토픽명과 함께 조회 (AI 코멘트 세션 컨텍스트용).
     *
     * 네이티브 쿼리 사용 이유: Submission↔Question↔Topic 간 @ManyToOne 연관관계가 없어
     * JPQL theta-join 시 데카르트 조인 발생 우려.
     *
     * @return Object[] = { String topicDisplayName, Boolean isCorrect }
     */
    @Query(value =
        "SELECT t.display_name AS topic_name, s.is_correct " +
        "FROM submission s " +
        "JOIN question q ON s.question_uuid = q.question_uuid " +
        "JOIN topic t ON q.topic_uuid = t.topic_uuid " +
        "WHERE s.session_uuid = CAST(:sessionUuid AS uuid) " +
        "ORDER BY s.submitted_at ASC",
        nativeQuery = true)
    List<Object[]> findTopicResultsBySessionUuid(@Param("sessionUuid") String sessionUuid);

    /**
     * 통계 화면 AI 코멘트용 최근 N일 학습 현황 조회.
     *
     * Object[] = { Long recentCount, LocalDateTime lastActiveAt }
     * recentCount  : since 이후 제출 건수
     * lastActiveAt : 가장 최근 제출 시각 (제출 없으면 null)
     *
     * 네이티브 쿼리 이유: CAST(:memberUuid AS uuid) 패턴 필요 (같은 파일 다른 네이티브 쿼리와 동일 방식)
     */
    @Query(value =
        "SELECT COUNT(*) AS recent_count, " +
        "       MAX(s.submitted_at) AS last_active_at " +
        "FROM submission s " +
        "WHERE s.member_uuid = CAST(:memberUuid AS uuid) " +
        "  AND s.submitted_at >= :since",
        nativeQuery = true)
    List<Object[]> findRecentActivityStats(
        @Param("memberUuid") String memberUuid,
        @Param("since") LocalDateTime since
    );

    /**
     * 마이페이지 오답 노트용 — 최근 틀린 문제 목록 (문제 제목 미리보기 + 토픽명 포함).
     *
     * 동일 문제를 여러 번 틀렸어도 1건만 반환 (GROUP BY question_uuid).
     * 최신 오답 시각 기준 정렬.
     *
     * Object[] = { String questionUuid, String stem, String topicName, LocalDateTime lastWrongAt }
     */
    @Query(value =
        "SELECT CAST(s.question_uuid AS varchar), " +
        "       q.stem, " +
        "       t.display_name, " +
        "       MAX(s.submitted_at) AS last_wrong_at " +
        "FROM submission s " +
        "JOIN question q ON q.question_uuid = s.question_uuid " +
        "JOIN topic t ON t.topic_uuid = q.topic_uuid " +
        "WHERE s.member_uuid = CAST(:memberUuid AS uuid) " +
        "  AND s.is_correct = false " +
        "  AND q.is_active = true " +
        "GROUP BY s.question_uuid, q.stem, t.display_name " +
        "ORDER BY last_wrong_at DESC " +
        "LIMIT :limit",
        nativeQuery = true)
    List<Object[]> findWrongQuestionsWithMeta(
        @Param("memberUuid") String memberUuid,
        @Param("limit") int limit
    );
}
