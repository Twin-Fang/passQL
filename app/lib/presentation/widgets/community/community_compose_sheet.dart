import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/error/app_exception.dart';
import '../../../data/community/community_image_compressor.dart';
import '../../design/design.dart';
import '../../providers/community_providers.dart';

/// 의견 작성 바텀시트: 본문(500자 카운터) + 사진 최대 2장 + '내 풀이 같이 보여주기' 토글 + UGC 안내
/// 사진은 고르는 즉시 폰에서 WebP 로 압축, 등록하기에서 순차 업로드 > 글 작성. 등록되면 true 를 돌려주며 닫힘
class CommunityComposeSheet extends ConsumerStatefulWidget {
  const CommunityComposeSheet({super.key, required this.query});

  final CommunityPostsQuery query;

  static Future<bool?> show(BuildContext context, CommunityPostsQuery query) =>
      showPassqlSheet<bool>(
        context,
        title: '의견 쓰기',
        builder: (_) => CommunityComposeSheet(query: query),
      );

  /// 본문 최대 글자 수 (서버 검증과 같은 값)
  static const int maxContentLength = 500;

  /// 화면에 보여 줄 운영 정책 안내 (UGC 신고 유도)
  static const String policyNotice = '운영 정책에 어긋나는 글은 신고해 주세요';

  @override
  ConsumerState<CommunityComposeSheet> createState() =>
      _CommunityComposeSheetState();
}

class _CommunityComposeSheetState extends ConsumerState<CommunityComposeSheet> {
  final _contentController = TextEditingController();
  bool _shouldIncludeSolveSnapshot = false;
  bool _isSending = false;
  bool _isPreparingImage = false;
  String? _errorMessage;
  String? _progressMessage;
  final List<CommunityImageDraft> _imageDrafts = [];
  final _imagePicker = ImagePicker();
  final _imageCompressor = CommunityImageCompressor();

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      !_isSending &&
      !_isPreparingImage &&
      _contentController.text.trim().isNotEmpty;

  bool get _canAddImage =>
      !_isSending &&
      !_isPreparingImage &&
      _imageDrafts.length < CommunityImageLimits.maxImageCountPerPost;

  /// 갤러리 선택 > 폰에서 WebP 압축 (한도 초과·변환 실패는 한국어 안내)
  Future<void> _pickImage() async {
    setState(() => _errorMessage = null);
    try {
      // 선택 단계에서 긴 변 1600px 로 먼저 줄임 (회전 보정 포함, 이후 압축은 WebP 변환·용량 맞추기)
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: CommunityImageLimits.imageLongSidePixels.toDouble(),
        maxHeight: CommunityImageLimits.imageLongSidePixels.toDouble(),
        requestFullMetadata: false,
      );
      if (pickedFile == null || !mounted) return;
      setState(() => _isPreparingImage = true);
      final compressed = await _imageCompressor.compress(
        await pickedFile.readAsBytes(),
      );
      if (!mounted) return;
      setState(() {
        _isPreparingImage = false;
        _imageDrafts.add(CommunityImageDraft(compressed));
      });
    } on AppException catch (exception) {
      _showImageError(exception.message);
    } catch (error) {
      debugPrint('[community compose] pick image failed : $error');
      _showImageError('사진을 불러오지 못했어요. 다시 선택해 주세요.');
    }
  }

  void _showImageError(String message) {
    if (!mounted) return;
    setState(() {
      _isPreparingImage = false;
      _errorMessage = message;
    });
  }

  void _removeImage(CommunityImageDraft draft) =>
      setState(() => _imageDrafts.remove(draft));

  /// 등록: 사진 순차 업로드 > 글 작성 (실패하면 입력·사진 유지, 이미 올라간 사진은 재시도 때 다시 올리지 않음)
  Future<void> _submit() async {
    if (_isSending) return;
    final notifier = ref.read(
      communityQuestionPostsProvider(widget.query).notifier,
    );
    setState(() {
      _isSending = true;
      _errorMessage = null;
    });
    try {
      final pendingCount = _imageDrafts
          .where((draft) => !draft.isUploaded)
          .length;
      var uploadedCount = 0;
      final imageUuids = await uploadCommunityImageDrafts(_imageDrafts, (
        compressed,
      ) async {
        if (mounted) {
          setState(
            () => _progressMessage =
                '사진 올리는 중 (${++uploadedCount}/$pendingCount)',
          );
        }
        return notifier.uploadImage(compressed);
      });
      if (mounted) setState(() => _progressMessage = null);
      await notifier.submitPost(
        content: _contentController.text.trim(),
        shouldIncludeSolveSnapshot: _shouldIncludeSolveSnapshot,
        imageUuids: imageUuids,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on AppException catch (exception) {
      if (!mounted) return;
      setState(() {
        _isSending = false;
        _progressMessage = null;
        _errorMessage = exception.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        PassqlSpacing.md,
        PassqlSpacing.xxs,
        PassqlSpacing.md,
        PassqlSpacing.md,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(PassqlSpacing.sm),
              decoration: BoxDecoration(
                color: colors.fill,
                borderRadius: BorderRadius.circular(PassqlRadius.md),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CupertinoTextField.borderless(
                    controller: _contentController,
                    enabled: !_isSending,
                    autofocus: true,
                    minLines: 4,
                    maxLines: 6,
                    maxLength: CommunityComposeSheet.maxContentLength,
                    padding: EdgeInsets.zero,
                    placeholder: '헷갈린 점이나 풀이 팁을 남겨 보세요',
                    placeholderStyle: PassqlTypography.body.copyWith(
                      color: colors.secondaryLabel,
                    ),
                    style: PassqlTypography.body.copyWith(color: colors.label),
                    cursorColor: colors.accent,
                    onChanged: (_) => setState(() => _errorMessage = null),
                  ),
                  Text(
                    '${_contentController.text.characters.length}/'
                    '${CommunityComposeSheet.maxContentLength}',
                    style: PassqlTypography.caption.copyWith(
                      color: colors.secondaryLabel,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: PassqlSpacing.sm),
            _ImageAttachRow(
              drafts: _imageDrafts,
              isPreparing: _isPreparingImage,
              isLocked: _isSending,
              onAddTap: _canAddImage ? _pickImage : null,
              onRemoveTap: _removeImage,
            ),
            const SizedBox(height: PassqlSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '내 풀이 같이 보여주기',
                        style: PassqlTypography.body.copyWith(
                          color: colors.label,
                        ),
                      ),
                      Text(
                        '정답 여부와 시도 횟수가 글에 함께 표시돼요',
                        style: PassqlTypography.footnote.copyWith(
                          color: colors.secondaryLabel,
                        ),
                      ),
                    ],
                  ),
                ),
                CupertinoSwitch(
                  value: _shouldIncludeSolveSnapshot,
                  activeTrackColor: colors.accent,
                  onChanged: _isSending
                      ? null
                      : (isOn) =>
                            setState(() => _shouldIncludeSolveSnapshot = isOn),
                ),
              ],
            ),
            SizedBox(
              height: PassqlSize.messageSlotHeight,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _errorMessage ??
                      _progressMessage ??
                      CommunityComposeSheet.policyNotice,
                  style: PassqlTypography.caption.copyWith(
                    color: _errorMessage == null
                        ? colors.secondaryLabel
                        : colors.wrongText,
                  ),
                ),
              ),
            ),
            PassqlButton(
              label: '등록하기',
              isLoading: _isSending,
              onPressed: _canSubmit ? _submit : null,
            ),
          ],
        ),
      ),
    );
  }
}

/// 사진 추가 버튼 + 선택한 사진 미리보기(썸네일) 줄: 미리보기 우상단 X 로 제거
class _ImageAttachRow extends StatelessWidget {
  const _ImageAttachRow({
    required this.drafts,
    required this.isPreparing,
    required this.isLocked,
    required this.onAddTap,
    required this.onRemoveTap,
  });

  final List<CommunityImageDraft> drafts;
  final bool isPreparing;

  /// 업로드 중 (제거·추가 막음)
  final bool isLocked;
  final VoidCallback? onAddTap;
  final ValueChanged<CommunityImageDraft> onRemoveTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Row(
      children: [
        PassqlPressable(
          onTap: onAddTap,
          semanticLabel:
              '사진 추가, ${drafts.length}/${CommunityImageLimits.maxImageCountPerPost}',
          child: Container(
            width: PassqlSize.communityImageDraftPreview,
            height: PassqlSize.communityImageDraftPreview,
            decoration: BoxDecoration(
              color: colors.fill,
              borderRadius: BorderRadius.circular(PassqlRadius.md),
            ),
            child: isPreparing
                ? const Center(child: PassqlLoadingIndicator())
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.photo,
                        size: PassqlIconSize.lg,
                        color: onAddTap == null
                            ? colors.tertiaryLabel
                            : colors.accent,
                      ),
                      Text(
                        '${drafts.length}/${CommunityImageLimits.maxImageCountPerPost}',
                        style: PassqlTypography.caption.copyWith(
                          color: colors.secondaryLabel,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        for (final draft in drafts) ...[
          const SizedBox(width: PassqlSpacing.xs),
          SizedBox(
            width: PassqlSize.communityImageDraftPreview,
            height: PassqlSize.communityImageDraftPreview,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(PassqlRadius.md),
                  child: Image.memory(
                    draft.compressed.thumbnailBytes,
                    fit: BoxFit.cover,
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: PassqlSemanticButton(
                    label: '사진 제거',
                    onTap: isLocked ? null : () => onRemoveTap(draft),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: isLocked ? null : () => onRemoveTap(draft),
                      // 보이는 원은 24, 누르는 영역은 모서리 44x44
                      child: SizedBox.square(
                        dimension: PassqlSize.minTouchTarget,
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            width: PassqlSize.communityImageRemoveBadge,
                            height: PassqlSize.communityImageRemoveBadge,
                            margin: const EdgeInsets.all(PassqlSpacing.xxs),
                            decoration: BoxDecoration(
                              color: colors.cardElevated,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              CupertinoIcons.xmark,
                              size: PassqlIconSize.sm,
                              color: colors.label,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
