package com.passql.submission.repository;

import com.passql.submission.entity.ExamAnswerItem;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface ExamAnswerItemRepository extends JpaRepository<ExamAnswerItem, UUID> {

    List<ExamAnswerItem> findAllByExamAnswerRoundUuidOrderByQuestionNoAsc(UUID examAnswerRoundUuid);
}
