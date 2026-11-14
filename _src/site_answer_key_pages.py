# -*- coding: utf-8 -*-
"""SQLD 회차별 가답안·OMR 가채점 페이지 (#1075): 회차 페이지(sqld/63/) + 회차 목록(sqld/answers/) + 첫 화면 띠
회차 페이지 흐름: 히어로 > OMR 입력 > 결과·공유 > 가답안 표 > 앱 안내 > 면책 > FAQ
HTML 틀은 여기 한 곳, 값 채우기·채점·공유 카드는 exam-answer.js (규칙·문구는 페이지에 넣은 JSON 설정에서 읽음)
"""

import datetime
import json

import site_answer_key_content as answer_content
import site_content as content
from site_head import escape, render_play_link_attribute, render_symbol
from site_page_frame import calculate_root, render_app_callout, render_guide_page
from site_schedule import format_long_date, format_short_date, to_date
from site_schema import build_exam_event_json_ld

# 페이지 전용 정적 자산 (build_site STATIC_ASSET_PATHS 에도 포함)
ANSWER_KEY_STYLESHEET_PATH = "exam-answer.css"
# 실행 순서대로 (defer): 채점 계산 > 가답안 표 > 공유 > 페이지 흐름(앞 셋을 조립)
ANSWER_KEY_SCRIPT_PATHS = ["exam-answer-grading.js", "exam-answer-table.js", "exam-answer-share.js", "exam-answer.js"]
# 보기 번호 > 원문자 (OMR·정답 표시)
CHOICE_SYMBOLS = {"1": "①", "2": "②", "3": "③", "4": "④"}


# ── 회차 등록 ──
def is_round_live(answer_round, today=None):
    """시험일 ~ 합격자 발표일 사이면 진행 중 (상단 메뉴 강조·첫 화면 띠)"""
    today = today or datetime.date.today()
    exam_round = answer_content.find_exam_round(answer_round["round"])
    return to_date(exam_round["exam"]) <= today <= to_date(exam_round["result"])


def find_live_round(today=None):
    return next((answer_round for answer_round in answer_content.ANSWER_KEY_ROUNDS if is_round_live(answer_round, today)), None)


def register_answer_key_pages(today=None):
    """회차 페이지를 GUIDE_PAGES 에 등록 (빵부스러기·sitemap·관련 안내·하단 링크 공용)
    진행 중 회차: 상단 메뉴의 '가답안·가채점' 자리를 그 회차로 바꾸고 강조
    """
    for answer_round in answer_content.ANSWER_KEY_ROUNDS:
        content.GUIDE_PAGES[answer_content.to_round_path(answer_round)] = answer_content.build_round_guide_page(answer_round)
    live_round = find_live_round(today)
    if live_round:
        live_path = answer_content.to_round_path(live_round)
        menu_index = content.GUIDE_MENU_PATHS.index(answer_content.ANSWER_KEY_INDEX_PATH)
        content.GUIDE_MENU_PATHS[menu_index] = live_path
        content.NAV_LIVE_PATHS.add(live_path)


# ── 첫 화면 띠 ──
def render_home_answer_banner(today=None):
    """첫 화면 맨 위 진행 중 가채점 띠 (진행 중 회차가 없으면 빈 문자열, '오늘 시험 끝!'은 방문 날짜가 시험일일 때만 site.js 가 표시)"""
    today = today or datetime.date.today()
    live_round = find_live_round(today)
    if not live_round:
        return ""
    exam_round = answer_content.find_exam_round(live_round["round"])
    return f"""
<a class="live-banner" href="{answer_content.to_round_path(live_round)}">
  <span class="live-dot" aria-hidden="true"></span>
  <span class="live-banner-text"><strong><span data-exam-day-only="{exam_round['exam']}" hidden>오늘 시험 끝! </span>SQLD {live_round['round']}회 가채점</strong><span>가답안 보고 OMR로 내 점수·합격 확인</span></span>
  <span class="live-banner-go">가채점하기{render_symbol("arrow_forward")}</span>
</a>"""


# ── 회차 페이지 조각 ──
def render_round_hero_extra(answer_round, exam_round, rule):
    """히어로 아래: 회차·집계 상태 > 숫자 카드 3개(사이트 fact-card) > 시작 버튼 > 연결 상태"""
    facts = [
        ("groups", "가채점 참여", '<span data-participant-count>0</span>명'),
        ("fact_check", "정답 모인 문항", f'<span data-decided-count>0</span> / {rule["questionCount"]}'),
        ("update", "마지막 갱신", '<span data-updated-at>집계 대기</span>'),
    ]
    fact_cards = "".join(
        f"""
      <li class="fact-card"><span class="fact-icon">{render_symbol(icon_name)}</span><span class="fact-label">{escape(label)}</span><strong>{value_html}</strong></li>"""
        for icon_name, label, value_html in facts
    )
    return f"""
    <p class="ak-hero-meta"><span class="ak-chip">{render_symbol("event")}제{answer_round['round']}회 · {escape(format_short_date(exam_round['exam']))} 시행</span>
      <span class="ak-chip ak-chip-live" data-round-status>{render_symbol("campaign")}실시간 집계 중</span></p>
    <div class="cta ak-hero-cta">
      <a class="btn btn-primary" href="#omr">{render_symbol("edit_note")}OMR로 가채점 시작</a>
      <a class="btn btn-ghost" href="#answer-key">{render_symbol("fact_check")}가답안 먼저 보기</a>
    </div>
    <ul class="fact-grid ak-hero-facts">{fact_cards}
    </ul>
    <p class="ak-connection" data-connection-status>{render_symbol("info")}빌드 때 받은 가답안을 보여 주고 있어요. 서버에 연결되면 1분마다 새로 집계해요.</p>"""


def render_omr_subject(subject):
    """OMR 과목 1개 (접기): 과목명·입력 수 > 문항 줄 (번호 + 보기 4개 버튼, 다시 누르면 모름)"""
    rows = "".join(
        f"""
          <div class="omr-row" data-omr-row="{question_number}">
            <span class="omr-no">{question_number}</span>
            <div class="omr-choices" role="group" aria-label="{question_number}번 답">{"".join(
              f'<button type="button" class="omr-bubble" data-choice="{choice}" aria-pressed="false" aria-label="{question_number}번 {choice}번">{choice}</button>'
              for choice in range(1, answer_content.CHOICE_COUNT + 1))}</div>
          </div>"""
        for question_number in range(subject["firstQuestionNo"], subject["lastQuestionNo"] + 1)
    )
    question_count = subject["lastQuestionNo"] - subject["firstQuestionNo"] + 1
    return f"""
      <details class="omr-subject" data-omr-subject="{subject['subjectNo']}" open>
        <summary>
          <span class="omr-subject-title"><strong>{escape(subject['name'])}</strong><small>{subject['firstQuestionNo']}~{subject['lastQuestionNo']}번 · {subject['maxScore']}점</small></span>
          <span class="omr-subject-count"><b data-omr-subject-filled>0</b> / {question_count}</span>
          {render_symbol("expand_more", "omr-subject-chevron")}
        </summary>
        <div class="omr-grid">{rows}
        </div>
      </details>"""


def render_omr_section(rule):
    subjects = "".join(render_omr_subject(subject) for subject in rule["subjects"])
    return f"""
<section id="omr" class="section-tight ak-omr-section">
  <div class="wrap">
    <p class="kicker">STEP 1 · OMR 입력</p>
    <h2>기억나는 답을 찍어 보세요</h2>
    <p class="sec-lead">모르는 문항은 비워 두면 돼요. 같은 번호를 다시 누르면 지워지고, 입력하는 대로 이 브라우저에 자동 저장돼요.</p>
    <div class="omr-quick">
      <label for="omr-quick-input">{render_symbol("keyboard")}숫자로 한 번에 입력</label>
      <input id="omr-quick-input" class="omr-quick-input" type="text" inputmode="numeric" autocomplete="off" spellcheck="false"
        maxlength="{rule['questionCount']}" placeholder="1번부터 차례로, 모르면 0 (예: 2314)" data-omr-quick>
      <p class="omr-hint">PC에서는 OMR 칸을 누른 뒤 숫자 키 1~4로 입력하면 다음 문항으로 넘어가요.</p>
    </div>
    <div class="omr-sheet">
    <div class="omr-panel" data-omr tabindex="-1">{subjects}
    </div>
    <div class="omr-bar" data-omr-bar>
      <div class="omr-progress">
        <p><strong data-omr-filled>0</strong> / {rule['questionCount']} 입력 <span data-omr-saved></span></p>
        <div class="omr-progress-track"><span data-omr-progress></span></div>
      </div>
      <button type="button" class="btn btn-ghost btn-small omr-reset" data-omr-reset aria-label="입력 초기화">{render_symbol("restart_alt")}<span>초기화</span></button>
      <button type="button" class="btn btn-primary btn-small" data-omr-submit>{render_symbol("fact_check")}채점하기</button>
    </div>
    </div>
  </div>
</section>"""


def render_subject_score_rows(rule):
    """결과 카드 과목 막대 틀 (과락선 위치는 생성 시 계산, 점수는 JS)"""
    return "".join(
        f"""
          <div class="score-subject" data-score-subject="{subject['subjectNo']}">
            <div class="score-subject-head"><strong>{escape(subject['name'])}</strong><span><b data-subject-score>-</b> / {subject['maxScore']}점</span></div>
            <div class="score-track">
              <span class="score-fill" data-subject-fill></span>
              <span class="score-cut" style="left:{subject['failUnderScore'] * 100 / subject['maxScore']:.0f}%"><small>과락 {subject['failUnderScore']}점</small></span>
            </div>
            <p class="score-subject-note" data-subject-note></p>
          </div>"""
        for subject in rule["subjects"]
    )


def render_result_section(answer_round, rule):
    """결과 카드 > 문항별 O/X 줄 > 공유 (채점 전에는 안내 문구, 값은 JS)"""
    return f"""
<section id="result" class="section-tight band ak-result-section">
  <div class="wrap">
    <p class="kicker">STEP 2 · 가채점 결과</p>
    <h2>내 예상 점수</h2>
    <div class="score-card" data-score-card data-state="empty">
      <div class="score-empty" data-score-empty>
        <span class="feature-icon">{render_symbol("edit_note")}</span>
        <p><strong>아직 채점 전이에요</strong>OMR에 답을 찍고 채점하기를 누르면 과목별 점수와 합격 여부가 여기에 나와요.</p>
        <a class="btn btn-ghost btn-small" href="#omr">{render_symbol("edit_note")}OMR 입력하러 가기</a>
      </div>
      <div class="score-body">
      <div class="score-main">
        <div class="score-total">
          <p class="score-label">SQLD {answer_round['round']}회 가채점</p>
          <p class="score-number"><strong data-total-score>-</strong><span>/ 100점</span></p>
          <p class="score-verdict" data-verdict>-</p>
        </div>
        <ul class="score-facts">
          <li><span>점수 범위</span><strong data-score-range>-</strong><small data-score-range-note></small></li>
          <li><span>참여자 중</span><strong data-percentile>-</strong><small data-percentile-note>채점하기를 누르면 계산해요</small></li>
          <li><span>맞힌 문항</span><strong data-correct-count>-</strong><small data-pending-note></small></li>
        </ul>
      </div>
      <div class="score-subjects">{render_subject_score_rows(rule)}
      </div>
      <div class="score-marks" data-score-marks aria-label="문항별 채점 결과"></div>
      <p class="score-basis">합격: 총점 {rule['passScore']}점 이상 + 과목별 40% 이상. 가답안 기준 예상 점수이며 공식 점수가 아니에요.</p>
      </div>
    </div>
    {render_share_panel()}
  </div>
</section>"""


def render_share_panel():
    """공유: 점수 공개 선택 > 결과 이미지 미리보기 > 이미지·링크·카카오톡·X"""
    return f"""
    <div class="share-panel" data-share-panel>
      <div class="share-copy">
        <h3>{render_symbol("share")}친구와 같이 맞춰 보기</h3>
        <p>결과를 이미지 카드로 만들어 공유해요. 점수는 원할 때만 넣어요.</p>
        <label class="share-toggle"><input type="checkbox" data-share-score-public> 이미지와 문구에 내 점수 넣기</label>
        <div class="share-buttons">
          <button type="button" class="btn btn-primary btn-small" data-share-image>{render_symbol("image")}이미지로 공유</button>
          <button type="button" class="btn btn-ghost btn-small" data-share-copy>{render_symbol("content_copy")}링크 복사</button>
          <button type="button" class="btn btn-small share-kakao" data-share-kakao>카카오톡</button>
          <button type="button" class="btn btn-small share-x" data-share-x>X에 올리기</button>
        </div>
        <p class="share-toast" data-share-toast role="status" aria-live="polite"></p>
      </div>
      <figure class="share-preview">
        <canvas class="share-canvas" width="1080" height="1350" data-share-canvas aria-label="가채점 결과 공유 이미지 미리보기"></canvas>
      </figure>
    </div>"""


def render_tally_rows(item):
    """보기 분포 4줄 (득표 수·비율 막대) — 스냅샷 값으로 채우고 JS 가 갱신"""
    tally = item.get("tally") or {}
    vote_count = item.get("voteCount") or 0
    rows = []
    for choice in range(1, answer_content.CHOICE_COUNT + 1):
        count = int(tally.get(str(choice), 0) or 0)
        percent = round(count * 100 / vote_count) if vote_count else 0
        rows.append(
            f'<li data-tally-choice="{choice}"><span class="tally-choice">{CHOICE_SYMBOLS[str(choice)]}</span>'
            f'<span class="tally-track"><span class="tally-fill" style="width:{percent}%"></span></span>'
            f'<span class="tally-value"><b data-tally-count>{count}</b>명 · <span data-tally-percent>{percent}</span>%</span></li>'
        )
    return "".join(rows)


def render_answer_row(item):
    """가답안 1행 (접기): 번호 > 정답 > 상태 > 합의율 > 개념 한 줄 > 내 채점 / 펼치면 보기 분포·메모·앱 연결"""
    question_number = item["questionNo"]
    status = item.get("answerStatus") or "UNKNOWN"
    answer = str(item["answer"]) if item.get("answer") else ""
    status_label = answer_content.ANSWER_STATUS_LABELS.get(status, answer_content.ANSWER_STATUS_LABELS["UNKNOWN"])[0]
    agreement_percent = round((item.get("agreementRate") or 0) * 100)
    concept_title = item.get("conceptTitle") or "출제 개념 정리 중"
    note_html = escape(item.get("note") or "")
    return f"""
      <details class="ak-row" data-question-no="{question_number}" data-status="{escape(status)}">
        <summary>
          <span class="ak-no">{question_number}</span>
          <span class="ak-answer" data-answer>{CHOICE_SYMBOLS.get(answer, "?")}</span>
          <span class="ak-main">
            <span class="ak-concept" data-concept>{escape(concept_title)}</span>
            <span class="ak-meta"><span class="ak-status" data-status-label>{escape(status_label)}</span>
              <span class="ak-agree"><span class="ak-agree-track"><span class="ak-agree-fill" data-agree-fill style="width:{agreement_percent}%"></span></span><span data-agree-text>합의 {agreement_percent}%</span></span></span>
          </span>
          <span class="ak-mine" data-mine aria-label="내 답"></span>
          {render_symbol("expand_more", "ak-chevron")}
        </summary>
        <div class="ak-detail">
          <p class="ak-detail-head">보기별 선택 <small data-vote-count>{item.get("voteCount") or 0}명 응답</small></p>
          <ul class="tally">{render_tally_rows(item)}</ul>
          <p class="ak-note" data-note>{note_html}</p>
          <a class="ak-app-link" href="{content.APP_STORE_URL}" rel="noopener"{render_play_link_attribute()}>{render_symbol("school")}앱에서 이 개념 풀기</a>
        </div>
      </details>"""


def render_answer_key_section(rule, snapshot):
    """가답안 표: 상태 범례 > 필터 > 과목별 행"""
    item_by_number = {item["questionNo"]: item for item in snapshot["items"]}
    legend = "".join(
        f'<li data-status="{status}"><span class="ak-status">{escape(label)}</span>{escape(text)}</li>'
        for status, (label, text) in answer_content.ANSWER_STATUS_LABELS.items()
    )
    groups = "".join(
        f"""
    <h3 class="ak-group-title">{escape(subject['name'])}<small>{subject['firstQuestionNo']}~{subject['lastQuestionNo']}번</small></h3>
    <div class="ak-list">{"".join(render_answer_row(item_by_number[number]) for number in range(subject['firstQuestionNo'], subject['lastQuestionNo'] + 1))}
    </div>"""
        for subject in rule["subjects"]
    )
    return f"""
<section id="answer-key" class="section-tight ak-key-section">
  <div class="wrap">
    <p class="kicker">STEP 3 · 문항별 가답안</p>
    <h2>문항별 가답안과 합의율</h2>
    <p class="sec-lead">보기마다 몇 명이 골랐는지와 합의율로 보여 줘요. 문항을 누르면 보기 분포와 출제 개념이 펼쳐져요.</p>
    <ul class="ak-legend">{legend}</ul>
    <div class="ak-filters" role="group" aria-label="가답안 거르기">
      <button type="button" class="ak-filter" data-ak-filter="all" aria-pressed="true">전체</button>
      <button type="button" class="ak-filter" data-ak-filter="uncertain" aria-pressed="false">갈림·집계 중</button>
      <button type="button" class="ak-filter" data-ak-filter="wrong" aria-pressed="false">내가 틀린 문항</button>
    </div>{groups}
  </div>
</section>"""


def render_disclaimer_section():
    lines = "".join(f"<li>{escape(line)}</li>" for line in answer_content.DISCLAIMER_LINES)
    return f"""
<section class="section-tight band ak-disclaimer">
  <div class="wrap">
    <h2>꼭 확인해 주세요</h2>
    <ul class="ak-disclaimer-list">{lines}</ul>
    <p class="ak-takedown">{render_symbol("mail")}{escape(answer_content.TAKEDOWN_NOTE)} <a href="mailto:{content.CONTACT_EMAIL}">{content.CONTACT_EMAIL}</a></p>
    <p class="official-note">{render_symbol("open_in_new")}공식 점수·합격 발표 <a href="{content.OFFICIAL_EXAM_URL}" rel="noopener">데이터자격검정 바로가기</a></p>
  </div>
</section>"""


def to_inline_json(value):
    """<script type="application/json"> 안에 넣을 JSON (</script> 끊김 방지)"""
    return json.dumps(value, ensure_ascii=False, separators=(",", ":")).replace("</", "<\\/")


def build_page_config(answer_round, exam_round, rule, path):
    """exam-answer.js 설정: 회차·API·채점 규칙·문구 (브라우저 채점과 화면 문구가 같은 원본을 씀)"""
    return {
        "certType": answer_round["cert_type"],
        "roundNumber": answer_round["round"],
        "examDate": exam_round["exam"],
        "scorePreviewStartDate": exam_round["score_preview_start"],
        "resultDate": exam_round["result"],
        "apiBaseUrl": content.API_BASE_URL + answer_content.ANSWER_KEY_API_PATH,
        "pageUrl": content.SITE_URL + path,
        "siteHost": content.SITE_URL.split("//", 1)[1].rstrip("/"),
        "markImageUrl": calculate_root(path) + "icon/mark.png",
        "storageKeyPrefix": answer_content.STORAGE_KEY_PREFIX,
        "liveRefreshSeconds": answer_content.LIVE_REFRESH_SECONDS,
        "rules": rule,
        "statusLabels": {status: label for status, (label, _) in answer_content.ANSWER_STATUS_LABELS.items()},
        "verdictLabels": answer_content.VERDICT_LABELS,
        "choiceSymbols": CHOICE_SYMBOLS,
    }


def render_answer_round_page(answer_round, snapshot):
    """회차 페이지 1장 (sqld/63/): 히어로 > OMR > 결과·공유 > 가답안 > 앱 안내 > 면책 > FAQ"""
    path = answer_content.to_round_path(answer_round)
    root = calculate_root(path)
    exam_round = answer_content.find_exam_round(answer_round["round"])
    rule = answer_content.build_scoring_rule()
    round_number = answer_round["round"]
    config_json = to_inline_json(build_page_config(answer_round, exam_round, rule, path))
    snapshot_json = to_inline_json(snapshot)
    body = (
        render_omr_section(rule)
        + render_result_section(answer_round, rule)
        + render_answer_key_section(rule, snapshot)
        + render_app_callout(root, "헷갈린 개념, 다음 시험 전에 잡아요",
                             "가답안에서 갈린 개념을 passQL 앱에서 비슷한 문제로 풀고, 보기 SQL을 직접 실행해 결과로 확인하세요.",
                             [("terminal", "보기 SQL 직접 실행"), ("auto_awesome", "틀린 이유 AI 해설"), ("timer", "실전 모의고사")])
        + render_disclaimer_section()
        + f"""
<script type="application/json" id="answer-key-config">{config_json}</script>
<script type="application/json" id="answer-key-snapshot">{snapshot_json}</script>"""
    )
    lead = (f"OMR에 기억나는 답을 찍으면 과목별 점수·과락·합격 여부가 바로 나와요. "
            f"사전점수 공개 {format_short_date(exam_round['score_preview_start'])}, 합격자 발표 {format_short_date(exam_round['result'])}.")
    return render_guide_page(
        path, f'SQLD {round_number}회 <span class="hl">가답안·가채점</span>', lead, body,
        faqs=answer_content.build_round_faqs(answer_round), faq_heading=f"SQLD {round_number}회 가채점 자주 묻는 질문",
        extra_json_ld=[build_exam_event_json_ld(exam_round)],
        hero_extra_html=render_round_hero_extra(answer_round, exam_round, rule),
        extra_stylesheet_paths=[ANSWER_KEY_STYLESHEET_PATH], extra_script_paths=ANSWER_KEY_SCRIPT_PATHS,
    )


# ── 회차 목록 ──
def render_answer_index_page(today=None):
    """회차 목록 (sqld/answers/): 회차 카드 > 이용 순서 > FAQ"""
    path = answer_content.ANSWER_KEY_INDEX_PATH
    root = calculate_root(path)
    cards = []
    for answer_round in answer_content.ANSWER_KEY_ROUNDS:
        exam_round = answer_content.find_exam_round(answer_round["round"])
        is_live = is_round_live(answer_round, today)
        badge = (f'<span class="ak-live-pill">{render_symbol("campaign")}진행 중</span>' if is_live
                 else '<span class="ak-past-pill">지난 회차</span>')
        cards.append(f"""
      <a class="ak-round-card{' is-live' if is_live else ''}" href="{root}{answer_content.to_round_path(answer_round)}">
        <span class="ak-round-card-head"><strong>SQLD 제{answer_round['round']}회</strong>{badge}</span>
        <span class="ak-round-card-date">{escape(format_long_date(exam_round['exam']))} 시행</span>
        <span class="ak-round-card-steps">사전점수 {escape(format_short_date(exam_round['score_preview_start']))} · 합격 발표 {escape(format_short_date(exam_round['result']))}</span>
        <span class="ak-round-card-go">가답안 보고 가채점하기{render_symbol("arrow_forward")}</span>
      </a>""")
    steps = [
        ("edit_note", "OMR에 답 찍기", "기억나는 답을 1~4로 찍어요. 모르면 비워 두고, 숫자로 한 번에 입력해도 돼요."),
        ("fact_check", "가답안으로 채점", "문항별 가답안으로 과목별 점수·과락·합격 여부와 점수 범위를 계산해요."),
        ("groups", "참여할수록 정확하게", "제출한 답안이 모여 문항별 보기 분포와 합의율이 1분마다 갱신돼요."),
    ]
    step_cards = "".join(
        f"""
      <article class="principle">
        <span class="feature-icon">{render_symbol(icon_name)}</span>
        <h3>{escape(title)}</h3>
        <p>{escape(text)}</p>
      </article>"""
        for icon_name, title, text in steps
    )
    body = f"""
<section class="section-tight">
  <div class="wrap">
    <h2>회차별 가답안</h2>
    <div class="ak-round-grid">{"".join(cards)}
    </div>
  </div>
</section>
<section class="section-tight band">
  <div class="wrap">
    <h2>이렇게 가채점해요</h2>
    <div class="principle-grid ak-step-grid">{step_cards}
    </div>
  </div>
</section>""" + render_disclaimer_section()
    return render_guide_page(
        path, 'SQLD <span class="hl">가답안·가채점</span>',
        "시험이 끝나면 회차별 가답안을 문항 득표와 합의율로 모으고, OMR에 내 답을 찍어 점수와 합격 여부를 바로 확인해요.",
        body, faqs=answer_content.ANSWER_INDEX_FAQS, extra_stylesheet_paths=[ANSWER_KEY_STYLESHEET_PATH],
    )
