package com.passql.question.event;

import java.util.List;
import java.util.UUID;

/**
 * 관리자 고정 세트 교체됨 (기존 고정 OK 세트 비활성 > 새 세트) > 옛 세트를 가리키는 회차 문항 재연결 (#1155)
 * 교체와 같은 트랜잭션 안에서 처리 (롤백 시 함께 롤백)
 */
public record CuratedChoiceSetReplacedEvent(
        UUID questionUuid,
        List<UUID> disabledChoiceSetUuids,
        UUID newChoiceSetUuid
) {}
