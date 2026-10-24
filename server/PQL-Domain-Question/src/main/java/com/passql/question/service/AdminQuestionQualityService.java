package com.passql.question.service;

import com.passql.question.dto.AdminQuestionListItem;
import com.passql.question.dto.AdminQuestionQualityDetail;
import com.passql.question.entity.QuestionQualityStat;
import com.passql.question.repository.QuestionQualityStatRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * 관리자 문제 품질 지표: 목록 행에 풀이·정답률·신고 수 붙이기, 상세의 선택 분포·신고 요약
 * 집계 원본은 QuestionQualityStat 뷰 (집계 쿼리 1곳)
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AdminQuestionQualityService {

    private final QuestionQualityStatRepository questionQualityStatRepository;

    /** 목록 페이지 행 > 품질 지표 붙인 행 (페이지 uuid 만 한 번에 조회) */
    public Page<AdminQuestionListItem> attachQualityStats(Page<AdminQuestionListItem> page) {
        List<UUID> questionUuids = page.getContent().stream().map(AdminQuestionListItem::questionUuid).toList();
        Map<UUID, QuestionQualityStat> statByQuestionUuid = questionQualityStatRepository.findAllById(questionUuids)
                .stream().collect(Collectors.toMap(QuestionQualityStat::getQuestionUuid, Function.identity()));
        return page.map(item -> {
            QuestionQualityStat stat = statByQuestionUuid.get(item.questionUuid());
            return stat == null ? item
                    : item.attachQualityStat(stat.getSolveCount(), stat.getAccuracyPercent(), stat.getReportCount());
        });
    }

    /** 문제 1건 품질 요약: 풀이·정답·신고 수 + 보기 키별 선택 분포 */
    public AdminQuestionQualityDetail getQualityDetail(UUID questionUuid) {
        QuestionQualityStat stat = questionQualityStatRepository.findById(questionUuid).orElse(null);
        long solveCount = stat == null ? 0L : stat.getSolveCount();
        List<AdminQuestionQualityDetail.ChoiceSelection> choiceSelections = questionQualityStatRepository
                .findChoiceSelectionsByQuestionUuid(questionUuid).stream()
                .map(row -> new AdminQuestionQualityDetail.ChoiceSelection(row.getChoiceKey(), row.getSelectedCount(),
                        row.getCorrectCount(), solveCount == 0 ? 0.0 : 100.0 * row.getSelectedCount() / solveCount))
                .toList();
        return new AdminQuestionQualityDetail(solveCount,
                stat == null ? 0L : stat.getCorrectCount(),
                stat == null ? null : stat.getAccuracyPercent(),
                stat == null ? 0L : stat.getReportCount(),
                stat == null ? 0L : stat.getPendingReportCount(),
                choiceSelections);
    }
}
