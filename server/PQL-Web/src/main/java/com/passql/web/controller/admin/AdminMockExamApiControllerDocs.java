package com.passql.web.controller.admin;

import com.passql.common.dto.Author;
import com.passql.submission.dto.mockexam.AdminMockExamAttemptRow;
import com.passql.submission.dto.mockexam.AdminMockExamComposeRequest;
import com.passql.submission.dto.mockexam.AdminMockExamComposeResult;
import com.passql.submission.dto.mockexam.AdminMockExamEligibleCount;
import com.passql.submission.dto.mockexam.AdminMockExamItemReplaceRequest;
import com.passql.submission.dto.mockexam.AdminMockExamItemStat;
import com.passql.submission.dto.mockexam.AdminMockExamPublishCheck;
import com.passql.submission.dto.mockexam.AdminMockExamRoundDetail;
import com.passql.submission.dto.mockexam.AdminMockExamRoundRow;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import kr.suhsaechan.suhapilog.annotation.ApiLog;
import kr.suhsaechan.suhapilog.annotation.ApiLogs;
import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;

import java.util.List;
import java.util.UUID;

@Tag(name = "Admin - MockExam", description = "관리자 SQLD 모의고사 회차 구성·공개·통계 (관리자 세션)")
public interface AdminMockExamApiControllerDocs {

    @ApiLogs({@ApiLog(date = "2026.11.07", author = Author.SUHSAECHAN, issueNumber = 866, description = "모의고사 회차 목록 API 추가")})
    @Operation(summary = "회차 목록", description = "번호 큰 순. 응시·채점 수, 평균 점수, 합격률, 공개 회차는 지금 기준 공개 검사 오류 수(점검 필요)")
    ResponseEntity<List<AdminMockExamRoundRow>> getRounds();

    @ApiLogs({@ApiLog(date = "2026.11.07", author = Author.SUHSAECHAN, issueNumber = 866, description = "모의고사 회차 자동 구성 API 추가")})
    @Operation(summary = "회차 자동 구성 (초안)", description = "토픽별 문항 수(생략 시 기본 비율, 합계 10/40) > 출제 가능 세트가 있는 문제에서 최근 3개 회차 겹침을 피해 난이도 섞어 고름. 모자라면 경고")
    ResponseEntity<AdminMockExamComposeResult> compose(AdminMockExamComposeRequest request);

    @ApiLogs({@ApiLog(date = "2026.11.07", author = Author.SUHSAECHAN, issueNumber = 866, description = "모의고사 회차 상세 API 추가")})
    @Operation(summary = "회차 상세", description = "50문항 표(토픽·난이도·지문 앞부분·세트 출처·지금 출제 가능 여부), 공개 검사, 응시 수")
    ResponseEntity<AdminMockExamRoundDetail> getRoundDetail(UUID roundUuid);

    @ApiLogs({@ApiLog(date = "2026.11.07", author = Author.SUHSAECHAN, issueNumber = 866, description = "모의고사 초안 문항 교체 API 추가")})
    @Operation(summary = "초안 문항 교체", description = "questionUuid 지정(출제 가능·회차에 없음) 또는 생략 시 같은 토픽에서 자동. 초안만")
    ResponseEntity<Void> replaceItem(UUID roundUuid, UUID itemUuid, AdminMockExamItemReplaceRequest request);

    @ApiLogs({@ApiLog(date = "2026.11.07", author = Author.SUHSAECHAN, issueNumber = 866, description = "모의고사 공개 검사 API 추가"),
        @ApiLog(date = "2026.11.07", author = Author.SUHSAECHAN, issueNumber = 905, description = "공개 검사 경고에 문항 형식 위반 추가")})
    @Operation(summary = "공개 검사", description = "오류: 50문항·10/40, 번호 1~50, 문제 중복, 문제 활성·세트 출제 가능. 경고: 보기 근거 없음, 문항 형식 위반(#905)")
    ResponseEntity<AdminMockExamPublishCheck> checkPublish(UUID roundUuid);

    @ApiLogs({@ApiLog(date = "2026.11.07", author = Author.SUHSAECHAN, issueNumber = 866, description = "모의고사 회차 공개 API 추가")})
    @Operation(summary = "공개", description = "공개 검사 통과 필수(실패 400 MOCK_EXAM_PUBLISH_CHECK_FAILED). 공개 뒤 문항 고정")
    ResponseEntity<Void> publish(UUID roundUuid);

    @ApiLogs({@ApiLog(date = "2026.11.07", author = Author.SUHSAECHAN, issueNumber = 866, description = "모의고사 회차 보관 API 추가")})
    @Operation(summary = "보관", description = "사용자 목록에서만 뺌. 응시 기록·결과 유지")
    ResponseEntity<Void> archive(UUID roundUuid);

    @ApiLogs({@ApiLog(date = "2026.11.07", author = Author.SUHSAECHAN, issueNumber = 866, description = "모의고사 초안 되돌리기 API 추가")})
    @Operation(summary = "초안으로 되돌리기", description = "응시 0건일 때만 (있으면 409 MOCK_EXAM_ROUND_NOT_EDITABLE)")
    ResponseEntity<Void> revertToDraft(UUID roundUuid);

    @ApiLogs({@ApiLog(date = "2026.11.07", author = Author.SUHSAECHAN, issueNumber = 866, description = "모의고사 초안 삭제 API 추가")})
    @Operation(summary = "초안 삭제", description = "초안 회차와 문항 삭제")
    ResponseEntity<Void> deleteDraft(UUID roundUuid);

    @ApiLogs({@ApiLog(date = "2026.11.07", author = Author.SUHSAECHAN, issueNumber = 866, description = "모의고사 문항 통계 API 추가")})
    @Operation(summary = "문항 통계", description = "채점된 응시 기준 정답률·보기별 선택률·안 고른 비율, 정답률 30% 미만·정답보다 많이 고른 오답 보기 표시, 미처리 신고 수")
    ResponseEntity<List<AdminMockExamItemStat>> getItemStats(UUID roundUuid);

    @ApiLogs({@ApiLog(date = "2026.11.07", author = Author.SUHSAECHAN, issueNumber = 866, description = "모의고사 응시 기록 API 추가")})
    @Operation(summary = "응시 기록", description = "회차·회원 필터(생략 시 전체), 시작 최신순")
    ResponseEntity<Page<AdminMockExamAttemptRow>> searchAttempts(UUID roundUuid, UUID memberUuid, int page, int size);

    @ApiLogs({@ApiLog(date = "2026.11.07", author = Author.SUHSAECHAN, issueNumber = 866, description = "모의고사 토픽별 출제 가능 문제 수 API 추가")})
    @Operation(summary = "토픽별 출제 가능 문제 수 (관리자 전용)", description = "출제 가능 세트가 있는 활성 문제 수와 기본 구성 문항 수. 사용자 노출 금지(#636)")
    ResponseEntity<List<AdminMockExamEligibleCount>> getEligibleCounts();
}
