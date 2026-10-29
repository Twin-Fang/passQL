import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/error/app_exception.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/monitoring/crash_reporter.dart';
import '../../../core/validation/feedback_validator.dart';
import '../../../data/feedback/feedback_image_compressor.dart';
import '../../design/design.dart';
import '../../../router/app_routes.dart';
import '../../providers/feedback_providers.dart';
import '../../widgets/common/app_toast.dart';
import '../../widgets/feedback/feedback_content_field.dart';
import '../../widgets/feedback/feedback_diagnostics_check_row.dart';
import '../../widgets/feedback/feedback_diagnostics_sheet.dart';
import '../../widgets/feedback/feedback_image_strip.dart';

const String _successToastMessage = '보내 주셔서 고마워요. 확인까지 2~3일 걸릴 수 있어요';
const String _imageLimitToastMessage = '사진은 최대 ${FeedbackImageLimits.maxImageCount}장까지 보낼 수 있어요';
const String _sendFailedMessage = '의견을 보내지 못했어요. 잠시 후 다시 시도해 주세요.';
const String _imageLoadFailedMessage = '사진을 불러오지 못했어요. 다시 선택해 주세요.';

/// 의견 보내기 화면: 글 + 사진(최대 5장) + 진단 정보 동의를 한 번에 전송
class FeedbackPage extends ConsumerStatefulWidget {
  const FeedbackPage({super.key});

  @override
  ConsumerState<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends ConsumerState<FeedbackPage> {
  final _contentController = TextEditingController();
  final _imagePicker = ImagePicker();
  final _imageCompressor = FeedbackImageCompressor();
  final List<FeedbackImageDraft> _imageDrafts = [];

  bool _isSending = false;
  bool _isOpeningDiagnosticsSheet = false;
  bool _shouldIncludeDiagnostics = true;
  String? _errorMessage;
  int _nextImageId = 0;

  /// 의견 화면 진입 직전 경로 패턴 (쿼리스트링 제외)
  String? _previousRoute;

  @override
  void initState() {
    super.initState();
    _previousRoute = _readPreviousRoutePattern();
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  /// 라우터 스택에서 현재 화면 바로 아래 경로의 패턴 (파라미터 값·쿼리 제외)
  String? _readPreviousRoutePattern() {
    try {
      final matches = GoRouter.of(
        context,
      ).routerDelegate.currentConfiguration.matches;
      for (var index = matches.length - 2; index >= 0; index--) {
        final route = matches[index].route;
        if (route is GoRoute) return route.path;
      }
    } catch (error) {
      AppLogger.warn('feedback', 'previous route unavailable : $error');
    }
    return null;
  }

  bool get _isCompressingImage =>
      _imageDrafts.any((draft) => draft.isCompressing);

  bool get _canSend =>
      !_isSending &&
      !_isCompressingImage &&
      FeedbackValidator.isValid(_contentController.text);

  bool get _canAddImage =>
      !_isSending && _imageDrafts.length < FeedbackImageLimits.maxImageCount;

  /// 갤러리 다중 선택 > 남은 칸만큼 자름 > 장마다 즉시 압축 (실패 장은 제거 + 토스트)
  Future<void> _pickImages() async {
    final remainingCount =
        FeedbackImageLimits.maxImageCount - _imageDrafts.length;
    List<XFile> pickedFiles;
    try {
      pickedFiles = await _imagePicker.pickMultiImage(
        maxWidth: FeedbackImageLimits.longSidePixels.toDouble(),
        maxHeight: FeedbackImageLimits.longSidePixels.toDouble(),
        requestFullMetadata: false,
      );
    } catch (error) {
      AppLogger.warn('feedback', 'pick images failed : $error');
      if (mounted) showAppToast(context, _imageLoadFailedMessage);
      return;
    }
    if (pickedFiles.isEmpty || !mounted) return;
    if (pickedFiles.length > remainingCount) {
      showAppToast(context, _imageLimitToastMessage);
      pickedFiles = pickedFiles.take(remainingCount).toList();
    }
    final pendingDrafts = [
      for (final _ in pickedFiles) FeedbackImageDraft(id: _nextImageId++),
    ];
    setState(() => _imageDrafts.addAll(pendingDrafts));
    for (var index = 0; index < pickedFiles.length; index++) {
      if (!mounted) return;
      await _compressImage(pendingDrafts[index].id, pickedFiles[index]);
    }
  }

  Future<void> _compressImage(int draftId, XFile pickedFile) async {
    String? failureMessage;
    try {
      final compressed = await _imageCompressor.compress(
        await pickedFile.readAsBytes(),
      );
      if (!mounted) return;
      _replaceDraft(FeedbackImageDraft(id: draftId, image: compressed));
      return;
    } on AppException catch (exception) {
      failureMessage = exception.message;
    } catch (error) {
      AppLogger.warn('feedback', 'compress image failed : $error');
      failureMessage = _imageLoadFailedMessage;
    }
    if (!mounted) return;
    setState(() => _imageDrafts.removeWhere((draft) => draft.id == draftId));
    showAppToast(context, failureMessage);
  }

  void _replaceDraft(FeedbackImageDraft updatedDraft) => setState(() {
    final index = _imageDrafts.indexWhere(
      (draft) => draft.id == updatedDraft.id,
    );
    if (index >= 0) _imageDrafts[index] = updatedDraft;
  });

  void _removeImage(int draftId) {
    if (_isSending) return;
    setState(() => _imageDrafts.removeWhere((draft) => draft.id == draftId));
  }

  Future<void> _showDiagnosticsSheet() async {
    // 수집·시트 표시 중 중복 탭 무시
    if (_isOpeningDiagnosticsSheet) return;
    _isOpeningDiagnosticsSheet = true;
    try {
      await _openDiagnosticsSheet();
    } finally {
      _isOpeningDiagnosticsSheet = false;
    }
  }

  Future<void> _openDiagnosticsSheet() async {
    final collector = ref.read(appDiagnosticsCollectorProvider);
    final diagnostics = await collector.collect(
      context: context,
      previousRoute: _previousRoute,
    );
    final logBytes = await AppLogger.currentLogBytes();
    if (!mounted) return;
    await showFeedbackDiagnosticsSheet(context, diagnostics, logBytes);
  }

  /// 전송: 진단 수집(체크 시) > 전송 > 성공이면 닫고 토스트, 실패면 입력·첨부 유지
  Future<void> _send() async {
    setState(() {
      _isSending = true;
      _errorMessage = null;
    });
    // pop 뒤에도 토스트를 띄울 수 있게 최상위 Navigator context 를 미리 확보
    final toastContext = Navigator.of(context, rootNavigator: true).context;
    try {
      final diagnostics = _shouldIncludeDiagnostics
          ? await ref
                .read(appDiagnosticsCollectorProvider)
                .collect(context: context, previousRoute: _previousRoute)
          : null;
      await ref
          .read(feedbackSubmitterProvider)
          .submit(
            rawContent: _contentController.text,
            images: [for (final draft in _imageDrafts) ?draft.image],
            shouldIncludeDiagnostics: _shouldIncludeDiagnostics,
            diagnostics: diagnostics,
          );
      // 전송 중 화면을 떠났으면 결과는 무시
      if (!mounted) return;
      // 딥링크 등으로 되돌아갈 화면이 없으면 설정으로 이동
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(AppRoutes.settings);
      }
      if (toastContext.mounted) {
        showAppToast(toastContext, _successToastMessage);
      }
    } on AppException catch (exception, stackTrace) {
      reportIfUnexpectedFailure(exception, stackTrace, reason: 'feedbackSend');
      if (mounted) setState(() => _errorMessage = exception.message);
    } catch (error, stackTrace) {
      // 로그 읽기·조립 등 예상 밖 실패도 에러 줄로 안내
      reportIfUnexpectedFailure(error, stackTrace, reason: 'feedbackSend');
      AppLogger.warn('feedback', 'send failed : $error');
      if (mounted) setState(() => _errorMessage = _sendFailedMessage);
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Scaffold(
      appBar: PassqlNavBar(title: '의견 보내기', leading: PassqlNavLeading.back),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.all(PassqlSpacing.md),
              children: [
                Text(
                  '앱에 바라는 점이나 불편한 점을 알려 주세요',
                  style: PassqlTypography.headline.copyWith(
                    color: colors.label,
                  ),
                ),
                const SizedBox(height: PassqlSpacing.sm),
                FeedbackContentField(
                  controller: _contentController,
                  isEnabled: !_isSending,
                  onChanged: () => setState(() {}),
                ),
                const SizedBox(height: PassqlSpacing.md),
                FeedbackImageStrip(
                  drafts: _imageDrafts,
                  onAddPressed: _canAddImage ? _pickImages : null,
                  onRemovePressed: _removeImage,
                ),
                const SizedBox(height: PassqlSpacing.md),
                FeedbackDiagnosticsCheckRow(
                  isChecked: _shouldIncludeDiagnostics,
                  onToggled: _isSending
                      ? null
                      : () => setState(
                          () => _shouldIncludeDiagnostics =
                              !_shouldIncludeDiagnostics,
                        ),
                  onShowPressed: _showDiagnosticsSheet,
                ),
              ],
            ),
          ),
          if (_errorMessage != null)
            Container(
              width: double.infinity,
              color: colors.wrongTint,
              padding: const EdgeInsets.symmetric(
                horizontal: PassqlSpacing.md,
                vertical: PassqlSpacing.xs,
              ),
              child: Text(
                _errorMessage!,
                style: PassqlTypography.footnote.copyWith(
                  color: colors.wrongText,
                ),
              ),
            ),
          PassqlBottomActionBar(
            actions: [
              PassqlButton(
                label: '보내기',
                isLoading: _isSending,
                onPressed: _canSend ? _send : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
