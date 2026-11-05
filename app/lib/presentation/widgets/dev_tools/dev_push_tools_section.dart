import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/push/dev_simulated_push_messaging_client.dart';
import '../../../core/push/push_link.dart';
import '../../design/design.dart';
import '../../providers/home_providers.dart';

/// 흉내 알림 받는 방식 2종: 앱 사용 중 수신(토스트 + '보기'), 시스템 알림 탭(바로 이동)
enum DevPushDelivery {
  foreground('앱 사용 중 받기'),
  opened('알림 탭으로 열기');

  const DevPushDelivery(this.label);

  final String label;
}

/// 개발자 도구 푸시 알림 테스트 (#819): 이동 화면 5종마다 흉내 알림 1건
/// 실제 수신·탭 스트림에 끼워 넣어 실제 알림과 같은 토스트·이동 경로를 탐 (서버 발송·알림함 기록 없음)
class DevPushToolsSection extends ConsumerStatefulWidget {
  const DevPushToolsSection({super.key});

  @override
  ConsumerState<DevPushToolsSection> createState() =>
      _DevPushToolsSectionState();
}

class _DevPushToolsSectionState extends ConsumerState<DevPushToolsSection> {
  DevPushDelivery _delivery = DevPushDelivery.foreground;

  /// 이동 화면 > 표시 이름 (서버 PushLinkTarget 라벨과 같은 문구)
  static String _labelOf(PushLinkTarget target) => switch (target) {
    PushLinkTarget.home => '홈',
    PushLinkTarget.dailySet => '오늘의 세트',
    PushLinkTarget.questions => '문제 탭',
    PushLinkTarget.questionDetail => '문제 상세',
    PushLinkTarget.stats => '통계',
  };

  /// 시트 닫기 > 흉내 알림 1건 (받는 방식에 따라 수신 또는 탭)
  void _firePush(PushLink link) {
    Navigator.of(context).pop();
    switch (_delivery) {
      case DevPushDelivery.foreground:
        final label = _labelOf(link.target);
        DevSimulatedPushMessagingClient.simulateForegroundMessage(
          ReceivedPushMessage(
            title: '[테스트] $label 알림',
            body: '보기를 누르면 $label 화면으로 이동해요',
            link: link,
          ),
        );
      case DevPushDelivery.opened:
        DevSimulatedPushMessagingClient.simulateOpenedLink(link);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 문제 상세용 문제: 오늘의 세트 첫 문제 (전 회원 공통, 홈 학습 묶음에서 읽음)
    final sampleQuestionUuid = ref.watch(
      homeLearningStatusProvider.select(
        (status) =>
            status.valueOrNull?.dailySet?.questions.firstOrNull?.questionUuid,
      ),
    );
    return PassqlGroupedSection(
      header: '푸시 알림 테스트',
      footer:
          '앱 안에서만 흉내 내요 (시스템 알림 배너·서버 발송·알림함 기록 없음). '
          '알림 탭으로 열기는 실제 알림을 눌렀을 때와 같은 이동이에요',
      children: [
        Padding(
          padding: const EdgeInsets.all(PassqlSpacing.sm),
          child: PassqlSegmentedControl<DevPushDelivery>(
            segments: [
              for (final delivery in DevPushDelivery.values)
                PassqlSegment(value: delivery, label: delivery.label),
            ],
            selectedValue: _delivery,
            onSelected: (delivery) => setState(() => _delivery = delivery),
          ),
        ),
        for (final target in PushLinkTarget.values)
          _buildTargetRow(target, sampleQuestionUuid),
      ],
    );
  }

  /// 이동 화면 1종 행 (문제 상세는 오늘의 세트 문제를 모르면 누를 수 없음)
  Widget _buildTargetRow(PushLinkTarget target, String? sampleQuestionUuid) {
    final isQuestionDetail = target == PushLinkTarget.questionDetail;
    final link = !isQuestionDetail
        ? PushLink(target)
        : sampleQuestionUuid == null
        ? null
        : PushLink(target, questionUuid: sampleQuestionUuid);
    return PassqlListRow(
      title: '${_labelOf(target)} 알림',
      subtitle: link == null ? '오늘의 세트를 불러온 뒤 쓸 수 있어요' : null,
      hasChevron: link != null,
      onTap: link == null ? null : () => _firePush(link),
    );
  }
}
