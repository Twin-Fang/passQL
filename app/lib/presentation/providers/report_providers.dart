import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/error/app_exception.dart';
import '../../core/error/error_code.dart';
import '../../core/network/api_providers.dart';
import '../../core/validation/report_validator.dart';
import '../../data/models/report/report_models.dart';

/// 신고 대상: 어떤 문제의 어떤 제출인지.
typedef ReportTarget = ({String questionUuid, String submissionUuid});

/// 이 제출을 이미 신고했는지. 화면을 벗어나면 해제된다.
///
/// 상태 확인이 실패해도 신고 자체를 막지 않는다(서버가 중복을 거절하므로 안전하다).
final reportStatusProvider = FutureProvider.autoDispose
    .family<bool, ReportTarget>((ref, target) async {
      try {
        final res = await ref
            .read(reportApiProvider)
            .getReportStatus(target.questionUuid, target.submissionUuid);
        return res.reported;
      } on DioException {
        return false;
      }
    });

/// 신고 전송.
class ReportSubmitter {
  ReportSubmitter(this._ref);

  final Ref _ref;

  /// 서버가 거절하거나 네트워크가 실패하면 [AppException] 을 던진다.
  /// 이미 신고한 제출은 목적이 달성된 것이므로 성공으로 본다.
  Future<void> submit({
    required ReportTarget target,
    String? choiceSetUuid,
    required Set<ReportCategory> categories,
    required String detail,
  }) async {
    if (!ReportValidator.isValid(categories, detail)) {
      throw const AppException(
        code: ErrorCode.validation,
        message: '신고 사유를 선택해 주세요. 기타는 내용을 입력해야 해요.',
      );
    }
    try {
      await _ref
          .read(reportApiProvider)
          .submitReport(
            target.questionUuid,
            ReportRequest(
              submissionUuid: target.submissionUuid,
              choiceSetUuid: choiceSetUuid,
              categories: categories.toList(),
              detail: ReportValidator.detailFor(categories, detail),
            ),
          );
    } on DioException catch (e) {
      final error = e.asAppException;
      if (error.code != ErrorCode.reportAlreadyExists) throw error;
    }
    _ref.invalidate(reportStatusProvider(target));
  }
}

final reportSubmitterProvider = Provider<ReportSubmitter>(ReportSubmitter.new);
