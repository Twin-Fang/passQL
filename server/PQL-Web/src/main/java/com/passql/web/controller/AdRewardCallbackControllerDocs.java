package com.passql.web.controller;

import com.passql.common.dto.Author;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import kr.suhsaechan.suhapilog.annotation.ApiLog;
import kr.suhsaechan.suhapilog.annotation.ApiLogs;

@Tag(name = "Ads", description = "AdMob 보상형 광고 서버 검증 콜백")
public interface AdRewardCallbackControllerDocs {

    @ApiLogs({
        @ApiLog(date = "2026.11.07", author = Author.SUHSAECHAN, issueNumber = 860, description = "AdMob 보상형 광고 서버 검증(SSV) 콜백 추가: 서명 확인 후 광고 보너스 기록"),
    })
    @Operation(
        summary = "AdMob 보상형 광고 서버 검증 콜백",
        description = """
            ## 인증(JWT): **없음** (Google 이 호출, 쿼리 서명으로 검증)

            AdMob 콘솔 광고 단위의 서버 측 확인 콜백 URL 로 등록한다.
            서명 대상 = 쿼리에서 `&signature=` 앞부분, 공개키 = https://www.gstatic.com/admob/reward/verifier-keys.json (`key_id`)

            ## 쿼리 (AdMob 규격)
            - `ad_unit`, `custom_data`(앱 보상 표식), `transaction_id`, `user_id`(회원 UUID), `timestamp`, `reward_amount`, `reward_item`, `signature`, `key_id`

            ## 처리
            - 서명 확인 > 허용 광고 단위(`ads.reward.ssv_ad_unit_ids`, 비면 확인 안 함) > 회원·거래 ID > 광고 보너스 1회 기록
            - 같은 `transaction_id`·같은 회원 `custom_data` 는 다시 기록하지 않음
            - 결제 꺼짐·프로 회원, 오늘 2회 소진, 회원 없음은 기록 없이 200

            ## 에러코드
            - **`ACCESS_DENIED`** (403): 서명 불일치·형식 오류
            - **`EXTERNAL_API_ERROR`** (502): 공개키 목록을 받을 수 없음
            """
    )
    void receiveRewardCallback(HttpServletRequest request);
}
