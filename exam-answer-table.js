// SQLD 가답안 표 (#1075): 문항 행 값 채우기(정답·상태·합의율·보기 분포) > 내 답 O/X > 히어로 숫자 > 거르기
// 행 HTML 틀은 _src/site_answer_key_pages.py, exam-answer.js 가 window.PassqlExamAnswer.createAnswerTable(options) 로 사용
(function () {
  "use strict";

  /** options: config, getState(), isUncertainItem, countDecidedItems, setText, showToast */
  function createAnswerTable(options) {
    var config = options.config;
    var getState = options.getState;
    var unknownMark = config.rules.unknownAnswerMark;
    var isUncertainItem = options.isUncertainItem;
    var countDecidedItems = options.countDecidedItems;
    var setText = options.setText;
    var showToast = options.showToast;

    function renderAnswerKey() {
      var answerKey = getState().answerKey;
      document.querySelectorAll("[data-question-no]").forEach(function (row) {
        var item = answerKey.items[Number(row.getAttribute("data-question-no"))];
        if (!item) return;
        row.setAttribute("data-status", item.answerStatus);
        var alternativeText = item.alternativeAnswers.length ? "+" + item.alternativeAnswers.map(toChoiceSymbol).join("") : "";
        row.querySelector("[data-answer]").textContent = item.answer && item.answerStatus !== "UNKNOWN" ? toChoiceSymbol(item.answer) + alternativeText : "?";
        row.querySelector("[data-concept]").textContent = item.conceptTitle || "출제 개념 정리 중";
        row.querySelector("[data-status-label]").textContent = config.statusLabels[item.answerStatus] || config.statusLabels.UNKNOWN;
        var agreementPercent = Math.round(item.agreementRate * 100);
        row.querySelector("[data-agree-fill]").style.width = agreementPercent + "%";
        // 득표 0: 운영 가답안만 있는 상태 > 합의 0% 대신 수집 중 안내
        row.querySelector("[data-agree-text]").textContent = item.voteCount ? "합의 " + agreementPercent + "%" : "응답 모으는 중";
        row.querySelector("[data-vote-count]").textContent = item.voteCount ? item.voteCount.toLocaleString("ko-KR") + "명 응답" : "passQL 운영 가답안";
        var topCount = Math.max.apply(null, Object.keys(item.tally).map(function (choice) { return item.tally[choice]; }));
        row.querySelectorAll("[data-tally-choice]").forEach(function (tallyRow) {
          var count = item.tally[tallyRow.getAttribute("data-tally-choice")] || 0;
          var percent = item.voteCount ? Math.round(count * 100 / item.voteCount) : 0;
          tallyRow.classList.toggle("is-top", count > 0 && count === topCount);
          tallyRow.querySelector(".tally-fill").style.width = percent + "%";
          tallyRow.querySelector("[data-tally-count]").textContent = count.toLocaleString("ko-KR");
          tallyRow.querySelector("[data-tally-percent]").textContent = percent;
        });
        row.querySelector("[data-note]").textContent = [item.note, item.conceptTags ? "#" + String(item.conceptTags).split(",").map(function (tag) { return tag.trim(); }).filter(Boolean).join(" #") : ""].filter(Boolean).join("  ");
      });
      renderHeroStats();
      renderMyMarks();
      applyFilter(getState().activeFilter);
    }

    function toChoiceSymbol(choice) {
      return config.choiceSymbols[choice] || choice;
    }

    /** 가답안 행 오른쪽 내 답 (채점 후에만) */
    function renderMyMarks() {
      var result = getState().gradeResult;
      document.querySelectorAll("[data-question-no]").forEach(function (row) {
        var mine = row.querySelector("[data-mine]");
        var question = result ? result.perQuestion[Number(row.getAttribute("data-question-no")) - 1] : null;
        mine.classList.remove("is-correct", "is-wrong", "is-pending");
        if (!question || question.myAnswer === unknownMark) { mine.textContent = ""; return; }
        mine.textContent = "내 답 " + toChoiceSymbol(question.myAnswer) + (question.isCorrect === null ? "" : question.isCorrect ? " O" : " X");
        mine.classList.add(question.isCorrect === null ? "is-pending" : question.isCorrect ? "is-correct" : "is-wrong");
      });
    }

    function renderHeroStats() {
      var answerKey = getState().answerKey;
      setText("[data-participant-count]", answerKey.participantCount.toLocaleString("ko-KR"));
      setText("[data-decided-count]", countDecidedItems());
      setText("[data-updated-at]", answerKey.updatedAt ? formatUpdatedAt(answerKey.updatedAt) : "집계 대기");
      var statusElement = document.querySelector("[data-round-status]");
      if (statusElement && answerKey.status === "OFFICIAL") {
        statusElement.lastChild.textContent = "공식 정답 반영";
        statusElement.classList.add("is-official");
      }
    }

    /** ISO 시각 > "오후 3:12" (오늘이 아니면 "11.15 오후 3:12") */
    function formatUpdatedAt(isoText) {
      var date = new Date(isoText);
      if (isNaN(date.getTime())) return "집계 대기";
      var time = date.toLocaleTimeString("ko-KR", { hour: "numeric", minute: "2-digit" });
      var isToday = date.toDateString() === new Date().toDateString();
      return isToday ? time : (date.getMonth() + 1) + "." + date.getDate() + " " + time;
    }

    function bindFilters() {
      document.querySelectorAll("[data-ak-filter]").forEach(function (button) {
        button.addEventListener("click", function () { applyFilter(button.getAttribute("data-ak-filter")); });
      });
    }

    /** 거르기: 전체 / 갈림·집계 중 / 내가 틀린 문항(채점 후) */
    function applyFilter(filterName) {
      getState().activeFilter = filterName;
      document.querySelectorAll("[data-ak-filter]").forEach(function (button) {
        button.setAttribute("aria-pressed", String(button.getAttribute("data-ak-filter") === filterName));
      });
      var result = getState().gradeResult;
      document.querySelectorAll("[data-question-no]").forEach(function (row) {
        var questionNumber = Number(row.getAttribute("data-question-no"));
        var item = getState().answerKey.items[questionNumber];
        var isVisible = true;
        if (filterName === "uncertain") isVisible = isUncertainItem(item);
        if (filterName === "wrong") isVisible = !!result && result.perQuestion[questionNumber - 1].isCorrect === false;
        row.classList.toggle("is-filtered-out", !isVisible);
      });
      if (filterName === "wrong" && !result) showToast("채점을 먼저 하면 틀린 문항만 볼 수 있어요.");
    }

    return { render: renderAnswerKey, renderMyMarks: renderMyMarks, bindFilters: bindFilters };
  }

  window.PassqlExamAnswer = window.PassqlExamAnswer || {};
  window.PassqlExamAnswer.createAnswerTable = createAnswerTable;
})();
