package com.passql.application.community.feed;

import com.passql.question.constant.CommunityFeedSource;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

/**
 * 피드 후보 문제 선택 방식 (탭 1개 = 구현 1개, 새 방식은 구현 추가만으로 확장)
 */
public interface FeedStrategy {

    // 후보 최대 개수 (캐시 크기·메모리 보호)
    int MAX_CANDIDATES = 200;

    CommunityFeedSource source();

    /** 노출 순서대로 후보 문제 (차단 필터는 적용하지 않음, 글 목록에서 처리) */
    List<FeedCandidate> findCandidates(UUID viewerMemberUuid, LocalDateTime now);

    /** true 면 회원과 무관한 결과라 60초 캐시 가능 */
    boolean isSharedAcrossMembers();
}
