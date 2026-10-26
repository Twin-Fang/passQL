// passQL 소개 사이트 동작 (#650): 시험 D-day 계산 > 등장 효과 > 화면 모음 넘기기
(function () {
  "use strict";

  // 하루 길이 (밀리초)
  var DAY_MILLISECONDS = 24 * 60 * 60 * 1000;

  /** 시험일(YYYY-MM-DD) > 오늘 기준 남은 날 (한국 날짜 기준이 아닌 방문자 기기 날짜) */
  function calculateDaysUntil(examDateText) {
    var parts = examDateText.split("-").map(Number);
    var examDate = new Date(parts[0], parts[1] - 1, parts[2]);
    var today = new Date();
    var todayStart = new Date(today.getFullYear(), today.getMonth(), today.getDate());
    return Math.round((examDate - todayStart) / DAY_MILLISECONDS);
  }

  /** 남은 날 > 표시 문구 (D-n, D-DAY, 지난 시험은 null) */
  function toDdayLabel(daysUntil) {
    if (daysUntil > 0) return "D-" + daysUntil;
    if (daysUntil === 0) return "D-DAY";
    return null;
  }

  // D-day 카드·마지막 문구 채우기 (시험이 지났으면 날짜 문구 그대로)
  function renderExamCountdown() {
    var card = document.querySelector("[data-exam-date]");
    if (!card) return;
    var label = toDdayLabel(calculateDaysUntil(card.getAttribute("data-exam-date")));
    if (!label) return;
    var countElement = card.querySelector("[data-dday-count]");
    var dateElement = card.querySelector("[data-dday-date]");
    countElement.textContent = label;
    dateElement.hidden = false;
    var inlineElement = document.querySelector("[data-dday-inline]");
    if (inlineElement) inlineElement.textContent = inlineElement.textContent + " · " + label;
    // 모바일 첫 화면 D-day 알약 (D-day 카드가 첫 화면 아래로 밀려나는 폭)
    document.querySelectorAll("[data-dday-show]").forEach(function (element) {
      element.querySelector("[data-dday-label]").textContent = label;
      element.hidden = false;
    });
  }

  // 등장 효과 (화면에 들어올 때 1회, 관찰 미지원이면 바로 표시)
  function revealOnScroll() {
    var targets = document.querySelectorAll(".reveal");
    if (!("IntersectionObserver" in window)) {
      targets.forEach(function (target) { target.classList.add("is-visible"); });
      return;
    }
    var observer = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (!entry.isIntersecting) return;
        entry.target.classList.add("is-visible");
        observer.unobserve(entry.target);
      });
    }, { rootMargin: "0px 0px -8% 0px" });
    targets.forEach(function (target) { observer.observe(target); });
  }

  // 화면 모음 이전·다음 버튼 (한 칸 = 첫 화면 폭 + 간격)
  function bindGalleryButtons() {
    var gallery = document.querySelector("[data-gallery]");
    if (!gallery) return;
    document.querySelectorAll("[data-gallery-step]").forEach(function (button) {
      button.addEventListener("click", function () {
        var firstShot = gallery.querySelector(".shot");
        var stepPixels = firstShot ? firstShot.getBoundingClientRect().width + 24 : 280;
        gallery.scrollBy({ left: stepPixels * Number(button.getAttribute("data-gallery-step")), behavior: "smooth" });
      });
    });
  }

  renderExamCountdown();
  revealOnScroll();
  bindGalleryButtons();
})();
