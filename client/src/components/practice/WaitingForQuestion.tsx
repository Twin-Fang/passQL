import { getRandomMessage } from "../../constants/microcopy";

interface WaitingForQuestionProps {
  readonly topicName: string;
}

/**
 * 다음 문제 준비 대기: 스피너 + 토픽별 랜덤 문구
 */
export default function WaitingForQuestion({ topicName }: WaitingForQuestionProps) {
  return (
    <div className="flex-1 flex flex-col items-center justify-center gap-4 px-6">
      <div className="w-10 h-10 border-3 border-brand-light border-t-brand rounded-full animate-spin" />
      <p className="text-body text-center">{getRandomMessage(topicName)}</p>
      <p className="text-xs text-text-caption">잠시만 기다려주세요</p>
    </div>
  );
}
