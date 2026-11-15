package com.passql.web.controller;

import com.passql.application.oxquiz.OxQuizService;
import com.passql.application.oxquiz.dto.OxAnswerRequest;
import com.passql.application.oxquiz.dto.OxAnswerResponse;
import com.passql.application.oxquiz.dto.OxCardSetResponse;
import com.passql.common.dto.Author;
import com.passql.member.auth.presentation.annotation.AuthMember;
import com.passql.member.auth.presentation.security.LoginMember;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import kr.suhsaechan.suhapilog.annotation.ApiLog;
import kr.suhsaechan.suhapilog.annotation.ApiLogs;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;

@Tag(name = "OX Quiz", description = "개념 바로 확인 OX 간격 반복")
public interface OxQuizControllerDocs {

    @ApiLogs({
        @ApiLog(date = "2026.11.16", author = Author.SUHSAECHAN, issueNumber = 1083, description = "OX 카드 묶음 API"),
    })
    @Operation(summary = "OX 카드 묶음", description = """
        ## 인증(JWT): **필요** | 무료는 개념 학습 무료 단원 카드만, 프로는 전부
        - 카드 원천: 개념 자세히 본문의 바로 확인 표 (개념 학습 비공개면 빈 목록)
        - 순서: 기한 지난 복습 카드(오래 밀린 순, 낮은 칸) > 처음 보는 카드(단원·개념 순서)
        - size (기본 10, 1~20 보정)
        ## 반환값 (OxCardSetResponse)
        - cards[]: cardKey, conceptUuid, conceptTitle, topicName, statement, isTrue, reason, box(처음이면 null)
        - dueCardCount, newCardCount, todayAnsweredCount, dailyGoalCount(20), hasLockedTopics
        """)
    ResponseEntity<OxCardSetResponse> getCardSet(
        @AuthMember LoginMember loginMember,
        @RequestParam(defaultValue = OxQuizService.DEFAULT_CARD_SET_SIZE) int size
    );

    @ApiLogs({
        @ApiLog(date = "2026.11.16", author = Author.SUHSAECHAN, issueNumber = 1083, description = "OX 답 기록 API (Leitner 5칸)"),
    })
    @Operation(summary = "OX 답 기록", description = """
        ## 인증(JWT): **필요**
        - 요청 OxAnswerRequest { cardKey, isCorrect } (채점은 앱)
        - 맞히면 칸 +1(최대 5), 틀리면 1칸. 칸별 다음 출제 간격 1, 2, 4, 7, 14일 (처음 푸는 카드는 1칸에서 시작)
        - 열 수 없는 카드(없음, 잠긴 단원) > 404 OX_CARD_NOT_FOUND
        ## 반환값 (OxAnswerResponse)
        - cardKey, box, nextReviewDate, correctStreak, todayAnsweredCount
        """)
    ResponseEntity<OxAnswerResponse> answer(
        @AuthMember LoginMember loginMember,
        @RequestBody OxAnswerRequest request
    );
}
