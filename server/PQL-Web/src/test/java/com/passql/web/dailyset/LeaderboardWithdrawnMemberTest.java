package com.passql.web.dailyset;

import com.passql.application.service.DailySetService;
import com.passql.member.constant.MemberStatus;
import com.passql.member.entity.Member;
import com.passql.member.repository.MemberRepository;
import com.passql.question.dto.LeaderboardResponse;
import com.passql.question.entity.DailySetSubmission;
import com.passql.question.repository.DailyChallengeRepository;
import com.passql.question.repository.DailySetSubmissionRepository;
import com.passql.submission.repository.SubmissionRepository;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

/** 탈퇴한 회원의 기록은 오늘의 순위에 보이지 않아야 한다 (#377). */
class LeaderboardWithdrawnMemberTest {

    private final DailySetSubmissionRepository dailySetRepo = mock(DailySetSubmissionRepository.class);
    private final MemberRepository memberRepo = mock(MemberRepository.class);
    private final DailySetService service = new DailySetService(
            dailySetRepo, memberRepo, mock(SubmissionRepository.class), mock(DailyChallengeRepository.class));

    private DailySetSubmission record(UUID member, int correct) {
        DailySetSubmission s = mock(DailySetSubmission.class);
        when(s.getMemberUuid()).thenReturn(member);
        when(s.getCorrectCount()).thenReturn(correct);
        return s;
    }

    private Member member(UUID uuid, String nickname, MemberStatus status) {
        Member m = mock(Member.class);
        when(m.getMemberUuid()).thenReturn(uuid);
        when(m.getNickname()).thenReturn(nickname);
        when(m.getStatus()).thenReturn(status);
        return m;
    }

    @Test
    void 탈퇴한_회원은_순위에서_빠지고_나머지_순위가_당겨진다() {
        UUID withdrawn = UUID.randomUUID();
        UUID me = UUID.randomUUID();
        // 목은 스터빙 문장 밖에서 미리 만든다
        List<DailySetSubmission> board = List.of(record(withdrawn, 2), record(me, 2));
        List<Member> members = List.of(
                member(withdrawn, "탈퇴회원_1234abcd", MemberStatus.WITHDRAWN),
                member(me, "당당한다이아몬드", MemberStatus.ACTIVE));
        when(dailySetRepo.findByChallengeDateOrderByScore(any())).thenReturn(board);
        when(memberRepo.findAllById(any())).thenReturn(members);

        LeaderboardResponse res = service.getLeaderboard(me);

        assertEquals(1, res.entries().size());
        assertEquals("당당한다이아몬드", res.entries().get(0).nickname());
        assertEquals(1, res.myEntry().rank());
    }
}
