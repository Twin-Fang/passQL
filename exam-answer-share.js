// SQLD 가채점 공유 (#1075): 점수 공개 선택 > 결과 카드 canvas(1080x1350, 흰 바탕·로고·글자만, #1109) > 이미지 공유·링크 복사·카카오톡·X
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
    var logoImage = new Image();
    logoImage.src = config.logoImageUrl;
    logoImage.onload = function () { drawShareCard(); };

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

    // 공유 카드 배치 (1080x1350 기준 px): 바깥 여백, 로고 높이(logo.png 213x58 원본), 본문 시작 줄, 바닥 구분선 위치
    var SHARE_CARD_PADDING_PIXELS = 96;
    var SHARE_LOGO_HEIGHT_PIXELS = 72;
    var SHARE_BODY_TOP_PIXELS = 500;
    var SHARE_FOOTER_LINE_TOP_PIXELS = 1180;

    /** 공유 카드 그리기 (1080x1350): 흰 바탕 > 로고 > 회차 가채점 > 판정·점수(공개 시) 또는 초대 문구 > 구분선 > 주소
     *  그라데이션·빛 번짐·알약·과목 막대 없음 (#1109, 앱 공유 이미지와 같은 구성) */
    function drawShareCard() {
      if (!shareCanvas || !shareCanvas.getContext) return;
      var context = shareCanvas.getContext("2d");
      var width = SHARE_CARD_WIDTH_PIXELS;
      var height = SHARE_CARD_HEIGHT_PIXELS;
      var left = SHARE_CARD_PADDING_PIXELS;
      var colors = {
        surface: readToken("--surface"), text: readToken("--text"), muted: readToken("--muted"), dim: readToken("--dim"),
        line: readToken("--line"), wrong: readToken("--wrong"), confirmed: readToken("--status-confirmed"),
        disputed: readToken("--status-disputed"), unknown: readToken("--status-unknown")
      };
      var fontFamily = '"Pretendard Variable", Pretendard, -apple-system, sans-serif';
      var result = getState().gradeResult;
      var isPublic = isScorePublic();

      context.fillStyle = colors.surface;
      context.fillRect(0, 0, width, height);
      context.textAlign = "left";
      context.textBaseline = "alphabetic";

      // 로고 (원본 비율 유지)
      if (logoImage.complete && logoImage.naturalWidth) {
        var logoWidth = logoImage.naturalWidth * SHARE_LOGO_HEIGHT_PIXELS / logoImage.naturalHeight;
        context.drawImage(logoImage, left, SHARE_CARD_PADDING_PIXELS, logoWidth, SHARE_LOGO_HEIGHT_PIXELS);
      }

      context.fillStyle = colors.muted;
      context.font = "600 44px " + fontFamily;
      context.fillText("SQLD 제" + config.roundNumber + "회 가채점", left, SHARE_BODY_TOP_PIXELS);

      if (isPublic) {
        // 판정 (의미색 글자) > 총점
        context.fillStyle = result.passStatus === "PASS" ? colors.confirmed : result.passStatus === "FAIL" ? colors.wrong
          : result.passStatus === "BORDERLINE" ? colors.disputed : colors.unknown;
        context.font = "800 72px " + fontFamily;
        context.fillText(config.verdictLabels[result.passStatus], left, SHARE_BODY_TOP_PIXELS + 104);
        context.fillStyle = colors.text;
        context.font = "800 280px " + fontFamily;
        var scoreText = String(result.totalScore);
        context.fillText(scoreText, left - 12, SHARE_BODY_TOP_PIXELS + 384);
        var scoreWidth = context.measureText(scoreText).width;
        context.fillStyle = colors.dim;
        context.font = "700 56px " + fontFamily;
        context.fillText("/ 100점", left + scoreWidth + 8, SHARE_BODY_TOP_PIXELS + 384);
      } else {
        // 점수 비공개: 판정도 싣지 않고 초대 문구만
        context.fillStyle = colors.text;
        context.font = "800 88px " + fontFamily;
        context.fillText(result ? "가채점 완료!" : "내 점수는 몇 점?", left, SHARE_BODY_TOP_PIXELS + 120);
        context.fillStyle = colors.muted;
        context.font = "600 42px " + fontFamily;
        context.fillText("OMR에 답만 찍으면", left, SHARE_BODY_TOP_PIXELS + 230);
        context.fillText("과목별 점수, 과락, 합격 여부가 바로", left, SHARE_BODY_TOP_PIXELS + 292);
        if (getState().answerKey.participantCount > 0) {
          context.fillStyle = colors.dim;
          context.font = "600 38px " + fontFamily;
          context.fillText(getState().answerKey.participantCount.toLocaleString("ko-KR") + "명이 함께 맞춰 보는 중", left, SHARE_BODY_TOP_PIXELS + 400);
        }
      }

      // 바닥: 구분선 > 회차 주소
      context.fillStyle = colors.line;
      context.fillRect(left, SHARE_FOOTER_LINE_TOP_PIXELS, width - left * 2, 2);
      context.fillStyle = colors.muted;
      context.font = "600 38px " + fontFamily;
      context.fillText(config.siteHost + "/sqld/" + config.roundNumber, left, SHARE_FOOTER_LINE_TOP_PIXELS + 76);
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
