// SQLD 회차 가답안·OMR 가채점 (#1075): 설정·스냅샷 읽기 > OMR 입력·자동 저장 > 채점(브라우저) > 서버 저장·상위 %
// > 가답안 갱신(1분마다, 표는 exam-answer-table.js) > 공유(exam-answer-share.js). 채점 계산은 exam-answer-grading.js
// 채점 규칙·문구는 페이지 JSON 설정(answer-key-config, 원본 _src/site_answer_key_content.py), 색은 style.css 토큰
(function () {
  "use strict";

  var config = readJsonScript("answer-key-config");
  if (!config) return;
  var rules = config.rules;
  var grader = window.PassqlExamAnswer.createGrader(rules);
  var toAnswerArray = grader.toAnswerArray;
  var normalizeAnswerKey = grader.normalizeAnswerKey;
  var isUncertainItem = grader.isUncertainItem;
  var questionCount = rules.questionCount;
  var unknownMark = rules.unknownAnswerMark;
  // API 요청 제한 시간 (6초)
  var API_TIMEOUT_MILLISECONDS = 6000;
  // 자동 저장 표시가 사라지기까지 (1.6초)
  var SAVED_NOTICE_MILLISECONDS = 1600;
  var isReducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;

  var roundKey = config.certType + "." + config.roundNumber;
  var storageKeys = {
    clientToken: config.storageKeyPrefix + "clientToken",
    answers: config.storageKeyPrefix + roundKey + ".answers",
    isScorePublic: config.storageKeyPrefix + roundKey + ".isScorePublic",
    isSubmitted: config.storageKeyPrefix + roundKey + ".isSubmitted"
  };
  var roundApiUrl = config.apiBaseUrl + encodeURIComponent(config.certType) + "/" + config.roundNumber;

  var state = {
    answers: loadAnswers(),
    answerKey: normalizeAnswerKey(readJsonScript("answer-key-snapshot")),
    isLive: false,
    cursorIndex: 0,
    gradeResult: null,
    percentile: null,
    activeFilter: "all"
  };

  // ── 공통 ──
  function readJsonScript(elementId) {
    var element = document.getElementById(elementId);
    if (!element) return null;
    try { return JSON.parse(element.textContent); } catch (error) { return null; }
  }

  function readStorage(key) {
    try { return window.localStorage.getItem(key); } catch (error) { return null; }
  }

  function writeStorage(key, value) {
    try { window.localStorage.setItem(key, value); } catch (error) { /* 사생활 보호 모드: 저장 없이 진행 */ }
  }

  /** 클라이언트 토큰 (기기·브라우저당 1개, 서버는 해시만 저장) */
  function getClientToken() {
    var token = readStorage(storageKeys.clientToken);
    if (token) return token;
    token = window.crypto && window.crypto.randomUUID ? window.crypto.randomUUID() : createFallbackUuid();
    writeStorage(storageKeys.clientToken, token);
    return token;
  }

  function createFallbackUuid() {
    return "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".replace(/[xy]/g, function (character) {
      var random = Math.random() * 16 | 0;
      return (character === "x" ? random : (random & 0x3) | 0x8).toString(16);
    });
  }

  /** fetch + 제한 시간 > JSON (실패는 reject) */
  function requestJson(url, options) {
    var controller = "AbortController" in window ? new AbortController() : null;
    var timer = controller ? window.setTimeout(function () { controller.abort(); }, API_TIMEOUT_MILLISECONDS) : null;
    var requestOptions = Object.assign({ headers: { Accept: "application/json" } }, options || {});
    if (controller) requestOptions.signal = controller.signal;
    return fetch(url, requestOptions).then(function (response) {
      if (timer) window.clearTimeout(timer);
      if (!response.ok) throw new Error("http " + response.status);
      return response.json();
    }, function (error) {
      if (timer) window.clearTimeout(timer);
      throw error;
    });
  }

  // ── 답안 ('0' 모름, '1'~'4') ──
  function loadAnswers() {
    var saved = readStorage(storageKeys.answers) || "";
    return toAnswerArray(saved);
  }

  function countFilledAnswers() {
    return state.answers.filter(function (answer) { return answer !== unknownMark; }).length;
  }

  /** 입력 1회: 상태 > 저장 > OMR·빠른 입력·진행 표시 > (채점한 적 있으면) 재채점 */
  function setAnswer(index, choice) {
    state.answers[index] = choice;
    writeStorage(storageKeys.answers, state.answers.join(""));
    renderOmrRow(index);
    renderOmrProgress(true);
    syncQuickInput();
    if (state.gradeResult) gradeAndRender();
  }

  function countDecidedItems() {
    return grader.countDecidedItems(state.answerKey);
  }

  function gradeAnswers(answers) {
    return grader.gradeAnswers(answers, state.answerKey);
  }

  // ── OMR ──
  var omrPanel = document.querySelector("[data-omr]");
  var omrRows = Array.prototype.slice.call(document.querySelectorAll("[data-omr-row]"));
  var quickInput = document.querySelector("[data-omr-quick]");
  var savedNoticeTimer = null;

  function renderOmrRow(index) {
    var row = omrRows[index];
    if (!row) return;
    var answer = state.answers[index];
    row.classList.toggle("is-filled", answer !== unknownMark);
    row.querySelectorAll("[data-choice]").forEach(function (bubble) {
      bubble.setAttribute("aria-pressed", String(bubble.getAttribute("data-choice") === answer));
    });
  }

  function renderOmrProgress(isSaved) {
    var filledCount = countFilledAnswers();
    setText("[data-omr-filled]", filledCount);
    // 과목 접기 머리줄 입력 수
    rules.subjects.forEach(function (subject) {
      var subjectFilledCount = state.answers.slice(subject.firstQuestionNo - 1, subject.lastQuestionNo)
        .filter(function (answer) { return answer !== unknownMark; }).length;
      setText('[data-omr-subject="' + subject.subjectNo + '"] [data-omr-subject-filled]', subjectFilledCount);
    });
    var progress = document.querySelector("[data-omr-progress]");
    if (progress) progress.style.width = (filledCount * 100 / questionCount) + "%";
    var savedElement = document.querySelector("[data-omr-saved]");
    if (!savedElement || !isSaved) return;
    savedElement.textContent = "자동 저장됨";
    window.clearTimeout(savedNoticeTimer);
    savedNoticeTimer = window.setTimeout(function () { savedElement.textContent = ""; }, SAVED_NOTICE_MILLISECONDS);
  }

  /** 빠른 입력칸 <- OMR (끝의 모름은 잘라 짧게) */
  function syncQuickInput() {
    if (!quickInput || document.activeElement === quickInput) return;
    quickInput.value = state.answers.join("").replace(new RegExp(unknownMark + "+$"), "");
  }

  function moveCursor(index, shouldFocus) {
    state.cursorIndex = Math.max(0, Math.min(questionCount - 1, index));
    omrRows.forEach(function (row, rowIndex) { row.classList.toggle("is-cursor", rowIndex === state.cursorIndex); });
    var row = omrRows[state.cursorIndex];
    if (!shouldFocus || !row) return;
    var target = row.querySelector('[aria-pressed="true"]') || row.querySelector("[data-choice]");
    target.focus({ preventScroll: true });
    row.scrollIntoView({ block: "nearest", behavior: isReducedMotion ? "auto" : "smooth" });
  }

  function bindOmr() {
    if (!omrPanel) return;
    // 보기 누르기 (같은 보기 다시 누르면 모름)
    omrPanel.addEventListener("click", function (event) {
      var bubble = event.target.closest("[data-choice]");
      if (!bubble) return;
      var index = Number(bubble.closest("[data-omr-row]").getAttribute("data-omr-row")) - 1;
      var choice = bubble.getAttribute("data-choice");
      setAnswer(index, state.answers[index] === choice ? unknownMark : choice);
      moveCursor(index, false);
    });
    // 키보드: 1~4 입력 후 다음 문항, 0·- 모름, Backspace 지우고 이전, 위·아래 문항 이동
    omrPanel.addEventListener("keydown", function (event) {
      if (event.metaKey || event.ctrlKey || event.altKey) return;
      var row = event.target.closest("[data-omr-row]");
      var index = row ? Number(row.getAttribute("data-omr-row")) - 1 : state.cursorIndex;
      var key = event.key;
      if (/^[1-9]$/.test(key) && Number(key) <= rules.choiceCount) {
        setAnswer(index, key);
        moveCursor(index + 1, true);
      } else if (key === "0" || key === "-") {
        setAnswer(index, unknownMark);
        moveCursor(index + 1, true);
      } else if (key === "Backspace") {
        setAnswer(index, unknownMark);
        moveCursor(index - 1, true);
      } else if (key === "ArrowDown" || key === "ArrowUp") {
        moveCursor(index + (key === "ArrowDown" ? 1 : -1), true);
      } else {
        return;
      }
      event.preventDefault();
    });
    omrPanel.addEventListener("focusin", function (event) {
      var row = event.target.closest("[data-omr-row]");
      if (row) moveCursor(Number(row.getAttribute("data-omr-row")) - 1, false);
    });
    // 빠른 입력: 숫자만 남겨 앞에서부터 채움 (공백·쉼표 허용)
    if (quickInput) {
      quickInput.addEventListener("input", function () {
        var digits = quickInput.value.replace(/[^0-9]/g, "").slice(0, questionCount);
        if (digits !== quickInput.value) quickInput.value = digits;
        var nextAnswers = toAnswerArray(digits);
        nextAnswers.forEach(function (answer, index) { state.answers[index] = answer; renderOmrRow(index); });
        writeStorage(storageKeys.answers, state.answers.join(""));
        renderOmrProgress(true);
        if (state.gradeResult) gradeAndRender();
      });
    }
    bindClick("[data-omr-reset]", function () {
      if (countFilledAnswers() > 0 && !window.confirm("입력한 답을 모두 지울까요?")) return;
      state.answers = toAnswerArray("");
      writeStorage(storageKeys.answers, "");
      omrRows.forEach(function (row, index) { renderOmrRow(index); });
      if (quickInput) quickInput.value = "";
      renderOmrProgress(false);
      state.gradeResult = null;
      renderResult();
      moveCursor(0, false);
    });
    bindClick("[data-omr-submit]", submitAnswers);
  }

  // ── 채점하기: 브라우저 채점·표시 > 서버 저장(성공 시 상위 %) ──
  function submitAnswers() {
    if (countFilledAnswers() === 0) {
      moveCursor(0, true);
      showToast("먼저 OMR에 답을 하나 이상 찍어 주세요.");
      return;
    }
    gradeAndRender();
    writeStorage(storageKeys.isSubmitted, "1");
    scrollToElement(document.getElementById("result"));
    saveSheetToServer();
  }

  function saveSheetToServer() {
    var body = JSON.stringify({ clientToken: getClientToken(), answers: state.answers.join(""), source: "WEB" });
    setText("[data-percentile-note]", "서버에 저장하는 중…");
    requestJson(roundApiUrl + "/sheets", { method: "POST", headers: { "Content-Type": "application/json", Accept: "application/json" }, body: body })
      .then(function (response) {
        state.percentile = readPercentile(response);
        renderPercentile();
        refreshAnswerKey();
      })
      .catch(function () {
        setText("[data-percentile-note]", "서버 연결 후 다시 채점하면 계산돼요");
      });
  }

  /** 채점 응답 > 상위 % (0~1 비율이면 백분율로) */
  function readPercentile(response) {
    var source = response && (response.result || response.gradeResult || response);
    var value = source ? Number(source.percentile) : NaN;
    if (!isFinite(value)) return null;
    return value > 0 && value < 1 ? value * 100 : value;
  }

  function gradeAndRender() {
    state.gradeResult = gradeAnswers(state.answers);
    renderResult();
    answerTable.renderMyMarks();
  }

  // ── 결과 카드 ──
  function renderResult() {
    var card = document.querySelector("[data-score-card]");
    if (!card) return;
    var result = state.gradeResult;
    if (!result) {
      card.setAttribute("data-state", "empty");
      card.removeAttribute("data-verdict-state");
      answerTable.renderMyMarks();
      share.draw();
      return;
    }
    card.setAttribute("data-state", "graded");
    card.setAttribute("data-verdict-state", result.passStatus);
    // 정답이 하나도 안 모였으면 점수 대신 '-' (0점·과락으로 오해 방지)
    var isPending = result.passStatus === "PENDING";
    if (isPending) setText("[data-total-score]", "-"); else animateNumber(card.querySelector("[data-total-score]"), result.totalScore);
    setText("[data-verdict]", config.verdictLabels[result.passStatus]);
    var hasRange = result.scoreRange.min !== result.scoreRange.max;
    setText("[data-score-range]", hasRange ? result.scoreRange.min + "~" + result.scoreRange.max + "점" : result.totalScore + "점 고정");
    setText("[data-score-range-note]", hasRange ? "갈림·집계 중 " + result.uncertainAnsweredCount + "문항을 틀림~맞음으로 가정" : "갈린 문항 없음");
    setText("[data-correct-count]", result.correctCount + " / " + result.decidedCount + "문항");
    setText("[data-pending-note]", result.decidedCount < questionCount ? (questionCount - result.decidedCount) + "문항은 정답 집계 중" : "모든 문항 정답 집계 완료");
    result.subjects.forEach(function (subjectResult) {
      var element = document.querySelector('[data-score-subject="' + subjectResult.subject.subjectNo + '"]');
      if (!element) return;
      element.classList.toggle("is-wrong", subjectResult.isFailCut && !isPending);
      element.querySelector("[data-subject-score]").textContent = isPending ? "-" : subjectResult.score;
      element.querySelector("[data-subject-fill]").style.width = (subjectResult.score * 100 / subjectResult.subject.maxScore) + "%";
      element.querySelector("[data-subject-note]").textContent = isPending ? "정답이 모이면 자동으로 계산돼요" : toSubjectNote(subjectResult);
    });
    renderScoreMarks(result);
    renderPercentile();
    share.draw();
  }

  function toSubjectNote(subjectResult) {
    var gapToCut = subjectResult.score - subjectResult.subject.failUnderScore;
    if (gapToCut < 0) return "과락선까지 " + (-gapToCut) + "점 모자라요";
    return "과락선보다 " + gapToCut + "점 여유" + (subjectResult.minScore !== subjectResult.maxScore ? " · 범위 " + subjectResult.minScore + "~" + subjectResult.maxScore + "점" : "");
  }

  function renderPercentile() {
    if (state.percentile == null) {
      setText("[data-percentile]", "-");
      if (state.gradeResult && !readStorage(storageKeys.isSubmitted)) setText("[data-percentile-note]", "채점하기를 누르면 계산해요");
      return;
    }
    setText("[data-percentile]", "상위 " + Math.max(1, Math.round(state.percentile)) + "%");
    setText("[data-percentile-note]", "참여자 " + state.answerKey.participantCount.toLocaleString("ko-KR") + "명 기준");
    share.draw();
  }

  /** 문항별 칸 50개: 맞음·틀림·집계 중·모름 */
  function renderScoreMarks(result) {
    var container = document.querySelector("[data-score-marks]");
    if (!container) return;
    container.innerHTML = result.perQuestion.map(function (question) {
      var className = question.myAnswer === unknownMark ? "is-blank" : question.isCorrect === null ? "is-pending" : question.isCorrect ? "is-correct" : "is-wrong";
      var label = question.myAnswer === unknownMark ? "모름" : question.isCorrect === null ? "집계 중" : question.isCorrect ? "맞음" : "틀림";
      return '<span class="score-mark ' + className + '" title="' + question.questionNo + "번 " + label + '">' + question.questionNo + "</span>";
    }).join("");
  }

  function animateNumber(element, target) {
    if (!element) return;
    var start = Number(element.textContent) || 0; // '-' 이면 0부터
    if (isReducedMotion || start === target) { element.textContent = String(target); return; }
    var startTime = null;
    function step(timestamp) {
      if (startTime === null) startTime = timestamp;
      var progress = Math.min(1, (timestamp - startTime) / 700);
      element.textContent = String(Math.round(start + (target - start) * (1 - Math.pow(1 - progress, 3))));
      if (progress < 1) window.requestAnimationFrame(step);
    }
    window.requestAnimationFrame(step);
  }

  // ── 서버 가답안 읽기 (처음 1회 + 1분마다, 탭이 숨겨지면 건너뜀) ──
  function refreshAnswerKey() {
    return requestJson(roundApiUrl).then(function (response) {
      if (!response || !response.items || !response.items.length) throw new Error("empty items");
      state.answerKey = normalizeAnswerKey(response);
      state.isLive = true;
      renderConnection();
      answerTable.render();
      if (state.gradeResult) gradeAndRender();
    }).catch(function () {
      state.isLive = false;
      renderConnection();
    });
  }

  function renderConnection() {
    var element = document.querySelector("[data-connection-status]");
    if (!element) return;
    element.classList.toggle("is-live", state.isLive);
    element.lastChild.textContent = state.isLive
      ? "실시간 집계에 연결됐어요. " + config.liveRefreshSeconds + "초마다 새로 불러와요."
      : "서버 연결 전이라 미리 받아 둔 가답안을 보여 주고 있어요. 가채점은 그대로 돼요.";
  }

  /** 이 브라우저에 답이 없고 예전에 제출했다면 서버에서 내 답안 복원 */
  function restoreSheetFromServer() {
    var token = readStorage(storageKeys.clientToken);
    if (!token || countFilledAnswers() > 0) return;
    requestJson(roundApiUrl + "/sheets/" + encodeURIComponent(token)).then(function (response) {
      var answersText = response && (response.answers || (response.sheet && response.sheet.answers));
      if (!answersText) return;
      state.answers = toAnswerArray(String(answersText));
      writeStorage(storageKeys.answers, state.answers.join(""));
      omrRows.forEach(function (row, index) { renderOmrRow(index); });
      syncQuickInput();
      renderOmrProgress(false);
      state.percentile = readPercentile(response);
      gradeAndRender();
    }).catch(function () { /* 제출 기록 없음 */ });
  }

  var toastTimer = null;
  function showToast(message) {
    var toast = document.querySelector("[data-share-toast]");
    if (!toast) return;
    toast.textContent = message;
    window.clearTimeout(toastTimer);
    toastTimer = window.setTimeout(function () { toast.textContent = ""; }, 3200);
  }

  // ── 작은 도우미 ──
  function setText(selector, value) {
    document.querySelectorAll(selector).forEach(function (element) { element.textContent = String(value); });
  }

  function bindClick(selector, handler) {
    var element = document.querySelector(selector);
    if (element) element.addEventListener("click", handler);
  }

  function scrollToElement(element) {
    if (element) element.scrollIntoView({ block: "start", behavior: isReducedMotion ? "auto" : "smooth" });
  }

  var answerTable = window.PassqlExamAnswer.createAnswerTable({
    config: config, getState: function () { return state; }, isUncertainItem: isUncertainItem,
    countDecidedItems: countDecidedItems, setText: setText, showToast: showToast
  });
  var share = window.PassqlExamAnswer.createShare({
    config: config, getState: function () { return state; }, readStorage: readStorage, writeStorage: writeStorage,
    scorePublicStorageKey: storageKeys.isScorePublic, showToast: showToast, bindClick: bindClick
  });

  // ── 시작: 저장된 답 표시 > 스냅샷 가답안 > (답이 있으면) 채점 > 서버 가답안·내 답안 복원 > 1분마다 갱신 ──
  omrRows.forEach(function (row, index) { renderOmrRow(index); });
  syncQuickInput();
  renderOmrProgress(false);
  moveCursor(state.answers.indexOf(unknownMark) >= 0 ? state.answers.indexOf(unknownMark) : 0, false);
  bindOmr();
  answerTable.bindFilters();
  share.bind();
  answerTable.render();
  if (countFilledAnswers() > 0) gradeAndRender(); else renderResult();
  renderConnection();
  refreshAnswerKey().then(restoreSheetFromServer);
  if (document.fonts && document.fonts.ready) document.fonts.ready.then(share.draw);
  window.setInterval(function () {
    if (!document.hidden) refreshAnswerKey();
  }, config.liveRefreshSeconds * 1000);
})();
