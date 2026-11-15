package com.passql.submission.service;

import com.passql.common.util.ServiceTimeZone;
import com.passql.question.entity.Question;
import com.passql.question.repository.QuestionRepository;
import com.passql.submission.constant.MockExamSubject;
import com.passql.submission.dto.HardestQuestionItem;
import com.passql.submission.dto.HardestQuestionsResponse;
import com.passql.submission.dto.QuestionFirstAttemptStat;
import com.passql.submission.repository.HardestQuestionQueryRepository;
import com.passql.submission.util.QuestionStemPreview;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

/**
 * 오답률 TOP (#1080): 첫 제출 집계 > 순위 > 지문 미리보기, 결과는 서버 메모리에 1시간 보관
 * 기동 후 첫 요청에서 계산, 지난 결과는 다음 요청에서 다시 계산 (등급 제한 없음)
 * 보관 결과를 돌려줄 때 DB 커넥션을 잡지 않게 클래스 트랜잭션 없음 (쿼리마다 읽기)
 */
@Service
@RequiredArgsConstructor
public class HardestQuestionService {

    // 목록 기본·최대 개수 (@RequestParam defaultValue 용 문자열 상수 포함)
    public static final String DEFAULT_LIMIT = "30";
    private static final int MAXIMUM_LIMIT = 30;
    // 목록에 넣는 최소 첫 제출 회원 수 (적으면 오답률이 흔들림)
    private static final int MINIMUM_ATTEMPT_COUNT = 20;
    // 집계 보관 시간
    private static final Duration CACHE_DURATION = Duration.ofHours(1);

    private final HardestQuestionQueryRepository hardestQuestionQueryRepository;
    private final QuestionRepository questionRepository;

    // 마지막 집계 (최대 30개 순위, 집계 시각)
    private volatile HardestQuestionsResponse cachedRanking;

    /** 상위 limit 개 (1~30 보정, 집계는 1시간마다) */
    public HardestQuestionsResponse getHardestQuestions(int limit) {
        HardestQuestionsResponse ranking = loadRanking();
        int itemCount = Math.min(Math.max(1, Math.min(limit, MAXIMUM_LIMIT)), ranking.items().size());
        return new HardestQuestionsResponse(
            ranking.items().subList(0, itemCount), ranking.aggregatedAt(), ranking.minimumAttemptCount());
    }

    // 보관 집계가 없거나 1시간 지났으면 다시 집계 (동시 요청은 한 번만 계산)
    private HardestQuestionsResponse loadRanking() {
        HardestQuestionsResponse ranking = cachedRanking;
        if (isFresh(ranking)) return ranking;
        synchronized (this) {
            if (!isFresh(cachedRanking)) {
                cachedRanking = aggregateRanking();
            }
            return cachedRanking;
        }
    }

    private static boolean isFresh(HardestQuestionsResponse ranking) {
        return ranking != null
            && ranking.aggregatedAt().plus(CACHE_DURATION).isAfter(LocalDateTime.now(ServiceTimeZone.ZONE));
    }

    // 첫 제출 집계 > 순위 30개 > 지문 미리보기 붙이기
    private HardestQuestionsResponse aggregateRanking() {
        LocalDateTime aggregatedAt = LocalDateTime.now(ServiceTimeZone.ZONE);
        List<QuestionFirstAttemptStat> stats = hardestQuestionQueryRepository.findFirstAttemptStats().stream()
            .map(HardestQuestionService::toQuestionFirstAttemptStat)
            .toList();
        List<QuestionFirstAttemptStat> ranked = HardestQuestionRanker.rank(stats, MINIMUM_ATTEMPT_COUNT, MAXIMUM_LIMIT);

        Map<UUID, String> stemByQuestionUuid = questionRepository
            .findAllById(ranked.stream().map(QuestionFirstAttemptStat::questionUuid).toList()).stream()
            .collect(Collectors.toMap(Question::getQuestionUuid, Question::getStem, (first, second) -> first));
        List<HardestQuestionItem> items = IntStream.range(0, ranked.size())
            .mapToObj(index -> toHardestQuestionItem(index + 1, ranked.get(index), stemByQuestionUuid::get))
            .toList();
        return new HardestQuestionsResponse(items, aggregatedAt, MINIMUM_ATTEMPT_COUNT);
    }

    // Object[] = { questionUuid, topicName, topicCode, attemptCount, wrongCount }
    private static QuestionFirstAttemptStat toQuestionFirstAttemptStat(Object[] row) {
        return new QuestionFirstAttemptStat(
            UUID.fromString((String) row[0]),
            (String) row[1],
            (String) row[2],
            ((Number) row[3]).intValue(),
            ((Number) row[4]).intValue()
        );
    }

    private static HardestQuestionItem toHardestQuestionItem(
        int rank, QuestionFirstAttemptStat stat, Function<UUID, String> stemOf
    ) {
        return new HardestQuestionItem(
            rank,
            stat.questionUuid(),
            QuestionStemPreview.toListPreview(stemOf.apply(stat.questionUuid())),
            stat.topicName(),
            MockExamSubject.fromTopicCode(stat.topicCode()),
            HardestQuestionRanker.toWrongRatePercent(stat),
            stat.attemptCount()
        );
    }
}
