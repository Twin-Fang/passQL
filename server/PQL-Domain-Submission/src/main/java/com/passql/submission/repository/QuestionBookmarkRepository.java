package com.passql.submission.repository;

import com.passql.submission.entity.QuestionBookmark;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.UUID;

public interface QuestionBookmarkRepository extends JpaRepository<QuestionBookmark, UUID> {

    boolean existsByMemberUuidAndQuestionUuid(UUID memberUuid, UUID questionUuid);

    @Modifying
    @Query("DELETE FROM QuestionBookmark b WHERE b.memberUuid = :memberUuid AND b.questionUuid = :questionUuid")
    int deleteByMemberUuidAndQuestionUuid(@Param("memberUuid") UUID memberUuid, @Param("questionUuid") UUID questionUuid);

    /**
     * 즐겨찾기 목록 한 페이지 (활성 문제만, 최근 추가 순)
     * Object[] = { String questionUuid, String stem, String topicName, String topicCode, Timestamp bookmarkedAt }
     */
    @Query(value = """
        SELECT CAST(b.question_uuid AS varchar),
               q.stem,
               t.display_name,
               t.code,
               b.created_at
        FROM question_bookmark b
        JOIN question q ON q.question_uuid = b.question_uuid
        LEFT JOIN topic t ON t.topic_uuid = q.topic_uuid
        WHERE b.member_uuid = CAST(:memberUuid AS uuid)
          AND q.is_active = true
        ORDER BY b.created_at DESC, b.question_bookmark_uuid DESC
        LIMIT :limit OFFSET :offset
        """, nativeQuery = true)
    List<Object[]> findBookmarkPage(@Param("memberUuid") String memberUuid,
                                    @Param("limit") int limit,
                                    @Param("offset") int offset);

    /** 즐겨찾기 수 (활성 문제만) */
    @Query(value = """
        SELECT COUNT(*)
        FROM question_bookmark b
        JOIN question q ON q.question_uuid = b.question_uuid
        WHERE b.member_uuid = CAST(:memberUuid AS uuid)
          AND q.is_active = true
        """, nativeQuery = true)
    long countActiveBookmarks(@Param("memberUuid") String memberUuid);

    /** 즐겨찾기 풀기 묶음: 활성 문제 중 무작위 N개 */
    @Query(value = """
        SELECT CAST(b.question_uuid AS varchar)
        FROM question_bookmark b
        JOIN question q ON q.question_uuid = b.question_uuid
        WHERE b.member_uuid = CAST(:memberUuid AS uuid)
          AND q.is_active = true
        ORDER BY RANDOM()
        LIMIT :limit
        """, nativeQuery = true)
    List<String> findRandomBookmarkedQuestionUuids(@Param("memberUuid") String memberUuid, @Param("limit") int limit);
}
