package com.passql.application.community;

import com.passql.application.community.feed.MySolvedFeedStrategy;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.member.entity.MemberBlock;
import com.passql.member.repository.MemberBlockRepository;
import com.passql.member.repository.MemberRepository;
import com.passql.question.constant.CommunityPostStatus;
import com.passql.question.dto.community.CommunityReportRequest;
import com.passql.question.entity.CommunityPost;
import com.passql.question.entity.QuestionDiscussionStats;
import com.passql.question.repository.CommunityPostLikeRepository;
import com.passql.question.repository.CommunityPostRepository;
import com.passql.question.repository.CommunityReportRepository;
import com.passql.question.repository.QuestionRepository;
import com.passql.submission.repository.SubmissionRepository;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

/**
 * 커뮤니티 핵심 규칙 (#525): 뜨는 점수·정렬, 풀이 전 접근 거절, 신고 3명 자동 숨김, 작성자 차단
 */
class CommunityRulesTest {

    private final UUID viewerUuid = UUID.randomUUID();
    private final UUID authorUuid = UUID.randomUUID();
    private final UUID questionUuid = UUID.randomUUID();
    private final UUID postUuid = UUID.randomUUID();

    private final CommunityPostRepository communityPostRepository = mock(CommunityPostRepository.class);
    private final CommunityReportRepository communityReportRepository = mock(CommunityReportRepository.class);
    private final SubmissionRepository submissionRepository = mock(SubmissionRepository.class);

    @Test
    void 뜨는_점수는_참여가_많을수록_높고_시간이_지날수록_낮다() {
        double fresh = CommunityHotScore.calculate(3, 4, 0);
        // (3*2+4) / 2^1.5
        assertThat(fresh).isEqualTo(10 / Math.pow(2, 1.5));
        assertThat(CommunityHotScore.calculate(5, 4, 0)).isGreaterThan(fresh);
        assertThat(CommunityHotScore.calculate(3, 4, 24)).isLessThan(fresh);
    }

    @Test
    void 내가_푼_문제_피드는_오답_문제를_먼저_그_안에서_최근_활동순으로_정렬한다() {
        UUID wrongOld = UUID.randomUUID();
        UUID wrongNew = UUID.randomUUID();
        UUID correctNewest = UUID.randomUUID();
        LocalDateTime now = LocalDateTime.of(2026, 10, 18, 12, 0);
        List<QuestionDiscussionStats> sorted = MySolvedFeedStrategy.sortWrongFirst(List.of(
                QuestionDiscussionStats.of(correctNewest, 1, 0, 0, now),
                QuestionDiscussionStats.of(wrongOld, 1, 0, 0, now.minusHours(5)),
                QuestionDiscussionStats.of(wrongNew, 1, 0, 0, now.minusHours(1))), Set.of(wrongOld, wrongNew));
        assertThat(sorted).extracting(QuestionDiscussionStats::getQuestionUuid)
                .containsExactly(wrongNew, wrongOld, correctNewest);
    }

    @Test
    void 풀지_않은_문제의_의견_목록은_400으로_거절하고_글을_조회하지_않는다() {
        when(submissionRepository.existsByMemberUuidAndQuestionUuid(viewerUuid, questionUuid)).thenReturn(false);
        QuestionRepository questionRepository = mock(QuestionRepository.class);
        com.passql.question.entity.Question question = mock(com.passql.question.entity.Question.class);
        when(question.getIsActive()).thenReturn(true);
        when(questionRepository.findById(questionUuid)).thenReturn(Optional.of(question));
        CommunityPostService postService = new CommunityPostService(communityPostRepository,
                mock(CommunityPostLikeRepository.class), questionRepository, mock(MemberRepository.class),
                new CommunitySolveService(submissionRepository, null, null), mock(CommunityContentPolicy.class),
                mock(CommunityWriteLimiter.class));

        assertThatThrownBy(() -> postService.getQuestionPosts(viewerUuid, questionUuid, null, null, null))
                .isInstanceOf(CustomException.class)
                .extracting(e -> ((CustomException) e).getErrorCode()).isEqualTo(ErrorCode.COMMUNITY_SOLVE_REQUIRED);
        verifyNoInteractions(communityPostRepository);
    }

    @Test
    void 서로_다른_회원_3명이_신고하면_자동_숨김_2명까지는_노출() {
        CommunityPost post = CommunityPost.createQuestionOpinion(questionUuid, authorUuid, "의견", null);
        when(communityPostRepository.findById(postUuid)).thenReturn(Optional.of(post));
        when(submissionRepository.existsByMemberUuidAndQuestionUuid(any(), any())).thenReturn(true);
        when(communityReportRepository.existsByTargetTypeAndTargetUuidAndReporterMemberUuid(any(), any(), any())).thenReturn(false);
        CommunityPostReactionService reactionService = new CommunityPostReactionService(communityPostRepository,
                mock(CommunityPostLikeRepository.class), communityReportRepository,
                new CommunitySolveService(submissionRepository, null, null));
        CommunityReportRequest request = new CommunityReportRequest("SPAM", null);

        when(communityReportRepository.countByTargetTypeAndTargetUuidAndStatus(any(), any(), any())).thenReturn(2L);
        reactionService.reportPost(viewerUuid, postUuid, request);
        assertThat(post.getStatus()).isEqualTo(CommunityPostStatus.VISIBLE);

        when(communityReportRepository.countByTargetTypeAndTargetUuidAndStatus(any(), any(), any())).thenReturn(3L);
        reactionService.reportPost(viewerUuid, postUuid, request);
        assertThat(post.getStatus()).isEqualTo(CommunityPostStatus.HIDDEN_AUTO);
        assertThat(post.getReportCount()).isEqualTo(3);
    }

    @Test
    void 글_기준_차단은_작성자를_저장하고_본인_글은_거절한다() {
        MemberBlockRepository memberBlockRepository = mock(MemberBlockRepository.class);
        MemberBlockService blockService = new MemberBlockService(memberBlockRepository, mock(MemberRepository.class), communityPostRepository);
        when(communityPostRepository.findById(postUuid))
                .thenReturn(Optional.of(CommunityPost.createQuestionOpinion(questionUuid, authorUuid, "의견", null)));

        blockService.blockAuthorOfPost(viewerUuid, postUuid);
        ArgumentCaptor<MemberBlock> saved = ArgumentCaptor.forClass(MemberBlock.class);
        verify(memberBlockRepository).save(saved.capture());
        assertThat(saved.getValue().getBlockerMemberUuid()).isEqualTo(viewerUuid);
        assertThat(saved.getValue().getBlockedMemberUuid()).isEqualTo(authorUuid);

        assertThatThrownBy(() -> blockService.blockAuthorOfPost(authorUuid, postUuid))
                .isInstanceOf(CustomException.class)
                .extracting(e -> ((CustomException) e).getErrorCode()).isEqualTo(ErrorCode.COMMUNITY_SELF_BLOCK_FORBIDDEN);
    }
}
