import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';

import '../../../core/exam_answer/exam_answer_score_report.dart';
import '../../../core/exam_answer/exam_answer_share_link.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/share/app_share_sheet.dart';
import '../../design/design.dart';
import '../common/app_toast.dart';
import 'exam_answer_share_card.dart';
import 'exam_answer_status_styles.dart';

/// 결과 공유 시트: 카드 미리보기 > 점수 공개 스위치 > 이미지로 공유 (시스템 공유 창, 글 + 회차 링크)
Future<void> showExamAnswerShareSheet(
  BuildContext context, {
  required String certType,
  required int roundNumber,
  required String roundTitle,
  required ExamAnswerScoreReport report,
}) => showPassqlSheet<void>(
  context,
  title: '결과 공유',
  builder: (_) => _ShareSheetBody(
    certType: certType,
    roundNumber: roundNumber,
    roundTitle: roundTitle,
    report: report,
  ),
);

class _ShareSheetBody extends StatefulWidget {
  const _ShareSheetBody({
    required this.certType,
    required this.roundNumber,
    required this.roundTitle,
    required this.report,
  });

  final String certType;
  final int roundNumber;
  final String roundTitle;
  final ExamAnswerScoreReport report;

  @override
  State<_ShareSheetBody> createState() => _ShareSheetBodyState();
}

class _ShareSheetBodyState extends State<_ShareSheetBody> {
  final GlobalKey _cardBoundaryKey = GlobalKey();
  final GlobalKey _shareButtonKey = GlobalKey();
  bool _isScorePublic = true;
  bool _isSharing = false;

  // 저장 이미지 배율 (카드 320pt > 960px)
  static const double _imagePixelRatio = 3;
  // 로그 접두사
  static const String _logTag = 'exam answer share';

  /// 공유: 카드 > PNG > 시스템 공유 창 (실패 시 토스트)
  Future<void> _share() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);
    try {
      final boundary =
          _cardBoundaryKey.currentContext!.findRenderObject()!
              as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: _imagePixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (byteData == null) throw StateError('png encoding returned null');
      await AppShareSheet.sharePngImage(
        pngBytes: byteData.buffer.asUint8List(),
        fileName:
            'passql_${widget.certType.toLowerCase()}_${widget.roundNumber}_result.png',
        text: _shareText(),
        originRect: _shareButtonRect(),
      );
    } catch (exception) {
      AppLogger.warn(_logTag, 'failed : $exception');
      if (mounted) showAppToast(context, '공유하지 못했어요');
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  /// 공유 글: 회차 + 판정(+ 점수) + 회차 링크
  String _shareText() {
    final report = widget.report;
    final scoreText = _isScorePublic ? ' ${report.totalScore}점' : '';
    final link = ExamAnswerShareLink.roundPageOf(
      widget.certType,
      widget.roundNumber,
    );
    return '${widget.roundTitle} 가채점 결과: ${report.passStatus.label}$scoreText\n'
        '나도 가채점해 보기 $link';
  }

  // iPad 공유 창 위치 (공유 버튼 영역)
  Rect? _shareButtonRect() {
    final renderBox =
        _shareButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return null;
    return renderBox.localToGlobal(Offset.zero) & renderBox.size;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        PassqlSpacing.md,
        0,
        PassqlSpacing.md,
        PassqlSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: RepaintBoundary(
              key: _cardBoundaryKey,
              child: ExamAnswerShareCard(
                roundTitle: widget.roundTitle,
                report: widget.report,
                isScorePublic: _isScorePublic,
              ),
            ),
          ),
          const SizedBox(height: PassqlSpacing.lg),
          PassqlListRow(
            title: '점수 공개',
            subtitle: '끄면 합격 예상 여부만 보여요',
            hasHorizontalPadding: false,
            trailing: CupertinoSwitch(
              value: _isScorePublic,
              activeTrackColor: colors.accent,
              onChanged: (isPublic) =>
                  setState(() => _isScorePublic = isPublic),
            ),
          ),
          const SizedBox(height: PassqlSpacing.md),
          PassqlButton(
            key: _shareButtonKey,
            label: '이미지로 공유',
            icon: CupertinoIcons.share,
            isLoading: _isSharing,
            onPressed: _share,
          ),
        ],
      ),
    );
  }
}
