package com.passql.application.oxquiz;

import com.passql.application.oxquiz.OxCardCatalog.OxCard;
import com.passql.application.oxquiz.dto.OxAnswerRequest;
import com.passql.application.oxquiz.dto.OxAnswerResponse;
import com.passql.application.oxquiz.dto.OxCardItem;
import com.passql.application.oxquiz.dto.OxCardSetResponse;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.common.util.ServiceTimeZone;
import com.passql.meta.entity.OxCardReview;
import com.passql.meta.repository.OxCardReviewRepository;
import com.passql.meta.service.oxquiz.LeitnerSchedule;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;
import java.util.stream.Stream;

/**
 * OX 퀴즈 (#1083): 카드 묶음(기한 지난 복습 > 새 카드), 답 기록 > Leitner 칸·다음 출제일 갱신
 * 채점은 앱이 하고 서버는 정오만 받음 (정답이 카드에 함께 내려감)
 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class OxQuizService {

    // 카드 묶음 기본·최대 장 수 (@RequestParam defaultValue 용 문자열 상수 포함)
    public static final String DEFAULT_CARD_SET_SIZE = "10";
    private static final int MAXIMUM_CARD_SET_SIZE = 20;
    // 오늘 목표 장 수
    private static final int DAILY_GOAL_CARD_COUNT = 20;
    // 기한 지난 카드 순서: 오래 밀린 것 > 낮은 칸
    private static final Comparator<DueCard> DUE_ORDER = Comparator
        .comparing((DueCard dueCard) -> dueCard.review().getDueAt())
        .thenComparing(dueCard -> dueCard.review().getBox());

    private final OxCardCatalog cardCatalog;
    private final OxCardReviewRepository reviewRepository;

    /** 카드 묶음: 열 수 있는 카드 > 기한 지난 복습(오래 밀린 순) > 새 카드(학습 순서) > size 장 (1~20 보정) */
    public OxCardSetResponse getCardSet(UUID memberUuid, int size) {
        OxCardCatalog.AccessibleOxCards accessibleCards = cardCatalog.loadAccessibleCards(memberUuid);
        Map<String, OxCardReview> reviewByCardKey = reviewRepository.findByMemberUuid(memberUuid).stream()
            .collect(Collectors.toMap(OxCardReview::getCardKey, Function.identity(), (first, second) -> first));
        LocalDateTime now = LocalDateTime.now(ServiceTimeZone.ZONE);

        // 기한 지난 복습 카드 / 처음 보는 카드 나누기 (기한 남은 카드는 제외)
        List<DueCard> dueCards = accessibleCards.cards().stream()
            .filter(card -> reviewByCardKey.containsKey(card.cardKey()))
            .map(card -> new DueCard(card, reviewByCardKey.get(card.cardKey())))
            .filter(dueCard -> !dueCard.review().getDueAt().isAfter(now))
            .sorted(DUE_ORDER)
            .toList();
        List<OxCard> newCards = accessibleCards.cards().stream()
            .filter(card -> !reviewByCardKey.containsKey(card.cardKey()))
            .toList();

        int cardCount = Math.max(1, Math.min(size, MAXIMUM_CARD_SET_SIZE));
        List<OxCardItem> pickedCards = Stream.concat(
                dueCards.stream().map(dueCard -> toItem(dueCard.card(), dueCard.review().getBox())),
                newCards.stream().map(card -> toItem(card, null)))
            .limit(cardCount)
            .toList();
        return new OxCardSetResponse(pickedCards, dueCards.size(), newCards.size(),
            countTodayAnswered(memberUuid, now), DAILY_GOAL_CARD_COUNT, accessibleCards.hasLockedTopics());
    }

    /** 답 기록: 요청 검증 > 열 수 있는 카드인지 > 복습 행(없으면 생성) > 칸·출제일·연속 정답 갱신 */
    @Transactional
    public OxAnswerResponse answer(UUID memberUuid, OxAnswerRequest request) {
        String cardKey = request.cardKey() == null ? "" : request.cardKey().trim();
        if (cardKey.isEmpty() || request.isCorrect() == null) {
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE, "cardKey and isCorrect are required");
        }
        boolean isAccessibleCard = cardCatalog.loadAccessibleCards(memberUuid).cards().stream()
            .anyMatch(card -> card.cardKey().equals(cardKey));
        if (!isAccessibleCard) {
            log.info("[ox quiz] rejected 404 : card not accessible, member={}", memberUuid);
            throw new CustomException(ErrorCode.OX_CARD_NOT_FOUND);
        }

        // 칸 이동 (처음이면 1칸에서 시작) > 다음 출제일 0시
        LocalDateTime now = LocalDateTime.now(ServiceTimeZone.ZONE);
        OxCardReview review = reviewRepository.findForUpdate(memberUuid, cardKey).orElse(null);
        boolean isCorrect = request.isCorrect();
        LeitnerSchedule.NextReview nextReview = LeitnerSchedule.next(
            review == null ? null : review.getBox(), isCorrect, now.toLocalDate());
        int correctStreak = isCorrect ? (review == null ? 0 : review.getCorrectStreak()) + 1 : 0;
        if (review == null) {
            review = OxCardReview.builder().memberUuid(memberUuid).cardKey(cardKey).build();
        }
        review.setBox(nextReview.box());
        review.setDueAt(nextReview.dueDate().atStartOfDay());
        review.setLastAnsweredAt(now);
        review.setCorrectStreak(correctStreak);
        reviewRepository.save(review);

        return new OxAnswerResponse(cardKey, nextReview.box(), nextReview.dueDate(), correctStreak,
            countTodayAnswered(memberUuid, now));
    }

    // 오늘(KST 0시 이후) 답한 카드 수
    private int countTodayAnswered(UUID memberUuid, LocalDateTime now) {
        LocalDate today = now.toLocalDate();
        return (int) reviewRepository.countByMemberUuidAndLastAnsweredAtGreaterThanEqual(memberUuid, today.atStartOfDay());
    }

    private static OxCardItem toItem(OxCard card, Integer box) {
        return new OxCardItem(card.cardKey(), card.conceptUuid(), card.conceptTitle(), card.topicName(),
            card.statement(), card.isTrue(), card.reason(), box);
    }

    /** 복습 기록이 있는 카드 */
    private record DueCard(OxCard card, OxCardReview review) {
    }
}
