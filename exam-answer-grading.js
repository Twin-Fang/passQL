// SQLD 가채점 채점 규칙 (#1075): 가답안 응답 정리 > 정답 집합 > 과목별 점수·범위·판정 (화면 없는 순수 함수)
// exam-answer.js 가 window.PassqlExamAnswer.createGrader(rules) 로 사용, 규칙 원본은 _src/site_answer_key_content.py
(function () {
  "use strict";

  function createGrader(rules) {
    var questionCount = rules.questionCount;
    var unknownMark = rules.unknownAnswerMark;

    /** 아무 문자열 > 길이 questionCount 답 배열 (숫자 1~4 외는 모름) */
    function toAnswerArray(text) {
      var answers = [];
      for (var index = 0; index < questionCount; index += 1) {
        var character = text.charAt(index);
        answers.push(/^[1-9]$/.test(character) && Number(character) <= rules.choiceCount ? character : unknownMark);
      }
      return answers;
    }

    // ── 가답안 (API·스냅샷 공용 형태로 정리) ──
    /** API 응답 > {status, participantCount, updatedAt, items: {문항번호: item}} (round 메타가 중첩·평면 모두 허용) */
    function normalizeAnswerKey(response) {
      var source = response || {};
      var roundMeta = source.round || {};
      var itemByNumber = {};
      (source.items || []).forEach(function (item) {
        itemByNumber[item.questionNo] = {
          questionNo: item.questionNo,
          subjectNo: item.subjectNo,
          conceptTitle: item.conceptTitle || "",
          conceptTags: item.conceptTags || "",
          answer: item.answer ? String(item.answer) : null,
          answerStatus: item.answerStatus || "UNKNOWN",
          alternativeAnswers: toChoiceList(item.alternativeAnswers),
          tally: toTallyMap(item.tally),
          voteCount: Number(item.voteCount) || 0,
          agreementRate: Number(item.agreementRate) || 0,
          note: item.note || ""
        };
      });
      return {
        status: roundMeta.status || source.status || "COLLECTING",
        participantCount: Number(source.participantCount != null ? source.participantCount : roundMeta.participantCount) || 0,
        updatedAt: source.updatedAt || roundMeta.updatedAt || null,
        items: itemByNumber
      };
    }

    /** 복수정답 '2,3' 또는 [2,3] > ['2','3'] */
    function toChoiceList(value) {
      if (!value) return [];
      var list = Array.isArray(value) ? value : String(value).split(",");
      return list.map(function (choice) { return String(choice).trim(); }).filter(Boolean);
    }

    /** 득표 {1:n,...} 또는 [n1..n4] > {'1':n,...} */
    function toTallyMap(value) {
      var tally = {};
      for (var choice = 1; choice <= rules.choiceCount; choice += 1) {
        var count = Array.isArray(value) ? value[choice - 1] : value && (value[choice] != null ? value[choice] : value[String(choice)]);
        tally[String(choice)] = Number(count) || 0;
      }
      return tally;
    }

    /** 문항 정답 집합 (집계 중이거나 답이 없으면 null) */
    function findCorrectChoices(item) {
      if (!item || !item.answer || item.answerStatus === "UNKNOWN") return null;
      return [item.answer].concat(item.alternativeAnswers);
    }

    function isUncertainItem(item) {
      return !item || !item.answer || rules.uncertainStatuses.indexOf(item.answerStatus) >= 0;
    }

    function countDecidedItems(answerKey) {
      var decidedCount = 0;
      for (var number = 1; number <= questionCount; number += 1) {
        if (findCorrectChoices(answerKey.items[number])) decidedCount += 1;
      }
      return decidedCount;
    }

    // ── 채점 (서버 규칙과 같음: 문항당 점수, 총점 합격선, 과목 과락선, 갈림·집계 중은 범위로) ──
    function gradeAnswers(answers, answerKey) {
      var perQuestion = [];
      var subjectResults = rules.subjects.map(function (subject) {
        var subjectResult = { subject: subject, score: 0, minScore: 0, maxScore: 0, correctCount: 0 };
        for (var number = subject.firstQuestionNo; number <= subject.lastQuestionNo; number += 1) {
          var myAnswer = answers[number - 1];
          var item = answerKey.items[number];
          var correctChoices = findCorrectChoices(item);
          var isAnswered = myAnswer !== unknownMark;
          var isCorrect = correctChoices ? isAnswered && correctChoices.indexOf(myAnswer) >= 0 : null;
          var isUncertain = isUncertainItem(item);
          if (isCorrect) {
            subjectResult.score += rules.pointsPerQuestion;
            subjectResult.correctCount += 1;
          }
          // 범위: 갈림·집계 중은 최소=틀림, 최대=맞음(답을 찍었을 때만)
          if (isCorrect && !isUncertain) subjectResult.minScore += rules.pointsPerQuestion;
          if ((isCorrect && !isUncertain) || (isUncertain && isAnswered)) subjectResult.maxScore += rules.pointsPerQuestion;
          perQuestion.push({ questionNo: number, myAnswer: myAnswer, isCorrect: isCorrect, isUncertain: isUncertain });
        }
        subjectResult.isFailCut = subjectResult.score < subject.failUnderScore;
        return subjectResult;
      });
      var totalScore = sumBy(subjectResults, "score");
      var minTotal = sumBy(subjectResults, "minScore");
      var maxTotal = sumBy(subjectResults, "maxScore");
      var isMinPassing = minTotal >= rules.passScore && subjectResults.every(function (result) { return result.minScore >= result.subject.failUnderScore; });
      var isMaxPassing = maxTotal >= rules.passScore && subjectResults.every(function (result) { return result.maxScore >= result.subject.failUnderScore; });
      var decidedCount = countDecidedItems(answerKey);
      var passStatus = decidedCount === 0 ? "PENDING" : isMinPassing ? "PASS" : !isMaxPassing ? "FAIL" : "BORDERLINE";
      return {
        subjects: subjectResults, totalScore: totalScore, scoreRange: { min: minTotal, max: maxTotal },
        passStatus: passStatus, perQuestion: perQuestion, decidedCount: decidedCount,
        correctCount: sumBy(subjectResults, "correctCount"),
        uncertainAnsweredCount: perQuestion.filter(function (question) { return question.isUncertain && question.myAnswer !== unknownMark; }).length
      };
    }

    function sumBy(list, key) {
      return list.reduce(function (sum, entry) { return sum + entry[key]; }, 0);
    }

    return {
      toAnswerArray: toAnswerArray, normalizeAnswerKey: normalizeAnswerKey, isUncertainItem: isUncertainItem,
      countDecidedItems: countDecidedItems, gradeAnswers: gradeAnswers
    };
  }

  window.PassqlExamAnswer = window.PassqlExamAnswer || {};
  window.PassqlExamAnswer.createGrader = createGrader;
})();
