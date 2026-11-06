// @vitest-environment node
/// <reference types="node" />
// 운영 주소 사본 일치 검사 (#462, #881): siteUrls.ts <-> vercel.json·public/legal·robots·sitemap·index.html·iOS 마케팅 URL·서버 소셜 콜백·CORS
import { describe, expect, it } from "vitest";
import { readFileSync } from "node:fs";
import { join } from "node:path";
import { PRODUCTION_SITE_URL, PUBLIC_LEGAL_PAGE_FILES, PUBLIC_LEGAL_SITE_URL } from "./siteUrls";

const CLIENT_ROOT = process.cwd();
const REPOSITORY_ROOT = join(CLIENT_ROOT, "..");
// 서버 소셜 로그인 웹 콜백 제공자 3개 (인가 코드 로그인)
const SOCIAL_CALLBACK_PROVIDER_PATHS = ["kakao", "naver", "github"] as const;

interface VercelRedirect {
  readonly source: string;
  readonly destination: string;
}

/** 레포 루트 기준 파일 > 문자열 */
function readRepositoryFile(relativePath: string): string {
  return readFileSync(join(REPOSITORY_ROOT, relativePath), "utf-8");
}

describe("운영 주소 단일 원본", () => {
  it.each(PUBLIC_LEGAL_PAGE_FILES)("/legal/%s 는 GitHub Pages 약관으로 이동한다", (legalPageFile) => {
    const publicLegalPageUrl = `${PUBLIC_LEGAL_SITE_URL}/${legalPageFile}`;

    // Vercel 리다이렉트 (운영)
    const vercelConfig = JSON.parse(readRepositoryFile("client/vercel.json")) as {
      redirects: readonly VercelRedirect[];
    };
    expect(vercelConfig.redirects).toContainEqual(
      expect.objectContaining({ source: `/legal/${legalPageFile}`, destination: publicLegalPageUrl }),
    );

    // 정적 파일 meta refresh·canonical (그 외 호스팅)
    const redirectPage = readRepositoryFile(`client/public/legal/${legalPageFile}`);
    expect(redirectPage).toContain(`url=${publicLegalPageUrl}"`);
    expect(redirectPage).toContain(`<link rel="canonical" href="${publicLegalPageUrl}">`);
  });

  it("robots.txt·sitemap.xml 은 운영 주소를 가리킨다 (#505)", () => {
    expect(readRepositoryFile("client/public/robots.txt")).toContain(`Sitemap: ${PRODUCTION_SITE_URL}/sitemap.xml`);
    expect(readRepositoryFile("client/public/sitemap.xml")).toContain(`<loc>${PRODUCTION_SITE_URL}/</loc>`);
  });

  it("index.html 은 운영 주소를 직접 쓰지 않고 자리표시자로 받는다", () => {
    const indexHtml = readRepositoryFile("client/index.html");
    expect(indexHtml).not.toContain(PRODUCTION_SITE_URL);
    expect(indexHtml).toContain("%PASSQL_SITE_URL%/og-image.png");
  });

  it("iOS 스토어 마케팅 URL 은 운영 주소와 같다", () => {
    expect(readRepositoryFile("app/ios/fastlane/marketing_url.txt").trim()).toBe(PRODUCTION_SITE_URL);
  });

  it("서버 소셜 로그인 콜백 허용 목록·CORS 기본값은 운영 주소를 쓴다", () => {
    const serverApplicationConfig = readRepositoryFile("server/PQL-Web/src/main/resources/application.yml");
    for (const providerPath of SOCIAL_CALLBACK_PROVIDER_PATHS) {
      expect(serverApplicationConfig).toContain(`- ${PRODUCTION_SITE_URL}/auth/callback/${providerPath}`);
    }
    const securityConfig = readRepositoryFile("server/PQL-Web/src/main/java/com/passql/web/config/SecurityConfig.java");
    expect(securityConfig).toContain(`cors.allowed-origin-patterns:${PRODUCTION_SITE_URL},`);
  });
});
