// 약관·개인정보처리방침 공개 페이지 공용 스크립트 (#403)
// 원본은 서버 DB(관리자 /admin/legal) 하나뿐이다. 이 페이지는 API 본문으로 덮어써서
// 앱·웹 모달·공개 URL이 같은 글을 보여 주게 한다.
// HTML 안의 본문은 JS 미실행 크롤러(스토어 검수 봇 등)와 API 장애 대비용 사본이다.
(function () {
  // public 정적 파일은 Vite env를 못 받으므로 운영 API 주소를 고정한다.
  // CORS 허용 오리진: passql.vercel.app, passql-*.vercel.app (SecurityConfig)
  var API_BASE = "https://api.passql.suhsaechan.kr/api";

  var body = document.getElementById("legal-body");
  var status = document.getElementById("legal-status");
  if (!body || !status) return;
  var type = body.getAttribute("data-legal-type");

  function escapeHtml(text) {
    return text
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;");
  }

  // 관리자가 쓰는 범위(제목·문단·목록·굵게)만 지원하는 최소 마크다운 변환.
  // 이스케이프 후 변환하므로 DB 본문에 HTML이 섞여도 실행되지 않는다.
  function inline(text) {
    return escapeHtml(text).replace(/\*\*(.+?)\*\*/g, "<strong>$1</strong>");
  }

  function renderMarkdown(markdown) {
    var html = [];
    var paragraph = [];
    var list = [];
    function flush() {
      if (paragraph.length) html.push("<p>" + paragraph.join("<br>") + "</p>");
      if (list.length) html.push("<ul>" + list.join("") + "</ul>");
      paragraph = [];
      list = [];
    }
    markdown.split(/\r?\n/).forEach(function (raw) {
      var line = raw.trim();
      var heading = /^(#{1,3})\s+(.*)$/.exec(line);
      var item = /^[-*]\s+(.*)$/.exec(line);
      if (!line) {
        flush();
      } else if (heading) {
        flush();
        // 페이지 h1은 문서 제목이 쓰므로 본문 제목은 h2부터 시작한다.
        var level = Math.max(2, heading[1].length);
        html.push("<h" + level + ">" + inline(heading[2]) + "</h" + level + ">");
      } else if (item) {
        if (paragraph.length) flush();
        list.push("<li>" + inline(item[1]) + "</li>");
      } else {
        if (list.length) flush();
        paragraph.push(inline(line));
      }
    });
    flush();
    return html.join("");
  }

  function showError() {
    status.innerHTML =
      '최신 원문을 불러오지 못해 저장된 사본을 표시하고 있습니다. ' +
      '<button type="button" id="legal-retry">다시 시도</button>';
    status.hidden = false;
    document.getElementById("legal-retry").addEventListener("click", load);
  }

  function load() {
    status.hidden = true;
    fetch(API_BASE + "/meta/legal/" + type, { headers: { Accept: "application/json" } })
      .then(function (res) {
        if (!res.ok) throw new Error("HTTP " + res.status);
        return res.json();
      })
      .then(function (data) {
        if (!data || typeof data.content !== "string" || !data.content.trim()) {
          throw new Error("empty content");
        }
        body.innerHTML = renderMarkdown(data.content);
        if (data.title) {
          document.getElementById("legal-title").textContent = data.title;
          document.title = data.title + " - passQL";
        }
      })
      .catch(showError);
  }

  load();
})();
