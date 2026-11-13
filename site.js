// passQL 소개 사이트 동작 (#650, #823, #1027): 시험 D-day > 일정 회차 표시 > Android 설치 주소 > 등장 효과 > 숫자 올리기
// > 첫 화면 캡처 바꾸기 > 스크롤 효과(첫 화면 폰 세우기·기능 폰 기울기·화면 모음 가운데 강조) > 화면 모음 넘기기
(function () {
  "use strict";

  // 하루 길이 (밀리초)
  var DAY_MILLISECONDS = 24 * 60 * 60 * 1000;
  // 첫 화면 캡처 바뀌는 간격 (밀리초)
  var HERO_SCREEN_INTERVAL_MILLISECONDS = 3200;
  // 숫자 올라가는 시간 (밀리초)
  var COUNT_UP_DURATION_MILLISECONDS = 1200;
  var isReducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;

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

  /** 값을 0..1 로 자름 */
  function clampToUnit(value) {
    return Math.min(1, Math.max(0, value));
  }

  // D-day 카드·마지막 문구 채우기 (시험이 지났으면 날짜 문구 그대로)
  function renderExamCountdown() {
    var card = document.querySelector("[data-exam-date]");
    if (!card) return;
    var label = toDdayLabel(calculateDaysUntil(card.getAttribute("data-exam-date")));
    if (!label) return;
    // 일정 카드면 숫자·날짜 칸 채움 (첫 화면 알약은 그 칸이 없음)
    var countElement = card.querySelector("[data-dday-count]");
    if (countElement) countElement.textContent = label;
    var dateElement = card.querySelector("[data-dday-date]");
    if (dateElement) dateElement.hidden = false;
    var inlineElement = document.querySelector("[data-dday-inline]");
    if (inlineElement) inlineElement.textContent = inlineElement.textContent + " · " + label;
    // 첫 화면 D-day 알약 (#1057 부터 모든 화면 크기)
    document.querySelectorAll("[data-dday-show]").forEach(function (element) {
      element.querySelector("[data-dday-label]").textContent = label;
      element.hidden = false;
    });
  }

  // 일정 페이지 회차 카드: 지난 회차 흐리게, 방문 날짜 기준 다음 회차 강조 (JS 없으면 모두 같은 모양)
  function markScheduleRounds() {
    var isNextFound = false;
    document.querySelectorAll("[data-round-exam]").forEach(function (card) {
      var badge = card.querySelector("[data-round-badge]");
      var daysUntil = calculateDaysUntil(card.getAttribute("data-round-exam"));
      if (daysUntil < 0) {
        card.classList.add("is-past");
        badge.textContent = "지난 회차";
      } else if (!isNextFound) {
        isNextFound = true;
        card.classList.add("is-next");
        badge.textContent = "다음 시험 · " + toDdayLabel(daysUntil);
      } else {
        return;
      }
      badge.hidden = false;
    });
  }

  // Android 방문자: 앱 받기 주소를 Play 로, Play 버튼을 앞으로 (html.is-android)
  function applyAndroidStoreLinks() {
    if (!/Android/i.test(navigator.userAgent)) return;
    document.documentElement.classList.add("is-android");
    document.querySelectorAll("[data-android-href]").forEach(function (link) {
      link.setAttribute("href", link.getAttribute("data-android-href"));
    });
  }

  /** 0 > 목표 숫자 (감속 곡선, 동작 줄이기면 바로 목표) */
  function countUp(element) {
    var target = Number(element.getAttribute("data-count-to"));
    if (isReducedMotion || target === 0) { element.textContent = String(target); return; }
    var startTime = null;
    element.textContent = "0";
    function step(timestamp) {
      if (startTime === null) startTime = timestamp;
      var progress = clampToUnit((timestamp - startTime) / COUNT_UP_DURATION_MILLISECONDS);
      element.textContent = String(Math.round(target * (1 - Math.pow(1 - progress, 3))));
      if (progress < 1) window.requestAnimationFrame(step);
    }
    window.requestAnimationFrame(step);
  }

  // 등장 효과 (.reveal·.share 화면에 들어올 때 1회, 숫자는 그때 올림. 관찰 미지원이면 바로 표시)
  function revealOnScroll() {
    var targets = document.querySelectorAll(".reveal, .share");
    function show(target) {
      target.classList.add("is-visible");
      target.querySelectorAll("[data-count-to]").forEach(countUp);
    }
    if (!("IntersectionObserver" in window)) { targets.forEach(show); return; }
    var observer = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (!entry.isIntersecting) return;
        show(entry.target);
        observer.unobserve(entry.target);
      });
    }, { rootMargin: "0px 0px -8% 0px" });
    targets.forEach(function (target) { observer.observe(target); });
  }

  // 첫 화면 캡처 차례로 바꾸기 (화면 빛 지나감·점 표시, 탭이 숨겨지면 멈춤)
  function cycleHeroScreens() {
    var stack = document.querySelector("[data-screen-cycle]");
    if (!stack || isReducedMotion) return;
    var screens = stack.querySelectorAll("img");
    var dots = document.querySelectorAll("[data-screen-dots] span");
    var shine = stack.parentElement.querySelector(".phone-shine");
    if (screens.length < 2) return;
    var activeIndex = 0;
    window.setInterval(function () {
      if (document.hidden) return;
      // 나가는 장은 아래에 그대로 두고 새 장이 위에서 나타남 (중간에 배경이 비치지 않게)
      stack.querySelectorAll(".is-previous").forEach(function (screen) { screen.classList.remove("is-previous"); });
      screens[activeIndex].classList.remove("is-active");
      screens[activeIndex].classList.add("is-previous");
      if (dots[activeIndex]) dots[activeIndex].classList.remove("is-active");
      activeIndex = (activeIndex + 1) % screens.length;
      screens[activeIndex].classList.add("is-active");
      if (dots[activeIndex]) dots[activeIndex].classList.add("is-active");
      if (shine) {
        shine.classList.remove("is-sweeping");
        void shine.offsetWidth; // 같은 애니메이션 다시 시작
        shine.classList.add("is-sweeping");
      }
    }, HERO_SCREEN_INTERVAL_MILLISECONDS);
  }

  // 스크롤 효과: 한 프레임에 한 번 계산 (첫 화면 폰 --lift, 기능 폰 --tilt, 화면 모음 --focus)
  function bindScrollEffects() {
    if (isReducedMotion) return;
    var liftTargets = document.querySelectorAll("[data-scroll-lift]");
    var tiltTargets = document.querySelectorAll("[data-scroll-tilt]");
    var gallery = document.querySelector("[data-gallery]");
    var isFrameRequested = false;
    tiltTargets.forEach(function (target) {
      target.style.setProperty("--tilt-direction", target.getAttribute("data-scroll-tilt"));
    });

    function updateScrollEffects() {
      isFrameRequested = false;
      var viewportHeight = window.innerHeight;
      // 첫 화면 폰: 위쪽이 화면 92% 지점 > 55% 지점으로 올라오는 동안 0 > 1
      liftTargets.forEach(function (target) {
        var top = target.getBoundingClientRect().top;
        target.style.setProperty("--lift", clampToUnit((viewportHeight * 0.92 - top) / (viewportHeight * 0.37)).toFixed(3));
      });
      // 기능 폰: 위쪽이 화면 아래 끝 > 30% 지점으로 올라오는 동안 0 > 1
      tiltTargets.forEach(function (target) {
        var top = target.getBoundingClientRect().top;
        target.style.setProperty("--tilt", clampToUnit((viewportHeight - top) / (viewportHeight * 0.7)).toFixed(3));
      });
      if (gallery) updateGalleryFocus(gallery);
    }
    function requestUpdate() {
      if (isFrameRequested) return;
      isFrameRequested = true;
      window.requestAnimationFrame(updateScrollEffects);
    }
    window.addEventListener("scroll", requestUpdate, { passive: true });
    window.addEventListener("resize", requestUpdate);
    if (gallery) gallery.addEventListener("scroll", requestUpdate, { passive: true });
    updateScrollEffects();
  }

  /** 화면 모음: 가운데에 가까운 장일수록 --focus 1 (반 장 폭 이상 떨어지면 0) */
  function updateGalleryFocus(gallery) {
    var galleryBox = gallery.getBoundingClientRect();
    var centerX = galleryBox.left + galleryBox.width / 2;
    gallery.querySelectorAll(".shot").forEach(function (shot) {
      var box = shot.getBoundingClientRect();
      var distanceRatio = Math.abs(box.left + box.width / 2 - centerX) / (box.width * 1.5);
      shot.style.setProperty("--focus", (1 - clampToUnit(distanceRatio)).toFixed(3));
    });
  }

  // 화면 모음 이전·다음 버튼 (한 칸 = 첫 장 폭 + 간격)
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
  markScheduleRounds();
  applyAndroidStoreLinks();
  revealOnScroll();
  cycleHeroScreens();
  bindScrollEffects();
  bindGalleryButtons();
})();
