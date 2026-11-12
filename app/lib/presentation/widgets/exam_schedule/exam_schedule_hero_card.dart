import 'package:flutter/widgets.dart';

import '../../../core/utils/date_format.dart';
import '../../../core/utils/exam_dday.dart';
import '../../../data/models/exam/exam_schedule_response.dart';
import '../../design/design.dart';
import 'exam_schedule_labels.dart';

/// 다음 시험 카드 (#991 B안): 회차·날짜·D-day > 단계 칩 > 가로 단계 4개 > 단계별 버튼
/// 버튼: 접수 중 "공식 사이트에서 접수하기 ›", 수험표·시험 대기 "시험 전 모의고사 풀기", 그 외 없음
class ExamScheduleHeroCard extends StatelessWidget {
  const ExamScheduleHeroCard({
    super.key,
    required this.schedule,
    required this.today,
    required this.onApplyPressed,
    required this.onMockExamPressed,
  });

  final ExamScheduleResponse schedule;
  final DateTime today;
  final VoidCallback onApplyPressed;
  final VoidCallback onMockExamPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final examDate = parseExamScheduleDate(schedule.examDate);
    final dday = examDdayLabel(daysUntilExam(schedule.examDate, now: today));
    final chip = examPhaseChipOf(schedule, today);
    final action = _actionOf(schedule.phase);
    return PassqlCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 머리 (회차·날짜·단계 칩 | D-day)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '다음 시험 · 제${schedule.round}회 ${schedule.certType}',
                      style: PassqlTypography.subheadlineSemibold.copyWith(
                        color: colors.secondaryLabel,
                      ),
                    ),
                    Text(
                      examDate == null
                          ? schedule.examDate
                          : formatCompactDottedMonthDayWeekday(examDate),
                      style: PassqlTypography.title2.copyWith(
                        color: colors.label,
                      ),
                    ),
                    if (chip != null) ...[
                      const SizedBox(height: PassqlSpacing.xs),
                      _ExamPhaseChip(chip: chip),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: PassqlSpacing.xs),
              Text(
                dday,
                style: PassqlTypography.title1.copyWith(
                  color: colors.accentText,
                  fontFeatures: PassqlTypography.tabular,
                ),
              ),
            ],
          ),
          const SizedBox(height: PassqlSpacing.md),
          _ExamStepTrack(schedule: schedule),
          if (action != null) ...[
            const SizedBox(height: PassqlSpacing.md),
            PassqlButton(
              label: action.label,
              variant: action.variant,
              onPressed: action.isApply ? onApplyPressed : onMockExamPressed,
            ),
          ],
        ],
      ),
    );
  }

  /// 단계 > 버튼 (없으면 null)
  static ({String label, PassqlButtonVariant variant, bool isApply})? _actionOf(
    ExamSchedulePhase phase,
  ) => switch (phase) {
    ExamSchedulePhase.applicationOpen => (
      label: '공식 사이트에서 접수하기 ›',
      variant: PassqlButtonVariant.filled,
      isApply: true,
    ),
    ExamSchedulePhase.waitingAdmissionTicket ||
    ExamSchedulePhase.waitingExam => (
      label: '시험 전 모의고사 풀기',
      variant: PassqlButtonVariant.tinted,
      isApply: false,
    ),
    _ => null,
  };
}

/// 단계 칩: 옅은 의미색 캡슐 + 깜빡이는 점 + 문구 (접수 중은 주황, 그 외 강조색)
class _ExamPhaseChip extends StatelessWidget {
  const _ExamPhaseChip({required this.chip});

  final ExamPhaseChip chip;

  // 칩 위아래 여백 (PassqlBadge 와 같은 캡슐 높이)
  static const double _verticalPadding = 3;

  @override
  Widget build(BuildContext context) {
    final (fillTone, textTone) = PassqlBadge.tonesOf(
      chip.isUrgent ? PassqlBadgeKind.warning : PassqlBadgeKind.topic,
      context.passqlColors,
    );
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PassqlSpacing.xs,
        vertical: _verticalPadding,
      ),
      decoration: BoxDecoration(
        color: fillTone.withValues(alpha: PassqlBadge.backgroundAlpha),
        borderRadius: BorderRadius.circular(PassqlRadius.capsule),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _BreathingOpacity(
            child: Container(
              width: PassqlSize.examPhaseDot,
              height: PassqlSize.examPhaseDot,
              decoration: BoxDecoration(
                color: textTone,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: PassqlSpacing.xxs),
          Flexible(
            child: Text(
              chip.text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: PassqlTypography.captionSemibold.copyWith(color: textTone),
            ),
          ),
        ],
      ),
    );
  }
}

/// 가로 단계 4개(접수·수험표·시험·발표): 지난 단계 채움, 지금 단계 숨쉬는 테두리, 진행선
class _ExamStepTrack extends StatelessWidget {
  const _ExamStepTrack({required this.schedule});

  final ExamScheduleResponse schedule;

  static const int _stepCount = 4;
  // 지금 단계 점 테두리 두께
  static const double _currentRingWidth = 3;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final progress = examStepProgressOf(schedule.phase);
    final steps = _stepsOf(schedule);
    // 진행선: 첫 점 가운데 ~ 지난 단계 마지막 점 가운데
    final filledFraction = (progress.completedStepCount / (_stepCount - 1))
        .clamp(0.0, 1.0);
    return ExcludeSemantics(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stepWidth = constraints.maxWidth / _stepCount;
          final lineWidth = stepWidth * (_stepCount - 1);
          return Stack(
            children: [
              Positioned(
                left: stepWidth / 2,
                top: (PassqlSize.examStepDot - PassqlSize.examStepLine) / 2,
                width: lineWidth,
                height: PassqlSize.examStepLine,
                child: ColoredBox(
                  color: colors.fill,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: filledFraction,
                      heightFactor: 1,
                      child: ColoredBox(color: colors.accent),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  for (var index = 0; index < _stepCount; index++)
                    Expanded(
                      child: _buildStep(
                        colors,
                        name: steps[index].name,
                        date: steps[index].date,
                        isDone: index < progress.completedStepCount,
                        isCurrent: index == progress.currentStepIndex,
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  /// 단계 한 칸: 점 > 이름 > 날짜
  Widget _buildStep(
    PassqlColors colors, {
    required String name,
    required String date,
    required bool isDone,
    required bool isCurrent,
  }) {
    final isReached = isDone || isCurrent;
    final Widget dot;
    if (isCurrent) {
      dot = _BreathingHalo(
        color: colors.accentTint,
        child: Container(
          width: PassqlSize.examStepDot,
          height: PassqlSize.examStepDot,
          decoration: BoxDecoration(
            color: colors.card,
            shape: BoxShape.circle,
            border: Border.all(color: colors.accent, width: _currentRingWidth),
          ),
        ),
      );
    } else {
      dot = Container(
        width: PassqlSize.examStepDot,
        height: PassqlSize.examStepDot,
        decoration: BoxDecoration(
          color: isDone ? colors.accent : colors.fill,
          shape: BoxShape.circle,
        ),
      );
    }
    return Column(
      children: [
        dot,
        const SizedBox(height: PassqlSpacing.xxs),
        Text(
          name,
          style: PassqlTypography.captionSemibold.copyWith(
            color: isReached ? colors.label : colors.secondaryLabel,
          ),
        ),
        Text(
          date,
          maxLines: 1,
          style: PassqlTypography.caption.copyWith(
            color: colors.secondaryLabel,
            fontFeatures: PassqlTypography.tabular,
          ),
        ),
      ],
    );
  }

  /// 단계 4개 이름·날짜 (날짜 모르면 '-')
  static List<({String name, String date})> _stepsOf(
    ExamScheduleResponse schedule,
  ) {
    String dayText(String? value) {
      final date = parseExamScheduleDate(value);
      return date == null ? '-' : formatCompactDottedMonthDay(date);
    }

    final applicationStart = parseExamScheduleDate(
      schedule.applicationStartDate,
    );
    final applicationEnd = parseExamScheduleDate(schedule.applicationEndDate);
    final applicationText = applicationStart != null && applicationEnd != null
        ? formatCompactDottedDateRange(applicationStart, applicationEnd)
        : dayText(schedule.applicationStartDate);
    return [
      (name: '접수', date: applicationText),
      (name: '수험표', date: dayText(schedule.admissionTicketDate)),
      (name: '시험', date: dayText(schedule.examDate)),
      (name: '발표', date: dayText(schedule.resultAnnouncementDate)),
    ];
  }
}

/// 숨쉬기 반복 컨트롤러 공통: 동작 줄이기면 가운데 값으로 멈춤
mixin _BreathingController<T extends StatefulWidget>
    on State<T>, SingleTickerProviderStateMixin<T> {
  late final AnimationController breathController = AnimationController(
    vsync: this,
    duration: PassqlMotion.segmentBreathePeriod,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (PassqlMotion.isReduced(context)) {
      breathController.stop();
      breathController.value = 0.5;
    } else if (!breathController.isAnimating) {
      breathController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    breathController.dispose();
    super.dispose();
  }
}

/// 깜빡이는 점 (불투명도 1 <-> 0.3)
class _BreathingOpacity extends StatefulWidget {
  const _BreathingOpacity({required this.child});

  final Widget child;

  @override
  State<_BreathingOpacity> createState() => _BreathingOpacityState();
}

class _BreathingOpacityState extends State<_BreathingOpacity>
    with SingleTickerProviderStateMixin, _BreathingController {
  static const double _minOpacity = 0.3;

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: Tween(begin: 1.0, end: _minOpacity).animate(breathController),
    child: widget.child,
  );
}

/// 지금 단계 점 둘레로 퍼졌다 줄어드는 옅은 빛 (0 <-> 6)
class _BreathingHalo extends StatefulWidget {
  const _BreathingHalo({required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  State<_BreathingHalo> createState() => _BreathingHaloState();
}

class _BreathingHaloState extends State<_BreathingHalo>
    with SingleTickerProviderStateMixin, _BreathingController {
  // 빛 최대 번짐 폭
  static const double _maxSpread = 6;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: breathController,
    child: widget.child,
    builder: (_, child) => DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: widget.color,
            spreadRadius: _maxSpread * breathController.value,
          ),
        ],
      ),
      child: child,
    ),
  );
}
