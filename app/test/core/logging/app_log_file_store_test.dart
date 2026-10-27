import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/logging/app_log_file_store.dart';

void main() {
  late Directory tempDir;

  setUp(() => tempDir = Directory.systemTemp.createTempSync('app_log_test'));
  tearDown(() => tempDir.deleteSync(recursive: true));

  test('1MB 넘으면 회전하고 합계 2MB 이하', () async {
    final store = AppLogFileStore(directory: tempDir, maxFileBytes: 1000);
    for (var i = 0; i < 50; i++) {
      await store.append(['x' * 99]);
    }
    expect(await store.totalBytes(), lessThanOrEqualTo(2000 + 100));
    expect(File('${tempDir.path}/app_log_1.txt').existsSync(), isTrue);
  });

  test('현재 파일 없이 이전 파일만 있어도 이어서 기록', () async {
    File('${tempDir.path}/app_log_1.txt').writeAsStringSync('old\n');
    final store = AppLogFileStore(directory: tempDir, maxFileBytes: 1000);
    await store.append(['new']);
    expect(utf8.decode(gzip.decode(await store.readAllGzipped())), 'old\nnew\n');
  });

  test('파일이 없거나 비어 있어도 예외 없이 빈 로그를 돌려준다', () async {
    final store = AppLogFileStore(directory: tempDir);
    expect(utf8.decode(gzip.decode(await store.readAllGzipped())), '');
    File('${tempDir.path}/app_log_0.txt').writeAsStringSync('');
    expect(await store.totalBytes(), 0);
    await store.clear();
  });
}
