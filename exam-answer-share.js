// SQLD 가채점 공유 (#1075): 점수 공개 선택 > 결과 카드 canvas(1080x1350) > 이미지 공유·링크 복사·카카오톡·X
// exam-answer.js 가 window.PassqlExamAnswer.createShare(options) 로 사용, 색은 style.css 토큰
(function () {
  "use strict";

  // 공유 이미지 크기 (4:5 세로, 인스타·카카오 미리보기 공용)
  var SHARE_CARD_WIDTH_PIXELS = 1080;
  var SHARE_CARD_HEIGHT_PIXELS = 1350;

  /** options: config, getState(), readStorage, writeStorage, scorePublicStorageKey, showToast, bindClick */
  function createShare(options) {
    var config = options.config;
    var getState = options.getState;
    var readStorage = options.readStorage;
    var writeStorage = options.writeStorage;
    var showToast = options.showToast;
    var bindClick = options.bindClick;

    function readToken(name) {
      return getComputedStyle(document.documentElement).getPropertyValue(name).trim();
    }

    var shareCanvas = document.querySelector("[data-share-canvas]");
    var scorePublicCheckbox = document.querySelector("[data-share-score-public]");
    var markImage = new Image();
    markImage.src = config.markImageUrl;
    markImage.onload = function () { drawShareCard(); };

    function isScorePublic() {
      return !!(scorePublicCheckbox && scorePublicCheckbox.checked && getState().gradeResult && getState().gradeResult.passStatus !== "PENDING");
    }

    function buildShareUrl() {
      return config.pageUrl + "?from=share";
    }

    /** 공유 문구: 점수 공개면 점수·판정, 아니면 초대 문구 */
    function buildShareText() {
      var roundName = config.certType + " " + config.roundNumber + "회";
      if (isScorePublic()) {
        var result = getState().gradeResult;
        return roundName + " 가채점 " + result.totalScore + "점 (" + config.verdictLabels[result.passStatus] + ") 나왔어요. 너도 OMR 찍어 봐!";
      }
      return roundName + " 가답안 나왔어요. OMR에 답 찍으면 점수·합격 여부 바로 나와요!";
    }

    /** 공유 카드 그리기 (1080x1350): 배경 > 로고 > 회차 > 점수·판정(공개 시) > 과목 막대 > 주소 */
    function drawShareCard() {
      if (!shareCanvas || !shareCanvas.getContext) return;
      var context = shareCanvas.getContext("2d");
      var width = SHARE_CARD_WIDTH_PIXELS;
      var height = SHARE_CARD_HEIGHT_PIXELS;
      var colors = {
        accent: readToken("--accent"), accent2: readToken("--accent-2"), text: readToken("--text"), muted: readToken("--muted"),
        surface: readToken("--surface"), surface2: readToken("--surface-2"), onAccent: readToken("--on-accent"),
        wrong: readToken("--wrong"), confirmed: readToken("--status-confirmed"), disputed: readToken("--status-disputed"),
        unknown: readToken("--status-unknown")
      };
      var fontFamily = '"Pretendard Variable", Pretendard, -apple-system, sans-serif';
      var result = getState().gradeResult;
      var isPublic = isScorePublic();

      // 배경: 브랜드 그라데이션 + 흰 카드
      var gradient = context.createLinearGradient(0, 0, width, height);
      gradient.addColorStop(0, colors.accent);
      gradient.addColorStop(1, colors.accent2);
      context.fillStyle = gradient;
      context.fillRect(0, 0, width, height);
      fillRoundRect(context, 72, 200, width - 144, height - 380, 56, colors.surface);

      // 머리: 로고 + 회차
      if (markImage.complete && markImage.naturalWidth) context.drawImage(markImage, 72, 72, 96, 96);
      context.fillStyle = colors.onAccent;
      context.font = "800 52px " + fontFamily;
      context.textBaseline = "middle";
      context.fillText("passQL", 188, 104);
      context.font = "600 32px " + fontFamily;
      context.fillText("SQLD 시험 가채점", 188, 148);

      context.textAlign = "center";
      context.fillStyle = colors.muted;
      context.font = "700 44px " + fontFamily;
      context.fillText("SQLD 제" + config.roundNumber + "회 가채점", width / 2, 300);

      if (isPublic) {
        var verdictColor = result.passStatus === "PASS" ? colors.confirmed : result.passStatus === "FAIL" ? colors.wrong
          : result.passStatus === "BORDERLINE" ? colors.disputed : colors.unknown;
        context.fillStyle = verdictColor;
        context.font = "800 240px " + fontFamily;
        context.fillText(String(result.totalScore), width / 2, 500);
        context.fillStyle = colors.muted;
        context.font = "700 44px " + fontFamily;
        context.fillText("/ 100점", width / 2, 650);
        drawPill(context, width / 2, 740, config.verdictLabels[result.passStatus], verdictColor, colors.onAccent, fontFamily);
        drawSubjectBars(context, result, colors, fontFamily, 840);
        if (getState().percentile != null) {
          context.fillStyle = colors.text;
          context.font = "700 40px " + fontFamily;
          context.fillText("참여자 중 상위 " + Math.max(1, Math.round(getState().percentile)) + "%", width / 2, 1110);
        }
      } else {
        context.fillStyle = colors.text;
        context.font = "800 96px " + fontFamily;
        context.fillText(result ? "가채점 완료!" : "내 점수는 몇 점?", width / 2, 520);
        context.fillStyle = colors.muted;
        context.font = "600 42px " + fontFamily;
        context.fillText("OMR에 답만 찍으면", width / 2, 660);
        context.fillText("과목별 점수·과락·합격 여부가 바로", width / 2, 720);
        drawPill(context, width / 2, 850, "나도 가채점 해 보기", colors.accent, colors.onAccent, fontFamily);
        if (getState().answerKey.participantCount > 0) {
          context.fillStyle = colors.text;
          context.font = "700 40px " + fontFamily;
          context.fillText(getState().answerKey.participantCount.toLocaleString("ko-KR") + "명이 함께 맞춰 보는 중", width / 2, 1010);
        }
      }
      // 바닥: 주소
      context.fillStyle = colors.onAccent;
      context.font = "700 40px " + fontFamily;
      context.fillText(config.siteHost + "/sqld/" + config.roundNumber, width / 2, height - 110);
      context.textAlign = "left";
    }

    function drawSubjectBars(context, result, colors, fontFamily, top) {
      var left = 160;
      var barWidth = SHARE_CARD_WIDTH_PIXELS - left * 2;
      result.subjects.forEach(function (subjectResult, index) {
        var y = top + index * 120;
        var subject = subjectResult.subject;
        context.textAlign = "left";
        context.fillStyle = colors.text;
        context.font = "700 34px " + fontFamily;
        context.fillText(subject.name.split(" · ")[0], left, y);
        context.textAlign = "right";
        context.fillText(subjectResult.score + " / " + subject.maxScore + "점", left + barWidth, y);
        fillRoundRect(context, left, y + 32, barWidth, 22, 11, colors.surface2);
        var fillWidth = Math.max(22, barWidth * subjectResult.score / subject.maxScore);
        fillRoundRect(context, left, y + 32, fillWidth, 22, 11, subjectResult.isFailCut ? colors.wrong : colors.accent);
        // 과락선
        var cutX = left + barWidth * subject.failUnderScore / subject.maxScore;
        context.fillStyle = colors.wrong;
        context.fillRect(cutX - 2, y + 24, 4, 38);
      });
      context.textAlign = "center";
    }

    function drawPill(context, centerX, centerY, text, background, foreground, fontFamily) {
      context.font = "800 44px " + fontFamily;
      var pillWidth = context.measureText(text).width + 96;
      fillRoundRect(context, centerX - pillWidth / 2, centerY - 44, pillWidth, 88, 44, background);
      context.fillStyle = foreground;
      context.fillText(text, centerX, centerY + 2);
    }

    function fillRoundRect(context, x, y, width, height, radius, color) {
      context.beginPath();
      context.moveTo(x + radius, y);
      context.arcTo(x + width, y, x + width, y + height, radius);
      context.arcTo(x + width, y + height, x, y + height, radius);
      context.arcTo(x, y + height, x, y, radius);
      context.arcTo(x, y, x + width, y, radius);
      context.closePath();
      context.fillStyle = color;
      context.fill();
    }

    /** 이미지 공유: 파일 공유 지원 기기는 공유 시트, 아니면 PNG 내려받기 */
    function shareImage() {
      drawShareCard();
      shareCanvas.toBlob(function (blob) {
        if (!blob) return;
        var fileName = "passQL-SQLD-" + config.roundNumber + "-가채점.png";
        var file = typeof File === "function" ? new File([blob], fileName, { type: "image/png" }) : null;
        if (file && navigator.canShare && navigator.canShare({ files: [file] })) {
          navigator.share({ files: [file], text: buildShareText() + " " + buildShareUrl() }).catch(function () {});
          return;
        }
        var link = document.createElement("a");
        link.href = URL.createObjectURL(blob);
        link.download = fileName;
        document.body.appendChild(link);
        link.click();
        link.remove();
        window.setTimeout(function () { URL.revokeObjectURL(link.href); }, 4000);
        showToast("이미지를 저장했어요. 인스타·카톡에 올려 보세요!");
      }, "image/png");
    }

    function copyShareLink(successMessage) {
      var text = buildShareText() + " " + buildShareUrl();
      var onCopied = function () { showToast(successMessage || "링크를 복사했어요."); };
      if (navigator.clipboard && window.isSecureContext) {
        navigator.clipboard.writeText(text).then(onCopied, function () { copyWithTextarea(text); onCopied(); });
        return;
      }
      copyWithTextarea(text);
      onCopied();
    }

    function copyWithTextarea(text) {
      var textarea = document.createElement("textarea");
      textarea.value = text;
      textarea.setAttribute("readonly", "");
      textarea.style.position = "fixed";
      textarea.style.opacity = "0";
      document.body.appendChild(textarea);
      textarea.select();
      try { document.execCommand("copy"); } catch (error) { /* 복사 미지원 */ }
      textarea.remove();
    }

    /** 카카오톡: 휴대폰 공유 시트(카카오톡 포함), 없으면 복사 후 붙여 넣기 안내 (카카오 SDK 키 없이) */
    function shareToKakao() {
      if (navigator.share) {
        navigator.share({ title: document.title, text: buildShareText(), url: buildShareUrl() }).catch(function () {});
        return;
      }
      copyShareLink("링크를 복사했어요. 카카오톡 대화창에 붙여 넣어 주세요.");
    }

    function shareToX() {
      var intentUrl = "https://twitter.com/intent/tweet?text=" + encodeURIComponent(buildShareText()) + "&url=" + encodeURIComponent(buildShareUrl());
      window.open(intentUrl, "_blank", "noopener");
    }


    function bindShare() {
      if (scorePublicCheckbox) {
        scorePublicCheckbox.checked = readStorage(options.scorePublicStorageKey) === "1";
        scorePublicCheckbox.addEventListener("change", function () {
          writeStorage(options.scorePublicStorageKey, scorePublicCheckbox.checked ? "1" : "0");
          if (scorePublicCheckbox.checked && !getState().gradeResult) showToast("채점하기를 누르면 점수가 이미지에 들어가요.");
          drawShareCard();
        });
      }
      bindClick("[data-share-image]", shareImage);
      bindClick("[data-share-copy]", function () { copyShareLink(); });
      bindClick("[data-share-kakao]", shareToKakao);
      bindClick("[data-share-x]", shareToX);
    }

    return { draw: drawShareCard, bind: bindShare };
  }

  window.PassqlExamAnswer = window.PassqlExamAnswer || {};
  window.PassqlExamAnswer.createShare = createShare;
})();
