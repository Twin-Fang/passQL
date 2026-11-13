import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../design/design.dart';

/// 잠금화면 미니 폰 그림 (소개 시트·홈 카드): 잠금 화면(시계) 위로 문제 화면이 올라왔다 내려가는 반복
/// 동작 줄이기면 문제 화면이 올라온 상태로 멈춤. 장식이라 스크린리더에서 제외
class LockScreenPhoneIllustration extends StatefulWidget {
  const LockScreenPhoneIllustration({super.key, this.width = sheetWidth});

  /// 소개 시트 크기, 홈 카드 크기 (폭, 높이는 폭 비율)
  static const double sheetWidth = 96;
  static const double cardWidth = 58;

  final double width;

  @override
  State<LockScreenPhoneIllustration> createState() =>
      _LockScreenPhoneIllustrationState();
}

class _LockScreenPhoneIllustrationState
    extends State<LockScreenPhoneIllustration> {
  // 폰 비율·테두리·모서리·안쪽 여백 (폭 기준 비율)
  static const double _heightRatio = 1.75;
  static const double _frameRatio = 0.05;
  static const double _cornerRatio = 0.2;
  static const double _paddingRatio = 0.08;

  Timer? _loopTimer;
  bool _isQuestionShown = false;

  @override
  void initState() {
    super.initState();
    _loopTimer = Timer.periodic(
      PassqlMotion.lockScreenIllustrationStep,
      (_) => setState(() => _isQuestionShown = !_isQuestionShown),
    );
  }

  @override
  void dispose() {
    _loopTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final width = widget.width;
    final isReduced = PassqlMotion.isReduced(context);
    final isQuestionShown = isReduced || _isQuestionShown;
    return ExcludeSemantics(
      child: Container(
        width: width,
        height: width * _heightRatio,
        decoration: BoxDecoration(
          color: colors.label,
          border: Border.all(color: colors.label, width: width * _frameRatio),
          borderRadius: BorderRadius.circular(width * _cornerRatio),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(
            width * (_cornerRatio - _frameRatio),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 잠금 화면: 큰 시계
              Align(
                alignment: const Alignment(0, -0.55),
                child: Text(
                  '9:41',
                  style: PassqlTypography.headline.copyWith(
                    color: colors.background,
                    fontSize: width * 0.2,
                  ),
                ),
              ),
              // 문제 화면: 아래에서 올라옴
              AnimatedSlide(
                offset: isQuestionShown ? Offset.zero : const Offset(0, 1),
                duration: PassqlMotion.durationOf(
                  context,
                  PassqlMotion.emphasized,
                ),
                curve: PassqlMotion.curve,
                child: _MiniQuestionScreen(padding: width * _paddingRatio),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 미니 문제 화면: 알약 > 지문 줄 > 보기 4줄(하나는 정답색)
class _MiniQuestionScreen extends StatelessWidget {
  const _MiniQuestionScreen({required this.padding});

  final double padding;

  // 보기 줄 수와 정답 줄 순서
  static const int _choiceCount = 4;
  static const int _correctChoiceIndex = 1;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final lineHeight = padding * 1.3;
    final radius = BorderRadius.circular(padding * 0.5);
    return ColoredBox(
      color: colors.background,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: padding * 3,
                height: lineHeight * 0.8,
                decoration: BoxDecoration(
                  color: colors.accentTint,
                  borderRadius: BorderRadius.circular(PassqlRadius.capsule),
                ),
              ),
            ),
            SizedBox(height: padding),
            Container(
              height: lineHeight * 2,
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: radius,
              ),
            ),
            for (var index = 0; index < _choiceCount; index++) ...[
              SizedBox(height: padding * 0.6),
              Container(
                height: lineHeight,
                decoration: BoxDecoration(
                  color: index == _correctChoiceIndex
                      ? colors.correctTint
                      : colors.card,
                  border: index == _correctChoiceIndex
                      ? Border.all(color: colors.correct)
                      : null,
                  borderRadius: radius,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
