import type { StoredAuthTokens } from "../stores/authStore";

/*
 * access token 재발급 조율 (#881): 탭 안 단일 비행 > 탭 간 잠금 > 잠금 안 저장값 재확인 > 필요할 때만 재발급
 * 회전된 refresh token 재사용 = 서버가 탈취로 보고 전 기기 세션 폐기 (DEC-0144) > 탭 여러 개여도 한 번만 보냄
 */

export interface AuthTokens {
  readonly accessToken: string;
  readonly refreshToken: string;
}

// 결과 3종: 새로 재발급 / 다른 요청·탭이 이미 재발급한 최신 토큰 재사용 / 다른 탭에서 로그아웃됨
export type AccessTokenReissueOutcome =
  | { readonly kind: "reissued" | "reusedLatest"; readonly accessToken: string }
  | { readonly kind: "signedOut" };

export interface AccessTokenReissueDependencies {
  // 저장소(탭 공유) 최신 토큰 > 메모리 반영 후 반환
  readonly readLatestStoredTokens: () => StoredAuthTokens;
  readonly requestRotatedTokens: (refreshToken: string) => Promise<AuthTokens>;
  readonly saveRotatedTokens: (tokens: AuthTokens) => void;
  readonly runExclusivelyAcrossTabs: <T>(task: () => Promise<T>) => Promise<T>;
}

export interface AccessTokenReissueCoordinator {
  // 거절된 요청이 보낸 access token > 재시도용 access token 확보 (실패 응답은 그대로 throw)
  readonly resolveAccessToken: (rejectedAccessToken: string | null) => Promise<AccessTokenReissueOutcome>;
}

// 브라우저 탭 간 잠금 이름 (같은 출처 탭끼리만 공유)
const ACCESS_TOKEN_REISSUE_LOCK_NAME = "passql-access-token-reissue";

/**
 * 탭 간 배타 실행: Web Locks 지원 > 잠금 획득 후 실행 / 미지원 > 바로 실행
 * 미지원 브라우저는 탭 안 단일 비행 + 잠금 자리의 저장값 재확인까지만 보장
 */
export function runWithAccessTokenReissueLock<T>(task: () => Promise<T>): Promise<T> {
  const lockManager = typeof navigator === "undefined" ? undefined : navigator.locks;
  if (!lockManager?.request) return task();
  return lockManager.request(ACCESS_TOKEN_REISSUE_LOCK_NAME, task);
}

export function createAccessTokenReissueCoordinator(
  dependencies: AccessTokenReissueDependencies,
): AccessTokenReissueCoordinator {
  // 진행 중 재발급 1건 (같은 탭 동시 401 이 같은 결과를 기다림)
  let reissueInFlight: Promise<AccessTokenReissueOutcome> | null = null;

  /** 잠금 안: 저장값 재확인 > 로그아웃됨 / 이미 바뀜 / 재발급 1회 */
  const reissueUnderLock = (rejectedAccessToken: string | null) =>
    dependencies.runExclusivelyAcrossTabs(async (): Promise<AccessTokenReissueOutcome> => {
      const latestTokens = dependencies.readLatestStoredTokens();
      if (!latestTokens.refreshToken) return { kind: "signedOut" };

      // 거절된 토큰과 다르면 다른 요청·탭이 이미 회전 > 옛 refresh token 을 보내지 않음
      const latestAccessToken = latestTokens.accessToken;
      if (latestAccessToken !== null && latestAccessToken !== rejectedAccessToken) {
        return { kind: "reusedLatest", accessToken: latestAccessToken };
      }

      const rotatedTokens = await dependencies.requestRotatedTokens(latestTokens.refreshToken);
      dependencies.saveRotatedTokens(rotatedTokens);
      return { kind: "reissued", accessToken: rotatedTokens.accessToken };
    });

  return {
    resolveAccessToken: (rejectedAccessToken) => {
      reissueInFlight ??= reissueUnderLock(rejectedAccessToken).finally(() => {
        reissueInFlight = null;
      });
      return reissueInFlight;
    },
  };
}
