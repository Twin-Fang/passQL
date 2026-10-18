package com.passql.application.community;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.member.entity.Member;
import com.passql.member.entity.MemberBlock;
import com.passql.member.repository.MemberBlockRepository;
import com.passql.member.repository.MemberRepository;
import com.passql.question.dto.community.BlockedMemberResponse;
import com.passql.question.entity.CommunityPost;
import com.passql.question.repository.CommunityPostRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * 작성자 차단: 글 기준 차단(작성자 UUID 비노출), 내 차단 목록, 해제(blockUuid 기준)
 * 차단은 내 화면에서만 상대 글을 숨김
 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class MemberBlockService {

    private final MemberBlockRepository memberBlockRepository;
    private final MemberRepository memberRepository;
    private final CommunityPostRepository communityPostRepository;

    /** 글 작성자 차단: 글 조회 > 본인 금지 > 이미 차단이면 무시 > 저장 */
    @Transactional
    public void blockAuthorOfPost(UUID blockerMemberUuid, UUID postUuid) {
        CommunityPost post = communityPostRepository.findById(postUuid)
                .filter(CommunityPost::isVisible)
                .orElseThrow(() -> new CustomException(ErrorCode.COMMUNITY_POST_NOT_FOUND));
        UUID blockedMemberUuid = post.getAuthorMemberUuid();
        if (blockedMemberUuid.equals(blockerMemberUuid)) {
            throw new CustomException(ErrorCode.COMMUNITY_SELF_BLOCK_FORBIDDEN);
        }
        if (memberBlockRepository.existsByBlockerMemberUuidAndBlockedMemberUuid(blockerMemberUuid, blockedMemberUuid)) {
            return;
        }
        memberBlockRepository.save(MemberBlock.of(blockerMemberUuid, blockedMemberUuid));
        log.info("[community] member blocked : post={}", postUuid);
    }

    /** 내 차단 목록 (최근 차단순, 닉네임만) */
    public List<BlockedMemberResponse> getMyBlocks(UUID blockerMemberUuid) {
        List<MemberBlock> blocks = memberBlockRepository.findAllByBlockerMemberUuidOrderByCreatedAtDesc(blockerMemberUuid);
        Map<UUID, String> nicknameByMemberUuid = memberRepository
                .findAllById(blocks.stream().map(MemberBlock::getBlockedMemberUuid).toList()).stream()
                .collect(Collectors.toMap(Member::getMemberUuid, Member::getNickname));
        return blocks.stream().map(block -> new BlockedMemberResponse(
                block.getMemberBlockUuid(),
                nicknameByMemberUuid.getOrDefault(block.getBlockedMemberUuid(), "탈퇴회원"),
                block.getCreatedAt())).toList();
    }

    /** 차단 해제 (내 차단 행만) */
    @Transactional
    public void unblock(UUID blockerMemberUuid, UUID blockUuid) {
        MemberBlock block = memberBlockRepository.findByMemberBlockUuidAndBlockerMemberUuid(blockUuid, blockerMemberUuid)
                .orElseThrow(() -> new CustomException(ErrorCode.COMMUNITY_BLOCK_NOT_FOUND));
        memberBlockRepository.delete(block);
        log.info("[community] member unblocked : block={}", blockUuid);
    }
}
