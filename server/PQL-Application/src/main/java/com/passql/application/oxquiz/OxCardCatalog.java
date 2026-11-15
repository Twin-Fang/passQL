package com.passql.application.oxquiz;

import com.passql.application.concept.ConceptAvailabilityPolicy;
import com.passql.application.concept.ConceptCatalog;
import com.passql.application.concept.ConceptCatalogLoader;
import com.passql.application.entitlement.FeatureAccessPolicy;
import com.passql.common.util.Sha256Hex;
import com.passql.meta.entity.ConceptDoc;
import com.passql.meta.entity.ConceptTag;
import com.passql.meta.entity.Topic;
import com.passql.meta.repository.ConceptDocRepository;
import com.passql.meta.service.concept.ConceptQuickCheckExtractor;
import com.passql.meta.service.concept.ConceptQuickCheckExtractor.ConceptQuickCheck;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * OX 카드 원천 (#1083): 개념 자세히 본문의 바로 확인 표 > 회원이 열 수 있는 카드 (단원 순서 > 개념 순서 > 표 순서)
 * 노출 규칙은 개념 학습과 같음: 이용 가능(공개·미리보기) > 초안 숨김 > 무료 단원(FeatureAccessPolicy)
 */
@Component
@RequiredArgsConstructor
public class OxCardCatalog {

    // 카드 키 문장 해시 길이 (SHA-256 hex 앞부분)
    private static final int STATEMENT_HASH_LENGTH = 16;
    // 카드 키 구분자: "{개념 uuid}:{문장 해시}"
    private static final String CARD_KEY_DELIMITER = ":";

    private final ConceptAvailabilityPolicy availabilityPolicy;
    private final ConceptCatalogLoader catalogLoader;
    private final ConceptDocRepository conceptDocRepository;
    private final FeatureAccessPolicy featureAccessPolicy;

    /** 카드 1장 (원천 그대로) */
    public record OxCard(String cardKey, UUID conceptUuid, String conceptTitle, String topicName, String statement,
                         boolean isTrue, String reason) {
    }

    /** 열 수 있는 카드 + 잠긴 단원 존재 여부 */
    public record AccessibleOxCards(List<OxCard> cards, boolean hasLockedTopics) {
    }

    public AccessibleOxCards loadAccessibleCards(UUID memberUuid) {
        if (!availabilityPolicy.isAvailableFor(memberUuid)) {
            return new AccessibleOxCards(List.of(), false);
        }

        // 열린 단원의 개념 (잠긴 단원은 표시만)
        ConceptCatalog catalog = catalogLoader.load(memberUuid);
        List<OpenConcept> openConcepts = new ArrayList<>();
        boolean hasLockedTopics = false;
        for (int orderIndex = 0; orderIndex < catalog.topics().size(); orderIndex++) {
            Topic topic = catalog.topics().get(orderIndex);
            List<ConceptTag> concepts = catalog.conceptsOf(topic.getTopicUuid());
            if (concepts.isEmpty()) {
                continue;
            }
            if (!featureAccessPolicy.canOpenConceptTopic(memberUuid, orderIndex)) {
                hasLockedTopics = true;
                continue;
            }
            concepts.forEach(concept -> openConcepts.add(new OpenConcept(concept, topic.getDisplayName())));
        }
        if (openConcepts.isEmpty()) {
            return new AccessibleOxCards(List.of(), hasLockedTopics);
        }

        // 개념 본문 > 바로 확인 카드 (같은 개념 안 같은 문장은 1장)
        Map<UUID, ConceptDoc> docByConcept = conceptDocRepository.findByConceptTagUuidInAndIsActiveTrue(
                openConcepts.stream().map(openConcept -> openConcept.concept().getConceptTagUuid()).toList())
            .stream()
            .collect(Collectors.toMap(ConceptDoc::getConceptTagUuid, Function.identity(), (first, second) -> first));
        List<OxCard> cards = new ArrayList<>();
        Set<String> seenCardKeys = new HashSet<>();
        for (OpenConcept openConcept : openConcepts) {
            ConceptDoc doc = docByConcept.get(openConcept.concept().getConceptTagUuid());
            if (doc == null) {
                continue;
            }
            for (ConceptQuickCheck quickCheck : ConceptQuickCheckExtractor.extract(doc.getDetailMd())) {
                OxCard card = toCard(openConcept, quickCheck);
                if (seenCardKeys.add(card.cardKey())) {
                    cards.add(card);
                }
            }
        }
        return new AccessibleOxCards(cards, hasLockedTopics);
    }

    /** 카드 키: 개념 uuid + 문장 해시 (표 순서가 바뀌어도 같은 문장은 같은 카드, 문장을 고치면 새 카드) */
    static String toCardKey(UUID conceptUuid, String statement) {
        return conceptUuid + CARD_KEY_DELIMITER + Sha256Hex.of(statement).substring(0, STATEMENT_HASH_LENGTH);
    }

    private static OxCard toCard(OpenConcept openConcept, ConceptQuickCheck quickCheck) {
        ConceptTag concept = openConcept.concept();
        return new OxCard(toCardKey(concept.getConceptTagUuid(), quickCheck.statement()), concept.getConceptTagUuid(),
            concept.getLabelKo(), openConcept.topicName(), quickCheck.statement(), quickCheck.isTrue(),
            quickCheck.reason());
    }

    private record OpenConcept(ConceptTag concept, String topicName) {
    }
}
