import { useEffect, useState } from "react";
import { fetchCommunityImageBlob } from "../api/community";
import type { CommunityImageSize } from "../api/community";
import { useAuthStore } from "../stores/authStore";
import { useMemberQueryScope } from "./useMemberQueryScope";

// 회원 + 이미지 + 크기 > object URL (진행 중 요청은 Promise 로 공유해 같은 이미지를 한 번만 받음)
const objectUrlPromiseByKey = new Map<string, Promise<string>>();
let cachedMemberUuid: string | null = useAuthStore.getState().memberUuid;

function revokeAllCachedObjectUrls(): void {
  for (const objectUrlPromise of objectUrlPromiseByKey.values()) {
    void objectUrlPromise.then((objectUrl) => URL.revokeObjectURL(objectUrl)).catch(() => {});
  }
  objectUrlPromiseByKey.clear();
}

// 회원 전환·로그아웃 시 이전 회원 이미지 비움
useAuthStore.subscribe((state) => {
  if (state.memberUuid === cachedMemberUuid) return;
  cachedMemberUuid = state.memberUuid;
  revokeAllCachedObjectUrls();
});

function loadObjectUrl(memberUuid: string, imageUuid: string, size: CommunityImageSize): Promise<string> {
  const cacheKey = `${memberUuid}:${imageUuid}:${size}`;
  const cachedPromise = objectUrlPromiseByKey.get(cacheKey);
  if (cachedPromise) return cachedPromise;

  const objectUrlPromise = fetchCommunityImageBlob(imageUuid, size).then((blob) => URL.createObjectURL(blob));
  objectUrlPromiseByKey.set(cacheKey, objectUrlPromise);
  // 실패는 캐시하지 않아 다음 마운트에서 재시도
  objectUrlPromise.catch(() => objectUrlPromiseByKey.delete(cacheKey));
  return objectUrlPromise;
}

interface CommunityImageUrlState {
  readonly requestKey: string;
  readonly objectUrl: string | null;
  readonly isFailed: boolean;
}

/** 인증 이미지 > object URL (캐시 공유, 회원 전환 시 revoke). 로딩 중 objectUrl null */
export function useCommunityImageUrl(imageUuid: string, size: CommunityImageSize) {
  const { memberUuid, isMemberQueryEnabled } = useMemberQueryScope();
  const requestKey = `${memberUuid}:${imageUuid}:${size}`;
  const [state, setState] = useState<CommunityImageUrlState>({ requestKey, objectUrl: null, isFailed: false });

  useEffect(() => {
    if (!isMemberQueryEnabled || memberUuid === null) return;
    let isCancelled = false;
    loadObjectUrl(memberUuid, imageUuid, size)
      .then((objectUrl) => !isCancelled && setState({ requestKey, objectUrl, isFailed: false }))
      .catch(() => !isCancelled && setState({ requestKey, objectUrl: null, isFailed: true }));
    return () => {
      isCancelled = true;
    };
  }, [isMemberQueryEnabled, memberUuid, imageUuid, size, requestKey]);

  // 다른 이미지로 바뀐 직후 이전 결과를 쓰지 않음
  const isCurrent = state.requestKey === requestKey;
  return { objectUrl: isCurrent ? state.objectUrl : null, isFailed: isCurrent && state.isFailed };
}
