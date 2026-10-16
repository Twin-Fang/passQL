import { useEffect } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { fetchMe, regenerateNickname, checkNickname, changeNickname, updateChoiceGenerationMode } from "../api/members";
import { useAuthStore } from "../stores/authStore";
import { useMemberQueryScope } from "./useMemberQueryScope";
import type { NicknameCheckResponse, NicknameChangeResponse, ChoiceGenerationMode } from "../types/api";

export function useMember() {
  const { memberUuid, isMemberQueryEnabled } = useMemberQueryScope();
  const setNickname = useAuthStore((s) => s.setNickname);

  const query = useQuery({
    queryKey: ["member", memberUuid],
    queryFn: fetchMe,
    enabled: isMemberQueryEnabled,
    staleTime: 1000 * 60 * 10,
    retry: false,
  });

  // 서버 닉네임 > 스토어 동기화 (렌더 중 setState 금지라 effect 에서)
  const fetchedNickname = query.data?.nickname;
  useEffect(() => {
    if (fetchedNickname && fetchedNickname !== useAuthStore.getState().nickname) {
      setNickname(fetchedNickname);
    }
  }, [fetchedNickname, setNickname]);

  return query;
}

export function useRegenerateNickname() {
  const queryClient = useQueryClient();
  const setNickname = useAuthStore((s) => s.setNickname);

  return useMutation({
    mutationFn: regenerateNickname,
    onSuccess: (result) => {
      setNickname(result.nickname);
      queryClient.invalidateQueries({ queryKey: ["member"] });
    },
  });
}

// 닉네임 중복 확인 뮤테이션 — 호출 시마다 서버에 요청
export function useCheckNickname() {
  return useMutation<NicknameCheckResponse, Error, string>({
    mutationFn: (nickname: string) => checkNickname(nickname),
  });
}

// 닉네임 변경 뮤테이션 — 성공 시 스토어 동기화 및 쿼리 무효화
export function useChangeNickname() {
  const queryClient = useQueryClient();
  const setNickname = useAuthStore((s) => s.setNickname);

  return useMutation<NicknameChangeResponse, Error, string>({
    mutationFn: (nickname: string) => changeNickname(nickname),
    onSuccess: (result) => {
      setNickname(result.nickname);
      queryClient.invalidateQueries({ queryKey: ["member"] });
    },
  });
}

// 선택지 생성 모드 변경 뮤테이션 — 성공 시 member 쿼리 무효화
export function useUpdateChoiceGenerationMode() {
  const queryClient = useQueryClient();

  return useMutation<
    { choiceGenerationMode: ChoiceGenerationMode },
    Error,
    ChoiceGenerationMode
  >({
    mutationFn: (mode: ChoiceGenerationMode) => updateChoiceGenerationMode(mode),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["member"] });
    },
  });
}
