// passQL 소개 사이트 첫 화면 동작 (#1057): 앱 재생 폰(단계 칩) > 공부 순서 이야기(스크롤 > 폰 화면) > 폰 기울기 > 모바일 앱 받기 띠
(function () {
  var isReducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
  // 재생 순서: [폰 단계, 머무는 시간(밀리초)] — 0 문제, 1 보기 선택, 2 실행 결과, 3 정답, 4 AI 해설
  var AUTOPLAY_TIMELINE = [[0, 1600], [1, 1500], [2, 2200], [3, 1900], [4, 5200]];
  // 단계 칩 4개가 맡는 폰 단계 (보기 선택은 첫 칩에 포함)
  var CHIP_STEPS = [0, 2, 3, 4];
  // AI 해설 타이핑: 한 번에 늘리는 글자 수, 간격(밀리초)
  var TYPING_CHARACTERS_PER_TICK = 2;
  var TYPING_INTERVAL_MILLISECONDS = 40;

  /** 폰 화면을 한 단계로 맞춤 (s1~s4 누적), 4단계면 해설 타이핑 */
  function setPhoneStep(app, step) {
    for (var index = 1; index <= 4; index++) app.classList.toggle("s" + index, step >= index);
    var typed = app.querySelector("[data-demo-typed]");
    var explanation = app.getAttribute("data-explanation");
    window.clearInterval(app.typingTimer);
    if (step < 4) { typed.textContent = ""; return; }
    if (isReducedMotion) { typed.textContent = explanation; return; }
    var length = 0;
    app.typingTimer = window.setInterval(function () {
      length += TYPING_CHARACTERS_PER_TICK;
      typed.textContent = explanation.slice(0, length);
      var cursor = document.createElement("span");
      cursor.className = "demo-cursor";
      typed.appendChild(cursor);
      if (length >= explanation.length) window.clearInterval(app.typingTimer);
    }, TYPING_INTERVAL_MILLISECONDS);
  }

  /** 누르는 손가락 표시 (보기·제출 버튼 위) */
  function showTap(app, selector) {
    var target = app.querySelector(selector), tap = app.querySelector(".demo-tap");
    if (!target || !tap || isReducedMotion) return;
    var appBox = app.getBoundingClientRect(), targetBox = target.getBoundingClientRect();
    tap.style.left = (targetBox.left - appBox.left + targetBox.width / 2 - 17) + "px";
    tap.style.top = (targetBox.top - appBox.top + targetBox.height / 2 - 17) + "px";
    tap.classList.remove("is-tapping");
    void tap.offsetWidth; // 같은 애니메이션 다시 시작
    tap.classList.add("is-tapping");
  }

  /** 첫 화면 폰: 문제 > 선택 > 실행 > 정답 > 해설 반복, 단계 칩 진행 막대 연동 (탭이 숨겨지면 다음 차례에서 멈춤) */
  function playHeroDemo() {
    var root = document.querySelector("[data-hero-demo]");
    if (!root) return;
    var app = root.querySelector("[data-demo-app]");
    var chips = Array.prototype.slice.call(root.querySelectorAll(".demo-chip"));
    if (isReducedMotion) { setPhoneStep(app, 4); return; }
    var timelineIndex = 0;
    function runNextStep() {
      if (document.hidden) { window.setTimeout(runNextStep, 1000); return; }
      var step = AUTOPLAY_TIMELINE[timelineIndex][0], durationMilliseconds = AUTOPLAY_TIMELINE[timelineIndex][1];
      if (step === 1) showTap(app, ".is-answer");
      if (step === 3) {
        showTap(app, ".demo-submit");
        app.classList.add("is-pressing");
        window.setTimeout(function () { app.classList.remove("is-pressing"); }, 150);
      }
      setPhoneStep(app, step);
      updateChips(chips, step, durationMilliseconds);
      timelineIndex = (timelineIndex + 1) % AUTOPLAY_TIMELINE.length;
      window.setTimeout(runNextStep, durationMilliseconds);
    }
    runNextStep();
  }

  /** 단계 칩: 지난 칩은 채움, 현재 칩은 머무는 시간 동안 차오름 (첫 칩은 문제+선택 두 차례 합산) */
  function updateChips(chips, step, durationMilliseconds) {
    var currentChipIndex = CHIP_STEPS.indexOf(step === 1 ? 0 : step);
    chips.forEach(function (chip, index) {
      var bar = chip.querySelector("b");
      if (bar.getAnimations) bar.getAnimations().forEach(function (animation) { animation.cancel(); });
      chip.classList.toggle("is-current", index === currentChipIndex);
      chip.classList.toggle("is-done", index < currentChipIndex);
      bar.style.width = index > currentChipIndex ? "0" : "";
      if (index === currentChipIndex && step !== 1 && bar.animate) {
        var fillMilliseconds = step === 0 ? AUTOPLAY_TIMELINE[0][1] + AUTOPLAY_TIMELINE[1][1] : durationMilliseconds;
        bar.animate([{ width: "0%" }, { width: "100%" }], { duration: fillMilliseconds, fill: "forwards" });
      }
    });
  }

  /** 공부 순서 이야기: 화면 가운데에 온 단계 글 > 고정 폰을 그 단계 실제 앱 캡처로 (#1062) */
  function bindStory() {
    var stage = document.querySelector("[data-story-demo]");
    if (!stage || !("IntersectionObserver" in window)) return;
    var shots = Array.prototype.slice.call(stage.querySelectorAll("[data-story-shot]"));
    var steps = Array.prototype.slice.call(document.querySelectorAll("[data-story-step]"));
    function showStep(stepElement) {
      var step = stepElement.getAttribute("data-story-step");
      steps.forEach(function (element) { element.classList.toggle("is-current", element === stepElement); });
      shots.forEach(function (shot) { shot.classList.toggle("is-current", shot.getAttribute("data-story-shot") === step); });
    }
    var observer = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) { if (entry.isIntersecting) showStep(entry.target); });
    }, { rootMargin: "-45% 0px -45% 0px" });
    steps.forEach(function (element) { observer.observe(element); });
    showStep(steps[0]);
  }

  /** 첫 화면 폰: 마우스를 따라 살짝 기울기 (정밀 포인터만) */
  function bindPhoneTilt() {
    var phone = document.querySelector("[data-hero-demo] .demo-phone");
    if (!phone || isReducedMotion || !window.matchMedia("(pointer: fine)").matches) return;
    window.addEventListener("pointermove", function (event) {
      var horizontal = event.clientX / window.innerWidth - 0.5, vertical = event.clientY / window.innerHeight - 0.5;
      phone.style.setProperty("--tilt-y", (horizontal * 10).toFixed(2) + "deg");
      phone.style.setProperty("--tilt-x", (-vertical * 8).toFixed(2) + "deg");
    }, { passive: true });
  }

  /** 모바일 앱 받기 띠: 첫 화면을 지나면 보이고, 마지막 다운로드 구역이 보이면 숨김 */
  function bindAppDock() {
    var dock = document.querySelector("[data-app-dock]");
    var hero = document.querySelector(".hero");
    var finalSection = document.querySelector(".final-cta");
    if (!dock || !hero) return;
    if (document.documentElement.classList.contains("is-android")) {
      var link = dock.querySelector("[data-android-href]");
      if (link) link.setAttribute("href", link.getAttribute("data-android-href"));
    }
    function update() {
      var isHeroPassed = hero.getBoundingClientRect().bottom < 0;
      var isFinalVisible = finalSection && finalSection.getBoundingClientRect().top < window.innerHeight;
      var isShown = isHeroPassed && !isFinalVisible;
      dock.classList.toggle("is-shown", isShown);
      dock.setAttribute("aria-hidden", isShown ? "false" : "true");
      dock.querySelector("a").tabIndex = isShown ? 0 : -1;
    }
    window.addEventListener("scroll", update, { passive: true });
    update();
  }

  playHeroDemo();
  bindStory();
  bindPhoneTilt();
  bindAppDock();
})();
