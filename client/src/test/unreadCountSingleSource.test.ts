// @vitest-environment node
/// <reference types="node" />
// 규칙 (#491): 안 읽은 개수 조회는 useUnreadNotificationCount 한 곳에서만
import { describe, expect, it } from "vitest";
import { readFileSync, readdirSync, statSync } from "node:fs";
import { join, relative } from "node:path";

const SOURCE_ROOT = join(process.cwd(), "src");
// 호출 정의(api)와 유일한 사용처(hook)
const ALLOWED_FILES = new Set(["api/notifications.ts", "hooks/useUnreadNotificationCount.ts"]);

function listSourceFiles(directory: string): string[] {
  return readdirSync(directory).flatMap((entryName) => {
    const entryPath = join(directory, entryName);
    if (statSync(entryPath).isDirectory()) return listSourceFiles(entryPath);
    return /\.tsx?$/.test(entryName) && !/\.test\.tsx?$/.test(entryName) ? [entryPath] : [];
  });
}

describe("안 읽은 개수 단일 출처", () => {
  it("fetchUnreadNotificationCount·unread-count 경로는 허용 파일에서만 등장", () => {
    const violations = listSourceFiles(SOURCE_ROOT)
      .map((filePath) => relative(SOURCE_ROOT, filePath))
      .filter((relativePath) => !ALLOWED_FILES.has(relativePath))
      .filter((relativePath) => /fetchUnreadNotificationCount|unread-count/.test(readFileSync(join(SOURCE_ROOT, relativePath), "utf-8")));
    expect(violations).toEqual([]);
  });
});
