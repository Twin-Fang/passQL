import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

/// 앱 로그 파일 저장소: 덧붙임, 회전, gzip 읽기, 삭제
/// 현재(app_log_0.txt) 가 maxFileBytes 초과 > 이전(app_log_1.txt) 삭제 후 현재를 이전으로 이동 (합계 최대 2개 파일)
class AppLogFileStore {
  AppLogFileStore({
    required Directory directory,
    int maxFileBytes = defaultMaxFileBytes,
  })  : _directory = directory,
        _maxFileBytes = maxFileBytes;

  // 로그 파일 1개 최대 크기 (256KB, 2개 합계 원문 512KB)
  static const int defaultMaxFileBytes = 256 * 1024;

  final Directory _directory;
  final int _maxFileBytes;

  File get _currentFile => File('${_directory.path}/app_log_0.txt');
  File get _previousFile => File('${_directory.path}/app_log_1.txt');

  Future<void> append(List<String> lines) async {
    if (lines.isEmpty) return;
    await _directory.create(recursive: true);
    await _currentFile.writeAsString('${lines.join('\n')}\n', mode: FileMode.append, flush: true);
    await _rotateIfTooLarge();
  }

  /// 이전 > 현재 순서로 이어 붙인 gzip (없으면 빈 로그)
  Future<Uint8List> readAllGzipped() async {
    final builder = BytesBuilder(copy: false);
    for (final file in [_previousFile, _currentFile]) {
      if (await file.exists()) builder.add(await file.readAsBytes());
    }
    // 최대 512KB 압축은 메인 isolate 밖에서 처리
    final rawBytes = builder.takeBytes();
    return Isolate.run(() => Uint8List.fromList(gzip.encode(rawBytes)));
  }

  Future<int> totalBytes() async {
    var total = 0;
    for (final file in [_previousFile, _currentFile]) {
      if (await file.exists()) total += await file.length();
    }
    return total;
  }

  Future<void> clear() async {
    for (final file in [_previousFile, _currentFile]) {
      if (await file.exists()) await file.delete();
    }
  }

  Future<void> _rotateIfTooLarge() async {
    if (await _currentFile.length() <= _maxFileBytes) return;
    if (await _previousFile.exists()) await _previousFile.delete();
    await _currentFile.rename(_previousFile.path);
  }
}
