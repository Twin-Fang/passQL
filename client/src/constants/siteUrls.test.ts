// @vitest-environment node
/// <reference types="node" />
// 운영 주소 사본 일치 검사 (#462): vercel.json·public/legal·index.html <-> siteUrls.ts
import { describe, expect, it } from "vitest";
import { readFileSync } from "node:fs";
import { join } from "node:path";
import { PRODUCTION_SITE_URL, PUBLIC_LEGAL_PAGE_FILES, PUBLIC_LEGAL_SITE_URL } from "./siteUrls";

const CLIENT_ROOT = process.cwd();

interface VercelRedirect {
  readonly source: string;
  readonly destination: string;
}

describe("운영 주소 단일 원본", () => {
  it.each(PUBLIC_LEGAL_PAGE_FILES)("/legal/%s 는 GitHub Pages 약관으로 이동한다", (legalPageFile) => {
    const publicLegalPageUrl = `${PUBLIC_LEGAL_SITE_URL}/${legalPageFile}`;

    // Vercel 리다이렉트 (운영)
    const vercelConfig = JSON.parse(readFileSync(join(CLIENT_ROOT, "vercel.json"), "utf-8")) as {
      redirects: readonly VercelRedirect[];
    };
    expect(vercelConfig.redirects).toContainEqual(
      expect.objectContaining({ source: `/legal/${legalPageFile}`, destination: publicLegalPageUrl }),
    );

    // 정적 파일 meta refresh (그 외 호스팅)
    const redirectPage = readFileSync(join(CLIENT_ROOT, "public/legal", legalPageFile), "utf-8");
    expect(redirectPage).toContain(`url=${publicLegalPageUrl}"`);
  });

  it("robots.txt·sitemap.xml 은 운영 주소를 가리킨다 (#505)", () => {
    const robotsText = readFileSync(join(CLIENT_ROOT, "public/robots.txt"), "utf-8");
    expect(robotsText).toContain(`Sitemap: ${PRODUCTION_SITE_URL}/sitemap.xml`);
    const sitemapXml = readFileSync(join(CLIENT_ROOT, "public/sitemap.xml"), "utf-8");
    expect(sitemapXml).toContain(`<loc>${PRODUCTION_SITE_URL}/</loc>`);
  });

  it("index.html 은 운영 주소를 직접 쓰지 않고 자리표시자로 받는다", () => {
    const indexHtml = readFileSync(join(CLIENT_ROOT, "index.html"), "utf-8");
    expect(indexHtml).not.toContain(PRODUCTION_SITE_URL);
    expect(indexHtml).toContain("%PASSQL_SITE_URL%/og-image.png");
  });
});
